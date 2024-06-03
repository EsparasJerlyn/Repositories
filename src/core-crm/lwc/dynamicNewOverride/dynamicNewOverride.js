import { LightningElement, api, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import {
  IsConsoleNavigation,
  getTabInfo,
  EnclosingTabId
} from "lightning/platformWorkspaceApi";

export default class dynamicNewOverride extends NavigationMixin(
  LightningElement
) {
  @api objectApiName;
  @api recordId;
  selectedRecordTypeId;
  recordOptions = [];
  parentId;

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

  get hasRecordTypes() {
    return this.recordOptions ? true : false;
  }

  navigateToNewRecordPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.objectApiName,
        actionName: "new"
      }
    });
  }

  handleRecordTypeChange(event) {
    this.selectedRecordTypeId = event.detail.value;
  }

  handleCancelClick() {
    //close the new tab
  }

  handleNewRecordWithParentId() {
    let encodeDefault = {};
    encodeDefault['ContactId'] = this.recordId;
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

  handleNextClick() {
    console.log("this.objectApiName", this.objectApiName);
    console.log("this.recordId",this.recordId);
    console.log("this.selectedRecordTypeId",this.selectedRecordTypeId);
    if(this.recordId){
      this.handleNewRecordWithParentId();
    }else{
      this.handleNewRecord();
    }
    
    // if (this.isConsoleNavigation) {
    //   getTabInfo(this.enclosingTabId)
    //     .then((tabInfo) => {
    //       const primaryTabId = tabInfo.isSubtab
    //         ? tabInfo.parentTabId
    //         : tabInfo.tabId;
    //       return primaryTabId;
    //     })
    //     .then((primaryTabId) => {
    //       return getTabInfo(primaryTabId);
    //     })
    //     .then((primaryTabInfo) => {
    //       this.parentId = this.getParentId(primaryTabInfo);
    //     })
    //     .catch((error) =>{
    //       console.log(error);
    //     })
    //     .finally(()=>{
    //       console.log("this.objectApiName", this.objectApiName);
    //       console.log("this.recordId",this.recordId);
    //       console.log("this.parentId",this.parentId);
    //     })
    // }
    
    //call navigation mixin with record type
    //close the new tab
  }

  // getParentId(primaryTabInfo) {
  //   const subTabsCount = primaryTabInfo.subtabs.length;
  //   return subTabsCount > 1
  //     ? primaryTabInfo.subtabs[subTabsCount - 2].recordId
  //     : primaryTabInfo.recordId;
  // }
}
