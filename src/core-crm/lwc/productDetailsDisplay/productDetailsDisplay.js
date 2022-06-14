/**
 * @description A LWC component to display product details
 *
 * @see ../classes/ProductController.cls
 * @see productDetailsDisplay
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | xenia.gaerlan             | November 2, 2021      | DEPP-618             | ProductController.cls, Study OPE             |
      |                           |                       |                      | Program UI Layout                            |
      | xenia.gaerlan             | Novemver 11, 2021     | DEPP-618             | Prescribed Program, Flexible Program         |
      |                           |                       |                      | Course Unit Program UI Layouts               |
      | xenia.gaerlan             | Novemver 18, 2021     | DEPP-618             | GetProgramTypeCtrl                           |
      | roy.nino.s.regala         | December 6, 2021      | DEPP-116             | Removed unsused code and added field mapping |
      | roy.nino.s.regala         | December 27, 2021     | DEPP-1028            | Added logiic to close modal and refresh      |
      |                           |                       |                      | product records on parent -> productDetails  |
      | john.bo.a.pineda          | January 19, 2022      | DEPP-1410            | Added logic for add to cart                  |
      | roy.nino.s.regala         | February 04, 2022     | DEPP-213             | Added logic for register interest            |
      | john.bo.a.pineda          | April 11, 2022        | DEPP-1211            | Modified logic for new UI                    |
      | keno.domienri.dico        | April 29, 2022        | DEPP-2038            | Added child product records                  |
      | marlon.vasquez            | May 04,2022           | DEPP-1531            | Added Questionnaire Form                     |
      | julie.jane.alegre         | May 24,2022           | DEPP-2070            | Added Group Registration Button              |
      | julie.jane.alegre         | June 01,2022          | DEPP-2781            | Fix bug for Group Registration button visibility     |
      | julie.jane.alegre         | June 11,2022          | DEPP-2985            | Fix bug for Apply button visibility          |
*/

import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import BasePath from "@salesforce/community/basePath";
import userId from "@salesforce/user/Id";
import isGuest from "@salesforce/user/isGuest";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import insertExpressionOfInterest from "@salesforce/apex/ProductDetailsCtrl.insertExpressionOfInterest";
import getRelatedCourseOffering from "@salesforce/apex/ProductDetailsCtrl.getCourseOfferingRelatedRecords";
import overview from "@salesforce/label/c.QUT_ProductDetail_Overview";
import evolveWithQUTeX from "@salesforce/label/c.QUT_ProductDetail_EvolveWithQUTeX";
import whoShouldParticipate from "@salesforce/label/c.QUT_ProductDetail_WhoShouldParticipate";
import coreConcepts from "@salesforce/label/c.QUT_ProductDetail_CoreConcepts";
import facilitator from "@salesforce/label/c.QUT_ProductDetail_Facilitator";
import details from "@salesforce/label/c.QUT_ProductDetail_Details";
import duration from "@salesforce/label/c.QUT_ProductDetail_Duration";
import delivery from "@salesforce/label/c.QUT_ProductDetail_Delivery";
import deliveryPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Delivery_Placeholder";
import availableStartDates from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates";
import availableStartDatesPlaceholder from "@salesforce/label/c.QUT_ProductDetail_AvailableStartDates_Placeholder";
import pricing from "@salesforce/label/c.QUT_ProductDetail_Pricing";
import pricingPlaceholder from "@salesforce/label/c.QUT_ProductDetail_Pricing_Placeholder";
import addToCart from "@salesforce/label/c.QUT_ProductDetail_AddToCart";
import registerInterest from "@salesforce/label/c.QUT_ProductDetail_RegisterInterest";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import professionalDevelopmentModules from "@salesforce/label/c.QUT_ProductDetail_Professional_Development_Modules";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import getQuestions from "@salesforce/apex/ProductDetailsCtrl.getQuestions";
const SUCCESS_TITLE = "Success!";
const ERROR_TITLE = "Error!";
const SUCCESS_VARIANT = "success";
const ERROR_VARIANT = "error";
const NO_REC_FOUND = "No record(s) found.";
const MODAL_TITLE = "Registration Details";
const INTEREST_EXISTS_ERROR =
  "You already registered your interest for this product.";

