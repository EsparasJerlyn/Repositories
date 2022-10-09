/**
 * @description A LWC component for single product details
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | marygrace.li              | October 07, 2022      | DEPP-4550            | Modified to handle hide/show of content      |
      |                           |                       |                      |                                              |
 */

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
        this.showOverview = this.product.productDetails.overview ? true : false;
        this.showEvolveWithQUTeX = this.product.productDetails.evolveWithQUTeX ? true : false;
        this.showWhoShouldParticipate = this.product.productDetails.whoShouldParticipate ? true : false;
        this.showCoreConcepts = this.product.productDetails.coreConcepts ? true : false;
        this.showMoreDetails = this.product.productDetails.moreDetails ? true : false;
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
