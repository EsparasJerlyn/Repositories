import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';

import ID from '@salesforce/schema/Engagement_List_Criteria__c.Id';
import STATUS from '@salesforce/schema/Engagement_List_Criteria__c.Status__c';

export default class deactivateCriteriaModal extends LightningElement {
    error;
    showClose = false;
    showError = false;
    showLoading = false;
    showNotice = true;

    @api recordId;

    handleCancel() {
        this.closeQuickAction();
    }

    handleClose() {
        this.closeQuickAction();
    }

    handleDeactivate() {
        this.showLoading = true;
        this.disableClose = true;
        const fields = {};
        fields[ID.fieldApiName] = this.recordId;
        fields[STATUS.fieldApiName] = 'Deactivated';
        const recordInput = { fields };
        updateRecord(recordInput)
            .catch((error) => {
                this.error = error.body.message;
                this.showError = true;
                this.showNotice = false;
                this.Loading = false;
            })
            .finally(() => {
                this.disableClose = false;
                if(!this.showError) {
                    this.closeQuickAction();
                }
            });
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}