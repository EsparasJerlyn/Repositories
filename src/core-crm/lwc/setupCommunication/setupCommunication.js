/**
 * @description A Custom LWC for Setup Communication for Product Request
 * @see .. classes / EmailTemplateCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | April 12, 2022        | DEPP-2247            | Created file                 |
      |                           |                       |                      |                              | 
 */

import { LightningElement, wire, api } from "lwc";
import getEmailTemplate from "@salesforce/apex/EmailTemplateCtrl.getEmailTemplate";
import getCommunicationData from '@salesforce/apex/EmailTemplateCtrl.getCommunicationData';
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import COMMUNICATION_SCHEDULE from "@salesforce/schema/Communication_Schedule__c";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const REGISTRATION_CONFIRMATION_EMAIL_TEMPLATE = "Registration Confirmation Email Template";
const PRE_SESSION_REMINDER_EMAIL = "Pre-Session Reminder Email";
const POST_COURSE_COMPLETION_EMAIL = "Post Course Completion Email";
const FACE_FACE_CONFIRMATION_EMAIL = "Face-Face Final Confirmation Email";
const VIRTUAL_FINAL_CONFIRMATION_EMAIL = "Virtual Final Confirmation Email";
const ONLINE_SELF_PACED_FINAL_CONFIRMATION_EMAIL = "Online Self-paced Final Confirmation Email";

export default class SetupCommunication extends LightningElement {
  @api productRequestId;
  @api isStatusCompleted;
  @api recordType; 
  formLoading = false;
  objectToBeCreated = COMMUNICATION_SCHEDULE;
  objectLabelName = "Email Template";

  fieldsCol1 = [
    { name: "Email_on_Registration__c" },
    { name: "Send_email_before_session__c" },
    { name: "Email_on_completion__c" },
    { name: "Email_on_final_confirmation__c" },
    { name: "Days_before_Start_Date__c" }
  ];

  fieldsCol2 = [];

  searchInProgress; 
  emailList;
  editMode;
  registrationConfirmationId;
  registrationConfirmationSearchItems = [];
  notificationBeforeId;
  notificationBeforeSearchItems = [];
  postCompletionId;
  postCompletionSearchItems = [];
  onFinalConfirmationId;
  onFinalConfirmationSearchItems=[];
  commSchedId;
  deliveryType;
  wiredCommunicationData;
  isLoading = true;
  showEditButton;

