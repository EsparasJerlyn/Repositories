import { LightningElement, wire, api, track } from "lwc";
import overview from "@salesforce/label/c.QUT_ProductDetail_Overview";
import duration from "@salesforce/label/c.QUT_ProductDetail_Duration";
import professionalDevelopmentModules from "@salesforce/label/c.QUT_ProductDetail_Professional_Development_Modules";
import facilitator from "@salesforce/label/c.QUT_ProductDetail_Facilitator";
import evolveWithQUTeX from "@salesforce/label/c.QUT_ProductDetail_EvolveWithQUTeX";
import whoShouldParticipate from "@salesforce/label/c.QUT_ProductDetail_WhoShouldParticipate";
import coreConcepts from "@salesforce/label/c.QUT_ProductDetail_CoreConcepts";
import location from "@salesforce/label/c.QUT_ProductDetail_Location";
import details from "@salesforce/label/c.QUT_ProductDetail_Details";
import delivery from "@salesforce/label/c.QUT_ProductDetail_Delivery";
import deliveryPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Delivery_Placeholder";
import availableStartDates from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates";
import availableStartDatesPlaceholder from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates_Placeholder";
import pricing from "@salesforce/label/c.QUT_ProductDetail_Pricing";
import pricingPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Pricing_Placeholder";
import addToCart from "@salesforce/label/c.QUT_ProductDetail_AddToCart";
import getRelatedCourseOffering from "@salesforce/apex/ProductDetailsCtrl.getCourseOfferingRelatedRecords";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";

import { loadStyle } from "lightning/platformResourceLoader";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";

export default class ProductDetailsDisplay extends LightningElement {
  @api product;
  @api isInternalUser;
  productDetails;
  priceBookEntries;
  deliveryOptions;
  cProducts;
  isNotFlexProgram;
  pdmStaticText;
  hasChildProducts;
  facilitator;
  @track displayFacilitatorNav = true;
  @track facilitatorIndex = 0;
  @track selectedCourseOfferingFacilitator = [];
  @track selectedCourseOfferingLocation;

  disableDelivery;
  @track courseOfferings = [];
  @track selectedCourseOffering;
  @track selectedPriceBookEntry;
  @track disableAvailStartDate = true;
  @track disablePriceBookEntry = true;
  @track disableAddToCart = true;

  label = {
    overview,
    duration,
    professionalDevelopmentModules,
    facilitator,
    evolveWithQUTeX,
    whoShouldParticipate,
    coreConcepts,
    location,
    details,
    delivery,
    deliveryPlaceholder,
    availableStartDates,
    availableStartDatesPlaceholder,
    pricing,
    pricingPlaceholder,
    addToCart
  }

  renderedCallback() {
    Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
  }

  connectedCallback(){
    console.log('this.product: '+JSON.stringify(this.product));
    this.productDetails = this.product.productDetails;
    this.priceBookEntryList = this.product.priceBookEntryList;
    this.deliveryOptions = this.product.deliveryOptions;
    this.cProducts = this.product.cProducts;
    this.hasChildProducts = this.cProducts.length == 0 ? false : true;
    this.isNotFlexProgram = this.product.isNotFlexProgram;
    this.accordionIcon = qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
    this.durationIcon = qutResourceImg + "/QUTImages/Icon/duration.svg";
    this.pdmStaticText =  "Each " + this.productDetails.Name + "Professional Development Module is a stand-alone course. Choose the expertise you need and explore each topic to find the time frame that suits you.";
    this.disableDelivery = this.deliveryOptions.length == 0 ? true : false;
  }

    handleAccordionToggle(event) {
      let accordionAriaExpanded = event.currentTarget;
      let accordionSection = event.currentTarget.closest("section");
      let accordionContent = accordionSection.querySelector(".accordionContent");
      let accordionIcon = accordionSection.querySelector(".slds-button__icon");
      accordionSection.classList.toggle("slds-is-open");
      if (accordionAriaExpanded.getAttribute("aria-expanded") == "true") {
        accordionAriaExpanded.setAttribute("aria-expanded", "false");
        accordionContent.setAttribute("hidden");
        accordionIcon.setAttribute(
          "src",
          qutResourceImg + "/QUTImages/Icon/accordionClose.svg"
        );
      } else {
        accordionAriaExpanded.setAttribute("aria-expanded", "true");
        accordionContent.removeAttribute("hidden");
        accordionIcon.setAttribute(
          "src",
          qutResourceImg + "/QUTImages/Icon/accordionOpen.svg"
        );
      }
    }

    handlePreviousFacilitator() {
      if (this.facilitatorIndex == 0) {
        this.facilitatorIndex = this.selectedCourseOfferingFacilitator.length - 1;
      } else {
        this.facilitatorIndex--;
      }
      this.facilitator = this.selectedCourseOfferingFacilitator[this.facilitatorIndex];
    }
  
    handleNextFacilitator() {
      if (
        this.facilitatorIndex ==
        this.selectedCourseOfferingFacilitator.length - 1
      ) {
        this.facilitatorIndex = 0;
      } else {
        this.facilitatorIndex++;
      }
      this.facilitator = this.selectedCourseOfferingFacilitator[this.facilitatorIndex];
    }

    handleDeliverySelected(event) {
      if (event.detail) {
        let yourSelectedValues = [];  
        event.detail.forEach(function (eachItem) {
          yourSelectedValues.push(eachItem.value);
        });  
        getRelatedCourseOffering({
          courseId: this.productDetails.Course__c,
          deliveryParam: yourSelectedValues
        })
          .then((results) => {
            this.courseOfferings = undefined;
            this.selectedCourseOffering = undefined;
            this.selectedCourseOfferingLocation = undefined;
            this.selectedCourseOfferingFacilitator = undefined;
            this.facilitator = undefined;
            this.displayFacilitatorNav = true;
            this.facilitatorIndex = 0;
            this.selectedPriceBookEntry = undefined;
            this.disableAvailStartDate = true;
            this.disablePriceBookEntry = true;
            this.disableAddToCart = true;
  
            if (results.length > 0) {
              this.courseOfferings = results;
              this.disableAvailStartDate = false;
            }
          })
          .catch((e) => {
            this.generateToast("Error.", LWC_Error_General, "error");
          });
      }
    }

    handleStartDateSelected(event) {
      this.displayFacilitatorNav = true;
      this.selectedCourseOffering = event.detail.value;
      this.courseOfferings.forEach((cOffer) => {
        if (cOffer.value === this.selectedCourseOffering) {
          this.selectedCourseOfferingLocation = cOffer.location;
          this.selectedCourseOfferingFacilitator = cOffer.facilitator;
          if (this.selectedCourseOfferingFacilitator.length > 0) {
            this.facilitator = this.selectedCourseOfferingFacilitator[this.facilitatorIndex];
            if (this.selectedCourseOfferingFacilitator.length == 1) {
              this.displayFacilitatorNav = false;
            }
          }
        }
      });
      this.disablePriceBookEntry = false;
    }

    handlePricebookSelected(event) {
      this.selectedPriceBookEntry = event.detail.value;
      if(this.isInternalUser == true){
        this.disableAddToCart = true;
      } else{
        this.disableAddToCart = false;            
      }
      this.priceBookEntries.forEach((pBookEntry) => {
        if (pBookEntry.value === this.selectedPriceBookEntry && pBookEntry.label == "Group Booking" ) {
          this.displayAddToCart = false;
        } else {
          this.displayAddToCart = true;
        }
      });
    }

    notifyAddToCart() {
      console.log('Internal User');
    }
  
  
}
