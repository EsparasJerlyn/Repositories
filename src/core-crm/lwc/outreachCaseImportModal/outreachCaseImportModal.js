import { LightningElement,track } from 'lwc';

export default class OutReachCaseImportModal extends LightningElement {
  
  @track modalOpen = true;
  @track isCreateButtonDisabled = true;

  closeModal() {
    const closeModalEvent = new CustomEvent('closemodal');
    this.dispatchEvent(closeModalEvent);
  }

  get modalClass() {
    return this.modalOpen ? 'slds-modal slds-fade-in-open' : 'slds-modal slds-fade-in-close';
  }

  get backdropClass() {
    return this.modalOpen ? 'slds-backdrop slds-backdrop_open' : 'slds-backdrop slds-backdrop_close';
  }

  handleFileChange(event) {
    if (event.target.files.length > 0) {
        this.isCreateButtonDisabled = false; 
    } else {
        this.isCreateButtonDisabled = true;
    }
}
}