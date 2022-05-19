import { LightningElement, api, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";
import delivery from "@salesforce/label/c.QUT_ProductDetail_Delivery";
import deliveryPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Delivery_Placeholder";
import availableStartDates from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates";
import availableStartDatesPlaceholder from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates_Placeholder";
import pricing from "@salesforce/label/c.QUT_ProductDetail_Pricing";
import pricingPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Pricing_Placeholder";
import addToCart from "@salesforce/label/c.QUT_ProductDetail_AddToCart";

export default class PrescribedProgram extends LightningElement {
    @api product;
    @api isInternalUser;
    productDetails;
    programModules;
    priceBookEntries;
    professionalDevelopmentModuleDescription;
    programLocation;
    showOverview;
    showProgramModules;
    showProgramModulesList;
    showLocation;
    
    deliveryTypeAndStartDates = {};
    @api availableDeliveryTypes = [];
    @api selectedDeliveryType;
    availableProgramOfferings = [];
    selectedProgramOffering='';
    availablePricings = [];
    selectedPricing='';

    @track disableProgramOfferings = true;
    @track disablePricing = true;
    @track disableAddToCart = true;
    @track displayAddToCart = true;

    label = {
        delivery,
        deliveryPlaceholder,
        availableStartDates,
        availableStartDatesPlaceholder,
        pricing,
        pricingPlaceholder,
        addToCart,
    };

    renderedCallback() {
        Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
    }

    connectedCallback() {
        this.productDetails = this.product.productDetails;
        this.programModules = this.product.programModules;
        this.priceBookEntries = this.product.priceBookEntryList;
        this.showOverview = true;
        this.showProgramModules = true;
        this.showLocation = true;
        this.professionalDevelopmentModuleDescription =
            "Each " +
            this.productDetails.Name +
            "Development Module is mandatory as part of this program.";
        this.programLocation =
            this.productDetails.Program_Plan__r.Location__r.Display_Name__c;
        let pricingsLocal = [];
        this.product.priceBookEntryList.forEach(function (priceBookEntry) {
            pricingsLocal.push({
                label: priceBookEntry.label,
                value: priceBookEntry.value,
                meta: priceBookEntry.meta
            });
        });
        this.availablePricings = pricingsLocal;
        for (let deliveryType in this.product.programDeliveryAndOfferings) {
            this.availableDeliveryTypes.push({
                label: deliveryType,
                value: deliveryType,
            });
            this.deliveryTypeAndStartDates[deliveryType] =
                this.product.programDeliveryAndOfferings[deliveryType];
        }
        this.accordionIcon =
            qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
        this.durationIcon = qutResourceImg + "/QUTImages/Icon/duration.svg";
    }

    get disableDelivery() {
        return this.availableDeliveryTypes.length == 0 ? true : false;
    }

    handleSectionToggle(event) {
        event.stopPropagation();
        let sourceId = event.detail.id;
        let value = event.detail.value;
        if (sourceId == "pp_programDevelopmentModules") {
            this.showProgramModulesList = value;
        } else {
            this.showProgramModulesList = false;
        }
        let eventSource = event.currentTarget;
        let parentSection = event.currentTarget.closest("ul");
        let productSectionComponents =
            parentSection.querySelectorAll("c-product-section");
        for (let i = 0; i < productSectionComponents.length; i++) {
            if (
                eventSource != productSectionComponents[i] &&
                productSectionComponents[i].showvalue == true
            ) {
                productSectionComponents[i].expand = "false";
                productSectionComponents[i].showvalue = false;
            }
        }
    }

    handleDeliveryTypeSelected(event) {
        this.selectedDeliveryType = event.detail.value;
        let availableProgramOfferingsLocal = [];
        let programOfferingsLocal = [];
        programOfferingsLocal =
            this.deliveryTypeAndStartDates[this.selectedDeliveryType];
        programOfferingsLocal.forEach(function (programOfferingLocal) {
            let meta = '';
            if(programOfferingLocal.availableSeats==10 && programOfferingLocal.availableSeats>1){
                meta = programOfferingLocal.availableSeats +
                " seat left for this course";
            } else if (programOfferingLocal.availableSeats<=10){
                meta = programOfferingLocal.availableSeats +
                " seats left for this course";
            }
                
            availableProgramOfferingsLocal.push({
                label: programOfferingLocal.startDate,
                value: programOfferingLocal.id,
                meta: meta,
            });
        });
        this.availableProgramOfferings = availableProgramOfferingsLocal;
        this.disableProgramOfferings = false;
        this.selectedProgramOffering = undefined;
        this.selectedPricing = undefined;
        this.disablePricing = true;
        this.disableAddToCart = true;
    }

    handleProgramOfferingSelected(event) {
        this.selectedProgramOffering = event.detail.value;
        this.selectedPricing = undefined;
        this.disablePricing = false;
        this.disableAddToCart = true;
    }

    handlePricingSelected(event) {
        this.selectedPricing = event.detail.value;
        if(this.isInternalUser == true){
            this.disableAddToCart = true;
        } else{
            this.disableAddToCart = false;            
        }
        this.priceBookEntries.forEach((pBookEntry) => {
            if (pBookEntry.value === this.selectedPricing &&
                pBookEntry.label == "Group Booking" ) {                    
                this.displayAddToCart = false;
            } else {
                this.displayAddToCart = true;
            }
        });
    }

    notifyAddToCart() {
        this.dispatchEvent(
            new CustomEvent("addtocart", {
                detail: {
                    programOfferingId: this.selectedProgramOffering,
                    pricebookEntryId: this.selectedPricing,
                },
            })
        );
    }
}