  //Loads default value for Email Template
  @wire(getCommunicationData, {
    emailNames: [
      REGISTRATION_CONFIRMATION_EMAIL_TEMPLATE,
      PRE_SESSION_REMINDER_EMAIL,
      POST_COURSE_COMPLETION_EMAIL,
      FACE_FACE_CONFIRMATION_EMAIL,
      VIRTUAL_FINAL_CONFIRMATION_EMAIL,
      ONLINE_SELF_PACED_FINAL_CONFIRMATION_EMAIL
    ],
    prodReqId : '$productRequestId',
    recordType : '$recordType'
  })
  wiredGetCommunicationData(result) {
    //console.log(result);
    if (result.data != undefined) {
      this.deliveryType = result.data.deliveryType;
      this.wiredCommunicationData = result;
      this.registrationConfirmationSearchItems = [
        {
          id: result.data.defaultEmail[REGISTRATION_CONFIRMATION_EMAIL_TEMPLATE],
          label: REGISTRATION_CONFIRMATION_EMAIL_TEMPLATE
        }
      ];
      this.registrationConfirmationId = result.data.defaultEmail[REGISTRATION_CONFIRMATION_EMAIL_TEMPLATE];
      
      this.notificationBeforeSearchItems = [
        {
          id: result.data.defaultEmail[PRE_SESSION_REMINDER_EMAIL],
          label: PRE_SESSION_REMINDER_EMAIL
        }
      ];
      this.notificationBeforeId =  result.data.defaultEmail[PRE_SESSION_REMINDER_EMAIL];

      this.postCompletionSearchItems = [
        {
          id:  result.data.defaultEmail[POST_COURSE_COMPLETION_EMAIL],
          label: POST_COURSE_COMPLETION_EMAIL
        }
      ];
      this.postCompletionId =  result.data.defaultEmail[POST_COURSE_COMPLETION_EMAIL];
      
      if(this.deliveryType == 'Face to Face'){
        this.onFinalConfirmationSearchItems = [
          {
            id:  result.data.defaultEmail[FACE_FACE_CONFIRMATION_EMAIL],
            label: FACE_FACE_CONFIRMATION_EMAIL
          }
        ];
        this.onFinalConfirmationId =  result.data.defaultEmail[FACE_FACE_CONFIRMATION_EMAIL];
      }else if(this.deliveryType =='Virtual Classroom'){
        this.onFinalConfirmationSearchItems = [
          {
            id:  result.data.defaultEmail[VIRTUAL_FINAL_CONFIRMATION_EMAIL],
            label: VIRTUAL_FINAL_CONFIRMATION_EMAIL
          }
        ];
        this.onFinalConfirmationId =  result.data.defaultEmail[VIRTUAL_FINAL_CONFIRMATION_EMAIL];
      }else if(this.deliveryType == 'Online'){
        this.onFinalConfirmationSearchItems = [
          {
            id:  result.data.defaultEmail[ONLINE_SELF_PACED_FINAL_CONFIRMATION_EMAIL],
            label: ONLINE_SELF_PACED_FINAL_CONFIRMATION_EMAIL
          }
        ];
        this.onFinalConfirmationId =  result.data.defaultEmail[ONLINE_SELF_PACED_FINAL_CONFIRMATION_EMAIL];
      }

      this.commSchedId = result.data.communicationRecord? result.data.communicationRecord.Id : undefined;
      
      this.fieldsCol2 = [    
      { name: "Send Email on Registration - Email Template" , 
        value: result.data.communicationRecord && result.data.communicationRecord.On_Registration_Template__c?  
        '/' + result.data.communicationRecord.On_Registration_Template__c : "" , 
        label: result.data.templateMap && result.data.communicationRecord ? 
          result.data.templateMap.find( item => item.id == result.data.communicationRecord.On_Registration_Template__c)? 
          result.data.templateMap.find( item => item.id == result.data.communicationRecord.On_Registration_Template__c).label: "" : ""
        },
      { name: "Email Notification before Session - Email Template", 
        value: result.data.communicationRecord && result.data.communicationRecord.Notification_Before_Session_Template__c ? 
        '/' + result.data.communicationRecord.Notification_Before_Session_Template__c : "" , 
        label: result.data.templateMap && result.data.communicationRecord ? 
          result.data.templateMap.find( item => item.id == result.data.communicationRecord.Notification_Before_Session_Template__c)?
          result.data.templateMap.find( item => item.id == result.data.communicationRecord.Notification_Before_Session_Template__c).label: "" : "" 
        },
      { name: "Send on Completion - Email Template",
        value: result.data.communicationRecord && result.data.communicationRecord.On_Completion_Template__c ?
        '/' + result.data.communicationRecord.On_Completion_Template__c : "" , 
        label: result.data.templateMap && result.data.communicationRecord ? 
          result.data.templateMap.find( item => item.id == result.data.communicationRecord.On_Completion_Template__c)? 
          result.data.templateMap.find( item => item.id == result.data.communicationRecord.On_Completion_Template__c).label: "" : "" 
        },
      { name: "Send Email on Final Confirmation",
        value: result.data.communicationRecord && result.data.communicationRecord.On_Final_Confirmation_Template__c? 
        '/' +result.data.communicationRecord.On_Final_Confirmation_Template__c : "" , 
        label: result.data.templateMap && result.data.communicationRecord ? 
          result.data.templateMap.find( item => item.id == result.data.communicationRecord.On_Final_Confirmation_Template__c)?
          result.data.templateMap.find( item => item.id == result.data.communicationRecord.On_Final_Confirmation_Template__c).label: "" : "" 
        }];
        this.isLoading = false;

    } else if (result.error) {
      this.generateToast("Error!", LWC_Error_General, "error");
      this.isLoading = false;
    }
  }

  //Registration Confirmation Email Template
  // Handles Registration Search Email when entering Values in The custom Search
  handleRegistrationSearch(event) {
    this.searchInProgress = true;
    //console.log("event -->", event.detail.filterString);
    getEmailTemplate({
      filterString: event.detail.filterString
    })
      .then((res) => {
        if (res) {
          //console.log("Get Email Template Res -->", res);
          this.registrationConfirmationSearchItems = res;
        } else {
          this.registrationConfirmationSearchItems = [];
        }
      })
      .finally(() => {
        this.searchInProgress = false;
      })
      .catch((error) => {
        //console.log(error);
        this.generateToast("Error.", LWC_Error_General, "error");
      });
  }
  //handles Lookup Select Registration Confirmation
  handleLookupSelectRegistrationConfirmation(event) {
    this.registrationConfirmationId = event.detail.value;
  }

