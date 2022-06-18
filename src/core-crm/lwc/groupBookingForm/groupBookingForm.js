import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import userId from "@salesforce/user/Id";
import getQuestionsForGroupBooking from "@salesforce/apex/ProductDetailsCtrl.getQuestionsForGroupBooking";
import addRegistration from '@salesforce/apex/ProductDetailsCtrl.addRegistration';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ACCOUNT_ID from '@salesforce/schema/Contact.AccountId';
import insertContactData from '@salesforce/apex/ProductDetailsCtrl.saveContactData';
import getContactAccountId from '@salesforce/apex/ProductDetailsCtrl.getContactAccountId';
import getUserContactDetails from '@salesforce/apex/ProductDetailsCtrl.getUserContactDetails';
import getUserCartDetails from '@salesforce/apex/ProductDetailsCtrl.getUserCartDetails';
import addToCartItem from '@salesforce/apex/ProductDetailsCtrl.addToCartItem';
import getPricebookEntryPrice from '@salesforce/apex/ProductDetailsCtrl.getPricebookEntryPrice';
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import communityId from "@salesforce/community/Id";
import { loadStyle } from "lightning/platformResourceLoader";
import customSR from "@salesforce/resourceUrl/QUTInternalCSS";

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
    @track isModalOpen;
    @api productDetails;
    @api selectedCourseOffering;
    @api selectedProgramOffering;
    @api isPrescribed;
    @track productId;
    @track ProductRequestID;
    @track courseOffering;
    @api priceBookEntry;
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
    saveInProgress = false;
    @track isOpenPayment = false;
    @track fromCartSummary = false;
    @track disablePayment = false;
    @track total;  //total needed for payment 
    @track cartExternalId;
    @track cartId;
    @track webStoreId;
    @track firstName;
    @track lastName;
    @track contactEmail;
    @track amount;
    @track xString;
    
  //get contact data
  @wire(getRecord, { recordId: userId, fields: CONTACT_FIELDS })
  wiredContact({ error, data }) {
    //if data is retrieved successfully
    if (data) {
      //populate the variables
      this.contactId = data.fields.ContactId.value;
      this.firstName = data.fields.Contact.value.fields.FirstName.value;
      this.lastName = data.fields.Contact.value.fields.LastName.value;
      this.contactEmail = data.fields.Contact.value.fields.Email.value;
      //else if error
    } else if (error) {
      this.error = error;
    }
  } 

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
      
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
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
    }
    
   //Create a list of accepted number of Participants
    get options(){
        
        for(let i=this.minParticipants; i<= this.maxParticipants;i++){
            this.listOfdata=[...this.listOfdata,{label: i.toLocaleString(), value: i}];
        }
        return this.listOfdata;
    }
    
    connectedCallback() {

        this.isModalOpen = true;
        this.productId = this.productDetails.Id;
        this.productCourseName = this.productDetails.Name;
   
        if(this.isPrescribed){
            this.minParticipants = this.productDetails.Program_Plan__r.Minimum_Participants__c;
            this.maxParticipants =  this.productDetails.Program_Plan__r.Maximum_Participants__c;
            this.ProductRequestID = this.productDetails.Program_Plan__r.Product_Request__c;
            this.courseOffering = this.selectedProgramOffering;
        }else{
            this.minParticipants = this.productDetails.Course__r.Minimum_Participants__c;
            this.maxParticipants =  this.productDetails.Course__r.Maximum_Participants__c;
            this.ProductRequestID = this.productDetails.Course__r.ProductRequestID__c;
            this.courseOffering = this.selectedCourseOffering;
        }
       
        //Get the Price of the selected course/program from pricebook entry
        getPricebookEntryPrice({
            pricebookId:this.priceBookEntry
        })
        .then((results) => {
               
            this.amount = results.UnitPrice;
          
        })
        .catch((e) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        });

        // Get the relayed Account of the Contact
        getContactAccountId({
            connId: this.contactId
        })
        .then((results) => {
            if (results.length > 0) {
                this.actResponseData = results;
                this.contactActId = this.actResponseData[0].AccountId; 
            }
        })
        .catch((e) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        });

        //Get the related Registration Question 
        getQuestionsForGroupBooking({
            productReqId: this.ProductRequestID
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
        //Get the external Id from the cart
        getUserCartDetails({
            userId: userId
          })
            .then((results) => {
              
                this.cartExternalId = results.External_Id__c;
              
            })
            .catch((e) => {
              this.generateToast("Error.", LWC_Error_General, "error");
            });
           

    }
  
    getQuestionsList(){
        this.responseData = getQuestionsForGroupBooking();
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

  get hasQuestions(){
        return this.questions && this.questions.length > 0?true:false;
   }

   submitDetails(event) {
    const allValid = [
        ...this.template.querySelectorAll('lightning-input'),
    ].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);

    if (allValid) {
        this.template.querySelectorAll("lightning-record-edit-form").forEach((form) => {form.submit();});
        if(this.counter == this.numberOfParticipants){
            let fieldsPrimary = {};
            fieldsPrimary.Id = this.contactId;
            this.contactFieldsPrimary = fieldsPrimary;
            this.total = this.amount * this.numberOfParticipants;
            
            this.saveRegistration(this.contactFieldsPrimary, this.courseOffering,this.responseData2, this.createAnswerRecordPrimary() ,JSON.stringify(this.createFileUploadMap())); 
                let blankRow = this.items;
                let contactDataList = [];
                for(let i = 0; i < blankRow.length; i++){
                    if(blankRow[i] !== undefined){
                        let conData = new Object();
                        conData.FirstName = blankRow[i].FirstName;
                        conData.LastName = blankRow[i].LastName;
                        conData.Email = blankRow[i].Email;
                        conData.Birthdate = blankRow[i].Birthdate;
                        conData.MobilePhone = blankRow[i].MobilePhone;
                        conData.Dietary_Requirement__c = blankRow[i].Dietary_Requirement__c;    
                        contactDataList.push(conData);
                    }
                }
                if(contactDataList.length > 0){
                    insertContactData({contactDataString: JSON.stringify(contactDataList)}).then(result => {
                        for(let i = 0; i < result.length; i++){
                            if(result[i] !== undefined){
                                let contactRecord = {'sobjectType' : 'Contact'};
                                contactRecord.Id = result[i].Id; //newly created contact ID
                                contactRecord.FirstName = result[i].FirstName;
                                contactRecord.LastName = result[i].LastName;
                                contactRecord.AccountId = result[i].AccountId;
        
                                let fields = {};
                                fields.Id = result[i].Id;
                                this.contactFields = fields;
        
                                let ItemsRecords = {};
                                ItemsRecords = this.items.map(item=>{  
        
                                    if (blankRow[i].id == item.id){
        
                                        let answerRecords = {};
                                        answerRecords = item.Questions.map(row=>{
                                            let record = {};
                                            record.Related_Answer__c = row.Id;
                                            record.Response__c = row.Answer;
                                            record.Sequence__c = row.Sequence;
                                            return record;                                  
                                        });
                                        this.answerRecords2 =  answerRecords;
                                    
                                    }
                                    return item;
                                });
        
                                this.saveRegistration(this.contactFields, this.courseOffering,this.responseData2, this.answerRecords2 ,JSON.stringify(this.createFileUploadMap()));
        
                            }
                            this.generateToast(SUCCESS_TITLE, 'Successfully Submitted', SUCCESS_VARIANT);
                            this.isOpenPayment = true;
                            this.createCartItem(
                                communityId,
                                this.productId,
                                this.contactActId,
                                this.productCourseName,
                                this.selectedCourseOffering,
                                this.selectedProgramOffering,
                                pricebookEntry,
                                userId);
                          
                        }
                    }).catch(error => {
                    })
                }else{
    
                }
    
    
        }
        else{
    
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

createFileUploadMap(){
    let fileUpload = [];
    fileUpload = this.questions2.map(item =>{
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

saveRegistration(contact,courseOffering,relatedAnswer,answer,fileUpload){
    addRegistration({
        contactRecord:contact,
        courseOfferingId:courseOffering,
        relatedAnswerList:relatedAnswer,
        answerList:answer,
        fileUpload:fileUpload,
        forApplication:false
    })
    .then(() =>{
            this.generateToast(SUCCESS_TITLE, 'Successfully Submitted', SUCCESS_VARIANT);
            refreshApex(this.tableData);
            
    })
    .finally(()=>{

    })
    .catch(error =>{
       
    });
  }

  get labelValue(){
    return 'PARTICIPANT ' + this.currentIndex;
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

  createCartItem(communityId,productId,effectiveAccountId,productName,courseOfferingId,programOfferingId,pricebookEntryId,userId){
      
    addToCartItem({
         communityId: communityId,
         productId: productId ,
         effectiveAccountId:effectiveAccountId,
         productName:productName,
         courseOfferingId: courseOfferingId,
         programOfferingId: programOfferingId,
         pricebookEntryId: pricebookEntryId,
         userId: userId
    })
    .then(() =>{
            this.generateToast(SUCCESS_TITLE, 'Successfully Submitted', SUCCESS_VARIANT);
            refreshApex(this.tableData);
          
    })
    .finally(()=>{

    })
    .catch(error =>{
       
    });
  }
  
  renderedCallback() {
    Promise.all([loadStyle(this, customSR + "/QUTInternalCSS.css")]);
  }
}