import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import GeneratePreviewELCModal from 'c/generatePreviewELCModal';

import cancelPreview from '@salesforce/apex/OutreachCampaignPreviewController.cancelPreview';

import ELC_PREVIEW_STATUS from '@salesforce/schema/Engagement_List_Criteria__c.Preview_Status__c';
import ELC_PREVIEW_URL from '@salesforce/schema/Engagement_List_Criteria__c.Preview_Result_URL__c';

const fields = [ELC_PREVIEW_STATUS, ELC_PREVIEW_URL];

export default class GeneratePreviewELC extends LightningElement {
    elcPreviewStatus = ELC_PREVIEW_STATUS;
    elcPreviewUrl = ELC_PREVIEW_URL;
    isLoading = false;
    showCancelPreview;
    showGeneratePreview;
    
    @api recordId;
    @api objectApiName;
    
    @track wireResponse;
    record;
    error;

    @wire(getRecord, { recordId: "$recordId", fields })
    wiredElc(response) {
        this.wireResponse = response;
        const { data, error } = response;
        if(data) {
            this.record = data;
            let previewStatus = this.record.fields.Preview_Status__c.value;
            if(previewStatus == 'In Progress') {
                this.showCancelPreview = true;
                this.showGeneratePreview = false;
            } else {
                this.showCancelPreview = false;
                this.showGeneratePreview = true;
            }
            this.error = undefined;
        } else if(error){
            this.record = undefined;
            this.error = error;
        }
    }

    async handleGeneratePreview() {
        this.isLoading = true;
        try {
            await refreshApex(this.wireResponse);
            console.log(this.record.fields.Preview_Status__c.value);
            await GeneratePreviewELCModal.open({
                size: 'small',
                recordId: this.recordId,
                previewStatus: this.record.fields.Preview_Status__c.value
            })
        } catch(error) {
            this.error = error;
        }
        this.isLoading = false;
    }

    async handleCancelPreview() {
        this.isLoading = true;
        try {
            await refreshApex(this.wireResponse);
            if(this.record.fields.Preview_Status__c.value == 'In Progress') {
                await cancelPreview({ recordId: this.recordId });
                await notifyRecordUpdateAvailable([{ recordId : this.recordId }]);
                const evt = new ShowToastEvent({
                    title: 'Preview Cancelled',
                    message: 'The preview has been cancelled.',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Unable to Cancel Preview',
                    message: 'A preview is not in progress. Please refresh the page.',
                    variant: 'info'
                });
                this.dispatchEvent(evt);
            }
            this.error = undefined;
        } catch(error) {
            this.error = error;
            console.log(error);
        }
        this.isLoading = false;
    }
}