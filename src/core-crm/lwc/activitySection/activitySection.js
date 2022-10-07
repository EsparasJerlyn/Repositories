/**
 * @description Lightning Web Component for add activity section in consultancy record page
 *
 * @see ../classes/ActionCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | July 12, 2022         | DEPP-2035            | Created file                 |
      |                           |                       |                      |                              |
*/

import { api, LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getActionDetails from '@salesforce/apex/ActionCtrl.getActionDetails';
import getActivitySectionDetails from '@salesforce/apex/ActionCtrl.getActivitySectionDetails';
import ACTION_OBJ from '@salesforce/schema/Action__c';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import RT_Action_Activity from '@salesforce/label/c.RT_Action_Activity';
   
const SUCCESS_TITLE = 'Success!';
const SUCCESS_VARIANT = 'success';
const SUCCESS_MSG = 'Record successfully saved!';  
const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';

const SECTION_TITLE = 'Activity Schedule';
const NO_REC_FOUND = 'No record(s) found.';
const ACT_BTN_NAME = 'Add';

export default class ActivitySection extends LightningElement {

    @api recordId;

    isEmpty = true;
    isModalOpen = false;
    sortBy;
    sortDirection;  
    activitySectionData = [];
    consultancyRecord; 
    recProdReqStatus; 

    columns = [
        { label: 'Action Name', fieldName: 'Name', type: 'text' },
        { label: 'Activity Name', fieldName: 'Activity_Name__c', type: 'text', sortable :'true' },
        { label: 'Activity Method', fieldName: 'Activity_Method__c', type: 'text', sortable :'true' },
        { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date', sortable :'true' },
        { label: 'End Date', fieldName: 'End_Date__c', type: 'date', sortable :'true' }
    ];

    @wire(getObjectInfo, { objectApiName: ACTION_OBJ})
    objectInfo;

    //retrieves actions to be displayed in the table
    actionDetails;
    @wire(getActionDetails, {recordId : '$recordId'})
    getActionDetails(result) {
        this.actionDetails = result;
        if(result.data){
            this.activitySectionData = result.data;      
            if (this.activitySectionData.length > 0) {
                this.isEmpty = false;
            }    
        }    
    }

    //retrieves the selected consultancy record based on product request id
    consultancy;
    @wire(getActivitySectionDetails, {recordId : '$recordId'})
    getActivitySectionDetails(result) {
        this.consultancy = result;
        if(result.data){
            this.consultancyRecord = result.data;    
            this.recProdReqStatus = this.consultancyRecord.prodReqStatus; 
            if (!this.consultancyRecord.hasActivity && this.consultancyRecord.markActivityAsComplete) {
                this.updateMarkActivityAsComplete(false);
            } 
            if(this.consultancyRecord.hasActivity && !this.consultancyRecord.markActivityAsComplete){
                this.updateMarkActivityAsComplete(true);
            }
        }    
    }

    //updates mark activity as complete
    updateMarkActivityAsComplete(hasActivity){
        let fields = {};   
        fields = {
            Id : this.consultancyRecord.id,
            Mark_Activity_as_Complete__c : hasActivity
        }
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => { refreshApex(this.consultancy); })
        .catch(() => {
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
        });
    }

    handleAddActivity(){
        this.isModalOpen = true;
    }

    //creates action record
    handleSubmit(event){        
        const recTypes = this.objectInfo.data.recordTypeInfos;
        let fields = {};  
        fields = {
            Consultancy__c : this.consultancyRecord.id,
            Activity_Name__c : event.detail.fields.Activity_Name__c,
            Activity_Method__c : event.detail.fields.Activity_Method__c,
            Start_Date__c : event.detail.fields.Start_Date__c,
            End_Date__c : event.detail.fields.End_Date__c,
            RecordTypeId : Object.keys(recTypes).find(rti => recTypes[rti].name == RT_Action_Activity)
        }
        const recordInput = { apiName: ACTION_OBJ.objectApiName, fields };
        createRecord(recordInput)
        .then(() => {  
            this.isModalOpen = false;
            refreshApex(this.actionDetails);
            refreshApex(this.consultancy);
        })
        .catch(error => {
            this.isModalOpen = true;
        });
    }

    handleSuccess(){
        this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
    }

    closeModalAction(){
        this.isModalOpen = false;
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
        let parseData = JSON.parse(JSON.stringify(this.activitySectionData));       
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.activitySectionData = parseData;
    }

    get getSectionTitle(){ return SECTION_TITLE; }
    get noRecordsFound() { return NO_REC_FOUND; }
    get activityButtonName() { return ACT_BTN_NAME; }
    get disableEditing(){ return this.recProdReqStatus === 'Completed' ? true : false; }
    
}