  //handles Lookup Remove Registration Confirmation
  handleLookupRemoveRegistrationConfirmation() {
    this.registrationConfirmationId = "";
    this.registrationConfirmationSearchItems = [];
  }

  //Notification Before Search Email
  // Handles Notifcation Before Search Email when entering Values in The custom Search
  handleNotificationBeforeSearchEmail(event) {
    this.searchInProgress = true;
    //console.log("event -->", event.detail.filterString);
    getEmailTemplate({
      filterString: event.detail.filterString
    })
      .then((res) => {
        if (res) {
          //console.log("Get Email Template Res -->", res);
          this.notificationBeforeSearchItems = res;
        } else {
          this.notificationBeforeSearchItems = [];
        }
      })
      .finally(() => {
        this.searchInProgress = false;
      })
      .catch((error) => {
        this.generateToast("Error.", LWC_Error_General, "error");
      });
  }

  handleLookupSelectNotification(event) {
    this.notificationBeforeId = event.detail.value;
  }

  handleLookupRemoveNotification() {
    this.notificationBeforeId = "";
    this.notificationBeforeSearchItems = [];
  }

  //Post Completion Email
  //Handles Post Compilation Search Email when entering Values in The custom Search
  handlePostComplationSearch(event) {
    this.searchInProgress = true;
    getEmailTemplate({
      filterString: event.detail.filterString
    })
      .then((res) => {
        if (res) {
          this.postCompletionSearchItems = res;
        } else {
          this.postCompletionSearchItems = [];
        }
      })
      .finally(() => {
        this.searchInProgress = false;
      })
      .catch((error) => {
        this.generateToast("Error.", LWC_Error_General, "error");
      });
  }

  //handles lookup Select of Post Completion Email
  handleLookupSelectPostCompletionEmail(event) {
    this.postCompletionId = event.detail.value;
  }

  //handles lookup Remove of Post Completion Email
  handleLookupRemovePostCompletion() {
    this.postCompletionId = "";
    this.postCompletionSearchItems = [];
  }

  //On Completion Email
  //Handles On Final Confirmation Search Email when entering Values in The custom Search
  handleOnFinalConfirmationSearch(event){
      this.searchInProgress = true;
      getEmailTemplate({
          filterString: event.detail.filterString
      }).then(res =>{
          if(res){
              this.onFinalConfirmationSearchItems = res;
          }
          else{
              this.onFinalConfirmationSearchItems = [];
          }
      })
      .finally(() =>{
          this.searchInProgress = false;
      })
      .catch(error =>{
          this.generateToast('Error.',LWC_Error_General,'error');
      });
  }

  //handles lookup Select of Post Completion Email
  handleLookupSelectOnFinalConfirmation(event){
      this.onFinalConfirmationId = event.detail.value;
  }

  //hanldes lookup Remove of Post Completion Email
  handleLookupRemoveOnFinalConfirmation(){
      this.onFinalConfirmationId = '';
      this.onFinalConfirmationSearchItems = [];
  }
  

  // handles submit form
  handleCreateCommunication(event) {
    event.preventDefault();
    let fields = event.detail.fields;
    if(this.commSchedId){
      fields.Id = this.commSchedId;
    }
    fields.On_Registration_Template__c = this.registrationConfirmationId;
    fields.Notification_Before_Session_Template__c = this.notificationBeforeId;
    fields.On_Completion_Template__c = this.postCompletionId;
    fields.On_Final_Confirmation_Template__c = this.onFinalConfirmationId;

    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }

  handleSuccessRecord(){
    this.isLoading = true;
    refreshApex(this.wiredCommunicationData).then( () =>{
      this.editMode = false;
      this.isLoading = false;
    }).catch((error) => {
      this.isLoading = false;
      this.generateToast("Error.", LWC_Error_General, "error");
    });
  }

  //handles on Load Form
  handleFormLoad() {
    this.formLoading = false;
  }

  //enables edit mode
  handleEdit() {
    this.editMode = true;
  }

  //cancels edit mode
  handleCancel() {
    this.editMode = false;
  }

  //shows toast on error upon saving the setup communication
  handleRecordError() {
    this.generateToast("Error.", LWC_Error_General, "error");
  }

  /**
   * creates toast notification
   */
  generateToast(_title, _message, _variant) {
    const evt = new ShowToastEvent({
      title: _title,
      message: _message,
      variant: _variant
    });
    this.dispatchEvent(evt);
  }
}