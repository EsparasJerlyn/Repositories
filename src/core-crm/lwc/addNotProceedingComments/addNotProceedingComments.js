/**
 * @description A LWC component to display not proceeding modal
 *
 * @see ../classes/productRequestList.js
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                        |
      |---------------------------|-----------------------|----------------------|---------------------------------------|
      | eccarius.karl.munoz       | March 21, 2022        | DEPP-1888            | Added file for Not Proceeding Modal   |
 */

import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MODAL_TITLE = 'Not Proceeding';

export default class AddNotProceedingComments extends LightningElement {

    isModalOpen = false;
    notProceedingComment = '';

    /**
     * Opens the modal
     */
    @api openSelectionModal(notProceedingComments) {        
        this.isModalOpen = true;        
        this.notProceedingComment = notProceedingComments;
    }

    /**
     * Closes the modal
     */
    closeModalAction(){
        this.isModalOpen = false;
    }

    /**
     * Handles Saving of modal. Dispatches an event to productRequestList
     */
    handleModalSave(){
        let notProceedingComments = this.template.querySelector('lightning-textarea').value;
        if(notProceedingComments && this.notProceedingComment != notProceedingComments){
            const editEvent = new CustomEvent('save', {
                detail: notProceedingComments
            });
            this.dispatchEvent(editEvent); 
            this.isModalOpen = false;
        }else{
            const evt = new ShowToastEvent({
                title: 'Error!',
                message: 'Not Proceeding Reason is required when stage is Not Proceeding.',
                variant: 'error',
            });
            this.dispatchEvent(evt);            
        }
    }    

    /**
     * Gets modal title
     */
    get modalTitle() {return MODAL_TITLE;}
}