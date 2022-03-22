/**
 * @description Lightning Web Component for manage registration section in product offerings
 *              tab located in product request ope page..
 *
 * @see ../classes/ManageRegistrationSectionCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 09, 2022     | DEPP-1482            | Created file                 |
      | eugene.andrew.abuan       | March 10, 2022        | DEPP-2037            | Modified to add Export       |
      |                           |                       |                      | Learners List button logic   |
      |                           |                       |                      |                              |
 */

import { api, LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRegistrationDetails from '@salesforce/apex/ManageRegistrationSectionCtrl.getRegistrationDetails';
import updateRegistration from '@salesforce/apex/ManageRegistrationSectionCtrl.updateRegistration';
import getRegistrationStatusValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getRegistrationStatusValues';
import getPaidInFullValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getPaidInFullValues';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const NO_REC_FOUND = 'No record(s) found.';
const MODAL_TITLE = 'Registration Details'
const SECTION_HEADER = 'Manage Registrations Overview';
const COLUMN_HEADER = 'First Name,Last Name,Contact Email,Birthdate,Registration Status,LMS Integration Status'

export default class ManageRegistrationSection extends LightningElement {

    @api prodReqId;
    @api enableEdit;

    searchField = '';
    picklistValue = '';
    rowRegStatus = '';
    rowPaidInFull = '';
    rowId = '';
    rowQuestId = '';
    modalName = '';
    isModalOpen = false;
    isLoading = false;
    empty = false;
    isDisabled = true;
    isForRejection = false;
    error;
    registrationStatusValues;
    registrationStatusModal;
    paidInFullValues;
    records = [];
    recordsTemp = [];

    columns = [
        { label: 'Full Name', fieldName: 'contactFullName', type: 'text', sortable: true },
        { label: 'Payment Method', fieldName: 'paymentMethod', type: 'text', sortable: true },
        { label: 'Paid in Full', fieldName: 'paidInFull', type: 'text', sortable: true },
        { label: 'Registration Status', fieldName: 'registrationStatus', type: 'text', sortable: true },
        { label: 'LMS Integration Status', fieldName: 'lmsIntegrationStatus', type: 'text', sortable: true },
        { label: 'Registration Questions', fieldName: 'applicationURL', sortable: true, type: 'url', typeAttributes: {label: 'View', target: '_blank'} }
    ];

    //Retrieves Student Registration
    tableData;
    @wire(getRegistrationDetails, {prodReqId : '$prodReqId'})
    wiredRegistrationDetails(result) {
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

    //Retrieves Registration Status Picklist Values
    @wire(getRegistrationStatusValues)
    wiredRegistrationStatusValues(result){
        if(result.data) {
            const resp = result.data;
            this.registrationStatusValues = resp.map(type => {
                return { label: type, value: type };
            });
            this.registrationStatusModal = resp.map(type => {
                return { label: type, value: type };
            });
            this.registrationStatusValues.unshift({ label: 'All', value: '' });
        }
    }

    //Retrieves Paid in Full Picklist Values
    @wire(getPaidInFullValues)
    wiredPaidInFullValues(result){
        if(result.data) {
            const resp = result.data;
            this.paidInFullValues = resp.map(type => {
                return { label: type, value: type };
            });
        }
    }

    //handles opening of modal
    handleOpenModal(event){
        this.isModalOpen = true;
        const row = event.detail;
        this.rowPaidInFull = row.paidInFull;
        this.rowRegStatus = row.registrationStatus;
        this.rowId = row.id;
        this.modalName = row.contactFullName;
        this.rowQuestId = row.questionId;
    }

    closeModalAction(){
        this.isModalOpen = false;
        this.isDisabled = true;
    }

    handlePaidInFull(event){
        this.isDisabled = false;
        this.rowPaidInFull = event.detail.value;
    }

    handleRegStatusModal(event){
        this.isDisabled = false;
        this.rowRegStatus = event.detail.value;
    }

    //handles saving of record from modal
    handleModalSave(){
        let response;
        this.isLoading = true;
        this.isModalOpen = false;
        this.isDisabled = true;
        updateRegistration({
            id: this.rowId,
            questionId: this.rowQuestId,
            registrationStatus: this.rowRegStatus,
            paidInFull: this.rowPaidInFull
        })
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
                } else {
                    this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                }
                refreshApex(this.tableData);
            });
    }

    handleSearch(event){
        this.searchField = event.target.value;
        this.searchRecord();
    }

    handleRegStatus(event){
        this.picklistValue = event.detail.value;
        this.searchRecord();
    }

    //Search records based on search criterias
    searchRecord(){
        if(this.searchField || this.picklistValue){
            this.empty = false;
            this.records = [...this.recordsTemp];
            this.records = this.records
                .filter(product => product.contactFullName.toLowerCase().includes(this.searchField.toLowerCase()))
                .filter(product => product.registrationStatus && product.registrationStatus.includes(this.picklistValue)
            );
        } else {
            this.empty = false;
            this.records = [...this.recordsTemp];
        }
        if(this.records.length === 0){
            this.empty = true;
        }
    }

    //Resets search criterias
    handleClear(){
        const regStatus = this.template.querySelector("lightning-combobox");
        if(regStatus){
            regStatus.value = '';
        }
        this.picklistValue = '';
        this.searchField = '';
        this.searchRecord();
    }

    //handles the exporting of list of learners via csv file.
    handleExportLearnersList(){

        let rowEnd = '\n';
        let csvString = '';
        let arrangedKeys = ['contactFirstName', 'contactLastName', 'contactEmail', 'contactBirthdate', 'registrationStatus', 'lmsIntegrationStatus'];

        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(arrangedKeys);

        csvString += COLUMN_HEADER;
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.records.length; i++){
            let colValue = 0;
            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.records[i][rowKey] === undefined ? '' : this.records[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        // Creating anchor element to download
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = 'Exported Learners List.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
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