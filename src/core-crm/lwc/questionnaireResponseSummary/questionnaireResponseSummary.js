/**
 * @description A custom LWC for Questionnaire Response Summary Lightning Layout
 *
 * @see ../classes/QuestionnaireResponseSummaryCtrl.cls
 *
 * @author Accenture
 * *
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | john.bo.a.pineda          | March 14, 2022        | DEPP-1463           | Created file                                           |
      |                           |                       |                     |                                                        |
*/
import { LightningElement, wire, api, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getQuestionnaireResponseSummaryDetails from "@salesforce/apex/QuestionnaireResponseSummaryCtrl.getQuestionnaireResponseSummaryDetails";
import updateApplicationStatus from "@salesforce/apex/QuestionnaireResponseSummaryCtrl.updateApplicationStatus";
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const ERROR_TITLE = 'Error'
const ERROR_VARIANT = 'error'
const SUCCESS_TITLE = 'Success'
const SUCCESS_VARIANT = 'success'

const TYPE_TITLE = "Type";
const PRODUCT_TITLE = "Product";
const CONTACT_TITLE = "Contact";
const STATUS_TITLE = "Status";
const QUESTION_TITLE = "Questions";
const ANSWER_TITLE = "Answers";

export default class QuestionnaireResponseSummary extends LightningElement {
  @api recordId;
  @track qrsResult = [];
  qrsType;
  qrsProduct;
  qrsProductURL;
  qrsContact;
  qrsContactURL;
  qrsStatus;
  qaList = [];
  error;
  saveInProgress;

  //Retrieves Questionnaire Summary Details
  @wire(getQuestionnaireResponseSummaryDetails, { qrsId: "$recordId" })
  wiredGetQRSDetails(result) {
    this.qrsResult = result;

    console.log(JSON.stringify(this.qrsResult));
    if (result.data) {
      this.qrsType = result.data.qrsType;
      this.qrsProduct = result.data.qrsProduct;
      this.qrsProductURL = result.data.qrsProductURL;
      this.qrsContact = result.data.qrsContact;
      this.qrsContactURL = result.data.qrsContactURL;
      this.qrsStatus = result.data.qrsStatus;
      this.qaList = result.data.qaList;
      this.error = undefined;
    } else if (result.error) {
      this.qrsType = undefined;
      this.qrsProduct = undefined;
      this.qrsProductURL = undefined;
      this.qrsContact = undefined;
      this.qrsContactURL = undefined;
      this.qrsStatus = undefined;
      this.qaList = undefined;
      this.error = result.error;
    }
  }

  updateStatus(event) {
    this.saveInProgress = true;
    let status = event.currentTarget.dataset.id;
    updateApplicationStatus({
      qrsId: this.recordId,
      qrsStatus: event.currentTarget.dataset.id
    })
      .then(() => {
        refreshApex(this.qrsResult);
        this.saveInProgress = false;
        this.generateToast(
          SUCCESS_TITLE,
          status == 'Approved'?'Application Approved':'Application Declined',
          SUCCESS_VARIANT
          );
      })
      .catch((error) => {
        this.saveInProgress = false;
        this.generateToast(
          ERROR_TITLE,
          LWC_Error_General,
          ERROR_VARIANT
          );
        console.log(error);
      });
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


  get showApproveDecline() {
    return (
      this.qrsStatus == "Pending" && this.qrsType == "Application Questions"
    );
  }

  get typeTitle() {
    return TYPE_TITLE;
  }
  get productTitle() {
    return PRODUCT_TITLE;
  }
  get contactTitle() {
    return CONTACT_TITLE;
  }
  get statusTitle() {
    return STATUS_TITLE;
  }
  get questionTitle() {
    return QUESTION_TITLE;
  }
  get answerTitle() {
    return ANSWER_TITLE;
  }
}
