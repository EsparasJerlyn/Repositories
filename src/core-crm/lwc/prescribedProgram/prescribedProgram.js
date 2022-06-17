import { LightningElement, api, track, wire } from "lwc";
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
import insertExpressionOfInterest from "@salesforce/apex/ProductDetailsCtrl.insertExpressionOfInterest";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isGuest from "@salesforce/user/isGuest";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import getQuestions from "@salesforce/apex/ProductDetailsCtrl.getQuestions";

const INTEREST_EXISTS_ERROR =
  "You already registered your interest for this product.";


export default class PrescribedProgram extends LightningElement {
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
  @track openModal;
  @track displayGroupRegistration = false;
  @track openGroupRegistration;
  @track openGroupBookingModal;
  @track displayGroupButton = false;
  @track isPrescribed = true;
  @track displayRegisterInterest;
  @track openAddToCartConfirmModal = false;

  responseData;
  questions;
  openApplicationQuestionnaire = false;

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

  @wire(getRecord, { recordId: userId, fields: [CONTACT_ID] })
  user;

  get contactId() {
    return getFieldValue(this.user.data, CONTACT_ID);
  }

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
        label: priceBookEntry.label === 'Standard Price Book'? priceBookEntry.label.slice(0, 8): priceBookEntry.label,
        value: priceBookEntry.value,
        meta: parseInt(priceBookEntry.meta).toLocaleString('en-US', { style: 'currency', currency: 'USD',  minimumFractionDigits: 0 })
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

    // Get Pre-selected Delivery and Start Date
    let getDeliveries = this.productDetails.Delivery__c.replace(";",",");
    let deliverySplit = getDeliveries.split(",");
    let preselected = deliverySplit[0];
    console.log('selectedDeliveryType: ', preselected);
    this.handleDeliveryTypePreSelected(preselected);

    if (this.productDetails.Program_Plan__c) {
      getQuestions({
        productReqId: this.productDetails.Program_Plan__r.Product_Request__c
      })
        .then((results) => {
          if (results.length > 0) {
            this.responseData = results;
            this.questions = results;
            this.availablePricings = JSON.parse(JSON.stringify(this.availablePricings)).filter(row => row.label != 'Group Booking');
          }
        })
        .catch((e) => {
          this.generateToast("Error.", LWC_Error_General, "error");
        });
    }

    // Display AddToCart / Register Interest
    if (
      this.availableDeliveryTypes.length == 0 &&
      this.productDetails.Register_Interest_Available__c == true
    ) {
      this.displayAddToCart = false;
      this.displayRegisterInterest = true;
    } else {
      this.displayAddToCart = true;
      this.displayRegisterInterest = false;
      this.displayGroupRegistration = false;
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

  /**
   * Pre-selected Delivery Type
   */
  handleDeliveryTypePreSelected(selected) {
    this.selectedDeliveryType = selected;
    let availableProgramOfferingsLocal = [];
    let programOfferingsLocal = [];
    programOfferingsLocal =
      this.deliveryTypeAndStartDates[this.selectedDeliveryType];
      console.log('programOfferingsLocal: ', programOfferingsLocal);
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
    this.disableAddToCart = true;

    this.selectedProgramOffering = availableProgramOfferingsLocal[0].value;
    console.log('programOfferingLocal Startdate: ', availableProgramOfferingsLocal[0].label); 
    this.handleProgramOfferingPreSelected(this.selectedProgramOffering);
  }

  handleDeliveryTypeSelected(event) {
    this.selectedDeliveryType = event.detail.value;
    console.log('selectedDel:', this.selectedDeliveryType);
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
    this.disableAddToCart = true;
    this.displayAddToCart = true;
    this.displayGroupRegistration = false;
    this.displayQuestionnaire = false;
  }

  handleProgramOfferingPreSelected(preselected) {
  //  this.selectedProgramOffering = preselected;
    this.selectedPricing = undefined;
    this.disablePricing = false;
    this.disableAddToCart = true;
  }

  handleProgramOfferingSelected(event) {
    this.selectedProgramOffering = event.detail.value;
    console.log('selectedProg:', this.selectedProgramOffering);
    this.selectedPricing = undefined;
    this.disablePricing = false;
    this.disableAddToCart = true;
    this.displayGroupRegistration = false;
    this.displayAddToCart = true;
    this.displayQuestionnaire = false;
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
      if(this.hasQuestions){
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
    if(this.hasQuestions){
      this.displayAddToCart = false;
      this.displayGroupRegistration = false;
      this.disableAddToCart = true;
      this.displayQuestionnaire = true;
    }

  }

  // Register Interest
  registerInterest() {
    if (!isGuest) {
      insertExpressionOfInterest({
        userId: userId,
        productId: this.productDetails.Id
      })
        .then(() => {
          this.generateToast("Success!", "Interest Registered", "success");
        })
        .catch((error) => {

          if (error.body.message == "Register Interest Exists") {
            this.generateToast("Error.", INTEREST_EXISTS_ERROR, "error");
          } else {
            this.generateToast("Error.", LWC_Error_General, "error");
          }
        });
    } else {
      // Display Custom Login Form LWC
      this.openModal = true;
    }
  }

  notifyApply() {
    if (!isGuest) {
      this.openApplicationQuestionnaire = true;
    } else {
      // Display Custom Login Form LWC
      this.openModal = true;
    }
    
  }

  notifyAddToCart() {
    if (!isGuest) {
      this.dispatchEvent(
        new CustomEvent("addtocart", {
          detail: {
            programOfferingId: this.selectedProgramOffering,
            pricebookEntryId: this.selectedPricing
          }
        })
      );
      this.openAddToCartConfirmModal = true;
    } else {
      this.openModal = true;

    }
  }

  handleModalClosed() {
    this.openModal = false;
  }
  groupRegistrationModalClosed() {
    this.openGroupRegistration = false;
    
  }
  groupRegistration() {
    if(!isGuest){
      this.openGroupRegistration = true;
    }
   else{
    this.openModal = true;
   }
  }

  applicationQuestionnaireClosed(){
    this.openApplicationQuestionnaire = false;
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
  addToCartModalClosed() {
    this.openAddToCartConfirmModal = false;
  }
}