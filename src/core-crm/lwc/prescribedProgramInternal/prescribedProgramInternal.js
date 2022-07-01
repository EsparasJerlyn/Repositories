/**
 * @description A LWC component to display product details for Prescribed Program in CRM Preview
 *
 * @see ../classes/ProductDetailsCtrl.cls
 * @see PrescribedProgramInternal
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | john.bo.a.pineda          | June 29, 2022         | DEPP-3323            | Modified logic for button display for Apply  |
*/
import { LightningElement, api, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import userId from "@salesforce/user/Id";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";
import delivery from "@salesforce/label/c.QUT_ProductDetail_Delivery";
import deliveryPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Delivery_Placeholder";
import availableStartDates from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates";
import availableStartDatesPlaceholder from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates_Placeholder";
import registerInterest from "@salesforce/label/c.QUT_ProductDetail_RegisterInterest";
import pricing from "@salesforce/label/c.QUT_ProductDetail_Pricing";
import pricingPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Pricing_Placeholder";
import addToCart from "@salesforce/label/c.QUT_ProductDetail_AddToCart";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import getQuestions from "@salesforce/apex/ProductDetailsCtrl.getQuestions";

const INTEREST_EXISTS_ERROR =
  "You already registered your interest for this product.";

export default class PrescribedProgramInternal extends LightningElement {
  @api product;
  @api isInternalUser;
  productDetails;
  programModules;
  priceBookEntries;
  professionalDevelopmentModuleDescription;
  showOverview;
  showProgramModules;
  showProgramModulesList;

  deliveryTypeAndStartDates = {};
  @api availableDeliveryTypes = [];
  @api selectedDeliveryType;
  availableProgramOfferings = [];
  selectedProgramOffering = "";
  availablePricings = [];
  selectedPricing = "";

  @track disableProgramOfferings = true;
  @track disablePricing = true;
  @track disableAddToCart = true;
  @track displayAddToCart = true;
  @track displayQuestionnaire = false;
  @track openModal = false;
  @track displayGroupRegistration = false;
  @track openGroupRegistration;
  @track openGroupBookingModal;
  @track displayGroupButton = false;
  @track isPrescribed = true;
  @track displayRegisterInterest;

  responseData;
  questions;

  label = {
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

  connectedCallback() {
    this.productDetails = this.product.productDetails;
    this.programModules = this.product.programModules;
    this.priceBookEntries = this.product.priceBookEntryList;
    this.showOverview = true;
    this.showProgramModules = true;
    this.professionalDevelopmentModuleDescription =
      "Each " +
      this.productDetails.Name +
      " Development Module is mandatory as part of this program.";
    let pricingsLocal = [];
    let pricingLabel;
    this.product.priceBookEntryList.forEach(function (priceBookEntry) {
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
    this.availablePricings = pricingsLocal;
    for (let deliveryType in this.product.programDeliveryAndOfferings) {
      this.availableDeliveryTypes.push({
        label: deliveryType,
        value: deliveryType
      });
      this.deliveryTypeAndStartDates[deliveryType] =
        this.product.programDeliveryAndOfferings[deliveryType];
    }
    this.accordionIcon = qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
    this.durationIcon = qutResourceImg + "/QUTImages/Icon/duration.svg";

    this.displayRegisterInterest = false;
    this.displayGroupRegistration = false;
    this.displayQuestionnaire = false;
    this.displayAddToCart = true;

    if (this.productDetails.Program_Plan__c) {
      getQuestions({
        productReqId: this.productDetails.Program_Plan__r.Product_Request__c
      })
        .then((results) => {
          if (results.length > 0) {
            this.displayQuestionnaire = true;
            this.displayAddToCart = false;
            this.responseData = results;
            this.questions = results;
            this.availablePricings = JSON.parse(
              JSON.stringify(this.availablePricings)
            ).filter((row) => row.label != "Group Booking");
          }
        })
        .catch((e) => {
          this.generateToast("Error.", LWC_Error_General, "error");
        })
        .finally(() => {
          // Display AddToCart / Register Interest
          this.displayRegisterInterest = false;
          if (
            this.availableDeliveryTypes.length == 0 &&
            this.productDetails.Register_Interest_Available__c == true
          ) {
            this.displayAddToCart = false;
            this.displayQuestionnaire = false;
            this.displayRegisterInterest = true;
          }
        });
    }
  }

  get disableDelivery() {
    return this.availableDeliveryTypes.length == 0 ? true : false;
  }

  get hasQuestions() {
    return this.questions && this.questions.length > 0 ? true : false;
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
      let meta = "";
      if (
        programOfferingLocal.availableSeats == 10 &&
        programOfferingLocal.availableSeats > 1
      ) {
        meta =
          programOfferingLocal.availableSeats + " seat left for this course";
      } else if (programOfferingLocal.availableSeats <= 10) {
        meta =
          programOfferingLocal.availableSeats + " seats left for this course";
      }

      availableProgramOfferingsLocal.push({
        label: programOfferingLocal.startDate,
        value: programOfferingLocal.id,
        meta: meta
      });
    });

    this.availableProgramOfferings = availableProgramOfferingsLocal;
    this.disableProgramOfferings = false;
    this.selectedProgramOffering = undefined;
    this.selectedPricing = undefined;
    this.disablePricing = true;
    this.displayGroupRegistration = false;
    this.displayQuestionnaire = false;
    this.disableAddToCart = true;
    this.displayAddToCart = true;
    if (this.hasQuestions) {
      this.displayQuestionnaire = true;
      this.displayAddToCart = false;
    }
  }

  handleProgramOfferingSelected(event) {
    this.selectedProgramOffering = event.detail.value;
    this.selectedPricing = undefined;
    this.disablePricing = false;
    this.displayGroupRegistration = false;
    this.displayQuestionnaire = false;
    this.disableAddToCart = true;
    this.displayAddToCart = true;
    if (this.hasQuestions) {
      this.displayQuestionnaire = true;
      this.displayAddToCart = false;
    }
  }

  handlePricingSelected(event) {
    let selectedPBLabel = event.detail.label;
    this.selectedPricing = event.detail.value;
    if (this.isInternalUser == true) {
      this.disableAddToCart = true;
    } else {
      this.disableAddToCart = false;
      this.displayGroupRegistration = false;
    }
    if (selectedPBLabel == "Group Booking") {
      this.displayAddToCart = false;
      this.displayGroupRegistration = true;
      this.disableAddToCart = true;
      if (this.hasQuestions) {
        this.displayAddToCart = false;
        this.displayGroupRegistration = false;
        this.disableAddToCart = true;
        this.displayQuestionnaire = true;
      }
    } else {
      this.displayGroupRegistration = false;
      this.displayAddToCart = true;
      this.disableAddToCart = false;
    }
    if (this.hasQuestions) {
      this.displayAddToCart = false;
      this.displayGroupRegistration = false;
      this.disableAddToCart = true;
      this.displayQuestionnaire = true;
    }
  }

  handleModalClosed() {
    this.openModal = false;
  }
  groupRegistrationModalClosed() {
    this.openGroupRegistration = false;
  }

  // Creates toast notification
  generateToast(_title, _message, _variant) {
    const evt = new ShowToastEvent({
      title: _title,
      message: _message,
      variant: _variant
    });
    this.dispatchEvent(evt);
  }
}
