import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import userId from "@salesforce/user/Id";
import getQuestionsForGroupBooking from "@salesforce/apex/ProductDetailsCtrl.getQuestionsForGroupBooking";
import addRegistration from '@salesforce/apex/ProductDetailsCtrl.addRegistration';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import ACCOUNT_ID from '@salesforce/schema/Contact.AccountId';
import insertContactData from '@salesforce/apex/ProductDetailsCtrl.saveContactData';
import getContactAccountId from '@salesforce/apex/ProductDetailsCtrl.getContactAccountId';
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";

const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';

export default class GroupBookingForm extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen;
    @api productDetails;
    @api selectedCourseOffering;
   // @api questionsTemp;
    @api newproductid;
    @track templatePicklist = true;
    @track numberOfParticipants;
    @track productCourseName;
    @track objectAPIName = 'Contact';
    @api contactId;// 003Bo000000sP1UIAU
 
    @track minParticipants;
    @track maxParticipants;
    @track listOfdata = [];
    @track items = [];
    @track counter = 1;
    @track disableAddBtn;
    @track logUser= [];
    @track courseData;
    contactActId;
    //@track questionsTemp = [];
    @track con;
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
    
    
    @wire(getRecord, { recordId: userId, fields: [CONTACT_ID] })
    user;
    get contactId() {
      return getFieldValue(this.user.data, CONTACT_ID);
    }


    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
      
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.templatePicklist = true;
        this.numberOfParticipants = 0;
        this.listOfdata=[];
        this.items=[];
        this.disableAddBtn = false;
        this.counter = 1;
        //this.questions = [];
        this.num = 1;

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
        this.productCourseName = this.productDetails.Name;
        this.minParticipants = this.productDetails.Course__r.Minimum_Participants__c;
        this.maxParticipants =  this.productDetails.Course__r.Maximum_Participants__c;
        console.log('CONTACT ID new: '+ this.contactId);
        console.log('productDetails: '+ JSON.stringify(this.productDetails));
        console.log('Course ID: '+ JSON.stringify(this.productDetails.Course__r.Id));
        console.log('Minimum: '+ JSON.stringify(this.productDetails.Course__r.Minimum_Participants__c));
        console.log('Maximum: ' + JSON.stringify(this.productDetails.Course__r.Maximum_Participants__c));
        console.log('selectedCourseOffering: '+ this.selectedCourseOffering);
        
        getContactAccountId({
            connId: this.contactId
          })
            .then((results) => {
                console.log('Account Id...'); 
              if (results.length > 0) {
                    this.actResponseData = results;
                    this.contactActId = this.actResponseData[0].AccountId;
                    console.log('Account Id: '+ this.contactActId); 
                 //console.log('responseData 1: '+ JSON.stringify(this.responseData)); 
                //console.log('responseData 2: '+ JSON.stringify(this.responseData[0].AccountId));
               // this.contactActId = JSON.parse(JSON.stringify(this.responseData[0].AccountId));
                  //alert('===slected record details==='+JSON.stringify(this.responseData[0].AccountId));    
              }
            })
            .catch((e) => {
              this.generateToast("Error.", LWC_Error_General, "error");
            });


            // let fields = {};
            // fields.Id = this.contactId;//003Bo000000sP1UIAU
            // //fields.Id = "003Bo000000sP1UIAU";//003Bo000000sP1UIAU
            // console.log('CONTACT fields: '+ this.contactId);
            // this.contactFields = fields;
            // if (this.hasQuestions) {
            //     this.handleRespondQuestions();
            //     console.log('SHOW Questions');
            // }   
            
            // getCourseDetails({
            //     courseOffId: this.productDetails.Course__r.Id
            //   })
            //     .then((results) => {
            //       if (results.length > 0) {
            //             this.courseData = results; 
            //             console.log("COURSE DETAILS------>" + JSON.stringify(this.courseData));
            //       }
            //     })
            //     .catch((e) => {
            //       this.generateToast("Error.", LWC_Error_General, "error");
            //     });                      


    }
  
    getQuestionsList(){
        this.responseData = getQuestionsForGroupBooking();
    }

     // This handle the picklist for number of participants
    async handleAfterPick(event){

        console.log('ACT ID: '+ this.contactActId);
        getQuestionsForGroupBooking({
            productReqId: this.productDetails.Course__r.ProductRequestID__c
         
          })
            .then((results) => {
              if (results.length > 0) {
                    this.responseData2 = results;
                    
                    //this.questions2 = this.formatQuestions(results);
                    this.questions2= this.formatQuestions(results);
                    this.questionsPrimary= this.formatQuestions(results);
                   console.log('question array: '+ JSON.stringify(this.questions2));  
                   // console.log('responseData: '+ JSON.stringify(this.responseData.LastName)); 
                   // console.log('questionsTemp: '+ JSON.stringify(this.questionsTemp));
  
              }
            })
            .catch((e) => {
              this.generateToast("Error.", LWC_Error_General, "error");
            });


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
      //  this.info = JSON.stringify(this.items);
       // console.log('LIST OF CONTACTS: ' + this.info);
    }
    //This handle added participants
    addParticipant() {

        this.currentIndex = this.currentIndex + 1;   
        //Contact list
        this.items = [...this.items, 
            { 
                id: this.items.length, //key
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
        console.log('Current Index: ' + this.currentIndex);    
        this.info = JSON.stringify(this.items);
        console.log('LIST: ' + this.info);
        //this.info = JSON.stringify(this.questions2);
        //console.log('questions array: ' + this.info);
        this.counter++;
        console.log('COUNTER: ' + this.counter , this.numberOfParticipants);
        //console.log("Product Details ------->: " + JSON.stringify(this.productDetails));
        

        if(this.counter < this.numberOfParticipants){
            this.disableAddBtn = false;
        }
        else{
            this.disableAddBtn = true;
        }
    }

    handleClick(event){
    
        if(event.target.name === 'openConfirmation'){
            //it can be set dynamically based on your logic
            //this.originalMessage = 'test message';
            //shows the component

            this.isDialogVisible = true;

        }else if(event.target.name === 'confirmModal'){

            //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
            if(event.detail !== 1){
                //gets the detail message published by the child component
                //this.displayMessage = 'Status: ' + event.detail.status + '. Event detail: ' + JSON.stringify(event.detail.originalMessage) + '.';
               
                if(event.detail.status === 'confirm') {

                    this.items = this.items.filter(function (element) {
                        console.log('=====' + parseInt(event.target.accessKey));
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
                    console.log('----' + JSON.stringify(this.items));
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
    // to close modal set isModalOpen tarck value as false
    //Add your code to call apex method or do some processing
    // this.saveInProgress = true;
    console.log("test 001:"+ JSON.stringify(this.items));
    //save answer for Primary contact
    let fieldsPrimary = {};
    fieldsPrimary.Id = this.contactId;
    this.contactFieldsPrimary = fieldsPrimary;

    this.saveRegistration(this.contactFieldsPrimary, this.selectedCourseOffering,this.responseData2, this.createAnswerRecordPrimary() ,JSON.stringify(this.createFileUploadMap())); 
        let blankRow = this.items;
        let contactDataList = [];
        for(let i = 0; i < blankRow.length; i++){
            if(blankRow[i] !== undefined){
                let conData = new Object();
                //console.log("account id2");
               // console.log('for save line 1: ' + blankRow[i].FirstName);
               // console.log('for save line: ' + JSON.stringify(blankRow[i].FirstName));
                conData.AccountId =  this.contactActId; 
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
            console.log('processing insert..');
            insertContactData({contactDataString: JSON.stringify(contactDataList)}).then(result => {
                for(let i = 0; i < result.length; i++){
                    if(result[i] !== undefined){
                        let contactRecord = {'sobjectType' : 'Contact'};
                        console.log('insert...done');
                        contactRecord.Id = result[i].Id; //newly created contact ID
                        contactRecord.FirstName = result[i].FirstName;
                        contactRecord.LastName = result[i].LastName;
                        contactRecord.AccountId = result[i].AccountId;

                        let fields = {};
                        fields.Id = result[i].Id;
                        this.contactFields = fields;

                        let ItemsRecords = {};
                        ItemsRecords = this.items.map(item=>{  
                            console.log("item.Id: "+JSON.stringify(item.id)); 
                            console.log("blankRow Id: "+blankRow[i].id); 
                    
                            if (blankRow[i].id == item.id){
                                console.log("test 1b");

                                let answerRecords = {};
                                answerRecords = item.Questions.map(row=>{
                                    console.log("test 1b -> row.Id: "+row.Id); 
                                    let record = {};
                                    record.Related_Answer__c = row.Id;
                                    record.Response__c = row.Answer;
                                    record.Sequence__c = row.Sequence;
                                    return record;                                  
                                });
                                this.answerRecords2 =  answerRecords;
                                console.log('answerRecords2 [' + i +'] ->'+JSON.stringify(this.answerRecords2));
                            }
                            return item;
                        });

                        this.saveRegistration(this.contactFields, this.selectedCourseOffering,this.responseData2, this.answerRecords2 ,JSON.stringify(this.createFileUploadMap()));                      
                        console.log("account id from database: "+JSON.stringify(result[i].AccountId));
                        console.log("contact id from database: "+JSON.stringify(result[i].Id));
                        console.log("contactFields data: "+JSON.stringify(this.contactFields));
                        console.log("selectedCourseOffering data: "+JSON.stringify(this.selectedCourseOffering));
                        console.log("reponse data: "+JSON.stringify(this.responseData2));
                       // console.log("Answer data: "+JSON.stringify(this.createAnswerRecord()));
                       
                    }
                    this.generateToast(SUCCESS_TITLE, 'Successfully Submitted', SUCCESS_VARIANT);
                    console.log('Submitted');
                    this.isOpenPayment = true;
                    
                }
            }).catch(error => {
                // window.alert('Please contact system admin: ' + error);
                console.log("event.target.contactId: "+JSON.stringify(error));
            })
        }else{
            //window.alert('Please select any row to insert data.');
        }
        
        // this.saveInProgress = false;
  // this.isModalOpen = false;
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
        fileUpload:fileUpload
    })
    .then(() =>{
            this.generateToast(SUCCESS_TITLE, 'Successfully Submitted', SUCCESS_VARIANT);
            refreshApex(this.tableData);
            
    })
    .finally(()=>{
        // this.saveInProgress = false;
        // this.isModalOpen = false;
        // this.isEditContact = false;
        // this.isAddContact = false;
        // this.isCreateContact = false;
        // this.isLoading = false;
        // this.saveInProgress = false;
        // this.contactId2 = '';
        // this.contactSearchItems = [];
    })
    .catch(error =>{
       // this.generateToast('Error.',LWC_Error_General,'error');
       
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
    console.log("handleChange dataset 1: "+JSON.stringify(event.target.dataset.contactId));  
    console.log("handleChange dataset 2: "+JSON.stringify(event.target.dataset.questionId));  
    console.log("event.target.questionId: "+JSON.stringify(event.target.questionId)); 
    console.log("event.target.contactId: "+JSON.stringify(event.target.contactId)); 
    console.log('UPDATE ITEMS 1: ' + JSON.stringify( event.target.value));  
    console.log('UPDATE ITEMS 2: ' + JSON.stringify(this.items));      
 
    this.items = this.items.map(item=>{  
        console.log("item.Id: "+JSON.stringify(item.id)); 
        console.log("contactId: "+event.target.dataset.contactId); 

        if (event.target.dataset.contactId == item.id){
            console.log("test 1");

            Questions = item.Questions.map(row=>{
                console.log("row.Id: "+row.Id); 
                console.log("question.Id: "+event.target.dataset.questionId); 

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
    //   console.log("handleBlur detail: "+JSON.stringify(event.detail));
    //   console.log("handleBlur target: "+JSON.stringify(event.target));  
    //   console.log("handleBlur event: "+JSON.stringify(event));
    //   console.log("handleBlur dataset 1: "+JSON.stringify(event.target.dataset.contactId));  
    //   console.log("handleBlur dataset 2: "+JSON.stringify(event.target.dataset.questionId));                  
    // this.questions2 = this.questions2.map(row=>{
    //     if(row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase()){
    //         row.Answer = '';
    //         row.ErrorMessage = row.Message?row.Message:'You are not qualified to proceed with registration.';
    //     }else if(row.IsCriteria && row.Answer!= '' && row.Answer.toUpperCase() == row.MandatoryResponse.toUpperCase()){
    //         row.ErrorMessage = '';
    //     }
    //     return row;
    // });

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



}