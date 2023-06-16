/**
 * @description LWC that handles the edit and new modals for the dynamicdatatable
 * @see ../lwc/dynamicDataTable
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | roy.nino.s.regala         | June 15, 2023         | DEPP-5391            | Created file                                 |
 */
import { LightningElement, api } from "lwc";

const CSS_CLASS = "modal-hidden";

export default class Modal extends LightningElement {
  @api showModal = false;
  @api showCloseButton = false;

  @api
  set header(value) {
    this.hasHeaderString = value !== "";
    this.headerPivate = value;
  }
  get header() {
    return this.headerPivate;
  }

  get hasBackDrop() {
    return this.showCloseButton ? "slds-backdrop slds-backdrop_open" : "";
  }

  hasHeaderString = false;
  headerPivate;

  @api show() {
    this.showModal = true;
  }

  @api hide() {
    this.showModal = false;
  }

  handleDialogClose() {
    const closedialog = new CustomEvent("closedialog");
    this.dispatchEvent(closedialog);
    this.hide();
  }

  handleSlotTaglineChange() {
    const taglineEl = this.template.querySelector("p");
    taglineEl.classList.remove(CSS_CLASS);
  }

  handleSlotFooterChange() {
    const footerEl = this.template.querySelector("footer");
    footerEl.classList.remove(CSS_CLASS);
  }
}
