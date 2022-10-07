import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRegisteredLearners from "@salesforce/apex/DiagnosticSessionDetailSectionCtrl.getRegisteredLearners";
import getSessionStatusValues from "@salesforce/apex/DiagnosticSessionDetailSectionCtrl.getSessionStatusValues";
import ID_FIELD from '@salesforce/schema/Session__c.Id';
import COMPLETION_DATE_FIELD from '@salesforce/schema/Session__c.Completion_Date__c';
import SESSION_STATUS_FIELD from '@salesforce/schema/Session__c.Session_Status__c';
import { updateRecord } from 'lightning/uiRecordApi';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const MODAL_TITLE = 'Learner Details';
const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const NO_REC_FOUND = 'No record(s) found.';

export default class DiagnosticSessionDetailSection extends NavigationMixin(LightningElement) {

    @api childRecordId;

    modalName = '';
    isModalOpen = false;
    isLoading = false;
    isDisabled = true;
    isEnableEdit = true;
    isEmpty = false;
    error;
    rowId = '';
    learnerName = '';
    completionDate = '';
    sessionStatus = '';
    records = [];
    studentList;
    objectApiName ='hed__Course_Enrollment__c';
    recordId = '';
    contactId = '';
    sessionStatusValues;

    columns = [
        { label: 'Learner Name', fieldName: 'learnerName', type: 'text', sortable: true },
        { label: 'Completion Date', fieldName: 'completionDate', type: 'text', sortable: false },
        { label: 'Session Status', fieldName: 'sessionStatus', type: 'text', sortable: false }
    ];

    //handles opening of modal
    handleEditSession(event){
        this.isModalOpen = true;
        const row = event.detail;
        this.modalName = row.learnerName;
    }

    //retrieves registered learners
    tableData;
    @wire(getRegisteredLearners, {childRecordId : '$childRecordId'})
    getRegisteredLearners(result) {
        this.isLoading = true;
        this.tableData = result;

        if(result.data){
            this.records = result.data;
            if(this.records.length === 0){
                this.isEmpty = true;
            }else{
                this.isEmpty = false;
            }
            this.isLoading = false;
            this.error = undefined;
        } else if(result.error){
            this.records = undefined;
            this.error = result.error;
            this.isLoading = false;
        }
    }

    //Retrieves Completion Status values
    @wire(getSessionStatusValues)
    getSessionStatusValues(result){
        if(result.data) {
            const resp = result.data;
            this.sessionStatusValues = resp.map(type => {
                return { label: type, value: type };
            });
            this.sessionStatusValues.unshift({ label: '--None--', value: '' });
        }
    }

    //handles opening of modal
    handleEditSession(event){
        this.isModalOpen = true;
        const row = event.detail;
        this.rowId = row.id;
        this.recordId = row.id;
        this.modalName = row.learnerName;
        this.learnerName = row.learnerName;
        this.completionDate = row.completionDate;
        this.sessionStatus = row.sessionStatus;
        this.contactId = row.contactId;
    }

    //handles closing of modal
    closeModalAction(){
        this.isModalOpen = false;
        this.isDisabled = true;
    }

    //handles when Completion Date field is updated
    handleDateChange(event){
        this.isDisabled = false;
        this.completionDate = event.detail.value;
    }

    //handles when Completion Status field is updated
    handleStatusChange(event){
        this.isDisabled = false;
        this.sessionStatus = event.detail.value;
    }

    //handles saving of record from modal
    handleModalSave(){
        let response;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[COMPLETION_DATE_FIELD.fieldApiName] = this.completionDate;
        fields[SESSION_STATUS_FIELD.fieldApiName] = this.sessionStatus;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.isModalOpen = false;
                this.isDisabled = true;
                response = 'Success';
            })
            .catch(error => {
                response = error;
            })
            .finally(() => {
                this.isLoading = false;
                if(response === 'Success'){
                    this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
                } else {
                    this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                }
                // Refresh data in datatable 
                refreshApex(this.tableData);
            });
    }

    //Function to generate toastmessage
    generateToast(_title, _message, _variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    get modalTitle(){ return MODAL_TITLE; }
    get modalName() {return this.modalName;}
    get noRecordsFound(){ return NO_REC_FOUND; }
    get sectionHeader(){ return SECTION_HEADER; }

}