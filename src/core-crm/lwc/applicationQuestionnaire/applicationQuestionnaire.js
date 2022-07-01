/**
 * @description Lightning Web Component for Application Question in Portal
 *
 * @see ../classes/ProductDetailsCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | john.bo.a.pineda          | June 29, 2022         | DEPP-3323            | Modified to add logic to     |
      |                           |                       |                      | validate Upload File Type    |
*/

import { LightningElement, api, track, wire} from 'lwc';
import saveApplication from "@salesforce/apex/ProductDetailsCtrl.saveApplication";
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from "lightning/platformResourceLoader";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customSR1 from "@salesforce/resourceUrl/QUTInternalCSS";
import BasePath from "@salesforce/community/basePath";
import getOPEProductCateg from "@salesforce/apex/PaymentConfirmationCtrl.getOPEProductCateg";

const ERROR_TITLE = 'Error'
const ERROR_VARIANT = 'error'
const SUCCESS_TITLE = 'Success'
const SUCCESS_VARIANT = 'success'

export default class ApplicationQuestionnaire extends LightningElement {

    isModalOpen = true;
    saveInProgress = false;
    disableCancel = true;
    @api responseData;
    @api isPrescribed;
    @api contactId;
    @api selectedOffering;
    @api priceBookEntry;
    @track questionsCopy;
    @track _questions;

    //modal confirmation message
    isModalMessage = false;
    message1;
    message2;
    isContinueBrowsing = false;
    isContinueToPayment = false;
    xButton;

    @api
    get questions() {
        return this.questionsCopy;
    }

    set questions(value) {
       this.questionsCopy = value;
       this._questions = this.formatQuestions(value);
    }

    get hasQuestions(){
        return this._questions?true:false;
    }
    /* Load Custom CSS */
    renderedCallback() {
        Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
        Promise.all([loadStyle(this, customSR1 + "/QUTInternalCSS.css")]);
    }

