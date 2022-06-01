import { LightningElement, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
const MODULE = 'Module';

export default class ProgramModule extends LightningElement {
    @api programModule;

    renderedCallback() {
        Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
    }

    connectedCallback() {
        this.durationIcon = qutResourceImg + "/QUTImages/Icon/duration.svg";
    }

    navigateToProductDetailPage() {
        const viewProductEvent = new CustomEvent("viewproduct", {
            detail: {
                value: this.programModule,
            },
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(viewProductEvent);
    }

    get getSequence(){
        return this.programModule.sequence;
    }
}