import { LightningElement, api, wire } from "lwc";
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

import ID from '@salesforce/schema/Engagement_List_Criteria__c.Id';
import PREVIEW_STATUS from '@salesforce/schema/Engagement_List_Criteria__c.Preview_Status__c';
import STATUS from '@salesforce/schema/Engagement_List_Criteria__c.Status__c';

const fields = [PREVIEW_STATUS, STATUS];

export default class activateCriteriaModal extends LightningElement {
    @api recordId;
    
    error;
    isBeforePreview;
    isSuccess = true;
    record;
    showConfirmation = false;
    showClose = false;
    showError = false;
    showLoading = true;
    showNotice = false;

    @wire(getRecord, { recordId: "$recordId", fields })
    wiredElc({ error, data }) {
        this.showLoading = true;
        if(data) {
            this.record = data;
            if(this.record.fields.Preview_Status__c.value == "Completed") {
                this.isBeforePreview = false;
            } else {
                this.isBeforePreview = true;
            }
            if(this.record.fields.Status__c.value == 'Draft') {
                this.showNotice = true;
            }
            this.error = undefined;
        } else if(error) {
            this.error = error.body.message;
            this.showError = true;
            this.record = undefined;
        }
        this.showLoading = false;
    }

    handleCancel() {
        this.closeQuickAction();
    }

    handleActivate() {
        this.showLoading = true;
        const fields = {};
        fields[ID.fieldApiName] = this.recordId;
        fields[STATUS.fieldApiName] = 'Active';
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.showConfirmation = true;
            })
            .catch((error) => {
                this.error = error.body.output.errors[0].message;
                this.showError = true;
            })
            .finally(() => {
                this.showClose = true;
                this.showNotice = false;
                this.showLoading = false;
            })
    }

    handleClose() {
        this.closeQuickAction();
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}