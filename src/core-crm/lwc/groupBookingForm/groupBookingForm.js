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
*/
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import userId from "@salesforce/user/Id";
import getQuestionsForGroupBooking from "@salesforce/apex/ProductDetailsCtrl.getQuestionsForGroupBooking";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getCartItemsByCart from "@salesforce/apex/CartItemCtrl.getCartItemsByCart";
import ACCOUNT_ID from '@salesforce/schema/Contact.AccountId';
import insertContactData from '@salesforce/apex/ProductDetailsCtrl.saveContactData';
import getContactAccountId from '@salesforce/apex/ProductDetailsCtrl.getContactAccountId';
import getUserContactDetails from '@salesforce/apex/ProductDetailsCtrl.getUserContactDetails';
import getUserCartDetails from '@salesforce/apex/ProductDetailsCtrl.getUserCartDetails';
import saveBooking from '@salesforce/apex/GroupBookingFormCtrl.saveBooking';
import addCartItems from '@salesforce/apex/GroupBookingFormCtrl.addCartItems';
import removeCartItems from '@salesforce/apex/GroupBookingFormCtrl.removeCartItems';
import getPricebookEntryPrice from '@salesforce/apex/ProductDetailsCtrl.getPricebookEntryPrice';
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import communityId from "@salesforce/community/Id";
import { loadStyle } from "lightning/platformResourceLoader";
import customSR from "@salesforce/resourceUrl/QUTInternalCSS";
import getMobileLocaleOptions from "@salesforce/apex/RegistrationFormCtrl.getMobileLocaleOptions";
import getUserMobileLocale from "@salesforce/apex/RegistrationFormCtrl.getUserMobileLocale";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";

