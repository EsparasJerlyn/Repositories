import { LightningElement, api } from "lwc";
//import LightningModal from "lightning/modal";

const CSS_CLASS = 'modal-hidden';

export default class CustomModal extends LightningElement {
    showModal = false;
    
    _modalId;
    _modalSize;

    // @api recordTypeId;
    // @api fields;
    // @api objectApiName;
    // @api modalTitle;
  
    // @api isError;
    // @api errorMessage;

    @api
    get modalId() {
        return this._modalId;
    }
    set modalId(value) {
       this._modalId = value;
       this.setAttribute('modal-id',value);
    }

    get modalContentId(){
        return `modal-content-id-${this.modalId}`;
    }

    get modalHeadingId(){
        return `modal-heading-id-${this.modalId}`;
    }
    
    @api
    get modalSize() {
        return `slds-modal slds-fade-in-open ${this._modalSize}`;
    }
    set modalSize(value) {
        this._modalSize = value;
        this.setAttribute('size',value);
    }
    
    @api
    set header(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    get header() {
        return this._headerPrivate;
    }

    hasHeaderString = false;
    _headerPrivate;



    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    handleDialogClose() {
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleSlotTaglineChange() {
        if (this.showModal === false) {
            return;
        }
        const taglineEl = this.template.querySelector('p');
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        if (this.showModal === false) {
            return;
        }
        const footerEl = this.template.querySelector('footer');
        footerEl.classList.remove(CSS_CLASS);
    }
  
    handleSuccess(event) {
        let output = {
          status: "success",
          id: event.detail.id,
          fields: event.detail.fields
        };
        this.close(output);
      }
    
    handleCancel() {
     this.close("cancel");
    }
}