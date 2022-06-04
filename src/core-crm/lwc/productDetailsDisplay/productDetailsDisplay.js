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
import addRegistration from "@salesforce/apex/ProductDetailsCtrl.addRegistration";
import { refreshApex } from "@salesforce/apex";
const SUCCESS_MSG = "Record successfully updated.";
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
            this.questions = this.formatQuestions(results);
          }
        })
        .catch((e) => {
          this.generateToast("Error.", LWC_Error_General, "error");
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
      getQuestions({
        productReqId: this.productDetails.Course__r.ProductRequestID__c
      })
        .then((results) => {
          if (results.length > 0) {
            this.responseData = results;
            this.questions = this.formatQuestions(results);
          }
        })
        .catch((e) => {
          this.generateToast("Error.", LWC_Error_General, "error");
        });
  
      let fields = {};
      fields.Id = this.contactId;
      this.contactFields = fields;
      if (this.hasQuestions) {
        this.handleRespondQuestions();
      } else {
        this.isLoading = true;
        this.saveInProgress = true;
        this.saveRegistration(fields, this.childRecordId, [], [], "",false);
      }
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
        this.disableAddToCart = true;
        this.displayGroupRegistration = false;

        if (results.length > 0) {
          this.courseOfferings = results;
          this.disableAvailStartDate = false;
        }
      })
      .catch((e) => {
        this.generateToast("Error.", LWC_Error_General, "error");
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
      this.displayGroupRegistration = true;
      if (this.responseData.length > 0) {
        this.displayQuestionnaire = true;
      } else {
        this.displayQuestionnaire = false;
      }
    } else {
      this.displayGroupRegistration = false;
      this.displayAddToCart = true;
      if (this.responseData.length > 0) {
        this.displayQuestionnaire = true;
        this.displayAddToCart = false;
      } else {
        this.displayQuestionnaire = false;
        this.displayAddToCart = true;
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
  get disableResponseSave() {
    let tempQuestions = this.questions.filter(
      (row) =>
        row.IsCriteria &&
        row.Answer != "" &&
        row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase()
    );
    if (
      (tempQuestions && tempQuestions.length > 0) ||
      (this.questions &&
        this.questions.filter(
          (item) => item.Answer == "" || item.Answer == undefined
        ) &&
        this.questions.filter(
          (item) => item.Answer == "" || item.Answer == undefined
        ).length > 0)
    ) {
      return true;
    } else {
      return false;
    }
  }

  formatQuestions(items) {
    let questions = items.map((item) => {
      let newItem = {};
      let newOptions = [];
      newItem.Id = item.Id;
      if (item.Question__c) {
        newItem.QuestionId = item.Question__r.Id;
        newItem.Label = item.Question__r.Label__c;
        newItem.MandatoryResponse = item.Question__r.Acceptable_Response__c;
        newItem.Message = item.Question__r.Message__c;
        newItem.Type = item.Question__r.Type__c;
        newItem.IsText = item.Question__r.Type__c == "Text" ? true : false;
        newItem.IsCheckbox =
          item.Question__r.Type__c == "Checkbox" ? true : false;
        newItem.IsNumber = item.Question__r.Type__c == "Number" ? true : false;
        newItem.IsDate = item.Question__r.Type__c == "Date" ? true : false;
        newItem.IsPicklist =
          item.Question__r.Type__c == "Picklist" ? true : false;
        newItem.IsMultiPicklist =
          item.Question__r.Type__c == "Multi-Select Picklist" ? true : false;
        newItem.IsFileUpload =
          item.Question__r.Type__c == "File Upload" ? true : false;
        if (item.Question__r.Dropdown_Options__c) {
          newOptions = item.Question__r.Dropdown_Options__c.split(";").map(
            (key) => {
              return { label: key, value: key };
            }
          );
        }
        newItem.Options = newOptions;
        newItem.Answer = newItem.IsCheckbox ? "false" : "";
      }
      newItem.QuestionnaireId = item.Questionnaire__c;
      newItem.IsCriteria =
        item.Questionnaire__r.Questionnaire_Type__c == "Registration Criteria"
          ? true
          : false;
      newItem.IsQuestion =
        item.Questionnaire__r.Questionnaire_Type__c == "Registration Questions"
          ? true
          : false;
      newItem.IsQuestion =
        item.Questionnaire__r.Questionnaire_Type__c == "Application Questions"
          ? true
          : false;
      newItem.Sequence = item.Sequence__c;
      newItem.ErrorMessage = "";
      newItem.FileData = undefined;
      return newItem;
    });

    return questions;
  }
  handleSaveResponse() {
    this.isLoading = false;
    this.saveInProgress = true;
    //this.productDetails.Course__r.Id
    //this.childRecordId
    this.saveRegistration(
      this.contactFields,
      this.selectedCourseOffering,
      this.responseData,
      this.createAnswerRecord(),
      JSON.stringify(this.createFileUploadMap()),
      true
    );
    this.resetResponses();
  }

  resetResponses() {
    this.questions = this.questions.map((item) => {
      item.Answer = item.IsCheckbox ? item.Answer : "";
      item.ErrorMessage = "";
      item.FileData = undefined;
      return item;
    });
  }

  handleRespondQuestions() {
    this.isModalOpen = true;
    this.isEditContact = false;
    this.isAddContact = false;
    this.isCreateContact = false;
    this.isRespondQuestions = true;
  }

  createFileUploadMap() {
    let fileUpload = [];
    fileUpload = this.questions.map((item) => {
      if (item.IsFileUpload) {
        let record = {};
        record.RelatedAnswerId = item.Id;
        record.Base64 = item.FileData.base64;
        record.FileName = item.FileData.filename;
        return record;
      }
    });

    return fileUpload.filter((key) => key !== undefined)
      ? fileUpload.filter((key) => key !== undefined)
      : fileUpload;
  }

  createAnswerRecord() {
    let answerRecords = {};
    answerRecords = this.questions.map((item) => {
      let record = {};
      record.Related_Answer__c = item.Id;
      record.Response__c = item.Answer;
      record.Sequence__c = item.Sequence;
      return record;
    });
    return answerRecords;
  }

  saveRegistration(contact, courseOffering, relatedAnswer, answer, fileUpload, forApplication) {
    addRegistration({
      contactRecord: contact,
      courseOfferingId: courseOffering,
      relatedAnswerList: relatedAnswer,
      answerList: answer,
      fileUpload: fileUpload,
      forApplication : forApplication
    })
      .then(() => {
        this.generateToast(
          SUCCESS_TITLE,
          "Successfully Submitted",
          SUCCESS_VARIANT
        );
        refreshApex(this.tableData);
      })
      .finally(() => {
        this.saveInProgress = false;
        this.isModalOpen = false;
        this.isEditContact = false;
        this.isAddContact = false;
        this.isCreateContact = false;
        this.isLoading = false;
        this.saveInProgress = false;
        this.contactId2 = "";
        this.contactSearchItems = [];
      })
      .catch((error) => {
        this.generateToast("Error.", LWC_Error_General, "error");
      });
  }

  closeManageResponse() {
    this.isModalOpen = false;
    this.isDisabled = true;
    this.contactId2 = undefined;
    this.resetResponses();
  }

  handleChange(event) {
    this.questions = this.questions.map((row) => {
      if (event.target.name === row.Id && row.IsCheckbox) {
        row.Answer = event.detail.checked.toString();
      } else if (event.target.name === row.Id && row.IsFileUpload) {
        row.Answer = event.detail.value.toString();
        const file = event.target.files[0];
        let reader = new FileReader();
        reader.onload = () => {
          let base64 = reader.result.split(",")[1];
          row.FileData = {
            filename: file.name,
            base64: base64,
            recordId: undefined
          };
        };
        reader.readAsDataURL(file);
      } else if (event.target.name === row.Id && row.IsMultiPicklist) {
        row.Answer = event.detail.value
          ? event.detail.value.toString().replace(/,/g, ";")
          : row.Answer;
      } else if (event.target.name === row.Id) {
        row.Answer = event.detail.value
          ? event.detail.value.toString()
          : row.Answer;
      }
      return row;
    });
  }

  handleBlur() {
    this.questions = this.questions.map((row) => {
      if (
        row.IsCriteria &&
        row.Answer != "" &&
        row.Answer.toUpperCase() != row.MandatoryResponse.toUpperCase()
      ) {
        row.Answer = "";
        row.ErrorMessage = row.Message
          ? row.Message
          : "You are not qualified to proceed with registration.";
      } else if (
        row.IsCriteria &&
        row.Answer != "" &&
        row.Answer.toUpperCase() == row.MandatoryResponse.toUpperCase()
      ) {
        row.ErrorMessage = "";
      }
      return row;
    });
  }

  groupRegistrationModalClosed() {
    this.openGroupBookingModal = false;
  }
  groupRegistration() {
  
    this.openGroupBookingModal = true;
  }
}