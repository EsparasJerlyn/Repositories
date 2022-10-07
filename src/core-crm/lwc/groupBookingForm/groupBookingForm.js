/**
 * @description A LWC component for group booking
 *
 * @see ../classes/GroupBookingFormCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                        |
      |---------------------------|-----------------------|----------------------|---------------------------------------|
      | julie.jane.alegre         | May 04, 2022          | DEPP-2070            | Created file                          |
      | julie.jane.alegre         | June 28, 2022         | DEPP-3313            | Fix modal sizing                      |
      | john.bo.a.pineda          | June 29, 2022         | DEPP-3323            | Modified to add logic to validate     |
      |                           |                       |                      | Upload File Type                      |
      | julie.jane.alegre         | July 28, 2022         | DEPP-3548            | Modified                              |
      | john.m.tambasen           | September 23, 2022    | DEPP-4367            | birthdate validation                  |
      | julie.jane.alegre         | September 29, 2022    |  DEPP-4471           | Add validation for available seats    |
*/
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from "@salesforce/user/Id";
import getQuestionsForGroupBooking from "@salesforce/apex/ProductDetailsCtrl.getQuestionsForGroupBooking";
import { getRecord } from "lightning/uiRecordApi";
import getCartItemsByCart from "@salesforce/apex/CartItemCtrl.getCartItemsByCart";
import getUserCartDetails from '@salesforce/apex/ProductDetailsCtrl.getUserCartDetails';
import saveBooking from '@salesforce/apex/GroupBookingFormCtrl.saveBooking';
import addCartItems from '@salesforce/apex/GroupBookingFormCtrl.addCartItems';
import removeCartItems from '@salesforce/apex/GroupBookingFormCtrl.removeCartItems';
import getAvailableSeats from '@salesforce/apex/GroupBookingFormCtrl.getAvailableSeats';
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import { loadStyle } from "lightning/platformResourceLoader";
import customSR from "@salesforce/resourceUrl/QUTInternalCSS";
import getMobileLocaleOptions from "@salesforce/apex/RegistrationFormCtrl.getMobileLocaleOptions";
import getUserMobileLocale from "@salesforce/apex/RegistrationFormCtrl.getUserMobileLocale";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import validateContactMatching from "@salesforce/apex/RegistrationMatchingHelper.validateContactMatching";
import { birthdateValidation } from 'c/commonUtils';

//Contact fields
const CONTACT_FIELDS = [
    "User.ContactId",
    "User.Contact.FirstName",
    "User.Contact.LastName",
    "User.Contact.Registered_Email__c"
  ];

export default class GroupBookingForm extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded
    isModalOpen = true;

    @api productDetails;
    @api selectedOffering;
    @api selectedProgramOffering;
    @api isPrescribed;
    @api priceBookEntry;


    productRequestId
    productId;
    courseOffering;
    accountId;
    cartId;
    availableSeats;

    @track templatePicklist = true;
    @track displayAccordion;
    @track numberOfParticipants;
    @track productCourseName;
    @track objectAPIName = 'Contact';
    @track contactId;
    @track minParticipants;
    @track maxParticipants;
    @track listOfdata = [];
    @track items = [];
    @track counter = 1;
    @track disableAddBtn;
    @track logUser= [];
    @track courseData;
    contactActId;
    @track con;
    @track regHeader=true;
    //registration Response variables
    isRespondQuestions;
    actResponseData;
    responseData2;
    questions;
    questions2 = [];
    contactFields;
    contactFieldsPrimary;
    answerRecords2;
    info;
    @track isDialogVisible = false;
    @track originalMessage;
    @track displayMessage = 'Click on the \'Open Confirmation\' button to test the dialog.';
    @track currentIndex = 1;
    @track isOpenPayment = false;
    @track fromCartSummary = false;
    @track disablePayment = false;
    @track total;  //total needed for payment
    @track cartExternalId;
    @track webStoreId;
    @track firstName;
    @track lastName;
    @track contactEmail;
    @track contactMobileLocale;
    @track amount;
    @track xString;
    @track questionsPrimary;

    localeOptions = [];
    localeDisplayName;
    localeConMobile;
    localeOptionsp1 = [];
    localeDisplayNamep1;
    localeConMobilep1;
    @track locale;
    @track localep1;
    hideMe = true;

    fieldsPrimary = {};
    contactMap = {};
    answerMap = {};
    fileUploadMap = {};
    emailToParticipantMap = {};
    cartItems;
    processing;
    /**
     * Payment Options
     */
    paymentOpt = [];
    @api hasPayNow;
    @api hasInvoice;
    cartItemsPbeUpdate = [];

    // Set Accepted File Formats
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', 'jpeg'];
    }

