/**
 * @description LWC that renders the custom chevron for an object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                                              |
 *    |---------------------------|-----------------------|----------------------|-----------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | Aug 22, 2023          | DEPP-5704            | Created file                                                                |
 */
import { LightningElement, api, wire, track } from "lwc";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { getFieldValue } from "lightning/uiRecordApi";
import { getRecord } from "lightning/uiRecordApi";

export default class CustomChevron extends LightningElement {
  @api objectApiName;
  @api fieldName;
  @api recordId;

  @track picklistvalues;
  @track record;
  @track chevronData = [];
  @track itemList;
  @track fieldValue;
  @track fieldArray;

  recordtypeId;
  index = 0;
  isFound = false;
  isfoundindex = 0;
  fieldApiName;
  fieldArray;
  masterRecordId;

  @wire(getObjectInfo, { objectApiName: "$objectApiName" })
  objectInfo({ data, error }) {
    if (data) {
      if (Object.keys(data.recordTypeInfos).length > 1) {
        this.fieldArray = [
          `${this.objectApiName}.${this.fieldName}`,
          `${this.objectApiName}.RecordTypeId`
        ];
      } else {
        this.fieldArray = [`${this.objectApiName}.${this.fieldName}`];
        const rtis = data.recordTypeInfos;
        this.masterRecordId = Object.keys(rtis).find(
          (rti) => rtis[rti].name === "Master"
        );
      }
      this.fieldApiName = `${this.objectApiName}.${this.fieldName}`;
    } 
  }

  /*Use this wire adapter to get a record’s data : 
       Recordtype ID and value of status field pass through API
    */
  @wire(getRecord, { recordId: "$recordId", fields: "$fieldArray" })
  wiredAccount({ error, data }) {
    if (data) {
      this.record = data;
      this.fieldvalue = getFieldValue(
        data,
        `${this.objectApiName}.${this.fieldName}`
      );
      this.recordtypeId = this.record.fields.RecordTypeId
        ? this.record.fields.RecordTypeId.value
        : this.masterRecordId;
    } else if (error) {
      this.record = undefined;
    }
  }

  /*Use this wire adapter to get the picklist values for a specified field.*/

  @wire(getPicklistValues, {
    fieldApiName: "$fieldApiName",
    recordTypeId: "$recordtypeId"
  })
  fetchRecordTypeInfo({ data, error }) {
    if (data) {
      this.picklistvalues = data.values;
      this.picklistvalues.forEach((item) => {
        let classType;
        if (this.fieldvalue == item.value) {
          classType = "slds-path__item slds-is-current slds-is-active bgColor";
          this.isFound = true;
          this.isfoundindex = this.index;
        } else {
          classType = "slds-path__item slds-is-incomplete";
          this.index++;
        }
        this.chevronData.push({
          stages: item,
          classType: classType
        });
      });
      if (this.isFound) {
        for (let i = 0; i < this.isfoundindex; i++) {
          this.chevronData[i].classType = "slds-path__item slds-is-complete";
        }
      }
    } 
  }
}
