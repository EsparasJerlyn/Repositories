import { LightningElement, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { birthdateValidation } from 'c/commonUtils';
import { refreshApex } from '@salesforce/apex';

import getAvailableSeat from '@salesforce/apex/GroupRegistrationCtrl.getAvailableSeat';
import getMobileLocaleOptions from "@salesforce/apex/GroupRegistrationCtrl.getMobileLocaleOptions";
import bulkRegister from "@salesforce/apex/GroupRegistrationCtrl.bulkRegister";
import validateContactMatching from "@salesforce/apex/RegistrationMatchingHelper.validateContactMatching";
import checkCreditAvailability from '@salesforce/apex/CorporateBundleAndSOAHelper.checkCreditAvailability';

import readCSV from '@salesforce/apex/CsvBulkRegistrationCtrl.readCSVFile';
import getAsset from '@salesforce/apex/CorporateBundleAndSOAHelper.getAsset';
import getDiscount from '@salesforce/apex/PromotionDiscountCtrl.getDiscount';
import CSV_TEMP from '@salesforce/resourceUrl/BulkRegistrationCSVTemplate';

import CONTACT_SCHEMA from '@salesforce/schema/Contact';

const PROD_CATEG_TAILORED = 'Tailored Executive Program';
const PROD_CATEG_SOA = 'QUTeX Learning Solutions';
const HEADER_TITLE = 'Bulk Registration';
const DESCRIPTION = 'To register multiple employees into this course, ' + 'download csv template, fully complete and upload the below file.';
const NOTE_LABEL = 'Please note: ';
const NOTE_LABEL_VALUE = 'Firstname, Lastname, Birthdate, and Email are mandatory for registration.';
const TOTAL_NUM_PLACES_LABEL = 'Total number of places: ';
const BUTTON_DOWNLOAD_LABEL = 'Download CSV Template';
const BUTTON_CANCEL_LBL = 'Cancel';
const BUTTON_PROCEED_LBL = 'Proceed';
const ERROR_MSG = 'An error has been encountered. Please contact your administrator.';
const ERROR_FOR_TEMPLATE = 'Template does not exist, Please contact your admin';
const AGE_OF_15_ERR = 'Must be 15 years or older to register.';
const DUPLICATE_EMAIL_ERR = 'Duplicate email entered. Please review your csv file or modify the table.';
const DEDUP_EMAIL_ERR = 'The email address doesn’t match the contact details provided. Please check the details.';
const DEDUP_PERSONAL_ERR = 'The personal details do not match with the email provided. Please check the details.';
const LEARNER_ALREADY_REG = 'Learner Already registered.';

const actions = [
    { label: 'Delete', name: 'delete' },
    { label: 'Edit', name: 'edit' },
];

const COLUMNS = [
    { label: 'First Name', fieldName: 'FirstName', type: 'text' },
    { label: 'Last Name', fieldName: 'LastName', type: 'text' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: "Mobile Locale", fieldName: "MobileLocale", type: "text" },
    { label: "Mobile", fieldName: "MobilePhone", type: "phone" },
    { label: 'Date of Birth', fieldName: 'Birthdate', type: 'date' },
    { label: "Dietary Requirement", fieldName: "DietaryRequirement", type: "text" },
    { label: "Accessibility Requirement", fieldName: "AccessibilityRequirement", type: "text" },
    { type: "action", typeAttributes: { rowActions: actions } }
];

export default class GroupRegistration extends NavigationMixin (LightningElement) {

    @api courseOffering; 
    @api productDetails; 
    @api pbEntryRecords;
    @api productCategory;
    @api pbEntryStandardRecord;
    @api pbEntryFreeRecord;
    @api prescribedProgram;
    @api learnerList;

    discountMessage = '';
    discountMessageClass = '';
    discountAmount = 0;
    promotionId = '';

    pbEntriesToAssetMap = {};
    pbEntryRecord;
    errors;
    recordId;    
    contacts;
    prefields;
    productCategoryCheck;
    availableSeats;
    totalAmount;

    columns = COLUMNS;
    errorForTemplate = ERROR_FOR_TEMPLATE;

    isCreateRecord = false;
    isEditRecord = false;
    processing = false;
    hasRowError = false;

    mobileLocaleList = [];
    filteredFieldNames = [];
    filteredMobileLocale = [];  
    contactList = [];

    availableSeatData;
    @wire(getAvailableSeat, { offeringId : '$courseOffering' })
    getAvailableSeat(result) {
        this.availableSeatData = result;
        if(result.data){
            this.availableSeats = result.data;
        }
    }

    @wire(getMobileLocaleOptions)
    getMobileLocaleOptions(result) {
        if(result.data){
            this.mobileLocaleList = result.data;
        }        
    }

    //Save Button Click (Proceed without invoice and Confirm Registration)
    processRegistration(){
        this.processing = true;

        if(this.isCorporateBundlePricebook){
            checkCreditAvailability({pbEntryId:this.pbEntryRecord,assetId:this.pbEntriesToAssetMap[this.pbEntryRecord].Id}).then((res) => {
                if(!res){
                    this.hasRowError = true;
                    this.generateToast('Error', 'Not enough credit to register the learner', 'error');
                }
            }).catch((error)=>{
                console.error(error);
            });
        }

        let rowsValidation = {};
        const emailsSet = new Set();
        this.contacts.forEach((element, index) => {
            this.contactList.push({
                FirstName: element.FirstName,
                LastName: element.LastName,
                Birthdate: element.Birthdate,
                Email : element.Email,
                Registered_Email__c : element.Email,
                ContactMobile_Locale__c : element.MobileLocale,
                Mobile_No_Locale__c : element.MobilePhone,
                Accessibility_Requirement__c : element.AccessibilityRequirement,                
                Dietary_Requirement__c : element.DietaryRequirement
            });
            
            //Check email if duplicate input
            if(emailsSet.has(element.Email)){
                if(rowsValidation[index + 1]){
                    rowsValidation[index + 1].messages.push(DUPLICATE_EMAIL_ERR);
                } else{
                    rowsValidation[index + 1] = { title: 'We found an error/s.', messages: [DUPLICATE_EMAIL_ERR] };
                }
            }
            
            //Check age
            if(!birthdateValidation(element.Birthdate)){
                if(rowsValidation[index + 1]){
                    rowsValidation[index + 1].messages.push(AGE_OF_15_ERR);
                } else{
                    rowsValidation[index + 1] = { title: 'We found an error/s.', messages: [AGE_OF_15_ERR] };
                }
            }
            emailsSet.add(element.Email);
        });

        //Check if has validation error message
        if(Object.keys(rowsValidation).length > 0){
            this.hasRowError = true;
            this.errors = { rows:rowsValidation };
            this.processing = false;
            this.contactList = [];
        }else{
            const learnerIds = [];
            this.learnerList.forEach((contact) => {
                learnerIds.push(contact.contactId);
            });

            let hasErrors = false;
            validateContactMatching({ newContactList : JSON.stringify(this.contactList) })
            .then((result) => {
                let validationResult = result;
                this.contactList.forEach((contactElement, index) => {
                    let validateResponse = validationResult.find(e => e.email == contactElement.Email);
                    if(validateResponse != undefined && validateResponse.contactRecord != undefined){  
                        if(validateResponse.isEmailMatch && validateResponse.isPartialMatch){
                            hasErrors = true;
                            rowsValidation[index + 1] = { title: 'We found an error.', messages: [DEDUP_PERSONAL_ERR] };
                        } else if(!validateResponse.isEmailMatch && validateResponse.isPartialMatch){
                            hasErrors = true;
                            rowsValidation[index + 1] = { title: 'We found an error.', messages: [DEDUP_EMAIL_ERR] };
                        } else if(validateResponse.isEmailMatch && !validateResponse.isPartialMatch){                            
                            let isLearnerExisting = learnerIds.includes(validateResponse.contactRecord.Id);
                            if(isLearnerExisting){
                                hasErrors = true;
                                rowsValidation[index + 1] = { title: 'We found an error.', messages: [LEARNER_ALREADY_REG] };
                            }else{
                                contactElement.Id = validateResponse.contactRecord.Id;
                            }
                        }
                    }
                });

                if(hasErrors){
                    this.errors = { rows:rowsValidation };
                    this.processing = false;
                    this.contactList = [];
                }

                return hasErrors || this.hasRowError;
            }).then((res) => {
                let response;
                if(!res){
                    let promoId = null;
                    if(this.promotionId){
                        promoId = this.promotionId;
                    }
                    let registrationDetailsparams = {
                        contacts : this.contactList,
                        offeringId : this.courseOffering, 
                        prescribedProgram : this.prescribedProgram, 
                        priceBookEntryId : this.pbEntryRecord,
                        discountAmount : this.discountAmount,
                        promotionId : promoId
                    };
                    
                    bulkRegister({ registrationDetails : registrationDetailsparams })
                    .then(res => {
                        if(res === 'Success'){
                            response = res;
                            refreshApex(this.availableSeatData);
                        }
                    }).catch(error => {
                        response = 'Failed';
                        console.error('Failure Error: ' + JSON.stringify(error));
                    }).finally(()=>{
                        const bulkRegisterEvent = new CustomEvent('bulkregister', {
                            detail: response
                        });
                        this.contactList = [];
                        this.processing = false;
                        this.dispatchEvent(bulkRegisterEvent); 
                        this.closeModalAction();
                    })
                }
            }).catch(error => {
                this.processing = false;
                console.error('Error: ' + JSON.stringify(error));
            });
        }
        
    }

    //Upload File
    handleUploadFinished(event) {
        this.processing = true;
        const uploadedFiles = event.detail.files;
        //Map file to Contacts
        readCSV({idContentDocument : uploadedFiles[0].documentId}).then(result => {
            this.contacts = result.map((contact,index)=> {
                let id = index + 1 + "";
                    return {
                        ...contact,
                        Birthdate :  contact.Birthdate ? this.convertDate(contact.Birthdate) : '',
                        id
                    }
            });  
            //Check Available Seats         
            if (this.contacts.length > this.availableSeats) {
                this.contacts = [];
                this.generateToast('Reminder', 'There are not enough seats available to complete this transaction.', 'warning');
            } else {
                //COMPUTE TOTAL AMOUNT HERE
                if(this.productCategoryCheck){
                    this.totalAmount = this.contacts.length * this.productDetails.PricebookEntries[0].UnitPrice; 
                }
                this.generateToast('Success', 'Contacts are created based on CSV file.', 'success');
            }
        }).catch(error => {
            console.error('Error: ' + JSON.stringify(error))
            this.generateToast('Error', ERROR_MSG, 'warning');
        }).finally(() => {
            this.processing = false;
            this.rowvalidation();
        });
    }

    rowvalidation(){
        let rowsValidation = {};
        this.contacts =  this.contacts.map(contact=>{  
            let fieldNames = [];
            let mobileLocaleExists = [];	
            mobileLocaleExists = this.mobileLocaleList.filter(lcl =>  //filters if contact mobile locale exist in mobile locale list
                lcl.value == contact.MobileLocale      
            );
            
            let contactLocale;
            //Validates inputted fields
            if(contact.Email && !this.validateEmail(contact.Email)) { //check email format
                fieldNames.push("Email");
            }               
            if (contact.MobileLocale.length == 0){  //check if mobile locale is empty
                fieldNames.push("Mobile Locale");
            }else if(mobileLocaleExists.length > 0){ //check if mobile locale is included from the mobile locale list
                contactLocale = contact.MobileLocale;
				fieldNames = fieldNames.filter(field => field != 'Mobile Locale')
			}else if(isNaN(contact.MobileLocale)){ //check if mobile locale is not a number
                fieldNames.push("Mobile Locale"); 
                contactLocale = contact.MobileLocale;  
            }else{
                this.filteredMobileLocale = this.mobileLocaleList.filter(lcl => 
                    lcl.countryCode == contact.MobileLocale        
                );
                if(this.filteredMobileLocale.length == 0 || this.filteredMobileLocale === undefined){
                    this.filteredFieldNames = fieldNames.filter(fld => fld == 'Mobile Locale')
                    if(this.filteredFieldNames.length == 0 || this.filteredFieldNames === undefined){
                        fieldNames.push('Mobile Locale');                   
                    }
                    contactLocale  = contact.MobileLocale;           
                }else{
                    contactLocale = this.filteredMobileLocale[0].value;
                    fieldNames = fieldNames.filter(field => field != 'Mobile Locale')
                }           
            }    
            //check mobile phone
            if(contact.MobilePhone.length == 0 || isNaN(contact.MobilePhone) || !this.validatePhone(contact.MobileLocale + contact.MobilePhone)) {
                fieldNames.push("Mobile Phone");                     
            }
            //check date of birth
            if(!contact.Birthdate || (contact.Birthdate && !this.validateDate(contact.Birthdate))) {
                fieldNames.push("Date of Birth");
            }
            //check names
            if(!contact.FirstName){
                fieldNames.push("First Name");
            }
            if(!contact.LastName){
                fieldNames.push("Last Name");
            }
            if(fieldNames.length>0){
                rowsValidation[contact.id] = {
                    title: 'We found an error/s.',
                    messages: ['Please enter valid value for the ff. fields', ...fieldNames],
                    fieldNames : fieldNames
                };
            }
            return{
                ...contact,
                MobileLocale: contactLocale
            }
        });
        this.errors = {
            rows:rowsValidation
        };
        this.hasRowError = false;
        if(Object.keys(rowsValidation).length > 0){
            this.hasRowError = true;
        }
    }

    handleRowAction(event) {
        this.recordId = event.detail.row.id
        this.objApiName = CONTACT_SCHEMA.objectApiName;
        if(event.detail.action.name == "edit"){
            let selectedContact = this.contacts.filter((contact) => contact.id == this.recordId)[0];
            this.prefields = {
                FirstName: selectedContact.FirstName,
                LastName: selectedContact.LastName,
                Email: selectedContact.Email,
                ContactMobile_Locale__c: selectedContact.MobileLocale,
                MobilePhone: selectedContact.MobilePhone,
                Birthdate: selectedContact.Birthdate,
                Accessibility_Requirement__c:selectedContact.AccessibilityRequirement,
                Dietary_Requirement__c: selectedContact.DietaryRequirement,
                id: selectedContact.id
            };    
            this.isEditRecord = true;
            this.isCreateRecord = false;
        }

        if(event.detail.action.name == "delete"){
            let tempHolder = this.contacts;
            this.contacts = tempHolder.filter(contact=> {
                return contact.id != this.recordId;
            });
            this.contacts.forEach((element, index) => {
                element.id = index + 1;
            });
        }
        this.rowvalidation();
    }

    saveEdit(event){
        let tempHolder= this.contacts;
        let details = event.detail;
        this.contacts = tempHolder.map((contact,index)=>{
            let id = index + 1;
            if (this.recordId == contact.id) {
                return {
                    FirstName: details.FirstName,
                    LastName: details.LastName,
                    Email: details.Email,
                    MobileLocale: details.ContactMobile_Locale__c,
                    MobilePhone: details.MobilePhone,
                    Birthdate: details.Birthdate,
                    DietaryRequirement: details.Dietary_Requirement__c,
                    AccessibilityRequirement: details.Accessibility_Requirement__c,
                    id
                };
            }else{
                return {
                    ...contact,
                    id
                }
            }
        });
        this.rowvalidation();
    }

    addNewRow(){
        if (this.contacts.length === this.availableSeats) {
            this.generateToast('Reminder','There are not enough seats available to complete this transaction.','warning');
        } 
        else if(this.contacts.length < this.availableSeats){
            this.objApiName = CONTACT_SCHEMA.objectApiName;
            this.prefields = {
                FirstName: "",
                LastName: "",
                Email: "",
                MobileLocale: "",
                MobilePhone: "",
                Birthdate: "",
                DietaryRequirement: "",
                AccessibilityRequirement: ""
            };
            this.isEditRecord = false;
            this.isCreateRecord = true;
        }
    }

    saveNew(event){
        let tempHolder = this.contacts
        let details = event.detail;
        let maxId = (this.contacts.length!=0)?Math.max.apply(Math, this.contacts.map(function(contact) { return contact.id;})):0;
        let id = (maxId + 1) + "";
        this.contacts = [...tempHolder,
            {
                FirstName: details.FirstName,
                LastName: details.LastName,
                Email: details.Email,
                MobileLocale: details.ContactMobile_Locale__c,
                MobilePhone: details.MobilePhone,
                Birthdate: details.Birthdate,
                AccessibilityRequirement: details.Accessibility_Requirement__c,
                DietaryRequirement: details.Dietary_Requirement__c,
                id
            }
        ];
        this.rowvalidation();
    }    

    handleSelectedPricing(event){
        this.hasRowError = false;
        this.isDisabled = false;
        this.pbEntryRecord = event.detail.value;
        if( !this.pbEntryFreeRecord){
            this.discountMessageClass = '';
            this.discountMessage = '';
            this.discountAmount = 0;
            const dicountField = this.template.querySelector(".grpRegDiscountField");
            if(dicountField){
                dicountField.value = null;
            }
        }

        if(this.isCorporateBundlePricebook){
            let pbEntries = [];
            pbEntries.push(this.pbEntryRecord);
            getAsset({pbEntryIds:pbEntries}).then((res) => {
                if(res){
                    this.pbEntriesToAssetMap = res;
                }else{
                    this.pbEntriesToAssetMap = [];
                } 
            }).catch((error)=>{
                console.error('Error: ' + JSON.stringify(error));
            });
        }
    }

    applyCoupon(){
        let couponCode = this.template.querySelector("lightning-input[data-id='grpRegdiscountField']").value;
        if (couponCode == "") {
            this.discountMessageClass = '';
            this.discountMessage = '';
            this.discountAmount = 0;
            this.promotionId = '';
            return;
        }
        let discountWrapper = {};
        discountWrapper.selectedPBId = this.pbEntryRecord;
        discountWrapper.offeringId = this.courseOffering;
        discountWrapper.prescribedProgram = this.prescribedProgram;
        discountWrapper.couponCode = couponCode;
        discountWrapper.standardPBId = this.pbEntryStandardRecord.id;

        getDiscount({discountWrapper:JSON.stringify(discountWrapper)}).then((data) => {
            if(data.discount == -1){
                this.discountMessageClass = 'warning-label slds-m-left_x-small';
                this.discountMessage = 'Invalid coupon.';
                this.discountAmount = 0;
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
        }).catch((error) => {
            console.error('Error: ' + JSON.stringify(error));
            this.generateToast('Error.', LWC_Error_General, 'error');
        });

    }
    
    validateEmail(email){
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return email.match(emailRegex) ? true : false;
    }
    
    validatePhone(phone){
        const phoneRegex=/^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/im;
        const mobileNumber= phone.replace(/[^0-9\.]/g, '');
        return mobileNumber.match(phoneRegex) ? true : false;
    }
     
    validateDate(Birthdate){
        return Birthdate === ''? false : true;
    }

    parseDate(date){
        if(date.replace('\r','') === ''){
            return '';
        }else{
            return date?new Date(date.replace('\r','')).toLocaleDateString('en-AU'):'';
        }
    }

    convertDate(date, separator = '-'){
        if(date.includes('/')){
            let d;
            let [day, month, year] = date.split('/');

            if (month.length == 1){
                month = "0" + month;
            }

            if (day.length == 1){
                day = '0' + day;
            }

            d = year + separator + month + separator + day;
            var newDay  = new Date(d)

            if(d.includes('undefined')){
                d = '';
            }else if(newDay == 'Invalid Date'){
                d = '';
            }
            return d;
        }else{
            return '';
        }
    };    

    closeModalAction(){
        let event = new CustomEvent('closemodal');
        this.dispatchEvent(event);
    }

    closeModal(){
        this.isCreateRecord = false;
        this.isEditRecord = false;
    }

    generateToast(_title, _message, _variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

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

    get disableProcessButton(){
        if(this.productCategory === PROD_CATEG_TAILORED){
            if(this.contacts && !this.hasRowError){
                return false;
            }
        }else{
            if(this.contacts && !this.hasRowError && this.pbEntryRecord){
                return false;
            }
        }
        return true;
    }

    get csvtemp(){
        return CSV_TEMP;
    }

    get headerTitle(){ return HEADER_TITLE; }
    get modalDescription(){ return DESCRIPTION; }
    get noteLabel(){ return NOTE_LABEL; }
    get noteLabelValue(){ return NOTE_LABEL_VALUE; }
    get totalNumPlacesLabel(){ return TOTAL_NUM_PLACES_LABEL; }
    get buttonDownloadLabel(){ return BUTTON_DOWNLOAD_LABEL; }
    get buttonCancelLabel(){ return BUTTON_CANCEL_LBL; }
    get buttonProceedLabel(){ return BUTTON_PROCEED_LBL; }
    get availableSeats(){ return this.availableSeats;}
    get standardHeaderLabel(){ return true;}
}