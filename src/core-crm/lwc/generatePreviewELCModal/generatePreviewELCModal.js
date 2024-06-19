import { api } from 'lwc';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import LightningModal from 'lightning/modal';
import processPreview from '@salesforce/apex/OutreachCampaignPreviewController.processPreview';

export default class GeneratePreviewELCModal extends LightningModal {
    @api recordId;
    @api previewStatus;

    dateToday;
    dateInput;
    error;
    showCloseButton;
    showConfirmation;
    showDateSelect;
    showError = false;
    showIsGenerating;
    showLoading;

    connectedCallback() {
        if(this.previewStatus == 'In Progress') {
            this.showIsGenerating = true;
            this.showCloseButton = true;
        } else {
            this.showDateSelect = true;
        }
        var currentDate=new Date(new Date().toISOString().substring(0, 10));
        this.dateToday = currentDate.toISOString();
    }

    handleCancel() {
        this.close();
    }

    handleClose() {
        this.close();
    }

    async handleGenerate() {
        this.showLoading = true;
        this.disableClose = true;
        try{
            const allValid = [
                ...this.template.querySelectorAll('lightning-input'),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if(allValid) {
                this.dateInput = this.template.querySelector('.inputDate').value;
                await processPreview({ recordId: this.recordId, dateInput: this.dateInput });
                await notifyRecordUpdateAvailable([{recordId : this.recordId}]);
                this.error = undefined;
                this.showDateSelect = false;
                this.showConfirmation = true;
                this.showCloseButton = true;
                console.log('The process successfully finished.');
            }
        } catch(error) {
            this.error = error.body.message;
            this.showError = true;
            this.showCloseButton = false;
            this.showConfirmation = false;
            this.showDateSelect = false;
            this.showIsGenerating = false;
            console.log('The process failed with errors:');
            console.log(this.error);
        }
        this.disableClose = false;
        this.showLoading = false;
    }
}