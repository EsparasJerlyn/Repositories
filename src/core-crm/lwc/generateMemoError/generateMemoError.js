import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class GenerateMemoError extends LightningElement {
  @api recordId;
  @api invoke() {
    this.showToast();
  }

  showToast() {
    const event = new ShowToastEvent({
      title: "Error",
      message: "Please populate Memo Approvers to proceed",
      variant: "error",
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }
}