/**
 * @description A reusable Lightning Web Component to mimic standard look and feel of a record details page
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                  |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------|
 *    | ryan.j.a.dela.cruz             | February 2, 2024      | DEPP-6950              | Created file                    |
 *    | kim.howard.capanas             | March 18, 2024        | DEPP-8203              | Added dynamic filters and logic parameter support for flexipage                 |
 *    | marygrace.li                   | May 6, 2024           | DEPP-8203              | Updated messageChannel name to  |
 *    |                                |                       |                        | designationMessageChannel       |
 *    |                                |                       |                        |                                 |
 */

import { LightningElement, api, wire, track } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import {publish,subscribe,APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import { loadStyle } from "lightning/platformResourceLoader";
import customForm from "@salesforce/resourceUrl/CustomRecordEditForm";
import getRecordIds from "@salesforce/apex/DynamicRecordEditFormCtrl.getRecordIds";
import getUiBehavior from "@salesforce/apex/DynamicRecordEditFormCtrl.getUiBehavior";
import getContentBlockFilter from "@salesforce/apex/DynamicRecordEditFormCtrl.getContentBlockFilter";
import designationMessageChannel from '@salesforce/messageChannel/Designation__c';

export default class DynamicRecordEditForm extends LightningElement {
  // start of params
  @api childObjectRecord;
  @api relatedListLabel;
  @api numberOfColumn;
  @api column1;
  @api column2;
  @api recordId;
  @api isSubscriber;
  @api contentBlockFilter;
  @api readOnlyByParentField;
  @api readOnlyByUser;
  @api objectApiName;


  // @track data;
  @track showContentBlock;
  @track passedRecordId;
  @track uiSectionBehavior;

  showEditField = true;
  showFooter;
  messageReceived = '';
  
  setParameters() {
    let paramsMap = {};
    paramsMap["recordId"] = this.recordId;
    paramsMap["parentRecord"] = this.objectApiName;
    paramsMap["visibilityByUser"] = this.readOnlyByUser;
    paramsMap["visibilityByParent"] = this.readOnlyByParentField
    return paramsMap;
  }

  setParametersForVisibilityFilter() {
    let paramsMap = {};
    paramsMap["recordId"] = this.passedRecordId;
    paramsMap["childRecord"] = this.childObjectRecord;
    paramsMap["contentBlockFilter"] = this.contentBlockFilter;
    return paramsMap;
  }

  renderedCallback() {
    Promise.all([loadStyle(this, customForm)]).then(() => {});
  }

  @wire(MessageContext)
  messageContext

  getRecordId(){
    return new Promise((resolve) => {
      getRecordIds({
        recordId: this.recordId,
        objectApiName : this.childObjectRecord
      })
      .then((result) =>{
        this.passedRecordId = result;
        resolve();
      })
      .catch((error) => {
        const logger = this.template.querySelector("c-logger");
        if (logger) {
          logger.error(
            "Exception caught in method getRecordId in LWC dynamicRecordEditForm: ",
            JSON.stringify(error)
          );
          logger.saveLog();
        }
        resolve();
      });
    });
  }

  get reactiveParentId(){
    return this.objectApiName + '.Id';
  } 

  @wire(getRecord, {
    recordId: "$recordId",
    fields: ["$reactiveParentId"],
  })
  handleEditBehavior(result){
    if (result.data) {
      this.getUiBehavior();
    }
  }
  
  async connectedCallback() {
    await this.getRecordId(); // passsedRecordId has value
    this.getUiBehavior(); // controls edit button
    this.getContentBlockFilter(); // section visibility filter
    if (this.isSubscriber){
      this.subscribeToMessageChannel();
    }
  }

  handleEdit() {
    this.showEditField = !this.showEditField;
  }

  getUiBehavior() {
    return new Promise((resolve) => {
      getUiBehavior({
        paramsMap: this.setParameters()
      })
      .then((result) => {
        this.uiSectionBehavior = result;
        resolve();
      })
      .catch((error) => {
        const logger = this.template.querySelector("c-logger");
        if (logger) {
          logger.error(
            "Exception caught in method getUiBehavior in LWC dynamicRecordEditForm: ",
            JSON.stringify(error)
          );
          logger.saveLog();
        }
        resolve();
      });
    })
  }

  getContentBlockFilter() {
    getContentBlockFilter({
      paramsMap: this.setParametersForVisibilityFilter()
    })
    .then((result) => {
      this.showContentBlock = result;
    })
    .catch((error) => {
      const logger = this.template.querySelector("c-logger");
      if (logger) {
        logger.error(
          "Exception caught in method getContentBlockFilter in LWC dynamicRecordEditForm: ",
          JSON.stringify(error)
        );
        logger.saveLog();
      }
    });
  }

  subscribeToMessageChannel(){
    this.subscription = subscribe(
      this.messageContext, 
      designationMessageChannel, 
      (message) => {
        this.handleMessage(message)
      },
      {
        scope :APPLICATION_SCOPE
      }
    )
  }

  handleMessage(message){
    this.messageReceived = message.lmsData.data ? message.lmsData.data : 'No data receieved';
    this.getUiBehavior();
    this.getContentBlockFilter();
  }

  handleSuccess() {
    this.showEditField = !this.showEditField;
    let lmsMessage = 'Content Block'; // update lmsMessage value for future use.
    const message = {
      lmsData : {
        data : lmsMessage
      }
    }
    publish(this.messageContext, designationMessageChannel, message);
  }

  handleCancel(event) {
    this.showFooter = false;
    this.showEditField = !this.showFooter;
  }

  updateShowFooter(event) {
    this.showFooter = event.detail.message;
    this.showEditField = !this.showFooter;
  }


  handleError(error) {
    // If there are additional builds in the future, such as adding a toast message when an error occurred, we can add it here.
  }

  get fetchColumn1() {
    return this.numberOfColumn >= 1 ? JSON.parse(this.column1) : "";
  }

  get fetchColumn2() {
    this.checker >= 2;
    return this.numberOfColumn >= 2 ? JSON.parse(this.column2) : "";
  }

  get sectionFilter(){
    return this.showContentBlock;
  }

  set sectionFilter(value){
    this.showContentBlock = value;
  }

  get editFilter(){
    return this.uiSectionBehavior;
  }

  set editFilter(value){
    this.uiSectionBehavior = value;
  }
}