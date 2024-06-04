import { LightningElement, api, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import {
  IsConsoleNavigation,
  getTabInfo,
  closeTab,
  setTabLabel,
  setTabIcon,
  EnclosingTabId
} from "lightning/platformWorkspaceApi";
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import tabClosedChannel from "@salesforce/messageChannel/lightning__tabClosed";

export default class dynamicNewOverride extends NavigationMixin(
  LightningElement
) {

  @api objectApiName;
  @api recordId;
  @api iconName;
  selectedRecordTypeId;
  recordOptions = [];
  uid;

  connectedCallback(){
    if (this.isConsoleNavigation) {
      getTabInfo(this.enclosingTabId)
      .then((tabInfo) => {
        console.log('response in lwc(current tab)',JSON.parse(JSON.stringify(tabInfo)));
        this.uid = tabInfo.pageReference.state.uid;
        if(this.recordId){
          window.sessionStorage.setItem(tabInfo.pageReference.state.uid,this.recordId)
        }
      })
      .then(()=>{
        return setTabLabel(this.enclosingTabId,'New '+ this.objectApiName);
      })
      .then(()=>{
        return setTabIcon(this.enclosingTabId,this.iconName);
      })
      .catch((error) =>{
        console.log(error);
      })
      .finally(()=>{
      })

      this.unsubscribe();
      this.messageSubscription = subscribe(this.messageContext, tabClosedChannel, (message) => {
        this.handleMessage(message);
      });
    }
  }

  disconnectedCallback() {
      this.unsubscribe();
  }

  unsubscribe() {
      if (!this.messageSubscription) {
        return;
      }
      unsubscribe(this.messageSubscription);
      this.messageSubscriptions = null;
  }

  handleMessage(message) {
    if (!message || !message.tabId) {
       return;
    }
    window.sessionStorage.removeItem(this.uid);
  }

  @wire(MessageContext) messageContext;
  messageSubscription = null;

  @wire(IsConsoleNavigation) isConsoleNavigation;
  @wire(EnclosingTabId) enclosingTabId;

  @wire(getObjectInfo, { objectApiName: "$objectApiName" })
  objectInfo({ error, data }) {
    if (data) {
      this.error = undefined;
      const recordTypes = data.recordTypeInfos;
      this.recordOptions = Object.keys(recordTypes).map((key) => ({
        label: recordTypes[key].name,
        value: recordTypes[key].recordTypeId
      }));
    } else if (error) {
      this.error = error;
      this.showToast("Error", error.body.message, "error");
    }
  }

  get parentId(){
    return window.sessionStorage.getItem(this.uid);
  }

  get hasRecordTypes() {
    return this.recordOptions ? true : false;
  }

  handleRecordTypeChange(event) {
    this.selectedRecordTypeId = event.detail.value;
  }

  handleCancelClick() {
    this.closeNewTab();
  }

  handleNextClick() {
    if(this.parentId){
      this.handleNewRecordWithParentId();
    }else{
      this.handleNewRecord();
    }
    this.closeNewTab();
  }

  handleNewRecordWithParentId() {
    let encodeDefault = {};
    
    encodeDefault['Lead__c'] = this.parentId;
    let finalDefaultValues = encodeDefaultFieldValues(encodeDefault);

    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.objectApiName,
        actionName: "new"
      },
      state: {
        defaultFieldValues: finalDefaultValues,
        recordTypeId: this.selectedRecordTypeId,
        useRecordTypeCheck: "false" 
      }
    });
  }

  handleNewRecord() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.objectApiName,
        actionName: "new"
      },
      state: {
        recordTypeId: this.selectedRecordTypeId,
        useRecordTypeCheck: "false" 
      }
    });
  }

  closeNewTab(){
    closeTab(this.enclosingTabId);
    window.sessionStorage.removeItem(this.uid);
  }
}
