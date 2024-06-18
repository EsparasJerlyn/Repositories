import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';

import ID from '@salesforce/schema/Engagement_List_Criteria__c.Id';
import STATUS from '@salesforce/schema/Engagement_List_Criteria__c.Status__c';

export default class DeactivateCriteriaModal extends LightningElement {
    @api recordId;
    @api invoke() {
        const fields = {};
        fields[ID.fieldApiName] = this.recordId;
        fields[STATUS.fieldApiName] = 'Deactivated';
        const recordInput = { fields };
        updateRecord(recordInput);
    }
}