const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
//Contact fields
const CONTACT_FIELDS = [
    "User.ContactId",
    "User.Contact.FirstName",
    "User.Contact.LastName",
    "User.Contact.Email"
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
    cartItems;
    processing;
    
    localeOptions = [];
    localeDisplayName;
    localeConMobile;
    @track locale;
    /**
     * Payment Options
     */
    paymentOpt = [];
    @api hasPayNow;
    @api hasInvoice;
    

@wire(getRecord, { recordId: userId, fields: CONTACT_FIELDS })
    wiredContact({ error, data }) {
    //if data is retrieved successfully
    if (data) {
        //populate the variables
        this.contactId = data.fields.ContactId.value;
        this.firstName = data.fields.Contact.value.fields.FirstName.value;
        this.lastName = data.fields.Contact.value.fields.LastName.value;
        this.contactEmail = data.fields.Contact.value.fields.Email.value;
        

        getUserMobileLocale({userId: this.contactId})
        .then((result) => {
            this.localeConMobile = result;
            
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
    
    get options(){
        
        for(let i=this.minParticipants; i<= this.maxParticipants;i++){
            this.listOfdata=[...this.listOfdata,{label: i.toLocaleString(), value: i}];
        }
        return this.listOfdata;
    }
    
    connectedCallback(){
        this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
        if(this.isPrescribed){
            this.productRequestId = this.productDetails.Program_Plan__c.Product_Request__c;
           
        }else{
            this.productRequestId = this.productDetails.Course__r.ProductRequestID__c;
        }
        
        this.productId = this.productDetails.Id;
        this.productCourseName = this.productDetails.Name;
        this.minParticipants = this.productDetails.Minimum_Participants_Group__c;
        this.maxParticipants =  this.productDetails.Maximum_Participants_Group__c;

        getQuestionsForGroupBooking({
            productReqId: this.productRequestId
        })
        .then((results) => {
                if (results.length >= 0) {
                    if(results.length == 0){
                        this.regHeader = false;
                    }
                    this.responseData2 = results;
                    this.questions2= this.formatQuestions(results);
                    this.questionsPrimary= this.formatQuestions(results);

                }
                
        })
        .catch((e) => {
            this.generateToast("Error.", LWC_Error_General, "error");
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
              this.generateToast("Error.", LWC_Error_General, "error");
        });

        // Get Locale Options
        getMobileLocaleOptions()
        .then((resultOptions) => {
            this.localeOptions = resultOptions;
            this.locale = this.localeConMobile;
        })
        .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "error");
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
        this.locale = event.detail.value;
        this.localeDisplayName = event.detail.label;
        this.localeOptions.forEach((localeOption) => {
        if (localeOption.value === this.locale) {
            this.localeConMobile = localeOption.conMobileLocale;
            }
        });

    }

     // This handle the picklist for number of participants
     handleAfterPick(event){
        
        this.numberOfParticipants = event.detail.value;
        if(this.numberOfParticipants == this.counter){
            this.disableAddBtn = true;
        }
        if(this.numberOfParticipants != null){
            this.templatePicklist = false;
           
        }
      
    }
    //This handle the change on accordion data
    updateOnAccordionDetails(event) {
        if(event.target.name === 'ContactMobile_Locale__c'){
            this.locale = event.target.value;
            this.localeOptions.forEach((localeOption) => {
            if (localeOption.value === this.locale) {
                this.localeConMobile = localeOption.conMobileLocale;
                }
            });
            this.items[event.currentTarget.dataset.id][event.target.name] = this.localeConMobile;
         
        } else {
            this.items[event.currentTarget.dataset.id][event.target.name] = event.target.value;
        }        
        
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
                MobilePhone: '',
                Dietary_Requirement__c: '',
                label: 'PARTICIPANT ' + this.currentIndex, 
                Questions: this.questions2
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

    formatQuestions(items){
        let questions2 = items.map(item =>{
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
        return questions2;
       }


    handleRespondQuestions(){
        this.isRespondQuestions = true;
      }


   submitDetails(event) {
    const allValid = [
        ...this.template.querySelectorAll('lightning-input'),
    ].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);

    if (allValid) {

        if(this.numberOfParticipants == 1){
            this.processing = false;
            const evt = new ShowToastEvent({
                            title: 'Toast Error',
                            message: 'Minimum participants for group booking is 2.',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
        }
        else{

            if(this.counter == this.numberOfParticipants){
            
                let fieldsPrimary = {};
                let contactMap = {};
                let answerMap = {};
                let fileUploadMap = {};
    
                fieldsPrimary.Id = this.contactId;
                const inputFields = this.template.querySelectorAll(
                    'lightning-input-field','lightning-combobox'
                );
        
                if (inputFields) {
                    inputFields.forEach(field => {
                        fieldsPrimary[field.fieldName] = field.value;
                    });
                }
    
                this.contactFieldsPrimary = fieldsPrimary;
                this.amount = this.productDetails.PricebookEntries.find(row => row.Id === this.priceBookEntry).UnitPrice,
                this.total = this.amount * this.numberOfParticipants;
    
                contactMap['PARTICIPANT 1'] = fieldsPrimary;
                answerMap['PARTICIPANT 1'] = this.createAnswerRecordPrimary();
                fileUploadMap['PARTICIPANT 1'] = JSON.stringify(this.createFileUploadMap());
    
                this.processing = true;
                    let blankRow = this.items;
                    for(let i = 0; i < blankRow.length; i++){
                        if(blankRow[i] !== undefined){
                            let conData = new Object();
                            conData.FirstName = blankRow[i].FirstName;
                            conData.LastName = blankRow[i].LastName;
                            conData.Email = blankRow[i].Email;
                            conData.Birthdate = blankRow[i].Birthdate;
                            conData.ContactMobile_Locale__c = blankRow[i].ContactMobile_Locale__c; 
                            conData.MobilePhone = blankRow[i].MobilePhone;
                            conData.Dietary_Requirement__c = blankRow[i].Dietary_Requirement__c;    
                            contactMap[blankRow[i].label] = conData;
                            let answerRecords = {};
                            answerRecords = blankRow[i].Questions.map(row=>{
                                let record = {};
                                record.Related_Answer__c = row.Id;
                                record.Response__c = row.Answer;
                                record.Sequence__c = row.Sequence;
                                return record;                                  
                            });
                            answerMap[blankRow[i].label] = answerRecords;
    
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
                            fileUploadMap[blankRow[i].label] = JSON.stringify(fileUpload.filter(key => key !== undefined)?fileUpload.filter(key => key !== undefined):fileUpload);
    
                        }
                    }
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
                        saveBooking({
                            participants:contactMap,
                            offeringId:this.selectedOffering,
                            relatedAnswer:this.responseData2,
                            answerMap:answerMap,
                            fileUpload:fileUploadMap,
                            isPrescribed: this.isPrescribed
                        }).then((result)=>{
                            addCartItems({
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
                            .then(() => {
                                
                                this.isOpenPayment = true;
                                this.dispatchEvent(
                                    new CustomEvent("cartchanged", {
                                      bubbles: true,
                                      composed: true
                                    })
                                  );
            
                                  getCartItemsByCart({
                                    cartId:this.cartId,
                                    userId:userId
                                  })
                                  .then((result) => {
                                    this.cartItems = JSON.parse(JSON.stringify(result.cartItemsList));
                                    this.processing = false;
                                   
                                    //checks payment options after remove
                                    this.paymentOptionButtons();
                                  })
                            })
                        }).catch((error)=>{
                            this.processing = false;
                           
                        })
                    })
                    .catch((e) =>{
                        this.processing = false;
                       
                    })
    
            }
            else{
    
                this.processing = false;
                const evt = new ShowToastEvent({
                                title: 'Toast Error',
                                message: 'Please fill up all added participants before proceed',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
            }
    
        }
            
        }
       
   
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
  generateToast(_title, _message, _variant) {
    const evt = new ShowToastEvent({
      title: _title,
      message: _message,
      variant: _variant
    });
    this.dispatchEvent(evt);
  }

  handleChange(event){
    this.items = this.items.map(item=>{  
        if (event.target.dataset.contactId == item.id){

            Questions = item.Questions.map(row=>{
                if(event.target.dataset.questionId === row.Id && row.IsCheckbox){ //checkbox
                    row.Answer = event.detail.checked.toString();
                }else if(event.target.dataset.questionId === row.Id && row.IsFileUpload){  //fileupload
                    row.Answer = event.detail.value.toString();
                    const file = event.target.files[0];
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
                }else if(event.target.dataset.questionId === row.Id && row.IsMultiPicklist){  //picklist
                    row.Answer = event.detail.value?event.detail.value.toString().replace(/,/g, ';'):row.Answer;
                }else if(event.target.dataset.questionId === row.Id){   //textbox
                    row.Answer = event.detail.value?event.detail.value.toString():row.Answer;
                }
                return row;
            });
        }
        return item;
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