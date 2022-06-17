import { LightningElement, wire, api, track } from "lwc";
import overview from "@salesforce/label/c.QUT_ProductDetail_Overview";
import duration from "@salesforce/label/c.QUT_ProductDetail_Duration";
import professionalDevelopmentModules from "@salesforce/label/c.QUT_ProductDetail_Professional_Development_Modules";
import facilitator from "@salesforce/label/c.QUT_ProductDetail_Facilitator";
import evolveWithQUTeX from "@salesforce/label/c.QUT_ProductDetail_EvolveWithQUTeX";
import whoShouldParticipate from "@salesforce/label/c.QUT_ProductDetail_WhoShouldParticipate";
import coreConcepts from "@salesforce/label/c.QUT_ProductDetail_CoreConcepts";
import details from "@salesforce/label/c.QUT_ProductDetail_Details";
import delivery from "@salesforce/label/c.QUT_ProductDetail_Delivery";
import deliveryPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Delivery_Placeholder";
import availableStartDates from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates";
import availableStartDatesPlaceholder from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates_Placeholder";
import pricing from "@salesforce/label/c.QUT_ProductDetail_Pricing";
import pricingPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Pricing_Placeholder";
import addToCart from "@salesforce/label/c.QUT_ProductDetail_AddToCart";
import registerInterest from "@salesforce/label/c.QUT_ProductDetail_RegisterInterest";
import getRelatedCourseOffering from "@salesforce/apex/ProductDetailsCtrl.getCourseOfferingRelatedRecords";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";