@wire(getRecord, { recordId: userId, fields: CONTACT_FIELDS })
    wiredContact({ error, data }) {
    //if data is retrieved successfully
    if (data) {
        //populate the variables
        this.contactId = data.fields.ContactId.value;
        this.firstName = data.fields.Contact.value.fields.FirstName.value;
        this.lastName = data.fields.Contact.value.fields.LastName.value;
        this.contactEmail = data.fields.Contact.value.fields.Registered_Email__c.value;


        getUserMobileLocale({userId: this.contactId})
        .then((result) => {
            this.localeConMobilep1 = result;
        })
        .catch((e)=> {

        });

        //else if error
    } else if (error) {
        this.error = error;

    }
}

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        removeCartItems({
            userId:userId
        })
        .then(()=>{
            this.dispatchEvent(
                new CustomEvent("cartchanged", {
                  bubbles: true,
                  composed: true
                })
              );
        })
        .catch((e) =>{
            this.error = e;
        })
        .finally(()=>{
            this.isModalOpen = false;
            this.templatePicklist = true;
            this.displayAccordion = false;
            this.numberOfParticipants = 0;
            this.listOfdata=[];
            this.items=[];
            this.disableAddBtn = false;
            this.counter = 1;
            this.num = 1;
            this.dispatchEvent(new CustomEvent('close'));
        })

    }

    getoptions(){

        for(let i=this.minParticipants; i<= this.maxParticipants;i++){
            this.listOfdata=[...this.listOfdata,{label: i.toLocaleString(), value: i}];
        }
        return this.listOfdata;
    }

    connectedCallback(){
        this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
        if(this.isPrescribed){
            this.productRequestId = this.productDetails.Program_Plan__r.Product_Request__c;
        }else{
            this.productRequestId = this.productDetails.Course__r.ProductRequestID__c;
           
        }
        this.productId = this.productDetails.Id;
        this.productCourseName = this.productDetails.Name;
        this.minParticipants = this.productDetails.Minimum_Participants_Group__c;
        this.maxParticipants =  this.productDetails.Maximum_Participants_Group__c;
        this.getoptions();
        getQuestionsForGroupBooking({
            productReqId: this.productRequestId
        })
        .then((results) => {
                if (results.length >= 0) {
                    if(results.length == 0){
                        this.regHeader = false;
                    }
                    this.responseData2 = results;
                    this.questions2= results;
                    this.questionsPrimary= this.formatQuestions(results);

                }

        })
        .catch((e) => {
            this.generateToast("Error.", LWC_Error_General, "warning", 'dismissable');
        });
        //get availableSeats
        getAvailableSeats({offeringId: this.selectedOffering, isPrescribed: this.isPrescribed})
        .then((results) => {
            this.availableSeats = results;
        })
        .catch((e)=> {
            console.log(e);
        });

        getUserCartDetails({
            userId: userId
          })
            .then((results) => {
                this.cartExternalId = results.External_Id__c;
                this.accountId = results.AccountId;
                this.cartId = results.Id;
            })
            .catch((e) => {
              this.generateToast("Error.", LWC_Error_General, "warning", 'dismissable');
        });

        // Get Locale Options
        getMobileLocaleOptions()
        .then((resultOptions) => {
            this.localeOptions = resultOptions;
            this.localeOptionsp1 = resultOptions;
            this.locale = this.localeConMobile;
            this.localep1 = this.localeConMobile;
        })
        .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "warning",'dismissable');
        });

    }

    handleFirstnameChange(event){
        this.firstName = event.detail.value;

    }
    handleLastnameChange(event){
        this.lastName = event.detail.value;
    }
    handleEmailChange(event){
        this.contactEmail = event.detail.value;
    }


    /*
    * Sets the mobile via event
    */
    handleLocaleChange(event) {
        this.localep1 = event.detail.value;
        this.localeDisplayName = event.detail.label;
        this.localeOptions.forEach((localeOption) => {
        if (localeOption.value === this.localep1) {
            this.localeConMobilep1 = localeOption.conMobileLocale;
        }
    });
    }

    // This handle the picklist for number of participants
    handleAfterPick(event){

        this.numberOfParticipants = event.detail.value;
        if(this.availableSeats >= this.numberOfParticipants){
                this.templatePicklist = false;
        }else{
            this.generateToast(
                'Error.',
                'There are no enough seats available to complete this transaction.',
                'warning',
                'dismissable'
            );
            this.templatePicklist = true;
            
        }
        

    }
    //This handle the change on accordion data
    updateOnAccordionDetails(event) {
        this.items[event.currentTarget.dataset.id][event.target.name] = event.target.value;
    }
    //This handle added participants
    addParticipant() {
    
        this.currentIndex = this.currentIndex + 1;
        //Contact list
        this.items = [...this.items,
            {
                id: this.items.length,
                FirstName: '',
                Email: '',
                Birthdate: '',
                LastName: '',
                ContactMobile_Locale__c: '',
                Mobile_No_Locale__c: '',
                Dietary_Requirement__c: '',
                Accessibility_Requirement__c: '',
                label: 'PARTICIPANT ' + this.currentIndex,
                Questions: this.formatQuestions(this.questions2,this.items.length),
                hasError: false,
                errorMessage:'',
                fieldsMismatch:[]
            }
            ];
        this.info = JSON.stringify(this.items);
        this.counter++;

        if(this.counter < this.numberOfParticipants){
            this.disableAddBtn = false;
        }
        else{
            this.disableAddBtn = true;
        }
        const accordion = this.template.querySelector('.example-accordion');
        this.xString='PARTICIPANT ' + this.currentIndex;
        setTimeout(() => {
            accordion.activeSectionName = this.xString;
        }, 100);
    }

    handleClick(event){

        if(event.target.name === 'openConfirmation'){
              //shows the component
             this.isDialogVisible = true;

        }else if(event.target.name === 'confirmModal'){
            //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
            if(event.detail !== 1){

                if(event.detail.status === 'confirm') {

                    this.items = this.items.filter(function (element) {
                        return parseInt(element.id) !== parseInt(event.target.accessKey);
                    });

                    this.counter--;
                    this.currentIndex = this.currentIndex - 1;
                    if(this.counter < this.numberOfParticipants){
                        this.disableAddBtn = false;

                    }
                    else{
                        this.disableAddBtn = true;
                    }
                }
                else if(event.detail.status === 'cancel'){
                }
            }
            //hides the component
            this.isDialogVisible = false;
        }
   }

    formatQuestions(items, counter){
        let questions2 = items.map(item =>{
            let newItem = {};
            let newOptions = [];
            newItem.Id = item.Id;
            if(item.Question__c){
                newItem.RowId = item.Question__r.Id + counter;
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
        return questions2;
       }


    handleRespondQuestions(){
        this.isRespondQuestions = true;
      }

    get disableSave(){
        let hasUnansweredQuestions = false;
        let formNotFilledOut = true;
        let hasNoParticipant = false;
        if(this.questionsPrimary && 
            this.questionsPrimary.filter((item) => item.Answer == '') && 
            this.questionsPrimary.filter((item) => item.Answer == '').length > 0){

                hasUnansweredQuestions = true;
        }

        if(this.items && this.items.length > 0){
            this.items.map((row) => {
                if( row.Questions && 
                    row.Questions.filter((key) => key.Answer == '') &&
                    row.Questions.filter((key) => key.Answer == '').length > 0){
                        hasUnansweredQuestions = true;
                    }
            })
        }else {
            hasNoParticipant = true;
        }
        
        let form = [...this.template.querySelectorAll('lightning-input'),
        ];
        
        if(form.length > 0){
            const allValid = [
                ...this.template.querySelectorAll('lightning-input'),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

            if(allValid){
                formNotFilledOut = false;
            }else{
                formNotFilledOut = true;
            }
        }
    
        return hasUnansweredQuestions || this.processing || hasNoParticipant ;
    }

 submitDetails() {
    const allValid = [
        ...this.template.querySelectorAll('lightning-input'),
    ].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);

    if (allValid && !this.checkForDuplicateEmails() && !this.checkDOB()) {
        if(this.numberOfParticipants == 1){
            this.processing = false;
            this.generateToast('Error.','Minimum participants for group booking is 2.','warning','dismissable');
        }
        else if(this.counter == this.numberOfParticipants){
            this.validateContact(this.setupContactDetailsData());
        }else{
            this.processing = false;
            this.generateToast(
                'Error.',
                'Please fill up all added participants before proceed.',
                'warning',
                'dismissable'
            );
        }
    }
}

processSaving(){
    removeCartItems({
        userId:userId
    })
    .then(()=>{
        this.dispatchEvent(
            new CustomEvent("cartchanged", {
                bubbles: true,
                composed: true
            })
        );
        return saveBooking({
            participants:this.contactMap,
            offeringId:this.selectedOffering,
            relatedAnswer:this.responseData2,
            answerMap:this.answerMap,
            fileUpload:this.fileUploadMap,
            isPrescribed: this.isPrescribed
        })
    })
    .then((result)=>{
        return addCartItems({
            productId:this.productId,
            productName:this.productCourseName,
            isPrescribed:this.isPrescribed,
            offeringId:this.selectedOffering,
            pricebookEntryId:this.priceBookEntry,
            pricebookUnitPrice:this.amount,
            userId:this.userId,
            contacts:result,
            cartId:this.cartId,
        })
    })
    .then(()=>{
        this.isOpenPayment = true;
        this.dispatchEvent(
            new CustomEvent("cartchanged", {
                bubbles: true,
                composed: true
            })
        );

        return getCartItemsByCart({
        cartId:this.cartId,
        userId:userId
        })
    })
    .then((result)=>{
        this.cartItems = JSON.parse(JSON.stringify(result.cartItemsList));
        this.processing = false;

        //checks payment options after remove
        this.paymentOptionButtons();
    })
    .catch((error)=>{
        this.processing = false;
        this.generateToast("Error.", LWC_Error_General, "warning", 'dismissable');
        console.log(error);

    })
}

checkForDuplicateEmails(){
    let emailArray = [];
    let hasDuplicate = false;

    emailArray.push(this.contactEmail);
    this.items.map(item =>{
        emailArray.push(item.Email);
    });

    this.items = this.items.map(item => {
        let record = item;
        if( emailArray.filter(obj => obj === record.Email) && 
            emailArray.filter(obj => obj === record.Email).length > 1){
            record.hasError = true;
            record.errorMessage = 'Duplicate emails found. Please review details provided.';
            hasDuplicate = true;
        }else{
            record.hasError = false;
            record.errorMessage = '';
        }
        return record;
    });

    if(hasDuplicate){
        this.generateToast(
            'Error.',
            'Error(s) found: Please review details provided.',
            'warning',
            'dismissable'
        );
    }

    return hasDuplicate;
   
}

checkDOB(){
    let hasInvalidDOB = false;

    this.items = this.items.map(item => {
        let record = item;
        if(!birthdateValidation(record.Birthdate)){
            record.hasError = true;
            record.errorMessage = 'Must be 15 years or older to register.';
            hasInvalidDOB = true;
        }else{
            record.hasError = false;
            record.errorMessage = '';
        }
        return record;
    });

    if(hasInvalidDOB){
        this.generateToast(
            'Error.',
            'Error(s) found: Please review details provided.',
            'warning',
            'dismissable'
        );
    }

    return hasInvalidDOB;
}

setupContactDetailsData(){

    this.fieldsPrimary.Id = this.contactId;
    this.fieldsPrimary["ContactMobile_Locale__c"] = this.localeConMobilep1;

    
    const inputFields = this.template.querySelectorAll(
        'lightning-input-field','lightning-combobox'
    );

    if (inputFields) {
        inputFields.forEach(field => {
            this.fieldsPrimary[field.fieldName] = field.value;
        });
        this.fieldsPrimary['MobilePhone'] = this.localeOptions.find( opt => opt.label === this.localeConMobilep1).countryCode + this.fieldsPrimary['Mobile_No_Locale__c'];
    }

    this.contactFieldsPrimary = this.fieldsPrimary;
    this.amount = this.productDetails.PricebookEntries.find(row => row.Id === this.priceBookEntry).UnitPrice,
    this.total = this.amount * this.numberOfParticipants;
    this.contactMap['PARTICIPANT 1'] = this.fieldsPrimary;
    this.answerMap['PARTICIPANT 1'] = this.createAnswerRecordPrimary();
    this.fileUploadMap['PARTICIPANT 1'] = JSON.stringify(this.createFileUploadMap());

    this.processing = true;
    let blankRow = this.items;
    let additionalContacts = [];

    for(let i = 0; i < blankRow.length; i++){
        if(blankRow[i] !== undefined){
            let conData = new Object();
            conData.Id = null;
            conData.FirstName = blankRow[i].FirstName;
            conData.LastName = blankRow[i].LastName;
            conData.Registered_Email__c = blankRow[i].Email;
            conData.Birthdate = blankRow[i].Birthdate;
            conData.ContactMobile_Locale__c = this.localeOptions.find( opt => opt.label === blankRow[i].ContactMobile_Locale__c).conMobileLocale;
            conData.Mobile_No_Locale__c = blankRow[i].Mobile_No_Locale__c;
            conData.MobilePhone = this.localeOptions.find( opt => opt.label === blankRow[i].ContactMobile_Locale__c).countryCode + blankRow[i].Mobile_No_Locale__c;
            conData.Dietary_Requirement__c = blankRow[i].Dietary_Requirement__c;
            conData.Accessibility_Requirement__c = blankRow[i].Accessibility_Requirement__c;
            this.emailToParticipantMap[blankRow[i].Email] = blankRow[i].label;
            this.contactMap[blankRow[i].label] = conData;
            additionalContacts.push(conData);
            let answerRecords = {};
            answerRecords = blankRow[i].Questions.map(row=>{
                let record = {};
                record.Related_Answer__c = row.Id;
                record.Response__c = row.Answer;
                record.Sequence__c = row.Sequence;
                return record;
            });
            this.answerMap[blankRow[i].label] = answerRecords;

            let fileUpload = [];
            fileUpload = blankRow[i].Questions.map(item =>{
                if(item.IsFileUpload){
                    let record = {};
                    record.RelatedAnswerId = item.Id;
                    record.Base64 = item.FileData.base64;
                    record.FileName = item.FileData.filename;
                    return record;
                }
            });
            this.fileUploadMap[blankRow[i].label] = JSON.stringify(fileUpload.filter(key => key !== undefined)?fileUpload.filter(key => key !== undefined):fileUpload);
        }
    }
    return additionalContacts;
}

validateContact(additionalContacts){
    
    validateContactMatching({newContactList:JSON.stringify(additionalContacts)})
    .then((result)=>{

        let hasMatchingError = false;
        let validationResult = result;

        validationResult.map(row => {
            if( row.isPartialMatch == false && 
                row.isEmailMatch == false){ //email and contact details did not match
                        this.items = this.items.map(item => {
                            let record = item;
                            if(record.Email === row.email ){
                                record.hasError = false;
                                record.errorMessage = '';
                                record.fieldsMismatch = [];
                            }
                            return record;
                        });
            }else if(   row.isPartialMatch == false && 
                        row.isEmailMatch == true){ //email and contact details matched
                        this.contactMap[this.emailToParticipantMap[row.email]].Id = row.contactRecord.Id;

                        this.items = this.items.map(item => {
                            let record = item;
                            if(record.Email === row.email ){
                                record.hasError = false;
                                record.errorMessage = '';
                                record.fieldsMismatch = [];
                            }
                            return record;
                        });
            }else if(   row.isPartialMatch == true &&
                        row.isEmailMatch == false){ //email did not match and contact details matched
                        this.items = this.items.map(item => {
                            let record = item;
                            if(record.Email === row.email ){
                                record.hasError = true;
                                record.errorMessage = 'The email address doesn’t match the contact details provided. Please contact QUTeX.';
                                record.fieldsMismatch = [];
                            }
                            return record;
                        });
                        this.processing = false;
                        hasMatchingError = true;
            }else if(   row.isPartialMatch == true && 
                        row.isEmailMatch == true){ //email match and contact details did not match   
                        this.items = this.items.map(item => {
                            let record = item;
                            if(record.Email === row.email ){
                                record.hasError = true;
                                record.errorMessage = 'Your personal details do not match with the email provided. Please check your details or contact QUTeX.';
                                record.fieldsMismatch = row.fieldsMismatch;
                            }
                            return record;
                        });
                        this.processing = false;    
                        hasMatchingError = true;                   
            } 
        }) 

        if(hasMatchingError){
            this.generateToast(
                'Error.',
                'Error(s) found: Please review details provided.',
                'warning',
                'dismissable'
            );
        }
        
        return hasMatchingError;
    })
    .then((result) =>{
        if(result === false){
            this.processSaving();
        }
    })
    .catch((error)=>{
       console.log(error);
       this.generateToast("Error.", LWC_Error_General, "warning", 'dismissable');
    })

}

paymentOptionButtons(){

    this.paymentOpt = this.productDetails.Payment_Options__c;

    if(this.paymentOpt == 'Pay Now'){
        this.hasPayNow = true;
    }
    else if(this.paymentOpt == 'Invoice'){
        this.hasInvoice = true;
    }
    else if(this.paymentOpt == 'Pay Now;Invoice'){
        this.hasPayNow = true;
        this.hasInvoice = true;
    }
    else{
        this.hasPayNow = false;
        this.hasInvoice = false;
    }

  }

createFileUploadMap(){
    let fileUpload = [];
    fileUpload = this.questionsPrimary.map(item =>{
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
    answerRecords = this.questionsPrimary.map(item =>{
        let record = {};
        record.Related_Answer__c = item.Id;
        record.Response__c = item.Answer;
        record.Sequence__c = item.Sequence;
        return record;
    });
    return answerRecords;

  }

  // Creates toast notification
  generateToast(_title, _message, _variant, _mode) {
    const evt = new ShowToastEvent({
      title: _title,
      message: _message,
      variant: _variant,
      mode:_mode
    });
    this.dispatchEvent(evt);
  }

  handleChange(event){
    this.items = this.items.map(item=>{
        let tempItem = item;
            
            tempItem.Questions = tempItem.Questions.map(row=>{
                let tempRow = row;
                if(event.target.dataset.rowId === tempRow.RowId && tempRow.IsCheckbox){ //checkbox
                    tempRow.Answer = event.detail.checked.toString();
                }else if(event.target.dataset.rowId === tempRow.RowId && tempRow.IsFileUpload){  //fileupload
                    tempRow.Answer = event.detail.value.toString();
                    const file = event.target.files[0];
                    let fileNameParts = file.name.split('.');
                    let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
                    if (this.acceptedFormats.includes(extension)) {
                        let reader = new FileReader();
                        reader.onload = () => {
                            let base64 = reader.result.split(',')[1];
                            tempRow.FileData = {
                                'filename': file.name,
                                'base64': base64,
                                'recordId': undefined
                            };
                        }
                        reader.readAsDataURL(file);
                    } else {
                        tempRow.Answer = '';
                        tempRow.FileData = undefined;
                        this.generateToast('Error.','Invalid File Format.','warning','dismissable');
                    }
                }else if(event.target.dataset.rowId === tempRow.RowId && tempRow.IsMultiPicklist){  //picklist
                    tempRow.Answer = event.detail.value?event.detail.value.toString().replace(/,/g, ';'):tempRow.Answer;
                }else if(event.target.dataset.rowId === tempRow.RowId){   //textbox
                    tempRow.Answer = event.detail.value?event.detail.value.toString():tempRow.Answer;
                }
                return tempRow;
            });
        return tempItem;    
    });
  }

  handleBlur(event){
    this.items.Questions = this.items.Questions.map(row=>{
        if(row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase()){
            row.Answer = '';
            row.ErrorMessage = row.Message?row.Message:'You are not qualified to proceed with registration.';
        }else if(row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() == row.MandatoryResponse.toUpperCase()){
            row.ErrorMessage = '';
        }
        return row;
    });
  }

  handleChangePrimary(event){
    this.questionsPrimary = this.questionsPrimary.map(row=>{
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
                this.generateToast('Error.','Invalid File Format.','error','dismissable');
            }
        }else if(event.target.name === row.Id && row.IsMultiPicklist){
            row.Answer = event.detail.value?event.detail.value.toString().replace(/,/g, ';'):row.Answer;
        }else if(event.target.name === row.Id){
            row.Answer = event.detail.value?event.detail.value.toString():row.Answer;
        }
        return row;
    });
  }

  handleBlurPrimary(){
    this.questionsPrimary = this.questionsPrimary.map(row=>{
        if(row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase()){
            row.Answer = '';
            row.ErrorMessage = row.Message?row.Message:'You are not qualified to proceed with registration.';
        }else if(row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() == row.MandatoryResponse.toUpperCase()){
            row.ErrorMessage = '';
        }
        return row;
    });
  }

  createAnswerRecordPrimary(){
    let answerRecords = {};
    answerRecords = this.questionsPrimary.map(item =>{
        let record = {};
        record.Related_Answer__c = item.Id;
        record.Response__c = item.Answer;
        record.Sequence__c =item.Sequence;
        return record;
    });
    return answerRecords;
  }

  renderedCallback() {
    Promise.all([loadStyle(this, customSR + "/QUTInternalCSS.css")]);
  }
 
}