/**
 * @description Lightning Web Component for custom buttons.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                   |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                                     | 
      | nicole.genon@qut.edu.au   | January 15, 2024      | DEPP-6966            | Added wiredList and isDisabledButton             | 
 */
import { LightningElement, api, wire } from 'lwc';
import { getRecord  } from 'lightning/uiRecordApi';
import LIST_STAGE from '@salesforce/schema/List__c.Stage__c';

export default class CustomHeaderButtons extends LightningElement {
     @api recordId;
     @api selectedRows;
     statusSelected = 'Close';
     stageValue;

     listMemberColumns = [LIST_STAGE];

     @wire(getRecord, { recordId: "$recordId", fields: "$listMemberColumns" })
     wiredList(responseData) {
          const { data, error } = responseData;

          if (data) {
               const fields = data.fields;
               this.stageValue = fields.Stage__c.value;
          }

     }

     get isDisabledButton() {
          return this.stageValue === "Distribute" || this.stageValue === 'Closed' ? true : false;
     }
}