import getQuestions from "@salesforce/apex/ProductDetailsCtrl.getQuestions";
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

  disableDelivery;
  @track courseOfferings = [];
  @track selectedCourseOffering;
  @track selectedPriceBookEntry;
  @track disableAvailStartDate = true;
  @track disablePriceBookEntry = true;
  @track displayAddToCart;
  @track displayRegisterInterest;
  @track displayGroupRegistration = false;

  @track selectedDelivery;
  //availablePricings = [];
  displayQuestionnaire = false;
  priceBookEntriesCopy = [];

  label = {
    overview,
    duration,
    professionalDevelopmentModules,
    facilitator,
    evolveWithQUTeX,
    whoShouldParticipate,
    coreConcepts,
    details,
    delivery,
    deliveryPlaceholder,
    availableStartDates,
    availableStartDatesPlaceholder,
    pricing,
    pricingPlaceholder,
    addToCart,
    registerInterest
  };

  renderedCallback() {
    Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
  }
  responseData = [];
  questions;

  connectedCallback() {
    console.log("this.product: " + JSON.stringify(this.product));
    this.productDetails = this.product.productDetails;
    this.priceBookEntries = this.product.priceBookEntryList;
    this.deliveryOptions = this.product.deliveryOptions;
    this.cProducts = this.product.cProducts;
    this.hasChildProducts = this.cProducts.length == 0 ? false : true;
    this.isNotFlexProgram = this.product.isNotFlexProgram;
    this.accordionIcon = qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
    this.durationIcon = qutResourceImg + "/QUTImages/Icon/duration.svg";
    this.pdmStaticText =
      "Each " +
      this.productDetails.Name +
      "Professional Development Module is a stand-alone course. Choose the expertise you need and explore each topic to find the time frame that suits you.";
    this.disableDelivery = this.deliveryOptions.length == 0 ? true : false;

    let pricingsLocal = [];
    this.priceBookEntries.forEach(function (priceBookEntry) {
      pricingsLocal.push({
        label:
          priceBookEntry.label === "Standard Price Book"
            ? priceBookEntry.label.slice(0, 8)
            : priceBookEntry.label,
        value: priceBookEntry.value,
        meta: parseInt(priceBookEntry.meta).toLocaleString("en-US", {
          style: "currency",
          currency: "USD",
          minimumFractionDigits: 0
        })
      });
    });

    if (this.productDetails.Course__c) {
      getQuestions({
        productReqId: this.productDetails.Course__r.ProductRequestID__c
      })
        .then((results) => {
          if (results.length > 0) {
            this.responseData = results;
            this.questions = results;
            this.priceBookEntriesCopy = JSON.parse(
              JSON.stringify(pricingsLocal)
            ).filter((row) => row.label != "Group Booking");
          } else {
            this.priceBookEntriesCopy = pricingsLocal;
          }
        })
        .catch((e) => {
          this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
        });
    }

    // Display AddToCart / Register Interest
    if (
      this.deliveryOptions.length == 0 &&
      this.productDetails.Register_Interest_Available__c == true
    ) {
      this.displayAddToCart = false;
      this.displayRegisterInterest = true;
    } else {
      this.displayAddToCart = true;
      this.displayRegisterInterest = false;
      this.displayGroupRegistration = false;
    }
    this.priceBookEntriesCopy = pricingsLocal;
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
      /*accordionIcon.setAttribute(
        "src",
        qutResourceImg + "/QUTImages/Icon/accordionOpen.svg"
      );*/
    }
  }

  handlePreviousFacilitator() {
    if (this.facilitatorIndex == 0) {
      this.facilitatorIndex = this.selectedCourseOfferingFacilitator.length - 1;
    } else {
      this.facilitatorIndex--;
    }
    this.facilitator =
      this.selectedCourseOfferingFacilitator[this.facilitatorIndex];
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
    this.facilitator =
      this.selectedCourseOfferingFacilitator[this.facilitatorIndex];
  }

  handleDeliverySelected(event) {
    this.selectedDelivery = event.detail.value;

    getRelatedCourseOffering({
      courseId: this.productDetails.Course__c,
      deliveryParam: this.selectedDelivery
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
        this.displayAddToCart = true;
        this.disableAddToCart = true;
        this.displayGroupRegistration = false;
        this.displayQuestionnaire = false;

        if (results.length > 0) {
          this.courseOfferings = results;
          this.disableAvailStartDate = false;
        }
      })
      .catch((e) => {
        this.generateToast("Error.", LWC_Error_General, "error");
      });
  }

  handleStartDateSelected(event) {
    this.displayFacilitatorNav = true;
    this.selectedCourseOffering = event.detail.value;
    this.courseOfferings.forEach((cOffer) => {
      if (cOffer.value === this.selectedCourseOffering) {
        this.selectedCourseOfferingFacilitator = cOffer.facilitator;
        if (this.selectedCourseOfferingFacilitator.length > 0) {
          this.facilitator =
            this.selectedCourseOfferingFacilitator[this.facilitatorIndex];
          if (this.selectedCourseOfferingFacilitator.length == 1) {
            this.displayFacilitatorNav = false;
          }
        }
      }
    });
    this.disablePriceBookEntry = false;
    this.displayAddToCart = true;
    this.disableAddToCart = true;
  }

  // Set Selected Price Book Entry value
  handlePricebookSelected(event) {
    let selectedPBLabel = event.detail.label;
    this.selectedPriceBookEntry = event.detail.value;

    if (this.isInternalUser == true) {
      this.disableAddToCart = true;
    } else {
      this.disableAddToCart = false;
      this.displayGroupRegistration = false;
    }

    if (selectedPBLabel == "Group Booking") {
      this.displayAddToCart = false;
      this.disableAddToCart = true;
      this.displayGroupRegistration = true;
      if (this.responseData.length > 0) {
        this.displayQuestionnaire = true;
      } else {
        this.displayQuestionnaire = false;
      }
    } else {
      this.displayGroupRegistration = false;
      this.displayAddToCart = true;
      this.disableAddToCart = false;
      if (this.responseData.length > 0) {
        this.displayQuestionnaire = true;
        this.displayAddToCart = false;
        this.disableAddToCart = true;
      } else {
        this.displayQuestionnaire = false;
        this.displayAddToCart = true;
        this.disableAddToCart = false;
      }
    }
  }

  notifyAddToCart() {
    console.log("Internal User");
  }
}
