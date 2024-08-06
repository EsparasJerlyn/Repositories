import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import updateLeadVoiceCall from '@salesforce/apex/AddNewLeadCtrl.updateVoiceCallRelatedLead';
import updateMessagingSession from '@salesforce/apex/AddNewLeadCtrl.updateMessagingSessionRelatedLead';

const SUCCESS_RESPONSE = 'Success';
const SUCCESS_MSG = 'Record(s) successfully saved.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';

export default class LeadCreationComponent extends LightningElement {
    @api recordId; 
    @api objectApiName;
    isLoading = false;

    handleSuccess(event) {
        let response;
        if (this.objectApiName == 'MessagingSession'){
            updateMessagingSession({ recordId : this.recordId, createdLeadId : event.detail.id})
                    .then((result) => {
                        response = result;
                    })
                    .catch((error) => {                    
                        response = error;
                    })
                    .finally(() => {    
                        if(response == SUCCESS_RESPONSE) {
                            this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
                            this.resetFormAction(event);
                        } else {
                            this.generateToast(ERROR_TITLE, response, ERROR_VARIANT);
                        }
                        this.isLoading = !this.isLoading;
                    });
        } else if (this.objectApiName == 'VoiceCall'){
            updateLeadVoiceCall({ recordId : this.recordId, createdLeadId : event.detail.id})
                    .then((result) => {
                        response = result;
                    })
                    .catch((error) => {                    
                        response = error;
                    })
                    .finally(() => {    
                        if(response === SUCCESS_RESPONSE) {
                            this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
                            this.resetFormAction(event);
                        } else {
                            this.generateToast(ERROR_TITLE, response, ERROR_VARIANT);
                        }
                        this.isLoading = !this.isLoading;
                    });
        }
    }

    handleSubmit(event) {
        this.isLoading = !this.isLoading;
        event.preventDefault(); 
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleError(event) {
        const errors = event.detail.detail; 
        const errorMessage = errors?.[0]?.message || 'An unknown error occurred';
        
        const evt = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error'
        });
        this.dispatchEvent(evt);
        this.isLoading = !this.isLoading;
    }

    //Function to generate toastmessage
    generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    //Function to clear Details
    resetFormAction(event) {
        const lwcInputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (lwcInputFields) {
            lwcInputFields.forEach(field => {
                field.reset();
            });
        }
     }
}