export default class ProductDetailsDisplay extends NavigationMixin(
  LightningElement
) {
  @wire(getRecord, { recordId: userId, fields: [CONTACT_ID] })
  user;

  get contactId() {
    return getFieldValue(this.user.data, CONTACT_ID);
  }

  // Init Variables
  @api recordId;
  @api objectApiName;
  @api productDetails;
  @api priceBookEntries;
  @api deliveryOptions = [];
  @api cProducts;
  @api isNotFlexProgram;
  @api isInternalUser;
  @api unitPrice;

  @track courseOfferings = [];
  @track selectedCourseOffering;
  @track selectedCourseOfferingFacilitator = [];
  @track selectedPriceBookEntry;
  @track disableAvailStartDate = true;
  @track disablePriceBookEntry = true;
  @track disableAddToCart = true;
  @track displayAddToCart;
  @track displayRegisterInterest;
  @track facilitator;
  @track displayFacilitatorNav = true;
  @track facilitatorIndex = 0;
  @track openModal;
  @track displayGroupRegistration = false;
  @track openGroupBookingModal;
  @track selectedDelivery;
  @track isPrescribed = false;
  displayQuestionnaire = false;
  openApplicationQuestionnaire = false;
  priceBookEntriesCopy = [];

  // Set Custom Labels
  label = {
    overview,
    evolveWithQUTeX,
    whoShouldParticipate,
    coreConcepts,
    facilitator,
    details,
    duration,
    delivery,
    deliveryPlaceholder,
    availableStartDates,
    availableStartDatesPlaceholder,
    pricing,
    pricingPlaceholder,
    addToCart,
    registerInterest,
    professionalDevelopmentModules
  };

  bulkRegister = false;
  //Questionnaire
  cartVisible = true;
  @api prodReqId;
  @api enableEdit;
  @api childRecordId;
  @api disabled;

  searchField = "";
  picklistValue = "";
  rowRegStatus = "";
  rowPaidInFull = "";
  rowId = "";
  rowQuestId = "";
  modalName = "";
  isModalOpen = false;
  isLoading = false;
  empty = false;
  isDisabled = true;
  isForRejection = false;
  error;
  registrationStatusValues;
  registrationStatusModal;
  pricingValidationValues;
  pricingValidation;
  paidInFullValues;
  records = [];
  recordsTemp = [];

  //addcontact variables
  contactSearchItems = [];
  contactId2;
  searchInProgress;
  objectLabelName = "Contact";
  objectToBeCreated = "Contact";
  isAddContact = false;
  isCreateContact = false;
  isEditContact = false;
  saveInProgress = false;
  contactList;
  formLoading = false;
  contactFields;
  contactsDetail;
  responseDataQuestionnaire = [];

  //registration Response variables
  isRespondQuestions;
  responseData;
  questions;

  // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
  // which the NavigationMixin implicitly requires to function properly.
  _resolveConnected;
  _connected = new Promise((resolve) => {
    this._resolveConnected = resolve;
  });

  connectedCallback() {
    this._resolveConnected();
    // Load Default Icons
    this.accordionIcon = qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
    this.comboBoxUp = qutResourceImg + "/QUTImages/Icon/comboBoxUp.svg";
    this.comboBoxDown = qutResourceImg + "/QUTImages/Icon/comboBoxDown.svg";
    this.durationIcon = qutResourceImg + "/QUTImages/Icon/duration.svg";
    this.accordionClose = qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
    this.accordionOpen = qutResourceImg + "/QUTImages/Icon/accordionOpen.svg";
    this.comboBoxDown = qutResourceImg + "/QUTImages/Icon/comboBoxDown.svg";
    this.comboBoxUp = qutResourceImg + "/QUTImages/Icon/comboBoxUp.svg";
    this.iconangledown = qutResourceImg + "/QUTImages/Icon/icon-angle-down.svg";
    this.iconangleleft = qutResourceImg + "/QUTImages/Icon/icon-angle-left.svg";
    this.iconangleright =
      qutResourceImg + "/QUTImages/Icon/icon-angle-right.svg";
    this.iconcalendar = qutResourceImg + "/QUTImages/Icon/icon-calendar.svg";
    this.iconcart = qutResourceImg + "/QUTImages/Icon/icon-cart.svg";
    this.iconcircleminus =
      qutResourceImg + "/QUTImages/Icon/icon-circle-minus.svg";
    this.iconcircleplus =
      qutResourceImg + "/QUTImages/Icon/icon-circle-plus.svg";
    this.icondeleteimg = qutResourceImg + "/QUTImages/Icon/icon-delete.svg";
    this.icondollor = qutResourceImg + "/QUTImages/Icon/icon-dollor.svg";
    this.icondownload = qutResourceImg + "/QUTImages/Icon/icon-download.svg";
    this.iconexclamationfilled =
      qutResourceImg + "/QUTImages/Icon/icon-exclamation-filled.svg";
    this.iconhome = qutResourceImg + "/QUTImages/Icon/icon-home.svg";
    this.iconlinkedin = qutResourceImg + "/QUTImages/Icon/icon-linkedin.svg";
    this.iconmap = qutResourceImg + "/QUTImages/Icon/icon-map.svg";
    this.iconmapmarker = qutResourceImg + "/QUTImages/Icon/icon-map-marker.svg";
    this.iconupload = qutResourceImg + "/QUTImages/Icon/icon-upload.svg";
    this.iconuploadfilled =
      qutResourceImg + "/QUTImages/Icon/icon-upload-filled";
    this.linkedInLogo = qutResourceImg + "/QUTImages/Icon/linkedInLogo.svg";
    this.xMark = qutResourceImg + "/QUTImages/Icon/xMark.svg";

    if (this.productDetails.Course__c) {
      getQuestions({
        productReqId: this.productDetails.Course__r.ProductRequestID__c
      })
        .then((results) => {
          if (results.length > 0) {
            this.responseData = results;
            this.questions = results;
            this.priceBookEntriesCopy = JSON.parse(JSON.stringify(this.priceBookEntries)).filter(row => row.label != 'Group Booking');
          }else{
            this.priceBookEntriesCopy = this.priceBookEntries;
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
  }

  /* Load Custom CSS */
  renderedCallback() {
    Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
  }

  disconnectedCallback() {
    this._connected = new Promise((resolve) => {
      this._resolveConnected = resolve;
    });
  }

  /* Comment out temporarily old logic used for bulk register*/
  /* openRegisterModal() {
    if (this.isCCEPortal) {
      this.bulkRegister = true;
    }
  }

  closeModal() {
    this.bulkRegister = false;
  }

  get isCCEPortal() {
    return BasePath.toLowerCase().includes("cce");
  }

  get isOPEPortal() {
    return BasePath.toLowerCase().includes("study");
  }

  get isOPEAndIsProgram() {
    return this.isOPEPortal && this.productOnPage.Program_Plan__c;
  }

  handleClose() {
    this.closeModal();
    let event = new CustomEvent("refreshproduct");
    this.dispatchEvent(event);
  } */

  notifyApply() {
    if (!isGuest) {
      this.openApplicationQuestionnaire = true;
    } else {
      // Display Custom Login Form LWC
      this.openModal = true;
    }
    
  }
  // Emits a notification that the user wants to add the item to their cart.
  notifyAddToCart() {
    // Call AddToCart
    if (!isGuest) {
      // let quantity = 1;
      let courseOfferingId = this.selectedCourseOffering;
      //let programOfferingId = this.selectedCourseOffering;
      let pricebookEntryId = this.selectedPriceBookEntry;
      this.dispatchEvent(
        new CustomEvent("addtocart", {
          detail: {
            courseOfferingId,
            pricebookEntryId
          }
        })
      );
    } else {
      // Display Custom Login Form LWC
      this.openModal = true;
    }
    /* Comment out for bulk register */
    /* this.openRegisterModal(); */
  }

  // Disable Delivery when No Options retrieved
  get disableDelivery() {
    return this.deliveryOptions.length == 0 ? true : false;
  }

  // Register Interest
  registerInterest() {
    if (!isGuest) {
      insertExpressionOfInterest({
        userId: userId,
        productId: this.productDetails.Id
      })
        .then(() => {
          this.generateToast(SUCCESS_TITLE, "Interest Registered", SUCCESS_VARIANT);
        })
        .catch((error) => {
     
          if (error.body.message == "Register Interest Exists") {
            this.generateToast(ERROR_TITLE, INTEREST_EXISTS_ERROR,ERROR_VARIANT);
          } else {
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
          }
        });
    } else {
      // Display Custom Login Form LWC
      this.openModal = true;
    }
  }

  // Close Custom Login Form LWC
  handleModalClosed() {
    this.openModal = false;
  }

  // Accordion Toggle logic
  handleAccordionToggle(event) {
    // Get Aria Expanded value
    let accordionAriaExpanded = event.currentTarget;
    // Get Closest Section Element
    let accordionSection = event.currentTarget.closest("section");
    // Get Content Element
    let accordionContent = accordionSection.querySelector(".accordionContent");
    // Get Button Icon Element
    let accordionIcon = accordionSection.querySelector(".slds-button__icon");

    // Toggle Values
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

  // Retrieve Related Course Offering from Delivery Picklist Selected
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
        this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
      });
      
  }

  // Set Selected Course Offering value
  handleStartDateSelected(event) {
    this.displayFacilitatorNav = true;
    this.selectedCourseOffering = event.detail.value;
    this.courseOfferings.forEach((cOffer) => {
      if (cOffer.value === this.selectedCourseOffering) {
        this.selectedCourseOfferingFacilitator = cOffer.facilitator;
        if (this.selectedCourseOfferingFacilitator.length > 0) {
          this.setFacilitatorToDisplay();
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

  handlePreviousFacilitator() {
    if (this.facilitatorIndex == 0) {
      // If First Index, get Last Index
      this.facilitatorIndex = this.selectedCourseOfferingFacilitator.length - 1;
    } else {
      // Else get previous Index
      this.facilitatorIndex--;
    }
    this.setFacilitatorToDisplay();
  }

  handleNextFacilitator() {
    if (
      this.facilitatorIndex ==
      this.selectedCourseOfferingFacilitator.length - 1
    ) {
      // If Last Index, get First Index
      this.facilitatorIndex = 0;
    } else {
      // Else get next Index
      this.facilitatorIndex++;
    }
    this.setFacilitatorToDisplay();
  }

  // Set Facilitator Displayed
  setFacilitatorToDisplay() {
    this.facilitator =
      this.selectedCourseOfferingFacilitator[this.facilitatorIndex];
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
        this.displayAddToCart = false;
        this.disableAddToCart = false;
      }
    }
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

  // Display Professional Development Module static text
  get pdmStaticText() {
    return (
      `Each ` +
      this.productDetails.Name +
      ` Professional Development Module is a stand-alone course. Choose the expertise you need and explore each topic to find the time frame that suits you.`
    );
  }

  // Gets whether product information has been retrieved for display.
  get hasChildProducts() {
    return this.cProducts && this.cProducts.length > 0 ? true : false;
  }

  //Questionnaire
  get modalTitle() {
    return MODAL_TITLE;
  }
  get modalName() {
    return this.modalName;
  }
  get noRecordsFound() {
    return NO_REC_FOUND;
  }
  get sectionHeader() {
    return SECTION_HEADER;
  }
  get disableSaveExisting() {
    return this.saveInProgress || !this.contactId2;
  }
  get hasQuestions() {
    return this.questions && this.questions.length > 0 ? true : false;
  }
  

  applicationQuestionnaireClosed(){
    this.openApplicationQuestionnaire = false;
  }

  groupRegistrationModalClosed() {
    this.openGroupBookingModal = false;
  }
  groupRegistration() {
    //this.registerInterest();
    if (!isGuest) {
      this.openGroupBookingModal = true;
      
    }else{
     // Display Custom Login Form LWC
     this.openModal = true;
    }

  }
}