/**
 * @description An LWC component for completing program structure
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                            | Change Summary                       |
      |---------------------------|-----------------------|---------------------------------|--------------------------------------|
      | roy.nino.s.regala         | November 15, 2021     | DEPP-362                        | Created                              |
 */

import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import PROGRAM_PLAN_OBJECT from '@salesforce/schema/hed__Program_Plan__c';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PL_ProductRequest_Complete from '@salesforce/label/c.PL_ProductRequest_Completed';
import PL_ProductRequest_Not_Proceeding from '@salesforce/label/c.PL_ProductRequest_Not_Proceeding';
import upsertProgramPlanAndPlanRequirement from '@salesforce/apex/OpeProgramStructureCtrl.upsertProgramPlanAndPlanRequirement'; 

const COLUMNS = [
    { 
        label: 'Sequence', 
        fieldName: 'sequence',
        type: 'number',
        editable: true,
        cellAttributes: { alignment: 'left' },
    },
    { 
        label: 'Category', 
        fieldName: 'category',
    },
    {   
        label: 'RecordType', 
        fieldName: 'recordtype',
    },
    { 
        label: 'Course Name', 
        fieldName: 'coursename',
    }
];

const FLEXIBLE_TYPE = 'Flexible Program';
const PRESCRIBED_TYPE = 'Prescribed Program';

export default class ProgramStructure extends LightningElement {
    @api tableData = []; //plan requirement data from parent
    @api programPlan = {}; //program plan from parent
    @api hasPlanRequirementOnRender; //indicates that plan requirement records is already created
    @api programDeliveryStructure; // indicates the program delivery structure if Flexible program or prescribed program
    @api prodReqStatus; // indicates the status of the product request
    @api isDesignComplete; // indicates the mark design stage as complete
    
    @track draftTableData = [];//draft plan requirement data

    columns = COLUMNS;
    errors = {};
    mandatory = true;
    editable = false;
    hasSavedSequence = false;
    programDeliveryStructureValue;
    isProcessing = false;
    showPlanRequirementIsActiveColumn = true;

    /*
    *gets object info of program plan
    */
    @wire(getObjectInfo, { objectApiName: PROGRAM_PLAN_OBJECT })
    objectInfo;

    /*
    *sets value of draft table and program type
    */
    connectedCallback(){
       this.draftTableData = this.tableData;
       this.programDeliveryStructureValue = this.programPlan.Program_Delivery_Structure__c;
    }

    /*
    *getter for program plan url
    */
    get programNameUrl(){
        return '/' + this.programPlan.Id;
    }

    /*
    *decides if edit button is clickable
    */
    get canEdit(){
        if(this.programDeliveryStructure === FLEXIBLE_TYPE){
            return this.editable || (this.prodReqStatus === PL_ProductRequest_Complete || this.prodReqStatus === PL_ProductRequest_Not_Proceeding) || !HAS_PERMISSION;
        }else if(this.programDeliveryStructure === PRESCRIBED_TYPE){
            return this.editable || this.isDesignComplete || !HAS_PERMISSION;
        }
    }

     /*
    *decides if isFlexibleProgramType show
    */
    get isFlexibleProgramType(){
        if(this.programDeliveryStructure === FLEXIBLE_TYPE){
            return true;
        }else{
            return false;
        }   
        
    }

    /*
    *decides if cancel button is disabled and sequence input field is read only
    */
    get cantEdit(){
        return !this.editable || !HAS_PERMISSION;
    }

    /*
    *decides if  save button is disabled, sequence cannot be saved if it is not edited or sequence is wrong or program strucure is already completed
    *save can be clickable as well if it has a plan requirement on render and sequence is valid
    */
    get cantSave(){
        return (!this.sequenceEdited && this.hasPlanRequirementOnRender) ||
            (!this.sequenceEdited && this.hasPlanRequirementOnRender && !this.showPlanRequirementIsActiveColumn) ||
            this.sequenceHasRepeatsEmptyAndZeroes ||
            (this.prodReqStatus === PL_ProductRequest_Complete || this.prodReqStatus === PL_ProductRequest_Not_Proceeding) ||
            this.tableData.length < 0 ||
            !HAS_PERMISSION ||
            this.isStatusNotDesign||
            this.isProcessing;
    }

    /*
    *indicates that sequence is edited
    */
    get sequenceEdited(){
        return JSON.stringify(this.tableData) !== JSON.stringify(this.draftTableData);
    }

    /*
    *indicates that sequence is wrong
    */
    get sequenceHasRepeatsEmptyAndZeroes(){
        let sequences = this.draftTableData.filter( (row) => row.sequence !== '' && row.sequence > 0 && row.sequence <= this.tableData.length).map(row => {
            return row.sequence
        });
        return [...new Set(sequences)].length !== this.tableData.length;
    }
    
    /*
    *indicates that user is trying to edit the sequence
    */
     handleEdit(){
        this.editable = true;
     }

     /*
    *handles cancel scenario and resets drafttable sequence
    */
     @api 
     handleCancel(){
        this.showPlanRequirementIsActiveColumn = false;
         this.draftTableData = this.tableData.map(row=>({
            ...row,category:this.programDeliveryStructureValue === 'Flexible Program'?'Optional':'Required',
        }));
         this.editable = false;
     }

     /*
    *updates sequence on drafttable
    */
     handleChange(event){
        this.draftTableData  = this.draftTableData.map(row=>({
            ...row,sequence:event.target.name === row.courseid?parseInt(event.target.value):row.sequence,
        }));
     }
     handleCheck(event){
            this.draftTableData  = this.draftTableData.map(row=>({
            ...row,isactive:event.target.name === row.courseid?event.target.checked:row.isactive,
        }));
     }

     /*
    *upserts the program plan and plan requirement
    */
     handleSave(){

        this.isProcessing = true;
         upsertProgramPlanAndPlanRequirement({recordsToUpsert:this.createObjectRecord().planRequirement})
        .then(()=>{
            this.generateToast('Success!','Plan Requirement records saved','success');
            const programStructureSaved = new CustomEvent('programstrucuresaved');
            this.dispatchEvent(programStructureSaved);
        })
        .finally(()=>{
            this.isProcessing = false;
        })
        .catch((error)=>{
            console.error(JSON.stringify(error));
            this.generateToast('Error.',LWC_Error_General,'error');
        });
     }

     /*
    *creates object record to upsert and sent to parent
    */
     createObjectRecord(){
         let recordsToUpsert = {};
         recordsToUpsert.programPlan = {...this.programPlan};
         recordsToUpsert.planRequirement = this.draftTableData.map(result =>{
            let planRequirement = {};

            if(result.recordId){
                planRequirement['Id'] = result.recordId;
            }
            planRequirement['hed__Sequence__c'] = result.sequence !== ''?parseInt(result.sequence):null;
            planRequirement['hed__Category__c'] = result.category;
            planRequirement['hed__Course__c'] = result.courseid;
            planRequirement['IsActive__c'] = result.isactive; 
            planRequirement['hed__Program_Plan__c'] = this.programPlan.Id; 
            return planRequirement;
        });
        return recordsToUpsert; 
    }

    /*
    *generates toasts
    */
    generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}