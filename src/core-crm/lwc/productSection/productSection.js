import { LightningElement, api, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";

export default class ProductDetailsSectionCard extends LightningElement {
    @api sectionid;
    @api title;
    @api value;
    @api expand;
    @api showvalue;
    iconsrc;

    renderedCallback() {
        Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
        let sectionBlock = this.template.querySelector(
            ".slds-accordion__section"
        );
        if (!this.showvalue) {
            sectionBlock.className = "slds-accordion__section";
            this.iconsrc =
                qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
        } else {
            sectionBlock.className = "slds-accordion__section slds-is-open";
            this.iconsrc = qutResourceImg + "/QUTImages/Icon/accordionOpen.svg";
        }
    }

    handleAccordionToggle(event) {
        console.log("handleAccordionToggle is called");
        let containerSection = event.currentTarget.closest("section");
        containerSection.classList.toggle("slds-is-open");
        if (!this.showvalue) {
            this.showvalue = true;
            this.expand = "true";
        } else {
            this.showvalue = false;
            this.expand = "false";
        }
        const toggleSectionEvent = new CustomEvent("togglesection", {
            detail: {
                id: this.sectionid,
                value: this.showvalue,
            },
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(toggleSectionEvent);
    }

    toggleSection(event) {
        let containerSection = event.currentTarget.closest("section");
        containerSection.classList.toggle("slds-is-open");
        if (!this.showvalue) {
            this.showvalue = true;
            this.expand = "true";
        } else {
            this.showvalue = false;
            //this.expand = "false";
        }
        const toggleSectionEvent = new CustomEvent("togglesection", {
            detail: {
                id: this.sectionid,
                value: this.showvalue,
            },
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(toggleSectionEvent);
    }

}
