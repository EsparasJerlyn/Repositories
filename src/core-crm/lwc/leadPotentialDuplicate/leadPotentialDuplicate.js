import { LightningElement, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import getSelectedLead from '@salesforce/apex/LeadPotentialDuplicateCtrl.getSelectedLead';
import getLeadPotentialDuplicate from '@salesforce/apex/LeadPotentialDuplicateCtrl.getLeadPotentialDuplicate';
import mergeLeads from '@salesforce/apex/LeadPotentialDuplicateCtrl.mergeLeads';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const LEAD_INFO_TBL_TITLE = 'Lead Information';
const DUPLICATE_LEAD_TBL_TITLE = 'Duplicate Leads/Contacts';
const MODAL_TITLE = 'Potential Duplicates';
const ERR_MSG_ON_SAVE = 'You can only keep contact record when a contact part of the below list.';
const STRING_SUCCESS = 'Success';

export default class LeadPotentialDuplicate extends NavigationMixin(LightningElement) {
    @api recordId;

    potentialDuplicate = 0;
    maxRowSelection = 1;
    isLeadDuplicateModalOpen = false;
    isNextModalOpen = false;
    hasPotentialDuplicate = false;   
    isLoading = false;
    leadDuplicates = [];
    disableNextButton = true;
    disableSaveButton = true;
    records = [];
    duplicateLeadRecords = [];

    columns = [
        { label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true, editable: true },
        { label: 'Last Name', fieldName: 'lastName', type: 'text', sortable: true, editable: true },        
        { label: 'Email', fieldName: 'email', type: 'text', sortable: true, editable: true },
        { label: 'Work Email', fieldName: 'workEmail', type: 'text', sortable: true, editable: true }
    ];

    duplicateLeadColumns = [
        { label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true },
        { label: 'Last Name', fieldName: 'lastName', type: 'text', sortable: true },        
        { label: 'Email', fieldName: 'email', type: 'text', sortable: true },
        { label: 'Work Email', fieldName: 'workEmail', type: 'text', sortable: true },        
        { label: 'Type', fieldName: 'type', type: 'text', sortable: true }
    ];

    leads;
    @wire(getSelectedLead, {recordId : "$recordId"})
    wiredLeads(result) {
        this.leads = result;
        if(result.data){
            this.records = result.data;          
        }
    }

    duplicateLeads;
    @wire(getLeadPotentialDuplicate, {recordId : "$recordId"})
    wiredDuplicateLeads(result) {
        this.duplicateLeads = result;
        if(result.data){
            this.duplicateLeadRecords = result.data;
            this.potentialDuplicate = result.data.length;
            this.hasPotentialDuplicate = false;
            if(this.potentialDuplicate != 0){
                this.hasPotentialDuplicate = true; 
            }
        }
    }    

    handleInlineSave(event) {
        this.isLoading = true;
        let recId;
        let recFName;
        let recLname;
        let recEmail;
        let recWorkEmail;
        event.detail.forEach(dtl => {
            recId = dtl.id;
            recFName = dtl.firstName;
            recLname = dtl.lastName;
            recEmail = dtl.email;
            recWorkEmail = dtl.workEmail;
        });
        let fields = {
            Id : recId,
            FirstName : recFName,
            LastName : recLname,
            Email : recEmail,
            Work_Email__c : recWorkEmail
        };
        const recordInput = { fields };            
        updateRecord(recordInput)
        .then(() => {  
            this.isLoading = false;    
            this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);   
            refreshApex(this.leads); 
        })
        .catch(error => {
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            console.error('Error: ' + JSON.stringify(error));
        });
    }

    handleSave(){        
        this.isLoading = true;  
        let recordTosave;        
        this.selectedRecords.forEach(rec=>{
            recordTosave = rec;
        });
        if(recordTosave.type != 'Contact'){
            this.isLoading = false; 
            this.generateToast(ERROR_TITLE, ERR_MSG_ON_SAVE, ERROR_VARIANT);
        }else{
            let recordsToMerge = [];            
            let fordeleteion = [...this.duplicateLeadRecords, ...this.records];
            fordeleteion.forEach(rec=>{
                if(rec.id != recordTosave.id){
                    recordsToMerge.push(rec);
                }
            });
            mergeLeads({data : recordsToMerge})
                .then(result => {   
                    if(result != STRING_SUCCESS){
                        this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                    }else{
                        this.isLoading = false;   
                        this.closeModalAction();        
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: recordTosave.id,
                                objectApiName: CONTACT_OBJECT.objectApiName,
                                actionName: 'view'
                            }
                        });
                        this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);      
                        refreshApex(this.leads);       
                        refreshApex(this.duplicateLeads); 
                    }
                })
                .catch(error => {
                    this.isLoading = false; 
                    console.error('Error: ' + JSON.stringify(error));
                    this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                    this.closeModalAction();
                }
            );
        }
    }

    handleNextModal(){
        this.leadDuplicates = [...this.records, ...this.selectedRecords];
        this.isLeadDuplicateModalOpen = false;
        this.isNextModalOpen = true;
    }
    
    handleViewDuplicateLink(event){
        event.preventDefault();
        this.isLeadDuplicateModalOpen = true;
    }

    handleSelectedRows(event){
        this.selectedRecords = event.detail;         
        if(this.selectedRecords.length === 0){
            this.disableNextButton = true;  
        }else{
            this.disableNextButton = false;  
        }            
    }

    handleSelectRecordToSave(event){
        this.selectedRecords = event.detail;         
        this.disableSaveButton = false; 
    }

    closeModalAction(){
        this.leadDuplicates = [];
        this.disableNextButton = true;  
        this.isLeadDuplicateModalOpen = false;
        this.isNextModalOpen = false;
    }

    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    get cardTitle(){ return `We found ${this.potentialDuplicate} potential duplicate of this Lead.`;}
    get modalTitle(){ return MODAL_TITLE; }
    get leadInfoTableTitle(){ return LEAD_INFO_TBL_TITLE; }
    get duplicateInfoTableTitle(){ return DUPLICATE_LEAD_TBL_TITLE; }
}