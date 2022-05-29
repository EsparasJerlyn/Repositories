import { LightningElement, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import getSelectedContact from '@salesforce/apex/ContactPotentialDuplicateCtrl.getSelectedContact';
import getContactPotentialDuplicate from '@salesforce/apex/ContactPotentialDuplicateCtrl.getPotentialDuplicate';
import mergeContacts from '@salesforce/apex/ContactPotentialDuplicateCtrl.mergeContacts';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const CONTACT_INFO_TBL_TITLE = 'Contact Information';
const DUPLICATE_CONTACTS_TBL_TITLE = 'Duplicate Contacts';
const MODAL_TITLE = 'Potential Duplicates';
const STRING_SUCCESS = 'Success';

export default class ContactPotentialDuplicate extends NavigationMixin(LightningElement) {

    @api recordId;

    potentialDuplicate = 0;
    maxRowSelection = 1;
    isContactDuplicateModalOpen = false;
    isNextModalOpen = false;
    hasPotentialDuplicate = false;   
    isLoading = false;
    contactDuplicates = [];
    disableNextButton = true;
    disableSaveButton = true;
    records = [];
    duplicateContactRecords = [];

    columns = [
        { label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true, editable: true },
        { label: 'Last Name', fieldName: 'lastName', type: 'text', sortable: true, editable: true },
        { label: 'Date of Birth', fieldName: 'birthDate', type: 'text', sortable: true },
        { label: 'Email', fieldName: 'email', type: 'text', sortable: true, editable: true },
        { label: 'Work Email', fieldName: 'workEmal', type: 'text', sortable: true, editable: true },
        { label: 'QUT Learner Email', fieldName: 'qutLearnerEmail', type: 'text', sortable: true },
        { label: 'QUT Staff Email', fieldName: 'qutStaffEmail', type: 'text', sortable: true },
        { label: 'Student ID', fieldName: 'qutStudentEmail', type: 'text', sortable: true },
        { label: 'Employee ID', fieldName: 'qutEmployeeId', type: 'text', sortable: true }
    ];

    duplicateContactColumns = [
        { label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true },
        { label: 'Last Name', fieldName: 'lastName', type: 'text', sortable: true },
        { label: 'Date of Birth', fieldName: 'birthDate', type: 'text', sortable: true },
        { label: 'Email', fieldName: 'email', type: 'text', sortable: true },
        { label: 'Work Email', fieldName: 'workEmal', type: 'text', sortable: true },
        { label: 'QUT Learner Email', fieldName: 'qutLearnerEmail', type: 'text', sortable: true },
        { label: 'QUT Staff Email', fieldName: 'qutStaffEmail', type: 'text', sortable: true },
        { label: 'Student ID', fieldName: 'qutStudentEmail', type: 'text', sortable: true },
        { label: 'Employee ID', fieldName: 'qutEmployeeId', type: 'text', sortable: true }
    ];

    contacts;
    @wire(getSelectedContact, {recordId : "$recordId"})
    wiredContacts(result) {
        this.contacts = result;
        if(result.data){
            this.records = result.data;          
        }
    }

    duplicateContacts;
    @wire(getContactPotentialDuplicate, {recordId : "$recordId"})
    wiredDuplicateContacts(result) {
        this.duplicateContacts = result;
        if(result.data){
            this.duplicateContactRecords = result.data;
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
        event.detail.forEach(dtl => {
            recId = dtl.id;
            recFName = dtl.firstName;
            recLname = dtl.lastName;
            recEmail = dtl.email;
        });
        let fields = {
            Id : recId,
            FirstName : recFName,
            LastName : recLname,
            Email : recEmail
        };
        const recordInput = { fields };            
        updateRecord(recordInput)
        .then(() => {  
            this.isLoading = false;    
            this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);   
            refreshApex(this.contacts); 
        })
        .catch(error => {
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            console.error('Error: ' + JSON.stringify(error));
        });
    }

    handleSave(){
        this.isLoading = true;  
        let contactTosave;
        this.selectedRecords.forEach(con=>{
            contactTosave = con;
        });
        let contactsToMerge = [];
        let mainContact = [];
        this.contactDuplicates.forEach(con=>{
            if(con.id != contactTosave.id){
                if(con.id === this.recordId){
                    mainContact.push(con);
                }
                contactsToMerge.push(con);
            }
        });
        mergeContacts({data : contactsToMerge, contact : mainContact})
            .then(result=> {   
                if(result != STRING_SUCCESS){
                    this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                }else{
                    this.isLoading = false;      
                    if(contactTosave.id != this.recordId){
                        this.closeModalAction();  
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: contactTosave.id,
                                objectApiName: CONTACT_OBJECT.objectApiName,
                                actionName: 'view'
                            }
                        });
                    }else{
                        this.closeModalAction();  
                    }
                    this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);      
                    refreshApex(this.contacts);       
                    refreshApex(this.duplicateContacts);
                }
            })
            .catch(error => {
                this.isLoading = false; 
                this.generateToast(ERROR_TITLE, error.body.message, ERROR_VARIANT);
                this.closeModalAction();
            }
        );
    }

    handleNextModal(){
        this.contactDuplicates = [...this.records, ...this.selectedRecords];
        this.isContactDuplicateModalOpen = false;
        this.isNextModalOpen = true;
    }
    
    handleViewDuplicateLink(event){
        event.preventDefault();
        this.isContactDuplicateModalOpen = true;
    }

    handleSelectedRows(event){
        this.selectedRecords = event.detail;         
        if(this.selectedRecords.length === 0){
            this.disableNextButton = true;  
        }else{
            this.disableNextButton = false;  
        }            
    }

    handleSelectContactToSave(event){
        this.selectedRecords = event.detail;         
        if(this.selectedRecords.length === 1){
            let contactTosave;
            this.selectedRecords.forEach(con=>{
                contactTosave = con.id;
            });
            this.disableSaveButton = false;  
        }else if(this.selectedRecords.length > 1){
            this.disableSaveButton = true;  
        }  
        else{
            this.disableSaveButton = true;  
        }          
    }

    closeModalAction(){
        this.contactDuplicates = [];
        this.disableNextButton = true;  
        this.isContactDuplicateModalOpen = false;
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

    get cardTitle(){ return `We found ${this.potentialDuplicate} potential duplicate of this Contact.`;}
    get modalTitle(){ return MODAL_TITLE; }
    get contactInfoTableTitle(){ return CONTACT_INFO_TBL_TITLE; }
    get duplicateInfoTableTitle(){ return DUPLICATE_CONTACTS_TBL_TITLE; }

}