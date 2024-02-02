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
      | rhea.b.torres             | July 30, 2022         | DEPP-3594            | Modified to hide 'Registered |
      |                           |                       |                      | Email if Contact selected has|
      |                           |                       |                      | Registered_Email__c          |
      | john.m.tambasen           | August 03, 2022       | DEPP-3614            | show free pb ony if available|
      | john.m.tambasen           | August, 16 2022       | DEPP-1946            | Single/Group Coaching changes|
      | eccarius.karl.munoz       | August 29, 2022       | DEPP-3754            | Added dedup validation upon  |
      |                           |                       |                      | creation of contact          |
      | john.m.tambasen           | August, 22 2022       | DEPP-3325            | Added discount functionality |
      | kathy.cornejo             | September 12, 2022    | DEPP-4273            | Fixed error message          |
      | julie.jane.alegre         | September 26, 2023    | DEPP-4762            | Added Position & Company Name|
      | eugene.andrew.abuan       | October 10, 2023      | DEPP-6612            | Changed QUT_Student_Id__c to |
      |                           |                       |                      | QUT_Student_Username__c      |
*/

import { api, LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import getRegistrations from '@salesforce/apex/ManageRegistrationLearnersListHelper.getRegistrations';
import updateRegistration from '@salesforce/apex/ManageRegistrationLearnersListHelper.updateRegistration';
import getRegistrationStatusValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getRegistrationStatusValues';
import getPaidInFullValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getPaidInFullValues';
import getPricingValidationValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getPricingValidationValues';
import getSearchedContacts from '@salesforce/apex/ManageRegistrationSectionCtrl.getSearchedContacts';
import getQuestions from "@salesforce/apex/ManageRegistrationSectionCtrl.getQuestions";
import getEmailOptions from "@salesforce/apex/ManageRegistrationSectionCtrl.getEmailOptions";
import addRegistration from '@salesforce/apex/ManageRegistrationEnrolmentHelper.addRegistration';
import getPBEntries from '@salesforce/apex/ManageRegistrationSectionCtrl.getPBEntries';
import checkOfferingAvailability from '@salesforce/apex/ManageRegistrationSectionCtrl.checkOfferingAvailability';
import getAsset from '@salesforce/apex/CorporateBundleAndSOAHelper.getAsset';
import checkCreditAvailability from '@salesforce/apex/CorporateBundleAndSOAHelper.checkCreditAvailability';
import getRegisteredEmail from '@salesforce/apex/ManageRegistrationSectionCtrl.getRegisteredEmail';
import getDiscount from '@salesforce/apex/PromotionDiscountCtrl.getDiscount';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import LWC_List_ConfirmedLearnerStatus   from '@salesforce/label/c.LWC_List_ConfirmedLearnerStatus';
import { createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import SESSION_OBJECT from '@salesforce/schema/Session__c';
import RT_Specialised_Session from '@salesforce/label/c.RT_Session_Specialised_Session';

const COMMA = ',';
const CONFIRMED_STATUS = LWC_List_ConfirmedLearnerStatus.split(COMMA);
const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const NO_REC_FOUND = 'No record(s) found.';
const MODAL_TITLE = 'Registration Details';
const SECTION_HEADER = 'Manage Registrations Overview';
const COLUMN_HEADER = 'First Name,Last Name,Contact Email,Birthdate,Registration Status,LMS Integration Status,Registration Date, Paid Amount, Student Username, Position, Organisation, Dietary Requirement, Accessibility Requirement';
const PROD_CATEG_TAILORED = 'Tailored Executive Program';
const PROD_CATEG_SOA = 'QUTeX Learning Solutions';
const DATE_OPTIONS = { year: 'numeric', month: '2-digit', day: '2-digit' };
const ENABLED_PARTNER_REQUIRED = 'Please ensure Corporate Portal Administrator is enabled access to the portal before registering contacts.';

export default class ManageRegistrationSection extends NavigationMixin(LightningElement) {

    @api prodReqId;
    @api enableEdit;
    @api childRecordId;
    @api disabled;
    @api prescribedProgram;
    @api isCoachingProductRequest;
    @api noOfCoachingSessions;
    @api productCategory;
    @api maxParticipants;
    @api isChildOfPrescribedProgram;

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
    isGroupRegister = false;
    error;
    registrationStatusValues;
    registrationStatusModal;
    pricingValidationValues;
    pricingValidation;
    paidInFullValues;
    records = [];
    recordsTemp = [];
    activeLearners = [];

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
    emailOptions = [];
    registeredEmail;
    showContactErrorMessage = false;
    conErrorMessage;

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
    pbEntryStandardRecord;
    discountMessage = '';
    discountMessageClass = '';
    discountAmount = 0;
    promotionId = '';

    pbEntriesToAssetMap = {};

    columns = [
        { label: 'Full Name', fieldName: 'contactFullName', type: 'text', sortable: true },
        { label: "Registration Date",fieldName: "registrationDate",type: 'text'},    
        { label: 'Paid Amount', fieldName: 'paidAmount', type: 'currency', typeAttributes: {currencyCode:'AUD', step: '0.001'}},
        { label: 'Student Username', fieldName: 'studentUserName', type: 'text', sortable: true },
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

    @wire(getObjectInfo, { objectApiName: SESSION_OBJECT})
    sessionInfo;


    //Retrieves questionnaire data related to the product request
    tableData;
    @wire(getRegistrations, {childRecordId : '$childRecordId', prescribedProgram: '$prescribedProgram'})
    getRegistrations(result) {
        this.isLoading = true;
        this.tableData = result;
        if(result.data){
            this.records = result.data.map(item => {
                let record = {};
                record.contactFullName = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.Name : '';
                record.contactId = item.enrolmentDetails.hed__Contact__c ? item.enrolmentDetails.hed__Contact__c : '';
                record.contactLastName = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.LastName : '';
                record.contactFirstName = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.FirstName : '';
                record.contactBirthdate = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.Birthdate?this.formatDate(item.enrolmentDetails.hed__Contact__r.Birthdate):'' : '';
                record.contactEmail = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.Registered_Email__c : '';
                
                record.studentUserName = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.QUT_Student_Username__c : '';
                record.position = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.Position__c : '';
                record.organisation = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.hed__Primary_Organization__c?item.enrolmentDetails.hed__Contact__r.hed__Primary_Organization__r.Name:'' : '';
                record.dietaryRequirement = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.Dietary_Requirement__c : '';
                record.accessibilityRequirement = item.enrolmentDetails.hed__Contact__r ? item.enrolmentDetails.hed__Contact__r.Accessibility_Requirement__c : '';

                record.paidInFull = item.enrolmentDetails.Paid_in_Full__c ? item.enrolmentDetails.Paid_in_Full__c : '';
                record.registrationStatus = item.enrolmentDetails.hed__Status__c ? item.enrolmentDetails.hed__Status__c : '';
                record.lmsIntegrationStatus = item.enrolmentDetails.LMS_Integration_Status__c ? item.enrolmentDetails.LMS_Integration_Status__c : '';
                record.paymentMethod = item.enrolmentDetails.Payment_Method__c ? item.enrolmentDetails.Payment_Method__c : '';
                record.paidAmount = item.enrolmentDetails.Paid_Amount__c ? item.enrolmentDetails.Paid_Amount__c : '';
                record.registrationDate = item.enrolmentDetails.CreatedDate?this.formatDate(item.enrolmentDetails.CreatedDate):'';
                record.pricingValidation = item.enrolmentDetails.Pricing_Validation__c ? item.enrolmentDetails.Pricing_Validation__c : '';
                record.id = item.enrolmentDetails.Id ? item.enrolmentDetails.Id : '';

                if(item.applicationDetails){
                    record.questionId = item.applicationDetails.Id;
                    record.applicationName = item.applicationDetails.Name;
                    record.applicationURL = '/' + item.applicationDetails.Id;
                }

                record.regenerateInvoiceURL = item.regenerateInvoiceURL;

                return record;
            });
            this.contactList = result.data.map(item => {
                if(item.enrolmentDetails.hed__Status__c !== 'Cancelled'){
                    return item.enrolmentDetails.hed__Contact__c;
                }
            });
            this.recordsTemp = this.records;
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
            this.registeredEmail = undefined;
            this.emailOptions = [];
            this.activeLearners = this.records.filter(rec=> rec.registrationStatus.includes('Active'));
        } else if(result.error){
            this.records = undefined;
            this.recordsTemp = undefined;
            this.error = result.error;
            this.isLoading = false;
            this.registeredEmail = undefined;
            this.emailOptions = [];
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
            let pbEntryIds = [];
            const resp = result.data;
            const hasEarlyBird = resp.find(element => element.label === ('Early Bird'));
            const hasStandardPricing = resp.find(element => element.label === ('Standard Price Book'));
            this.pbEntryFreeRecord = resp.find(element => element.label === ('Free'));
            this.pbEntryStandardRecord = resp.find(element => element.label === ('Standard Price Book'));
            //check if free is available first
            if(this.pbEntryFreeRecord){
                tempRecords = resp.filter(rec=> 
                    rec.label.includes('Free') || 
                    rec.label.startsWith('SOA') || 
                    rec.label.startsWith('Corporate Bundle')); 
                this.pbEntryRecords = [...tempRecords];
                this.pbEntryRecords = tempRecords.map(type => {
                    pbEntryIds.push(type.id);
                    return { label: type.label, value: type.id };
                });
            } else if(hasEarlyBird && hasStandardPricing){
                tempRecords = resp.filter(rec=> !rec.label.includes('Standard Price Book'));
                this.pbEntryRecords = [...tempRecords];
                this.pbEntryRecords = tempRecords.map(type => {
                    pbEntryIds.push(type.id);
                    return { label: type.label, value: type.id };
                });
            }else{
                this.pbEntryRecords = resp.map(type => {
                    pbEntryIds.push(type.id);
                    return { label: type.label, value: type.id };
                });
            }

            //if child of SOA only show SOA pricing
            if(this.isQUTexLearningCategory){
                tempRecords = resp.filter(rec=> rec.label.startsWith('SOA'));
                if(tempRecords.length > 0){
                    pbEntryIds = [];
                    this.pbEntryRecords = tempRecords.map(type => {
                        pbEntryIds.push(type.id);
                        return { label: type.label, value: type.id };
                    });
                }
            }
        }
    }

    //handles pricing selection
    handleSelectedPricing(event){
        this.isDisabled = false;
        this.pbEntryRecord = event.detail.value;

        //show discount field if selected pricing is not for free
        if( !this.pbEntryFreeRecord){

            //reset discount variables
            this.discountMessageClass = '';
            this.discountMessage = '';
            this.discountAmount = 0;
            const dicountField = this.template.querySelector("lightning-input[data-id='discountField']");

            if(dicountField){
                dicountField.value = null;
            }
        }

        if(this.isCorporateBundlePricebook){
            let pbEntries = [];
            pbEntries.push(this.pbEntryRecord);
            getAsset({pbEntryIds:pbEntries})
                .then((res) => {
                    if(res){
                        this.pbEntriesToAssetMap = res;
                    }else{
                        this.pbEntriesToAssetMap = [];
                    } 
                })
                .catch((error)=>{
                    console.log(error);
                })
        }
    }

    handleEmailChange(event){
        this.registeredEmail = event.detail.value;
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
        checkOfferingAvailability({offeringId:this.childRecordId})
        .then((res)=>{
            if(res){
                if(!this.pbEntryRecords.length > 0 && !this.isTailoredProductCategory){
                    this.generateToast('Error.','Please setup pricing to proceed with registration.','error');
                }else{
                    this.isModalOpen = true;
                    this.isEditContact = false;
                    this.isAddContact = true;
                    this.isCreateContact = false;
                    this.isRespondQuestions = false;
                    this.pbEntryRecord = '';
                }
            }else{
                this.generateToast('Warning.','Unable to register the learner due to capacity limit or registration has expired.','error');
            }
        })
    }

    handleRespondQuestions(){
        this.isModalOpen = true;
        this.isEditContact = false;
        this.isAddContact = false;
        this.isCreateContact = false;
        this.isRespondQuestions = true;
    }

    handleCreateNewRecord(){
        if(!this.pbEntryRecord && !this.isTailoredProductCategory){
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

    handleProceedNoInvoiceClick(){
        this.isProceedNoInvoice = true;
    }

    handleRedirectToInvoiceClick(){
        this.isProceedNoInvoice = false;
    }

    handleCreateContact(event){
        event.preventDefault();
        if(this.isCorporateBundlePricebook){
            //check if asset credit is still available
            //check price book entry unit price against the asset remaining value
            checkCreditAvailability({pbEntryId:this.pbEntryRecord,assetId:this.pbEntriesToAssetMap[this.pbEntryRecord].Id})
            .then((res) => {
                if(res){
                    this.handleOnCreateContactFinal(event);
                }else{
                    this.generateToast(ERROR_TITLE, 'Not enough credit to register the learner', ERROR_VARIANT);
                } 
            })
            .catch((error)=>{
                console.log(error);
            })
        }else{
            this.handleOnCreateContactFinal(event);
        }
 
    }

    handleOnCreateContactFinal(event){
        
        let fields = event.detail.fields;
        this.contactFields = fields;
        if(this.hasQuestions){
            this.handleRespondQuestions();
        }else{
            this.isLoading = true;
            this.saveInProgress = true;
            this.saveRegistration(fields,this.childRecordId,[],[],'',this.prescribedProgram);
        }
    }

    handleCorporateBundleRegistration(){
        //check if asset credit is still available
        //check price book entry unit price against the asset remaining value
        checkCreditAvailability({pbEntryId:this.pbEntryRecord,assetId:this.pbEntriesToAssetMap[this.pbEntryRecord].Id})
        .then((res) => {
            if(res){
                this.handleExistingContactPWI();
            }else{
                this.generateToast(ERROR_TITLE, 'Not enough credit to register the learner', ERROR_VARIANT);
            } 
        })
        .catch((error)=>{
            console.log(error);
        })
    }

    handleExistingContactPWI(){
        
        let fields = {};
        fields.Id = this.contactId;
        fields.Registered_Email__c = this.registeredEmail;
        this.contactFields = fields;
        this.isProceedNoInvoice = true;
        if(this.hasQuestions){
            this.handleRespondQuestions();
        }else{
            this.isLoading = true;
            this.saveInProgress = true;
            this.saveRegistration(fields,this.childRecordId,[],[],'',this.prescribedProgram);
        }
    }
    
    
    handleExistingContact(){
        let fields = {};
        fields.Id = this.contactId;
        fields.Registered_Email__c = this.registeredEmail;
        this.isProceedNoInvoice = false;
        this.contactFields = fields;
        if(this.hasQuestions){
            this.handleRespondQuestions();
        }else{
            this.isLoading = true;
            this.saveInProgress = true;
            this.saveRegistration(fields,this.childRecordId,[],[],'',this.prescribedProgram);
        }
    }

    handleGroupRegister(){
        this.isGroupRegister = true;
        this.isAddContact = false;
        this.isCreateContact = false;
        this.isEditContact = false;
    }

    handleSaveResponse(){
        this.isLoading = true;
        this.saveInProgress = true;
        this.saveRegistration(this.contactFields,this.childRecordId,this.responseData.data,this.createAnswerRecord(),JSON.stringify(this.createFileUploadMap()),this.prescribedProgram);
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
                record.relatedAnswerId = item.Id;
                record.base64 = item.FileData.base64;
                record.fileName = item.FileData.filename;
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

    handleBulkRegistrationResponse(event){
        if(event.detail.response === 'Success'){
            this.generateToast(SUCCESS_TITLE, 'Bulk Registration Successful', SUCCESS_VARIANT);
            refreshApex(this.tableData);
        }else if(event.detail.response === 'Failed' && event.detail.errorMessage === ENABLED_PARTNER_REQUIRED){     
            this.generateToast('Error.',ENABLED_PARTNER_REQUIRED,'error');
        }else{
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }
    
    saveRegistration(contact, offeringId, relatedAnswer, answer, fileUpload, prescribedProgram){
        this.showContactErrorMessage = false; 

        let pbEntry;

        //if there's a discount set the variable to the standard pb entry record
        if(this.pbEntryRecord && this.discountAmount > 0 ){
            pbEntry = this.pbEntryStandardRecord.id;
        //else just use the selected pricing
        } else if(this.pbEntryRecord){
            pbEntry = this.pbEntryRecord;
        } else {
            pbEntry = null;
        }

        let registrationData = {};
        registrationData.contactRecord = contact;
        registrationData.offeringId = offeringId;
        registrationData.relatedAnswerList = relatedAnswer;
        registrationData.answerList = answer;
        registrationData.prescribedProgram = prescribedProgram;
        registrationData.priceBookEntryId = pbEntry;
        registrationData.isProceedNoInvoice = this.isProceedNoInvoice;
        registrationData.discountAmount = this.discountAmount;
        registrationData.promotionId = this.promotionId; 
        
        
        addRegistration({
            registrationData:JSON.stringify(registrationData),
            fileUpload:fileUpload
        })
        .then(res =>{
            if(!res.isContactInputValid){
                this.isModalOpen = true;
                this.isCreateContact = true;
                this.showContactErrorMessage = true;
                this.isRespondQuestions = false;
                this.conErrorMessage = res.contactValidationResponse;
            }else{
                //if single/group coaching and has number of sessions selected
                if(this.isCoachingProductRequest && (this.noOfCoachingSessions > 0 || this.noOfCoachingSessions != undefined)){
                    this.handleCreateSession(res);
                } else{
                    this.generateToast(SUCCESS_TITLE, 'Registration Successful', SUCCESS_VARIANT);
                    refreshApex(this.tableData);
                    if(!this.isProceedNoInvoice){
                        const config = {
                            type: 'standard__webPage',
                            attributes: {
                                url: res.paymentURL
                            }
                        };
                        this[NavigationMixin.Navigate](config);
                    }
                }
                this.isModalOpen = false;
                this.isCreateContact = false;
                this.isEditContact = false;
                this.isAddContact = false;
            }
        })
        .finally(()=>{
            this.handleClearAfterSave();
        })
        .catch(error =>{
            if( error && 
                error.body && 
                error.body.message == ENABLED_PARTNER_REQUIRED){
                    this.generateToast('Error.', error.body.message ,'error');
            }
            else if(error &&
                error.body &&
                error.body.fieldErrors &&
                error.body.fieldErrors.Birthdate){
                    this.generateToast('Error.', error.body.fieldErrors.Birthdate[0].message ,'error');
            }
            else{
                this.generateToast('Error.', LWC_Error_General ,'error');
            }
            console.error('ERROR: ' + JSON.stringify(error));
        });
    }
    
    handleClearAfterSave(){
        this.saveInProgress = false;            
        this.isLoading = false;
        this.contactId = '';
        this.contactSearchItems = [];
        this.registeredEmail = undefined;
        this.emailOptions = [];
    }

    handleNameChange(){
        this.showContactErrorMessage = false;
    }

    handleCreateSession(res){
        const recTypes = this.sessionInfo.data.recordTypeInfos;

        //loop through the current registered learners
        for (let i = 1; i <= this.noOfCoachingSessions; i++) {

            // Creating mapping of fields of Account with values
            var fields = {
                'Name' : res.contactName + ' Session ' + i.toString(),
                'Learner__c' : res.contactId,
                'RecordTypeId' : Object.keys(recTypes).find(rti => recTypes[rti].name == RT_Specialised_Session),
                'Course_Offering__c' : this.childRecordId
            };
            //variable to create the record with the Object and fields as parameter
            var objRecordInput = {'apiName' : 'Session__c', fields};
            //create record.
            createRecord(objRecordInput)
            .then(() => {
                
                //if in the last iteration
                if(i == this.noOfCoachingSessions){
                    this.dispatchEvent(new CustomEvent('addedregistrant'));
                    this.generateToast(SUCCESS_TITLE, 'Registration Successful', SUCCESS_VARIANT);
                    refreshApex(this.tableData);
                }
            })
            .catch(error => {
                console.error(error);
            });
        }
    }

    handleLookupSelect(event){
        this.contactId = event.detail.value;
        getEmailOptions({contactId:event.detail.value})
        .then((res) => {
            this.emailOptions = [...res];
            this.emailOptions = res.map(type => {
                return { label: type.label, value: type.value};
            });
        })

        getRegisteredEmail({contactId:event.detail.value})
        .then((res) => {
            this.registeredEmail = res;
        })
    }

    handleLookupRemove(){
        this.contactId = '';
        this.contactSearchItems = [];
        this.emailOptions = [];
        this.registeredEmail = '';
    }

    closeModalAction(){
        this.isModalOpen = false;
        this.isDisabled = true;
        this.contactId = undefined;
        this.emailOptions = [];
        this.registeredEmail = undefined;
        this.isGroupRegister = false;
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
        let studentRecord = {};
        studentRecord.Id = this.rowId;
        studentRecord.hed__Status__c = this.rowRegStatus;
        studentRecord.Paid_in_Full__c = this.rowPaidInFull;
        studentRecord.Pricing_Validation__c = this.pricingValidation;
        studentRecord.Program_Offering__c = programOfferingId != ''?programOfferingId:null;
        studentRecord.hed__Contact__c = this.rowContactId;

        updateRegistration({
            studentRecord: studentRecord
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
        let arrangedKeys = [
            'contactFirstName', 
            'contactLastName', 
            'contactEmail', 
            'contactBirthdate', 
            'registrationStatus', 
            'lmsIntegrationStatus',
            'registrationDate',
            'paidAmount',
            'studentUserName',
            'position',
            'organisation',
            'dietaryRequirement',
            'accessibilityRequirement'
        ];

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

    applyCoupon(){

        //get the discount code entered by the user and index from the array
        let couponCode = this.template.querySelector("lightning-input[data-id='discountField']").value;

        //if coupon code field is empty, reset values and return
        if (couponCode == "") {

            this.discountMessageClass = '';
            this.discountMessage = '';
            this.discountAmount = 0;
            this.promotionId = '';

            return;
        }

        let discountWrapper = {};
        discountWrapper.standardPBId = this.pbEntryStandardRecord.id;
        discountWrapper.selectedPBId = this.pbEntryRecord;
        discountWrapper.offeringId = this.childRecordId;
        discountWrapper.prescribedProgram = this.prescribedProgram;
        discountWrapper.couponCode = couponCode;

        //function to get the discount of the product
        getDiscount({
            discountWrapper:JSON.stringify(discountWrapper)
        })
        .then((data) => {

            //check returned value and show message accordingly
            //-1 means coupon entered is not valid
            if(data.discount == -1){
                this.discountMessageClass = 'warning-label slds-m-left_x-small';
                this.discountMessage = 'Invalid coupon.';
                this.discountAmount = 0;

            //-2 means the selected price is still less than the discounted
            }else if(data.discount == -2){
                this.discountMessageClass = 'warning-label slds-m-left_x-small';
                this.discountMessage = 'Selected price is less than the discounted standard price.';
                this.discountAmount = 0;

            } else{
                this.discountMessageClass = 'coupon-applied-label slds-m-left_x-small';    
                this.discountMessage = 'Valid coupon.';
                this.discountAmount = data.discount;
                this.promotionId = data.promotionId;
            }
            
        })
        .catch((error) => {
            this.generateToast('Error.',LWC_Error_General,'error');
        });

    }

    //formats date to AU format
    formatDate(date){
        return new Date(date).toLocaleDateString('en-AU',DATE_OPTIONS);
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
        if(this.productCategory != PROD_CATEG_TAILORED){
            return this.saveInProgress || !this.contactId || !this.pbEntryRecord || !this.registeredEmail;
        }
        return this.saveInProgress || !this.contactId || !this.registeredEmail;
    }

    get disableGroupRegistration(){
        if(this.contactId){
            return true;
        }
        return false;
    }

    get hasEmailOptions(){
        return this.emailOptions && this.emailOptions.length > 0;
    }

    get disableInvoiceBtn(){
        return this.saveInProgress || !this.contactId || !this.pbEntryRecord || (this.pbEntryFreeRecord && this.pbEntryRecord  == this.pbEntryFreeRecord.id) || !this.registeredEmail;
    }

    get disableInvoiceBtnOncreate(){
        return this.saveInProgress || (this.pbEntryFreeRecord && this.pbEntryRecord  == this.pbEntryFreeRecord.id);
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

    get contactErrorMessage(){ return this.conErrorMessage; }

    get isTailoredProductCategory() {
        return this.productCategory === PROD_CATEG_TAILORED;
    }

    get isQUTexLearningCategory() {
        return this.productCategory === PROD_CATEG_SOA;
    }

    get isCorporateBundlePricebook() {
        if( this.pbEntryRecord && 
            this.pbEntryRecords && 
            this.pbEntryRecords.find(item => item.value === this.pbEntryRecord).label.startsWith('Corporate Bundle')){
                return true;
        }else{
            return false;
        }
    }

    get isSOAPricebook() {
        if( this.pbEntryRecord && 
            this.pbEntryRecords && 
            this.pbEntryRecords.find(item => item.value === this.pbEntryRecord).label.startsWith('SOA')){
                return true;
        }else{
            return false;
        }
    }

    get hasAsset(){
        return this.isCorporateBundlePricebook && this.relatedAsset;
    }

    get relatedAsset(){
        if( this.pbEntryRecord &&
            this.isCorporateBundlePricebook &&
            this.pbEntriesToAssetMap){
                return this.pbEntriesToAssetMap[this.pbEntryRecord];
        }else{
            return {};
        }
    }

    get showDiscountSection(){
        if( !this.pbEntryFreeRecord && 
            !this.isCorporateBundlePricebook && 
            !this.isSOAPricebook &&
            this.pbEntryRecord){
                return true;
        }else{
            return false;
        }

    }
}