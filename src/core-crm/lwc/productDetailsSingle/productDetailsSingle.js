import { LightningElement, api, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";

export default class ProductDetailsSingle extends LightningElement {
    @api product;
    showOverview;
    showBackToProgram;
    showEvolveWithQUTeX;
    showWhoShouldParticipate;
    showCoreConcepts;
    showMoreDetails

    renderedCallback() {
        Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
    }

    connectedCallback() {
        console.log("this.product" + this.product);
        this.showOverview = true;
        this.showEvolveWithQUTeX = true;
        this.showWhoShouldParticipate = true;
        this.showCoreConcepts = true;
        this.showMoreDetails = true;
        this.durationIcon = qutResourceImg + "/QUTImages/Icon/duration.svg";
    }

    handleSectionToggle(event) {
        event.stopPropagation();
        let eventSource = event.currentTarget;
        let parentSection = event.currentTarget.closest("ul");
        let productSectionComponents =
            parentSection.querySelectorAll(".productSection");
        for (let i = 0; i < productSectionComponents.length; i++) {
            console.log(eventSource != productSectionComponents[i]);
            if (eventSource != productSectionComponents[i]) {
                //Ticket: DEPP-3574 | Removed line below (signle expand and collpased)
                //productSectionComponents[i].expand = "false";
                //productSectionComponents[i].showvalue = false;
            }
        }
    }

    backToProgram() {
        const backToProgram = new CustomEvent("backtoprogram", {
            detail: {
                value: this.product,
            },
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(backToProgram);
    }
}
