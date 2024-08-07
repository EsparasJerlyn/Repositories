/**
* @name : EinsteinButton
* @description : This Component is used to show the button on case record page if the category and sub category fields are auto populated using einstein classification.
* @author Accenture
* @history
*    | Developer Email                | Date                  | JIRA                   | Change Summary               |
|--------------------------------|-----------------------|------------------------|------------------------------|
| moiz.syed@qut.edu.au           | May 29, 2024          | DEPP-8870              | Created file
**/
import { LightningElement, api, wire } from 'lwc';
import { updateRecord, getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import EINSTEIN_FIELD from "@salesforce/schema/Case.Einstein_Recommendation_Applied__c";
import ID_FIELD from "@salesforce/schema/Case.Id";

export default class EinsteinButton extends LightningElement {
    @api recordId;

    //This method is used to get the case record field value using wire adapter
    @wire(getRecord, {
      recordId: "$recordId",
      fields: [EINSTEIN_FIELD]
    })
    caseRec;

    //This get method return the Einstein_Recommendation_Applied__c field value.
    get einValue() {
      return getFieldValue(this.caseRec.data, EINSTEIN_FIELD);
    }

    //This method is used to handle button click event, here we are updating case record field value using updateRecord.
    handleClick(){
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[EINSTEIN_FIELD.fieldApiName] = false;
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {});
    }
}