    // Set Accepted File Formats
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', 'jpeg'];
    }

    _resolveConnected;
    _connected = new Promise((resolve) => {
      this._resolveConnected = resolve;
    });

    connectedCallback() {
      this._resolveConnected();
      // Load Default Icons
      this.xMark = qutResourceImg + "/QUTImages/Icon/xMark.svg";
      // load confirm message
      this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
    }


    get disableResponseSave() {
        let tempQuestions = this._questions?this._questions.filter(
            (row) =>
              row.IsCriteria &&
              row.Answer != "" &&
              row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase()
          ):[];
        if (
          (tempQuestions && tempQuestions.length > 0) ||
          (this._questions &&
            this._questions.filter(
              (item) => item.Answer == "" || item.Answer == undefined
            ) &&
            this._questions.filter(
              (item) => item.Answer == "" || item.Answer == undefined
            ).length > 0) || this.saveInProgress
        ) {
          return true;
        } else {
          return false;
        }
      }


    formatQuestions(items) {
    let questions = items.map((item) => {
        let newItem = {};
        let newOptions = [];
        newItem.Id = item.Id;
        if (item.Question__c) {
        newItem.QuestionId = item.Question__r.Id;
        newItem.Label = item.Question__r.Label__c;
        newItem.MandatoryResponse = item.Question__r.Acceptable_Response__c;
        newItem.Message = item.Question__r.Message__c;
        newItem.Type = item.Question__r.Type__c;
        newItem.IsText = item.Question__r.Type__c == "Text" ? true : false;
        newItem.IsCheckbox =
            item.Question__r.Type__c == "Checkbox" ? true : false;
        newItem.IsNumber = item.Question__r.Type__c == "Number" ? true : false;
        newItem.IsDate = item.Question__r.Type__c == "Date" ? true : false;
        newItem.IsPicklist =
            item.Question__r.Type__c == "Picklist" ? true : false;
        newItem.IsMultiPicklist =
            item.Question__r.Type__c == "Multi-Select Picklist" ? true : false;
        newItem.IsFileUpload =
            item.Question__r.Type__c == "File Upload" ? true : false;
        if (item.Question__r.Dropdown_Options__c) {
            newOptions = item.Question__r.Dropdown_Options__c.split(";").map(
            (key) => {
                return { label: key, value: key };
            }
            );
        }
        newItem.Options = newOptions;
        newItem.Answer = newItem.IsCheckbox ? "false" : "";
        }
        newItem.QuestionnaireId = item.Questionnaire__c;
        newItem.IsCriteria =
        item.Questionnaire__r.Questionnaire_Type__c == "Registration Criteria"
            ? true
            : false;
        newItem.IsQuestion =
        item.Questionnaire__r.Questionnaire_Type__c == "Registration Questions"
            ? true
            : false;
        newItem.IsQuestion =
        item.Questionnaire__r.Questionnaire_Type__c == "Application Questions"
            ? true
            : false;
        newItem.Sequence = item.Sequence__c;
        newItem.ErrorMessage = "";
        newItem.FileData = undefined;
        return newItem;
    });

    return questions;
    }

    handleChange(event) {
        this._questions = this._questions.map((row) => {
            if (event.target.name === row.Id && row.IsCheckbox) {
            row.Answer = event.detail.checked.toString();
            } else if (event.target.name === row.Id && row.IsFileUpload) {
            row.Answer = event.detail.value.toString();
            const file = event.target.files[0];
            let fileNameParts = file.name.split('.');
            let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
                if (this.acceptedFormats.includes(extension)) {
                    let reader = new FileReader();
                    reader.onload = () => {
                        let base64 = reader.result.split(",")[1];
                        row.FileData = {
                        filename: file.name,
                        base64: base64,
                        recordId: undefined
                        };
                    };
                    reader.readAsDataURL(file);
                } else {
                    row.Answer = '';
                    row.FileData = undefined;
                    this.generateToast('Error.','Invalid File Format.','error');
                }
            } else if (event.target.name === row.Id && row.IsMultiPicklist) {
            row.Answer = event.detail.value
                ? event.detail.value.toString().replace(/,/g, ";")
                : row.Answer;
            } else if (event.target.name === row.Id) {
            row.Answer = event.detail.value
                ? event.detail.value.toString()
                : row.Answer;
            }
        return row;
        });

    }

    handleBlur() {
    this._questions = this._questions.map((row) => {
        if (
        row.IsCriteria &&
        row.Answer != "" &&
        row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase()
        ) {
        row.Answer = "";
        row.ErrorMessage = row.Message
            ? row.Message
            : "You are not qualified to proceed with registration.";
        } else if (
        row.IsCriteria &&
        row.Answer != "" &&
        row.Answer.toUpperCase() == row.MandatoryResponse.toUpperCase()
        ) {
        row.ErrorMessage = "";
        }
        return row;
    });
    }

    createFileUploadMap() {
    let fileUpload = [];
    fileUpload = this._questions.map((item) => {
        if (item.IsFileUpload) {
        let record = {};
        record.RelatedAnswerId = item.Id;
        record.Base64 = item.FileData.base64;
        record.FileName = item.FileData.filename;
        return record;
        }
    });

    return fileUpload.filter((key) => key !== undefined)
        ? fileUpload.filter((key) => key !== undefined)
        : fileUpload;
    }

    createAnswerRecord() {
    let answerRecords = {};
    answerRecords = this._questions.map((item) => {
        let record = {};
        record.Related_Answer__c = item.Id;
        record.Response__c = item.Answer;
        record.Sequence__c = item.Sequence;
        return record;
    });
    return answerRecords;
    }

    resetResponses() {
        this._questions = this._questions.map((item) => {
            item.Answer = item.IsCheckbox ? item.Answer : "";
            item.ErrorMessage = "";
            item.FileData = undefined;
            return item;
        });
    }

    closeModal() {
        this.isModalMessage = false;
        this.dispatchEvent(new CustomEvent('close'));
        this.resetResponses();
    }

    submitDetails(){
    this.saveInProgress = true;
    this.disableCancel = true;
        saveApplication({
            contactId : this.contactId,
            offeringId :this.selectedOffering,
            relatedAnswerList :this.responseData,
            answerList : this.createAnswerRecord(),
            fileUpload : JSON.stringify(this.createFileUploadMap()),
            isPrescribed : this.isPrescribed,
            pricebookEntryId : this.priceBookEntry
        })
        .then(() => {
            this.isModalMessage = true;
            this.message1 = 'Your application has been successfully submitted.';
            this.message2 = 'We will review your application and advise of the outcome shortly.';
            this.isContinueBrowsing = true;
            this.isContinueToPayment = false;
            // this.generateToast(
            //     SUCCESS_TITLE,
            //     "Successfully Submitted",
            //     SUCCESS_VARIANT
            //     );
        })
        .finally(() => {
            this.resetResponses();
            this.isModalOpen = false;
            // this.closeModal();
            this.saveInProgress = false;
        })
        .catch((error) => {
            console.log(error);
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            this.saveInProgress = false;
            this.disableCancel = false;
        })

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

    //to get the product category Id
    @wire(getOPEProductCateg)
    productCategData;

    handleContinueBrowsing(){
        //Direct to the product catalog
        window.location.href = BasePath + "/category/products/" + this.productCategData.data.Id;
    }

    handleContinueToPayment(event){
        //Direct to the cart summary page
        window.location.href = BasePath + "/cart/" + this.cartId;
    }

}