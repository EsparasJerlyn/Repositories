/**
 * @description A LWC component to display product details on CRM as Preview
 *
 * @see ../classes/ProductDetailsCtrl.cls
 * @see productDetailsDisplayInternal
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | john.bo.a.pineda          | June 29, 2022         | DEPP-3323            | Modified logic for button display for Apply  |
      | mary.grace.li             | July 04, 2022         | DEPP-3184            | Replaced custom labels with constant         |
*/
import { LightningElement, wire, api, track } from "lwc";
import getRelatedCourseOffering from "@salesforce/apex/ProductDetailsCtrl.getCourseOfferingRelatedRecords";

import getQuestions from "@salesforce/apex/ProductDetailsCtrl.getQuestions";
import { loadStyle } from "lightning/platformResourceLoader";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";

const LWC_ERROR_GENERAL ="An error has been encountered. Please contact your administrator.";
const DELIVERY= "Delivery";
const DELIVERY_PLACEHOLDER= "Choose delivery method";
const AVAILABLE_STARTDATES="Available start dates";
const AVAILABLE_STARTDATES_PLACEHOLDER="Choose start date";
const REGISTER_INTEREST="REGISTER INTEREST";
const PRICING="Pricing";
const PRICING_PLACEHOLDER="Choose pricing";
const ADD_TO_CART="ADD TO CART";
const OVERVIEW ="Overview";
const EVOLVE_WITH_QUTEX="Evolve with QUTeX";
const WHO_SHOULD_PARTICIPATE ="Who should participate";
const CORE_CONCEPTS ="Core concepts";
const FACILITATOR="Facilitator";
const DETAILS="Details";
const DURATION="Duration";
const PROF_DEV_MODULES ="Professional Development Modules";

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

  @track overview;
  @track evolveWithQUTeX;
  @track whoShouldParticipate;
  @track coreConcepts;
  @track facilitator;
  @track details;
  @track duration;
  @track delivery;
  @track deliveryPlaceholder;
  @track availableStartDates;
  @track availableStartDatesPlaceholder;
  @track pricing;
  @track pricingPlaceholder;
  @track addToCart;
  @track registerInterest;
  @track professionalDevelopmentModules;

  label = {
    overview:OVERVIEW,
    evolveWithQUTeX: EVOLVE_WITH_QUTEX,
    whoShouldParticipate: WHO_SHOULD_PARTICIPATE,
    coreConcepts: CORE_CONCEPTS,
    facilitator: FACILITATOR,
    details: DETAILS,
    duration: DURATION,
    delivery: DELIVERY,
    deliveryPlaceholder: DELIVERY_PLACEHOLDER,
    availableStartDates: AVAILABLE_STARTDATES,
    availableStartDatesPlaceholder: AVAILABLE_STARTDATES_PLACEHOLDER,
    pricing: PRICING,
    pricingPlaceholder: PRICING_PLACEHOLDER,
    addToCart: ADD_TO_CART,
    registerInterest: REGISTER_INTEREST,
    professionalDevelopmentModules: PROF_DEV_MODULES
  };

  renderedCallback() {
    Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
  }
  responseData = [];
  questions;

  connectedCallback() {
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

    this.displayRegisterInterest = false;
    this.displayGroupRegistration = false;
    this.displayQuestionnaire = false;
    this.displayAddToCart = true;

    if (this.productDetails.Course__c) {
      getQuestions({
        productReqId: this.productDetails.Course__r.ProductRequestID__c
      })
        .then((results) => {
          this.priceBookEntriesCopy = pricingsLocal;
          if (results.length > 0) {
            this.responseData = results;
            this.displayQuestionnaire = true;
            this.displayAddToCart = false;
            this.questions = results;
            this.priceBookEntriesCopy = JSON.parse(
              JSON.stringify(pricingsLocal)
            ).filter((row) => row.label != "Group Booking");
          }
        })
        .catch((e) => {
          this.generateToast(ERROR_TITLE, LWC_ERROR_GENERAL, ERROR_VARIANT);
        })
        .finally(() => {
          // Display AddToCart / Register Interest
          if (
            this.deliveryOptions.length == 0 &&
            this.productDetails.Register_Interest_Available__c == true
          ) {
            this.displayAddToCart = false;
            this.displayQuestionnaire = false;
            this.displayRegisterInterest = true;
          }
        });
    }
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
        this.disableAddToCart = true;
        this.displayGroupRegistration = false;
        this.displayAddToCart = true;
        this.displayQuestionnaire = false;
        if (this.responseData.length > 0) {
          this.displayAddToCart = false;
          this.displayQuestionnaire = true;
        }

        if (results.length > 0) {
          this.courseOfferings = results;
          this.disableAvailStartDate = false;
        }
      })
      .catch((e) => {
        this.generateToast("Error.", LWC_ERROR_GENERAL, "error");
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
