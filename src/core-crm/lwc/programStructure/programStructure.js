/**
 * @description An LWC component for completing program structure
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                            | Change Summary                       |
      |---------------------------|-----------------------|---------------------------------|--------------------------------------|
      | roy.nino.s.regala         | November 15, 2021     | DEPP-362                        | Created                              |
 */

import { LightningElement, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROGRAM_PLAN_OBJECT from '@salesforce/schema/hed__Program_Plan__c';
import PROGRAM_TYPE_FIELD from '@salesforce/schema/hed__Program_Plan__c.Program_Type__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertProgramPlanAndPlanRequirement from '@salesforce/apex/CreateProductsAndOfferingsCtrl.upsertProgramPlanAndPlanRequirement'; 

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

export default class ProgramStructure extends LightningElement {
    @api tableData = []; //plan requirement data from parent
    @api programPlan = {}; //program plan from parent
    @api markedAsComplete; //indicates that program structure is marked as complete
    @api hasPlanRequirementOnRender; //indicates that plan requirement records is already created
    draftTableData = [];//draft plan requirement data
    columns = COLUMNS;
    errors = {};
    mandatory = true;
    editable = false;
    hasSavedSequence = false;
    programType = 'Flexible Program';
    programTypeValue;
    

    /*
    *gets object info of program plan
    */
    @wire(getObjectInfo, { objectApiName: PROGRAM_PLAN_OBJECT })
    objectInfo;

    /*
    *gets picklist values of program type field of program plan
    */
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PROGRAM_TYPE_FIELD})
    programTypePicklistValues;

    /*
    *sets value of draft table and program type
    */
    connectedCallback(){
       this.draftTableData = this.tableData;
       this.programTypeValue = this.programPlan?(this.programPlan.Program_Type__c?this.programPlan.Program_Type__c:this.programType):'';
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
        return this.editable || this.markedAsComplete;
    }

    /*
    *decides if cancel button is disabled and sequence input field is read only
    */
    get cantEdit(){
        return !this.editable || this.markedAsComplete;
    }

    /*
    *decides if  save button is disabled, sequence cannot be saved if it is not edited or sequence is wrong or program strucure is already completed
    *save can be clickable as well if it has a plan requirement on render and sequence is valid
    */
    get cantSave(){
        return (!this.sequenceEdited && this.hasPlanRequirementOnRender) || this.sequenceHasRepeatsEmptyAndZeroes || this.markedAsComplete;
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
    *updates category column of draft table
    *and stores program type in a variable
    */
    handleTypeChange(event){
        this.draftTableData  = this.draftTableData.map(row=>({
            ...row,category:event.target.value ==='Flexible Program'?'Optional':event.target.value === 'Prescribed Program'?'Required':'',
        }));
        this.programType = event.target.value;
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
         this.draftTableData = this.tableData.map(row=>({
            ...row,category:this.programType === 'Flexible Program'?'Optional':'Required',
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

     /*
    *upserts the program plan and plan requirement
    */
     handleSave(){
         upsertProgramPlanAndPlanRequirement({recordsToUpsert:this.createObjectRecord().planRequirement,recordToUpdate:this.createObjectRecord().programPlan})
        .then(()=>{
            const programStructureSaved = new CustomEvent('programstrucuresaved');
            this.dispatchEvent(programStructureSaved);
        })
        .finally(()=>{
            this.generateToast('Success!','Plan Requirement records saved','success');
        })
        .catch(()=>{
            this.generateToast('Error.',MSG_ERROR,'error');
        })
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
            planRequirement['hed__Program_Plan__c'] = this.programPlan.Id; 
            return planRequirement;
        })
        recordsToUpsert.programPlan.Program_Type__c = this.programType;
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