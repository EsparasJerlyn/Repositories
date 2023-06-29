/**
 * @description Lightning Web Component for add investigation section in published tab of consultancy record page
 *
 * @see ../classes/ActionCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | July 15, 2022         | DEPP-2036            | Created file                 |
      |                           |                       |                      |                              |
*/
import { api, LightningElement, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import getInvestigationActionDetails from '@salesforce/apex/ActionCtrl.getInvestigationActionDetails';
import getActivitySectionDetails from '@salesforce/apex/ActionCtrl.getActivitySectionDetails';
import getRelatedFilesByRecordId from '@salesforce/apex/ActionCtrl.getRelatedFilesByRecordId';
import ACTION_OBJ from '@salesforce/schema/Action__c';
import RT_Action_Investigation from '@salesforce/label/c.RT_Action_Investigation';

const SUCCESS_TITLE = 'Success!';
const SUCCESS_VARIANT = 'success';
const SUCCESS_MSG = 'Record successfully saved!';  
const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';

const ADD_INV_NAME = 'Add Investigation';
const NO_REC_FOUND = 'No record(s) found.';
const SECTION_TITLE = 'Investigation Plan';
const INV_SUMM_SECTION_TITLE = 'Investigation Summary';
const MODAL_TITLE = 'Update Investigation Plan';


export default class InvestigationSection extends LightningElement {

    @api recordId;

    investigationActionData = [];
    filesList =[];
    isEmpty = true;
    isModalOpen = false;
    sortBy;
    sortDirection;
    consultancyRecord;
    recConsId;
    recMarkInvAsComplete;
    recInvSummary;
    recProdReqStatus;
    enableEdit = true;
    isUpdateModalOpen = false;
    rowId = '';
    investigationName;

    columns = [
        { label: 'Investigation Name', fieldName: 'Investigation_Name__c', type: 'text', sortable :'true' },
        { label: 'Investigation Method', fieldName: 'Investigation_Method__c', type: 'text', sortable :'true' },        
        { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date', sortable :'true' },
        { label: 'End Date', fieldName: 'End_Date__c', type: 'date', sortable :'true' },
        { label: 'Is Complete', fieldName: 'Is_Complete__c', type: 'boolean', cellAttributes: { alignment: 'center' } },
        { label: 'Summary', fieldName: 'Summary__c', type: 'text' },
        { type: 'action', typeAttributes: {  rowActions: [ { label: 'Edit', name: 'edit' } ] } }
    ];

    @wire(getObjectInfo, { objectApiName: ACTION_OBJ})
    objectInfo;

    //retrieves actions to be displayed in the table
    actionDetails;
    @wire(getInvestigationActionDetails, {recordId : '$recordId'})
    getInvestigationActionDetails(result) {
        this.actionDetails = result;
        if(result.data){
            this.investigationActionData = result.data;
            if (this.investigationActionData.length > 0) {
                this.isEmpty = false;
            }    
        }           
    }

    consultancy;
    @wire(getActivitySectionDetails, {recordId : '$recordId'})
    getActivitySectionDetails(result) {
        this.consultancy = result;
        if(result.data){
            this.consultancyRecord = result.data;   
            this.recConsId = this.consultancyRecord.id;
            this.recInvSummary = this.consultancyRecord.investigationSummary;
            this.recMarkInvAsComplete = this.consultancyRecord.markInvestigationAsComplete;
            this.recProdReqStatus = this.consultancyRecord.prodReqStatus;
        }  
        this.getFiles(this.recConsId);
    }

    handleAddInvestigation(){
        this.isModalOpen = true;
    }

    //creates action record
    handleSubmit(event){             
        const recTypes = this.objectInfo.data.recordTypeInfos;
        let fields = {};  
        fields = {
            Consultancy__c : this.consultancyRecord.id,
            Investigation_Name__c : event.detail.fields.Investigation_Name__c,
            Investigation_Method__c : event.detail.fields.Investigation_Method__c,
            Start_Date__c : event.detail.fields.Start_Date__c,
            End_Date__c : event.detail.fields.End_Date__c,
            Is_Complete__c : event.detail.fields.Is_Complete__c,
            Summary__c : event.detail.fields.Summary__c,
            RecordTypeId : Object.keys(recTypes).find(rti => recTypes[rti].name == RT_Action_Investigation)
        }
        const recordInput = { apiName: ACTION_OBJ.objectApiName, fields };
        createRecord(recordInput)
        .then(() => {  
            this.isModalOpen = false;
            refreshApex(this.actionDetails);
        })
        .catch(() => {
            this.isModalOpen = true;
        });;
    }

    //creates action record
    handleSave(event){
        let fields = {};
        fields = {
            Id : this.rowId,
            Investigation_Name__c : event.detail.fields.Investigation_Name__c,
            Investigation_Method__c : event.detail.fields.Investigation_Method__c,
            Start_Date__c : event.detail.fields.Start_Date__c,
            End_Date__c : event.detail.fields.End_Date__c,
            Is_Complete__c : event.detail.fields.Is_Complete__c,
            Summary__c : event.detail.fields.Summary__c
        }
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {  
            this.isUpdateModalOpen = false;
            refreshApex(this.actionDetails);
        })
        .catch(error => {
            this.isUpdateModalOpen = true;
            console.error('Error: ' + JSON.stringify(error));
        });
    }

    handleSuccess(){
        this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
    }

    //Update Consultancy Record
    handleEdit(event){    
        if(event.detail.fields.Mark_Investigation_as_Complete__c && !this.filesList.length){
            this.generateToast(ERROR_TITLE, 'Please upload investigation report before marking investigation as complete!', ERROR_VARIANT);
        }else{
            let fields = {};  
            fields = {
                Id : this.consultancyRecord.id,
                Mark_Investigation_as_Complete__c : event.detail.fields.Mark_Investigation_as_Complete__c,
                Investigation_Summary__c : event.detail.fields.Investigation_Summary__c
            }
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {    
                refreshApex(this.actionDetails);
                this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);     
                if(event.detail.fields.Mark_Investigation_as_Complete__c){
                    this.handleMarkAsComplete();
                }   
            })
            .catch(error => {
                console.error('Error: ' + JSON.stringify(error));
            });
        }           
    }

    //handles opening of modal
    handleRowAction(event){
        this.isUpdateModalOpen = true;
        const row = event.detail.row;
        this.rowId = row.Id;
        this.investigationName = row.Investigation_Name__c;
    }

    handleMarkAsComplete(){        
        let fields = {};  
        fields = {
            Id : this.recordId,
            Product_Request_Status__c : "Completed"
        }
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            refreshApex(this.consultancy);
        })
        .catch(error => {
            console.error('Error: ' + JSON.stringify(error));
        });
    }

    handleIsCompChange(event){
        this.recMarkInvAsComplete = event.target.checked;
        
    }

    //handles file upload
    handleUploadFinished() {
        this.getFiles(this.consultancyRecord.id);
    } 

    getFiles(consultancyRecordId){
        getRelatedFilesByRecordId({recordId:consultancyRecordId})
        .then(result=>{
            this.filesList = Object.keys(result).map(item=>({"label":result[item],
             "value": item,
             "url":`/sfc/servlet.shepherd/document/download/${item}`
            }));
        }).catch(()=>{
            this.filesList = []; 
        })
    }

    closeModalAction(){
        this.isModalOpen = false;
        this.isUpdateModalOpen = false;
    }
    
    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });

        this.dispatchEvent(evt);
    }

    //Sorts column for datatable
    handleSort(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {        
        let parseData = JSON.parse(JSON.stringify(this.investigationActionData));       
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.investigationActionData = parseData;
    }

    get getSectionTitle(){ return SECTION_TITLE; }
    get getInvSummSectionTitle(){ return INV_SUMM_SECTION_TITLE; }
    get noRecordsFound() { return NO_REC_FOUND; }
    get addInvestigationName() { return ADD_INV_NAME; }
    get activeSections(){ return [SECTION_TITLE, INV_SUMM_SECTION_TITLE]; }
    get acceptedFormats() { return ['.pdf','.png','.jpg']; }
    get disableEditing(){ return this.recProdReqStatus === 'Completed' ? true : false; }
    get modalTitle(){ return MODAL_TITLE;}
    get modalName() {return this.investigationName;}
}