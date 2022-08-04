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
      | roy.nino.regala           | March 29, 2022        | DEPP-1539            | Added Add Registration       |
      | eccarius.karl.munoz       | May 03, 2022          | DEPP-2314            | Handling for Prescribed Prog.|
      | keno.domienri.dico        | June 27, 2022         | DEPP-3287            | Added new button Proceed     |
      |                           |                       |                      | without Invoice              |
      | john.bo.a.pineda          | June 28, 2022         | DEPP-3315            | Modified handleSaveResponse  |
      |                           |                       |                      | logic for Proceed w/o Invoice|
      | john.bo.a.pineda          | June 29, 2022         | DEPP-3323            | Modified to add logic to     |
      |                           |                       |                      | validate Upload File Type    |
      | john.m.tambasen           | August 03, 2022       | DEPP-3614            | show free pb ony if available|
*/

import { api, LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import getRegistrations from '@salesforce/apex/ManageRegistrationSectionCtrl.getRegistrations';
import updateRegistration from '@salesforce/apex/ManageRegistrationSectionCtrl.updateRegistration';
import getRegistrationStatusValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getRegistrationStatusValues';
import getPaidInFullValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getPaidInFullValues';
import getPricingValidationValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getPricingValidationValues';
import getSearchedContacts from '@salesforce/apex/ManageRegistrationSectionCtrl.getSearchedContacts';
import getQuestions from "@salesforce/apex/ManageRegistrationSectionCtrl.getQuestions";
import addRegistration from '@salesforce/apex/ManageRegistrationSectionCtrl.addRegistration';
import addRegistration2 from '@salesforce/apex/ManageRegistrationSectionCtrl.addRegistration2';
import getPBEntries from '@salesforce/apex/ManageRegistrationSectionCtrl.getPBEntries';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import LWC_List_ConfirmedLearnerStatus	 from '@salesforce/label/c.LWC_List_ConfirmedLearnerStatus';

const COMMA = ',';
const CONFIRMED_STATUS = LWC_List_ConfirmedLearnerStatus.split(COMMA);
const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const NO_REC_FOUND = 'No record(s) found.';
const MODAL_TITLE = 'Registration Details'
const SECTION_HEADER = 'Manage Registrations Overview';
const COLUMN_HEADER = 'First Name,Last Name,Contact Email,Birthdate,Registration Status,LMS Integration Status'

export default class ManageRegistrationSection extends NavigationMixin(LightningElement) {

    @api prodReqId;
    @api enableEdit;
    @api childRecordId;
    @api disabled;
    @api prescribedProgram;

    searchField = '';
    picklistValue = '';
    rowRegStatus = '';
    rowPaidInFull = '';
    rowId = '';
    rowQuestId = '';
    rowContactId = '';
    modalName = '';
    isModalOpen = false;
    isLoading = false;
    empty = false;
    isDisabled = true;
    isForRejection = false;
    error;
    registrationStatusValues;
    registrationStatusModal;
    pricingValidationValues;
    pricingValidation;
    paidInFullValues;
    records = [];
    recordsTemp = [];

    //addcontact variables
    contactSearchItems = [];
    contactId;
    searchInProgress;
    objectLabelName = 'Contact';
    objectToBeCreated ='Contact';
    isAddContact = false;
    isCreateContact = false;
    isEditContact = false;
    saveInProgress = false;
    contactList;
    formLoading = false;
    contactFields;

    //proceed without Invoice
    isProceedNoInvoice = false;

    //registration Response variables
    isRespondQuestions;
    responseData;
    questions;

    selectedPricing;
    pbEntryRecords;
    pbEntryRecord;
    pbEntryFreeRecord;

    columns = [
        { label: 'Full Name', fieldName: 'contactFullName', type: 'text', sortable: true },
        { label: 'Selected Pricing', fieldName: 'selectedPricing', type: 'text', sortable: true, wrapText: true },
        { label: 'Pricing Validation', fieldName: 'pricingValidation', type: 'text', sortable: true },
        { label: 'Payment Method', fieldName: 'paymentMethod', type: 'text', sortable: true },
        { label: 'Paid in Full', fieldName: 'paidInFull', type: 'text', sortable: true },
        { label: 'Registration Status', fieldName: 'registrationStatus', type: 'text', sortable: true },
        { label: 'LMS Integration Status', fieldName: 'lmsIntegrationStatus', type: 'text', sortable: true },
        { label: 'Registration Questions', fieldName: 'applicationURL', sortable: true, type: 'url', typeAttributes: {label: 'View', target: '_blank'} },
        { label: 'Regenerate Invoice', fieldName: 'regenerateInvoiceURL', type: 'url', typeAttributes: {label: 'Regenerate Invoice', target: '_blank', tooltip: 'Payment Gateway Link'} }
    ];

    // Set Accepted File Formats
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', 'jpeg'];
    }

    //Retrieves questionnaire data related to the product request
    tableData;
    @wire(getRegistrations, {childRecordId : '$childRecordId', prescribedProgram: '$prescribedProgram'})
    getRegistrations(result) {
        this.isLoading = true;
        this.tableData = result;
        if(result.data){
            this.records = result.data;
            this.contactList = result.data.map(item => {
                return item.contactId;
            });
            this.recordsTemp = result.data;
            if(this.records.length === 0){
                this.empty = true;
            }else{
                this.empty = false;
            }
            this.error = undefined;
            this.isLoading = false;
            this.dispatchEvent(new CustomEvent('setemails', {
                detail: {
                    offeringId: this.childRecordId,
                    value : this.records.filter(
                        record => CONFIRMED_STATUS.includes(record.registrationStatus)
                    ).map(record => {return record.contactEmail})
                }
            }));
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

    //Retrieves Questionnaire Summary Details
    @wire(getQuestions, { productReqId: '$prodReqId' })
    getQuestions(result) {
        if(result.data){
            this.responseData = result;
            this.questions = this.formatQuestions(result.data);
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    //Retrieves Pricing validation values
    @wire(getPricingValidationValues)
    getPricingValidationValues(result){
        if(result.data) {
            const resp = result.data;
            this.pricingValidationValues = resp.map(type => {
                return { label: type, value: type };
            });
            this.pricingValidationValues.unshift({ label: 'None', value: '' });
        }
    }

    //Retrieves Price Book Entries
    pbEntries;
    @wire(getPBEntries, {childRecordId : "$childRecordId", prescribedProgram: '$prescribedProgram'})
    wiredpbEntries(result) {
        this.pbEntries = result;
        if (result.data) {
            let tempRecords = [];
            const resp = result.data;
            const hasEarlyBird = resp.find(element => element.label === ('Early Bird'));
            const hasStandardPricing = resp.find(element => element.label === ('Standard Price Book'));
            this.pbEntryFreeRecord = resp.find(element => element.label === ('Free'));

            //check if free is available first
            if(this.pbEntryFreeRecord){
                tempRecords = resp.filter(rec=> rec.label.includes('Free'));
                this.pbEntryRecords = [...tempRecords];
                this.pbEntryRecords = tempRecords.map(type => {
                    return { label: type.label, value: type.id };
                });
            } else if(hasEarlyBird && hasStandardPricing){
                tempRecords = resp.filter(rec=> !rec.label.includes('Standard Price Book'));
                this.pbEntryRecords = [...tempRecords];
                this.pbEntryRecords = tempRecords.map(type => {
                    return { label: type.label, value: type.id };
                });
            }else{
            this.pbEntryRecords = resp.map(type => {
                return { label: type.label, value: type.id };
            });
            }
        }
    }

    //handles pricing selection
    handleSelectedPricing(event){
        this.isDisabled = false;
        this.pbEntryRecord = event.detail.value;
    }

    //handles opening of modal
    handleEditContact(event){
        this.isModalOpen = true;
        this.isEditContact = true;
        this.isAddContact = false;
        this.isCreateContact = false;
        this.isRespondQuestions = false;
        const row = event.detail;
        this.rowPaidInFull = row.paidInFull;
        this.rowRegStatus = row.registrationStatus;
        this.rowId = row.id;
        this.modalName = row.contactFullName;
        this.rowQuestId = row.questionId;
        this.pricingValidation = row.pricingValidation;
        this.rowContactId = row.contactId;
    }

    //handles opening of modal
    handleAddContact(){
        if(!this.pbEntryRecords.length > 0){
            this.generateToast('Error.','Please setup pricing to proceed with registration.','error');
        }else{
            this.isModalOpen = true;
            this.isEditContact = false;
            this.isAddContact = true;
            this.isCreateContact = false;
            this.isRespondQuestions = false;
            this.pbEntryRecord = '';
        }
    }

    handleRespondQuestions(){
        this.isModalOpen = true;
        this.isEditContact = false;
        this.isAddContact = false;
        this.isCreateContact = false;
        this.isRespondQuestions = true;
    }

    handleCreateNewRecord(){
        if(!this.pbEntryRecord){
            this.generateToast('Error.','Please select pricing.','error');
        }else{
            this.formLoading = true;
            this.isModalOpen = true;
            this.isEditContact = false;
            this.isAddContact = false;
            this.isCreateContact = true;
            this.isRespondQuestions = false;
        }
    }

    formatQuestions(items){
        let questions = items.map(item =>{
            let newItem = {};
            let newOptions = [];
            newItem.Id = item.Id;
            if(item.Question__c){
                newItem.QuestionId = item.Question__r.Id;
                newItem.Label = item.Question__r.Label__c;
                newItem.MandatoryResponse = item.Question__r.Acceptable_Response__c;
                newItem.Message = item.Question__r.Message__c;
                newItem.Type = item.Question__r.Type__c;
                newItem.IsText = item.Question__r.Type__c == 'Text'?true:false;
                newItem.IsCheckbox = item.Question__r.Type__c == 'Checkbox'?true:false;
                newItem.IsNumber = item.Question__r.Type__c == 'Number'?true:false;
                newItem.IsDate = item.Question__r.Type__c == 'Date'?true:false;
                newItem.IsPicklist = item.Question__r.Type__c == 'Picklist'?true:false;
                newItem.IsMultiPicklist = item.Question__r.Type__c == 'Multi-Select Picklist'?true:false;
                newItem.IsFileUpload = item.Question__r.Type__c == 'File Upload'?true:false;
                if(item.Question__r.Dropdown_Options__c){
                    newOptions = item.Question__r.Dropdown_Options__c.split(';').map(key =>{
                        return {label: key, value: key};
                    });
                }
                newItem.Options = newOptions;
                newItem.Answer = newItem.IsCheckbox?'false':'';
            }
            newItem.QuestionnaireId = item.Questionnaire__c;
            newItem.IsCriteria = item.Questionnaire__r.Questionnaire_Type__c == 'Registration Criteria'?true:false;
            newItem.IsQuestion = item.Questionnaire__r.Questionnaire_Type__c == 'Registration Questions'?true:false;
            newItem.Sequence = item.Sequence__c;
            newItem.ErrorMessage = '';
            newItem.FileData = undefined;
            return newItem;
        });

        return questions;
    }

    handleChange(event){
        this.questions = this.questions.map(row=>{
            if(event.target.name === row.Id && row.IsCheckbox){
                row.Answer = event.detail.checked.toString();
            }else if(event.target.name === row.Id && row.IsFileUpload){
                row.Answer = event.detail.value.toString();
                const file = event.target.files[0];
                let fileNameParts = file.name.split('.');
                let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
                if (this.acceptedFormats.includes(extension)) {
                    let reader = new FileReader();
                    reader.onload = () => {
                        let base64 = reader.result.split(',')[1];
                        row.FileData = {
                            'filename': file.name,
                            'base64': base64,
                            'recordId': undefined
                        };
                    }
                    reader.readAsDataURL(file);
                } else {
                    row.Answer = '';
                    row.FileData = undefined;
                    this.generateToast('Error.','Invalid File Format.','error');
                }
            }else if(event.target.name === row.Id && row.IsMultiPicklist){
                row.Answer = event.detail.value?event.detail.value.toString().replace(/,/g, ';'):row.Answer;
            }else if(event.target.name === row.Id){
                row.Answer = event.detail.value?event.detail.value.toString():row.Answer;
            }
            return row;
        });
    }

    handleBlur(){
        this.questions = this.questions.map(row=>{
            if(row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase()){
                row.Answer = '';
                row.ErrorMessage = row.Message?row.Message:'You are not qualified to proceed with registration.';
            }else if(row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() == row.MandatoryResponse.toUpperCase()){
                row.ErrorMessage = '';
            }
            return row;
        });
    }

    handleSearchContact(event){
        this.searchInProgress = true;
        getSearchedContacts({
            filterString: event.detail.filterString,
            filterContacts: this.contactList
        })
        .then(result =>{
            if(result){
                this.contactSearchItems = result;
            }else{
                this.contactSearchItems = [];
            }
        })
        .finally(()=>{
            this.searchInProgress = false;
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

    handleProceedNoInvoiceClick(event){
        this.isProceedNoInvoice = true;
    }

    handleRedirectToInvoiceClick(event){
        this.isProceedNoInvoice = false;
    }

    handleCreateContact(event){
        event.preventDefault();
        let fields = event.detail.fields;
        this.contactFields = fields;
        if(this.hasQuestions){
            this.handleRespondQuestions();
        }else{
            this.isLoading = true;
            this.saveInProgress = true;
            if(this.isProceedNoInvoice = true){
                this.saveRegistration2(fields,this.childRecordId,[],[],'',this.prescribedProgram,this.isProceedNoInvoice);
            } else {
                this.saveRegistration(fields,this.childRecordId,[],[],'',this.prescribedProgram);
            }
        }
    }

    handleExistingContactPWI(){
        let fields = {};
        fields.Id = this.contactId;
        this.contactFields = fields;
        this.isProceedNoInvoice = true;
        if(this.hasQuestions){
            this.handleRespondQuestions();
        }else{
            this.isLoading = true;
            this.saveInProgress = true;
            this.saveRegistration2(fields,this.childRecordId,[],[],'',this.prescribedProgram,this.isProceedNoInvoice);
        }
    }

    handleExistingContact(){
        let fields = {};
        fields.Id = this.contactId;
        this.contactFields = fields;
        if(this.hasQuestions){
            this.handleRespondQuestions();
        }else{
            this.isLoading = true;
            this.saveInProgress = true;
            this.saveRegistration(fields,this.childRecordId,[],[],'',this.prescribedProgram);
        }
    }

    handleSaveResponse(){
        this.isLoading = true;
        this.saveInProgress = true;
        if(this.isProceedNoInvoice = true){
            this.saveRegistration2(this.contactFields,this.childRecordId,this.responseData.data,this.createAnswerRecord(),JSON.stringify(this.createFileUploadMap()),this.prescribedProgram,this.isProceedNoInvoice);
        } else {
            this.saveRegistration(this.contactFields,this.childRecordId,this.responseData.data,this.createAnswerRecord(),JSON.stringify(this.createFileUploadMap()),this.prescribedProgram);
        }

        this.resetResponses();
    }

    resetResponses(){
        this.questions = this.questions.map(item =>{
            item.Answer = item.IsCheckbox?item.Answer:'';
            item.ErrorMessage = '';
            item.FileData = undefined;
            return item;
        });
    }

    createFileUploadMap(){
        let fileUpload = [];
        fileUpload = this.questions.map(item =>{
            if(item.IsFileUpload){
                let record = {};
                record.RelatedAnswerId = item.Id;
                record.Base64 = item.FileData.base64;
                record.FileName = item.FileData.filename;
                return record;
            }
        });

        return fileUpload.filter(key => key !== undefined)?fileUpload.filter(key => key !== undefined):fileUpload;
    }

    createAnswerRecord(){
        let answerRecords = {};
        answerRecords = this.questions.map(item =>{
            let record = {};
            record.Related_Answer__c = item.Id;
            record.Response__c = item.Answer;
            record.Sequence__c =item.Sequence;
            return record;
        });
        return answerRecords;
    }

    saveRegistration2(contact,offeringId,relatedAnswer,answer,fileUpload,prescribedProgram,isProceedNoInvoice){
        addRegistration2({
            contactRecord:contact,
            offeringId:offeringId,
            relatedAnswerList:relatedAnswer,
            answerList:answer,
            fileUpload:fileUpload,
            prescribedProgram:prescribedProgram,
            priceBookEntryId : this.pbEntryRecord,
            isProceedNoInvoice : this.isProceedNoInvoice
        })
        .then(res =>{
                this.generateToast(SUCCESS_TITLE, 'Registration Successful', SUCCESS_VARIANT);
                refreshApex(this.tableData);
                // const config = {
                //     type: 'standard__webPage',
                //     attributes: {
                //         url: res
                //     }
                // };
                // this[NavigationMixin.Navigate](config);
        })
        .finally(()=>{
            this.saveInProgress = false;
            this.isModalOpen = false;
            this.isEditContact = false;
            this.isAddContact = false;
            this.isCreateContact = false;
            this.isLoading = false;
            this.saveInProgress = false;
            this.contactId = '';
            this.contactSearchItems = [];
        })
        .catch(error =>{
            let errMsg = LWC_Error_General;
            if(error.body.pageErrors){
                error.body.pageErrors.forEach(err => {
                    errMsg = err.message;
                });
            }
            if(error.body.fieldErrors.Username){
                error.body.fieldErrors.Username.forEach(err => {
                    errMsg = err.message;
                });
            }
            this.generateToast('Error.', errMsg ,'error');
            console.log('ERROR:', error);
        });
    }

    saveRegistration(contact,offeringId,relatedAnswer,answer,fileUpload,prescribedProgram){
        addRegistration({
            contactRecord:contact,
            offeringId:offeringId,
            relatedAnswerList:relatedAnswer,
            answerList:answer,
            fileUpload:fileUpload,
            prescribedProgram:prescribedProgram,
            priceBookEntryId : this.pbEntryRecord
        })
        .then(res =>{
                this.generateToast(SUCCESS_TITLE, 'Registration Successful', SUCCESS_VARIANT);
                refreshApex(this.tableData);
                const config = {
                    type: 'standard__webPage',
                    attributes: {
                        url: res
                    }
                };
                this[NavigationMixin.Navigate](config);
        })
        .finally(()=>{
            this.saveInProgress = false;
            this.isModalOpen = false;
            this.isEditContact = false;
            this.isAddContact = false;
            this.isCreateContact = false;
            this.isLoading = false;
            this.saveInProgress = false;
            this.contactId = '';
            this.contactSearchItems = [];
        })
        .catch(error =>{
            let errMsg = LWC_Error_General;
            if(error.body.pageErrors){
                error.body.pageErrors.forEach(err => {
                    errMsg = err.message;
                });
            }
            if(error.body.fieldErrors.Username){
                error.body.fieldErrors.Username.forEach(err => {
                    errMsg = err.message;
                });
            }
            this.generateToast('Error.', errMsg ,'error');
            console.log('ERROR:', error);
        });
    }

    handleLookupSelect(event){
        this.contactId = event.detail.value;
    }

    handleLookupRemove(){
        this.contactId = '';
        this.contactSearchItems = [];
    }

    closeModalAction(){
        this.isModalOpen = false;
        this.isDisabled = true;
        this.contactId = undefined;
    }

    closeManageResponse(){
        this.isModalOpen = false;
        this.isDisabled = true;
        this.contactId = undefined;
        this.resetResponses();
    }

    handlePaidInFull(event){
        this.isDisabled = false;
        this.rowPaidInFull = event.detail.value;
    }

    handlePricingValidation(event){
        this.isDisabled = false;
        this.pricingValidation = event.detail.value;
    }

    handleFormLoad(){
        this.formLoading = false;
    }

    handleRegStatusModal(event){
        this.isDisabled = false;
        this.rowRegStatus = event.detail.value;
    }

    //shows toast on error upon saving the course/program plan
    handleRecordError(){
        this.generateToast('Error.',LWC_Error_General,'error');
    }

    //handles saving of record from modal
    handleModalSave(){
        let response;
        let programOfferingId = '';
        this.isLoading = true;
        this.isModalOpen = false;
        this.isDisabled = true;
        if(this.prescribedProgram){
            programOfferingId = this.childRecordId;
        }
        updateRegistration({
            id: this.rowId,
            questionId: this.rowQuestId,
            registrationStatus: this.rowRegStatus,
            paidInFull: this.rowPaidInFull,
            pricingValidation: this.pricingValidation,
            programOfferingId: programOfferingId,
            contactId : this.rowContactId
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
    get disableSaveExisting(){
        return this.saveInProgress || !this.contactId || !this.pbEntryRecord;
    }
    get hasQuestions(){
        return this.questions && this.questions.length > 0?true:false;
    }
    get disableResponseSave(){
        let tempQuestions = this.questions.filter(row => row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase());
        if(
            (tempQuestions && tempQuestions.length > 0) ||
            (this.questions &&
            this.questions.filter(item => item.Answer == '' || item.Answer == undefined) &&
            this.questions.filter(item => item.Answer == '' || item.Answer == undefined).length > 0)
        ){
            return true;
        }else{
            return false;
        }
    }
}