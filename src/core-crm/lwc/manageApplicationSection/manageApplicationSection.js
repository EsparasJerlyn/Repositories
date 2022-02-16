/**
 * @description Lightning Web Component for manage application section in product offerings 
 *              tab located in product request ope page..
 * 
 * @see ../classes/ManageApplicationSectionCtrl.cls
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 09, 2022     | DEPP-1483            | Created file                 | 
      |                           |                       |                      |                              | 
 */

import { api, LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getStudentApplications from '@salesforce/apex/ManageApplicationSectionCtrl.getStudentApplications';
import updateStudentApplication from '@salesforce/apex/ManageApplicationSectionCtrl.updateStudentApplication';
import getApplicationStatusValues from '@salesforce/apex/ManageApplicationSectionCtrl.getApplicationStatusValues';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const NO_REC_FOUND = 'No record(s) found.';
const MODAL_TITLE = 'Edit Application';
const SECTION_HEADER = 'Manage Applications Overview';

export default class ManageApplicationSection extends LightningElement {   

    @api prodReqId;

    searchField = '';  
    picklistValue = '';
    rowAppStatus = '';
    rowRejectReason = '';
    rowId = '';
    isModalOpen = false;
    isLoading = false;
    empty = false;
    isDisabled = true;
    isForRejection = false;
    error;
    applicationStatusValues;  
    applicationStatusModal;
    records = [];
    recordsTemp = [];

    columns = [
        { label: 'Full Name', fieldName: 'contactFullName', type: 'text', sortable: true },
        { label: 'View Application', fieldName: 'applicationURL', sortable: true, type: 'url', typeAttributes: {label: 'View', target: '_blank'} },
        { label: 'Application Status', fieldName: 'applicationStatus', type: 'text', sortable: true },       
        { label: 'Reason for Rejection', fieldName: 'reasonForRejection', type: 'text', sortable: true }
    ];    

    //Retrieves Student Applications
    tableData;
    @wire(getStudentApplications, {prodReqId : "$prodReqId"})
    wiredStudentApplication(result) {
        this.isLoading = true;
        this.tableData = result;
        if(result.data){                  
            this.records = result.data;   
            this.recordsTemp = result.data;             
            if(this.records.length === 0){
                this.empty = true;
            }
            this.error = undefined;
            this.isLoading = false;
        } else if(result.error){
            this.records = undefined;
            this.recordsTemp = undefined;
            this.error = result.error;
            this.isLoading = false;
        }    
    }

    //Retrieves Application Status Picklist Values
    @wire(getApplicationStatusValues)
    getWiredApplicationStatus(result){
        if(result.data) {
            const resp = result.data;
            this.applicationStatusValues = resp.map(type => {
                return { label: type,  value: type };
            });    
            this.applicationStatusModal = resp.map(type => {
                return { label: type,  value: type };
            });   
            this.applicationStatusValues.unshift({ label: 'All', value: '' });
        }
    }    

    //handles opening of modal
    handleOpenModal(event){
        this.isModalOpen = true;
        const row = event.detail;
        this.rowAppStatus = row.applicationStatus;
        this.isForRejection = this.rowAppStatus === 'Rejected' ? true : false;
        this.rowRejectReason = row.reasonForRejection;
        this.rowId = row.id;
    }

    closeModalAction(){
        this.isModalOpen = false;
        this.isDisabled = true;
    }

    handleModalPicklist(event){
        this.isDisabled = false;
        this.rowAppStatus = event.detail.value;    
        this.isForRejection = this.rowAppStatus === 'Rejected' ? true : false;        
    }

    handleTextArea() {
        clearTimeout(this.timeoutId); 
        this.timeoutId = setTimeout(this.enableSave.bind(this), 700); 
    }

    enableSave() {
        this.isDisabled = false;
    }

    handleModalSave(){
        let response;
        this.rowRejectReason = this.template.querySelector('lightning-textarea').value;
        this.isLoading = true; 
        this.isModalOpen = false;
        this.isDisabled = true;  
        updateStudentApplication({ id: this.rowId, applicationStatus : this.rowAppStatus, reasonForRejection : this.rowRejectReason })
            .then((result) => {
                response = result;
            })
            .catch((error) => {                    
                response = error;
            })
            .finally(() => {
                this.picklistValue = '';
                this.searchField = '';
                this.isLoading = false;  
                if(response === 'Success'){
                    this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
                }else{
                    this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                }
                //this.clearFields();
                refreshApex(this.tableData);
            });       
    }

    handleSearch(event){
        this.searchField = event.target.value;
        this.searchRecord();
    }

    handleAppStatus(event){
        this.picklistValue = event.detail.value;
        this.searchRecord();
    }

    //Search records based on search criterias
    searchRecord(){
        if(this.searchField || this.picklistValue){
            this.empty = false;
            this.records = [...this.recordsTemp];      
            this.records = this.records
                .filter( product => product.contactFullName.toLowerCase().includes(this.searchField.toLowerCase()))
                .filter( product => product.applicationStatus && product.applicationStatus.includes(this.picklistValue)
            );
            if(this.records.length === 0){
                this.empty = true;
            }
        }else{
            this.empty = false;
            this.records = [...this.recordsTemp];                      
        }
        if(this.records.length === 0){
            this.empty = true;
        }
    }

    //Resets search criterias
    handleClear(){
        const applicationStatus = this.template.querySelector("lightning-combobox");
        if(applicationStatus){
            applicationStatus.value = '';
        }
        this.picklistValue = '';
        this.searchField = '';
        this.searchRecord();
    }

    //Function to generate toastmessage
    generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }   

    get modalTitle(){ return MODAL_TITLE; }
    get noRecordsFound(){ return NO_REC_FOUND; }
    get sectionHeader(){ return SECTION_HEADER; }
}