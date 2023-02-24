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
      | john.bo.a.pineda          | June 16, 2022         | DEPP-3114            | Modified to set values after registration    |
      | john.bo.a.pineda          | June 20, 2022         | DEPP-3185            | Modified logic for addToCard onload          |
      | john.bo.a.pineda          | June 22, 2022         | DEPP-3211            | Modified logic to use correct logic to get   |
      |                           |                       |                      | Earliest Upcoming Offering                   |
      | john.bo.a.pineda          | June 27, 2022         | DEPP-3216            | Modified to add identifer if values from     |
      |                           |                       |                      | addToCart are from URL Defaults              |
      | keno.domienri.dico        | June 28, 2022         | DEPP-3302            | Change toast confirmation to modal message   |
      | john.bo.a.pineda          | June 29, 2022         | DEPP-3323            | Modified logic for button display for Apply  |
      | keno.domienri.dico        | June 30, 2022         | DEPP-3349            | Bugfix custom modal confirmation message     |
      | mary.grace.li             | July 02, 2022         | DEPP-3124            | Modified to add recordNameId                 |
      | mary.grace.li             | July 04, 2022         | DEPP-3184            | Replaced custom labels with constant         |
      | john.bo.a.pineda          | July 04, 2022         | DEPP-3385            | Changed ?param to &param                     |
      | eugene.andrew.abuan       | July 22, 2022         | DEPP-2730            | Added employee self registration logic       |
      | john.m.tambasen           | July 29, 2022         | DEPP-3577            | early bird changes no of days                |
      | eugene.andrew.abuan       | June 30, 2022         | DEPP-3534            | Added Do not Show Start Date                 |
      | jessel.bajao              | August 2, 2022        | DEPP-3476            | Added code to get current product category   |
      | keno.domienri.dico        | August 03, 2022       | DEPP-3474            | CCE QUTeX Learning added product category    |
      | eugene.andrew.abuan       | August 08, 2022       | DEPP-3708            | Updated openModal to openRegisterModal       |
      | keno.domienri.dico        | August 25, 2022       | DEPP-3765            | Updated for CCE Product categories           |
      | eugene.john.basilan       | September 01, 2022    | DEPP-3479            | Added data to pass to child and bulk changes |
      | mary.grace.li             | September 20, 2022    | DEPP-4370            | Fix bug for Self-reg button                  |
      | dodge.j.palattao          | September 26, 2022    | DEPP-2699            | Added messageChannel for SubMenu active category|
      | John Oliver Esguerra      | September 28, 2022    | DEPP-4465            | Rename bulk registration to Group registration|
*/

import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import BasePath from "@salesforce/community/basePath";
import userId from "@salesforce/user/Id";
import isGuest from "@salesforce/user/isGuest";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import insertExpressionOfInterest from "@salesforce/apex/ProductDetailsCtrl.insertExpressionOfInterest";
import getRelatedCourseOffering from "@salesforce/apex/ProductDetailsCtrl.getCourseOfferingRelatedRecords";
import sendEmployeeRegistrationEmail from "@salesforce/apex/EmployeeSelfRegistrationCtrl.sendEmployeeRegistrationEmail"
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import getQuestions from "@salesforce/apex/ProductDetailsCtrl.getQuestions";
import assetRecordData from "@salesforce/apex/ProductDetailsCtrl.assetRecordData";
import { publish, MessageContext, subscribe, unsubscribe } from "lightning/messageService";
import payloadContainerLMSsubMenuName from "@salesforce/messageChannel/SubMenu__c";
import payloadAcctContainerLMS from '@salesforce/messageChannel/AccountId__c';
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const NO_REC_FOUND = "No record(s) found.";
const MODAL_TITLE = "Registration Details";
const INTEREST_EXISTS_ERROR = "You already registered your interest for this product.";
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
const Tailored_Executive_Education = 'Tailored Executive Education';
const Tailored_Executive_Program = 'Tailored Executive Program';
const Corporate_Bundle = 'Corporate Bundle';
const QUTeX_Learning_Solutions = 'QUTeX Learning Solutions';
const STORED_ACCTID = "storedAccountId";
const STOREPRODUCTCATEGORY = "product_category";
const CURRENTPRODUCTCATEGORY = "current_product_category";
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
  @api productCategory;
  @api productCategoryChild;
  @api priceReadOnly;
  @api ccePricebookEntryId;

  @track courseOfferings = [];
  courseOffering;
  @track selectedCourseOffering;
  @track selectedCourseOfferingFacilitator = [];
  @track selectedPriceBookEntry;
  @track disableAvailStartDate = true;
  @track disablePriceBookEntry = true;
  @track disableAddToCart = true;
  @track disableApply = true;
  @track displayAddToCart;
  @track displayRegisterInterest;
  @track facilitator;
  @track displayFacilitatorNav = true;
  @track facilitatorIndex = 0;
  @track openRegisterModal;
  @track openLoginModal;
  @track startURL;
  @track displayGroupRegistration = false;
  @track openGroupBookingModal;
  @track selectedDelivery;
  @track isPrescribed = false;
  @track displayPricing = true;
  @track displayBulkRegistration = false;
  @track displayEmployeeSelfRegistration = false;
  @track displayManageRegistration = false;
  @track disableBulkRegistration = true;
  @track disableEmployeeSelfRegistration = true;
  @track disableManageRegistration = false;
  displayQuestionnaire = false;
  openApplicationQuestionnaire = false;
  priceBookEntriesCopy = [];
  priceBookEntriesFiltered = [];
  paramURL;
  getParamObj = {};
  setParamObj = {};
  onLoadTriggerBtn;
  onLoadTriggerRegInterest = false;
  urlDefaultAddToCart = false;
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
  displayCsvBulkRegistration = false;

  subscription;
  accountId;

  @wire(MessageContext)
  messageContext;

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
  displayPricingReadOnly = false;
  // Product Category Booleans
  isTailoredExecEduc = false;
  isCorpBundle = false;
  isQUTexLearnSol = false;
  // Product Category Name
  fromCategoryId;
  fromCategoryName;

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
  doNotShowStartDate = false;

  //registration Response variables
  isRespondQuestions;
  responseData = [];
  questions;

  //preselected startdate and facilitators
  preselectedStartdate;

  //parameters for modal message
  @api isRegModalMessage;
  @api isModalMessage = false;
  @track message1;
  @track message2;
  @track isContinueToPayment;
  @track isContinueBrowsing;
  @track isOkay;

  //asset available credit
  assetAvailable;

  //Bulk Reg name to Group registration 
  groupBulkName;


  // group booking bulk registration
  @track openGroupBookingModalBulkRegistration;
  qutexLearningSolutionsCategoryBulkReg;

  // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
  // which the NavigationMixin implicitly requires to function properly.
  _resolveConnected;
  _connected = new Promise((resolve) => {
    this._resolveConnected = resolve;
  });

  // Get param from URL and decode to get default parameters
  @wire(CurrentPageReference)
  getpageRef(pageRef) {
    if (pageRef && pageRef.state && pageRef.state.param) {
      this.getParamObj = JSON.parse(atob(pageRef.state.param));
      if (this.getParamObj.triggerBtn == "regInt") {
        this.onLoadTriggerRegInterest = true;
      } else if (this.getParamObj.triggerBtn == "addCart") {
        this.urlDefaultAddToCart = true;
      }
    }
  }

  connectedCallback() {
    this.subscribeLMS();
    this._resolveConnected();

    if(this.isCCEPortal){
      //get current product category
      let currentProductCategory = JSON.parse(
        sessionStorage.getItem(STOREPRODUCTCATEGORY)
      );
      if(!!currentProductCategory){
        this.isTailoredExecEduc = currentProductCategory.isTailoredExecEduc;
        this.fromCategoryName = currentProductCategory.fromCategoryName;
        this.fromCategoryId = currentProductCategory.fromCategoryId;
        this.publishLMS();
      }
      
    }
      
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
    this.dollarIcon = qutResourceImg + "/QUTImages/Icon/dollar_icon.svg";
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
            this.priceBookEntriesCopy = JSON.parse(
              JSON.stringify(this.priceBookEntries)
            ).filter((row) => row.label != "Group Booking");
          } else {
            this.priceBookEntriesCopy = this.priceBookEntries;
          }
        })
        .catch((e) => {
          this.generateToast(ERROR_TITLE, LWC_ERROR_GENERAL, ERROR_VARIANT);
        });
    }
    //Populate the do not show start date
    if(this.productDetails.Do_not_Show_Start_Date__c){
      this.doNotShowStartDate = this.productDetails.Do_not_Show_Start_Date__c;
    }

    // Get Pre-selected fields for Delivery and Start Date
    if (this.productDetails.Delivery__c) {
      if (Object.keys(this.getParamObj).length > 0) {
        this.selectedDelivery = this.getParamObj.defDeliv;
      } else {
        this.deliveryOpt = this.productDetails.Delivery__c.replaceAll(";", ",");
        this.deliverySplit = this.deliveryOpt.split(",");
        if(this.deliveryOptions.length > 0){
          this.selectedDelivery = this.deliveryOptions[0].value;
        }else{
          this.selectedDelivery = this.deliverySplit;
        }
      }

      getRelatedCourseOffering({
        courseId: this.productDetails.Course__c,
        deliveryParam: this.selectedDelivery,
        ccePortal: this.isCCEPortal
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
          if(this.isCCEPortal){
            if (this.productCategory == Tailored_Executive_Education || this.productCategory == Tailored_Executive_Program) {
              this.groupBulkName ='Bulk Registration';
              this.isTailoredExecEduc = true;
              this.isCorpBundle = false;
              this.isQUTexLearnSol = false;
              this.displayPricingReadOnly = false;
              this.displayPricing = false;
              this.displayBulkRegistration = true;
              this.displayEmployeeSelfRegistration = true;
              this.displayManageRegistration = true;
              this.qutexLearningSolutionsCategoryBulkReg = false;
            }
            else if (this.productCategory == Corporate_Bundle){
              this.groupBulkName ='Bulk Registration';
              this.isTailoredExecEduc = false;
              this.isCorpBundle = true;
              this.isQUTexLearnSol = false;
              this.displayPricingReadOnly = true;
              this.displayPricing = false;
              this.displayBulkRegistration = true;
              this.displayEmployeeSelfRegistration = true;
              this.displayManageRegistration = true;
              this.qutexLearningSolutionsCategoryBulkReg = false;
              this.displayRegisterInterest = false;
            }
            else if (this.productCategory == QUTeX_Learning_Solutions){
              this.groupBulkName ='Group Registration';
              this.qutexLearningSolutionsCategoryBulkReg = true;
              this.isTailoredExecEduc = false;
              this.isCorpBundle = false;
              this.isQUTexLearnSol = true;
              this.displayPricingReadOnly = true;
              this.displayPricing = false;
              this.displayBulkRegistration = true;
              this.displayEmployeeSelfRegistration = false;
              this.displayManageRegistration = true;
            }
          }
          else
          {
            this.displayPricing = true;
          }

          this.disablePriceBookEntry = true;
          this.disableAddToCart = true;
          this.disableApply = true;
          this.displayGroupRegistration = false;

          if (results.length > 0) {
            this.courseOfferings = results;
            this.disableAvailStartDate = false;

            if (Object.keys(this.getParamObj).length > 0) {
              this.selectedCourseOffering = this.getParamObj.defCourseOff;
              this.selectedPriceBookEntry = this.getParamObj.defPBEntry;
              this.onLoadTriggerBtn = this.getParamObj.triggerBtn;
              if (this.selectedPriceBookEntry) {
                this.selectedPB = this.priceBookEntriesCopy.find(
                  (item) => item.value === this.selectedPriceBookEntry
                ).label;
              }
              this.disableAddToCart = false;
              this.disableApply = false;
            } else {
              this.selectedDelivery = this.courseOfferings[0].defDeliv;
              this.selectedCourseOffering = this.courseOfferings[0].value;
              this.disableAddToCart = true;
              this.disableApply = true;
              this.courseOfferings[0].defDeliv;
              this.selectedCourseOffering =
              this.courseOfferings[0].value;
              this.courseOffering = this.courseOfferings[0];

              this.disableAddToCart = true;
              this.disableApply = true;
            }
            this.handleFilterPricing();
            this.disablePriceBookEntry = false;
            if (this.selectedPB == "Group Booking") {
              this.displayAddToCart = false;
              this.displayGroupRegistration = true;
              if (this.responseData.length > 0) {
                this.displayQuestionnaire = true;
              } else {
                this.displayQuestionnaire = false;
              }
            } else {
              this.displayGroupRegistration = false;
              if (this.isCCEPortal) {
                this.displayAddToCart = false;
              }
              else
              {
                this.displayAddToCart = true;
              }
              if (this.responseData.length > 0) {
                this.displayQuestionnaire = true;
                this.disableApply = false;
                this.displayAddToCart = false;
                if (!this.selectedPriceBookEntry) {
                  this.disableApply = true;
                }
              }
            }

            if (this.onLoadTriggerBtn == "addCart") {
              // Trigger AddToCart
              this.dispatchAddToCartEvent();
            } else if (this.onLoadTriggerBtn == "groupReg") {
              // Trigger Group Reg
              this.groupRegistration();
            } else if (this.onLoadTriggerBtn == "apply") {
              // Trigger Apply
              this.notifyApply();
            }
          } else {
            this.checkSDatePlaceholder = this.availableStartDatesPlaceholder;
          }
        })
        .catch((e) => {
          this.generateToast(ERROR_TITLE, LWC_ERROR_GENERAL, ERROR_VARIANT);
        });
    } else {
      this.checkSDatePlaceholder = this.availableStartDatesPlaceholder;
    }

    // Display AddToCart / Register Interest
    this.displayRegisterInterest = false;
    if (
      this.deliveryOptions.length == 0 &&
      this.productDetails.Register_Interest_Available__c == true
    ) {
      this.displayAddToCart = false;
      this.displayQuestionnaire = false;
      this.displayRegisterInterest = true;
    }

    if (this.onLoadTriggerRegInterest) {
      // Trigger Register Interest
      this.handleRegisterInterest();
    }
  }

  subscribeLMS() {
    if (!this.subscription) {
        this.subscription = subscribe(
            this.messageContext, 
            payloadAcctContainerLMS, 
            (message) => this.validateValue(message));
    }
  }

  validateValue(val) {
      if (val && val.accountIdParameter) {
          let newValObj = JSON.parse(val.accountIdParameter);
          this.accountId = newValObj.accountId;
          sessionStorage.setItem(STORED_ACCTID,this.accountId);
      }
  }

  disconnectedCallback() {
    this.unsubscribeLMS();
    this._connected = new Promise((resolve) => {
      this._resolveConnected = resolve;
    });
  }

  unsubscribeLMS(){
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  searchString(nameKey, listArray) {
    for (let i = 0; i < listArray.length; i++) {
      if (listArray[i].name === nameKey) {
        return listArray[i];
      }
    }
  }

  get isOPEPortal() {
    return BasePath.toLowerCase().includes("study");
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

  get isCCEPortal() {
    return BasePath.toLowerCase().includes("cce");
  }
  notifyApply() {
    if (!isGuest) {
      this.openApplicationQuestionnaire = true;
    } else {
      // Display Custom Login Form LWC
      this.setParamURL("apply");
      this.openRegisterModal = true;
    }
  }
  // Emits a notification that the user wants to add the item to their cart.
  notifyAddToCart() {
    // Call AddToCart
    if (!isGuest) {
      this.urlDefaultAddToCart = false;
      this.dispatchAddToCartEvent();
    } else {
      // Display Custom Login Form LWC
      this.setParamURL("addCart");
      this.openRegisterModal = true;
    }
    /* Comment out for bulk register */
    /* this.openRegisterModal(); */
  }

  dispatchAddToCartEvent() {
    let courseOfferingId = this.selectedCourseOffering;
    let pricebookEntryId = this.selectedPriceBookEntry;
    let urlDefaultAddToCart = this.urlDefaultAddToCart;
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: {
          courseOfferingId,
          pricebookEntryId,
          urlDefaultAddToCart
        }
      })
    );
    this.isModalMessage = true;
    this.message1 = "Product is added successfully to the cart.";
    this.message2 = "How would you like to proceed?";
    this.isContinueBrowsing = true;
    this.isContinueToPayment = true;
    this.isOkay = false;
  }

  // Disable Delivery when No Options retrieved
  get disableDelivery() {
    return this.deliveryOptions.length == 0 || this.doNotShowStartDate ? true : false;
  }

  // Register Interest
  handleRegisterInterest() {
    if (!isGuest) {
      insertExpressionOfInterest({
        userId: userId,
        productId: this.productDetails.Id
      })
        .then(() => {
          this.isRegModalMessage = true;
          this.message1 =
            "Your interest has been successfully registered for this product.";
          this.message2 = "We will contact you once this product is available.";
          this.isContinueBrowsing = true;
          this.isContinueToPayment = false;
          this.isOkay = false;
          // this.generateToast(
          //   SUCCESS_TITLE,
          //   "Interest Registered",
          //   SUCCESS_VARIANT
          // );
        })
        .catch((error) => {
          if (error.body.message == "Register Interest Exists") {
            this.generateToast(
              ERROR_TITLE,
              INTEREST_EXISTS_ERROR,
              ERROR_VARIANT
            );
          } else {
            this.generateToast(ERROR_TITLE, LWC_ERROR_GENERAL, ERROR_VARIANT);
          }
        });
    } else {
      // Display Custom Login Form LWC
      this.setParamURL("regInt");
      this.openRegisterModal = true;
    }
  }

  // Close Custom Login Form LWC
  handleModalClosed() {
    this.openRegisterModal = false;
    this.openLoginModal = false;
  }

  // Handle Login Modal Open
  handleLoginModalOpen(event) {
    this.startURL = event.detail.startURL;
    this.openLoginModal = true;
    this.openRegisterModal = false;
  }

  // Handle Register Modal Open
  handleRegisterModalOpen() {
    this.openLoginModal = false;
    this.openRegisterModal = true;
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
      deliveryParam: this.selectedDelivery,
      ccePortal: this.isCCEPortal
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
        this.disableApply = true;
        this.displayGroupRegistration = false; 
        if(this.isCCEPortal){
          if (this.productCategory == Tailored_Executive_Education || this.productCategory == Tailored_Executive_Program) {
            this.isTailoredExecEduc = true;
            this.isCorpBundle = false;
            this.isQUTexLearnSol = false;
            this.displayPricingReadOnly = false;
            this.displayPricing = false;
            this.displayBulkRegistration = true;
            this.displayEmployeeSelfRegistration = true;
            this.displayManageRegistration = true;
          }
          else if (this.productCategory == Corporate_Bundle){
           this.isTailoredExecEduc = false;
            this.isCorpBundle = true;
            this.isQUTexLearnSol = false;
            this.displayPricingReadOnly = true;

            this.displayPricing = false;
            this.displayBulkRegistration = true;
            this.displayEmployeeSelfRegistration = true;
            this.displayManageRegistration = true;
          }
          else if (this.productCategory == QUTeX_Learning_Solutions){
            this.isTailoredExecEduc = false;
            this.isCorpBundle = false;
            this.isQUTexLearnSol = true;
            this.displayPricingReadOnly = true;

            this.displayPricing = false;
            this.displayBulkRegistration = true;
            this.displayEmployeeSelfRegistration = false;
            this.displayManageRegistration = true;
          }
          this.disableBulkRegistration = true;
          this.disableEmployeeSelfRegistration = true;
          this.disableManageRegistration = false;
        }  
        else
        {
          this.displayAddToCart = true; 
        }
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
        console.log(e);
        this.generateToast(ERROR_TITLE, LWC_ERROR_GENERAL, ERROR_VARIANT);
      });
  }

  // Set Selected Course Offering value
  handleStartDateSelected(event) {
 //get selected course offering
 this.courseOffering = this.courseOfferings.filter(crs => crs.value === event.detail.value )[0];
    //check if the same value was clicked
    if(this.selectedCourseOffering != event.detail.value){
      //reset the price dropdown and buttos
      this.selectedPriceBookEntry = undefined;
      this.disableAddToCart = true
      this.disableApply = true
      this.displayGroupRegistration = false
      this.displayQuestionnaire = false
    }

    this.displayFacilitatorNav = true;
    this.selectedCourseOffering = event.detail.value;
    this.disablePriceBookEntry = false;
    this.handleFilterPricing();
  }

  //handles filtering of prices
  handleFilterPricing(){
    this.courseOfferings.forEach((cOffer) => {
      if (cOffer.value === this.selectedCourseOffering) {
        if (this.isCCEPortal) {
          this.disableBulkRegistration = false;
          this.disableEmployeeSelfRegistration = false;
          this.disableManageRegistration = false;
        }

        this.selectedCourseOfferingFacilitator = cOffer.facilitator;
        if (this.selectedCourseOfferingFacilitator.length > 0) {
          this.setFacilitatorToDisplay();
          if (this.selectedCourseOfferingFacilitator.length == 1) {
            this.displayFacilitatorNav = false;
          }
        }

        //create temp array for pricebookentries
        let pbEntriesTemp = [...this.priceBookEntriesCopy];

        //loop on the price book entries
        pbEntriesTemp.forEach((item, index, arr) => {

          if (item.label === 'Early Bird') {

            //get and convert the date values
            let offeringDate = new Date(cOffer.label);
            let offeringDateMilli = offeringDate.setDate(offeringDate.getDate() - item.noOfDays);
            let offeringDateConverted = new Date(offeringDateMilli);
            let today = new Date();
            today = today.setHours(0, 0, 0, 0);

            //if today is past the early bird days
            if(today >= offeringDateConverted){
              //remove the early bird element
              arr.splice(index, 1);
            }
          }
        });

        //check if early bird is still there after checking for the number of days
        let found = pbEntriesTemp.find(element => element.label === 'Early Bird');

        //if early bird is found, remove the Standard Pricebookj
        if(found != undefined){

          //filter out the element with the current cart item id
          pbEntriesTemp = pbEntriesTemp.filter(function (obj) {
            return obj.label !== 'Standard';
          });
        }

        //reassign
        this.priceBookEntriesFiltered = pbEntriesTemp;
      }
    });
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

  get getPriceBookEntriesFiltered(){
    return this.priceBookEntriesFiltered;
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
        this.disableApply = false;
        this.displayQuestionnaire = true;
      } else {
        this.disableApply = true;
        this.displayQuestionnaire = false;
      }
    } else {
      this.displayGroupRegistration = false;
      this.displayAddToCart = true;
      this.disableAddToCart = false;
      if (this.responseData.length > 0) {
        this.displayQuestionnaire = true;
        this.disableApply = false;
        this.displayAddToCart = false;
        this.disableAddToCart = true;
      } else {
        this.displayQuestionnaire = false;
        this.disableApply = true;
        this.displayAddToCart = true;
        this.disableAddToCart = false;
      }
    }
  }

  setParamURL(btn) {
    // Set Button to Trigger on Load
    this.setParamObj.triggerBtn = btn;
    // Set Delivery default
    if (this.selectedDelivery) {
      this.setParamObj.defDeliv = this.selectedDelivery;
    }

    // Set Offering default
    if (this.selectedCourseOffering) {
      this.setParamObj.defCourseOff = this.selectedCourseOffering;
    }

    // Set Price default
    if (this.selectedPriceBookEntry) {
      this.setParamObj.defPBEntry = this.selectedPriceBookEntry;
    }
    this.paramURL = "?param=" + btoa(JSON.stringify(this.setParamObj));
  }

  // Triggers an email when employee self registration button is clicked
  // CCE Button functionality
  handleEmployeeSelfRegistration(){
    let pbEId = '';
    if(this.productCategory != Tailored_Executive_Education){
      pbEId = this.ccePricebookEntryId ? this.ccePricebookEntryId: '';
    }

    let selfRegistrationParameters = {
      userId: userId,
      productId: this.productDetails.Id,
      selectedOffering : this.selectedCourseOffering,
      pricebookEntryId : pbEId
    };

    sendEmployeeRegistrationEmail({
      selfRegistrationParams : selfRegistrationParameters,
      accountSelected : this.accountId
    }).then( (result) => {
      if(result == 'success'){
        this.isRegModalMessage = true;
        this.message1 = "The self-registration email has been sent to your email";
        this.message2 = null;
        this.isOkay= true;
        this.isContinueBrowsing = false;
        this.isContinueToPayment = false;
      } else {
        console.error('Error: ' + result);
        this.generateToast(ERROR_TITLE, LWC_ERROR_GENERAL, ERROR_VARIANT);
      }
    }).catch( (e) => {
      console.error('Error: ' + e);
      this.generateToast(ERROR_TITLE, LWC_ERROR_GENERAL, ERROR_VARIANT);
    });
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

  applicationQuestionnaireClosed() {
    this.openApplicationQuestionnaire = false;
  }

  groupRegistrationModalClosed() {
    this.openGroupBookingModal = false;
    this.openGroupBookingModalBulkRegistration = false;
  }
  groupRegistration() {
    if (!isGuest) {
      this.openGroupBookingModal = true;
    } else {
      // Display Custom Login Form LWC
      this.setParamURL("groupReg");
      this.openRegisterModal = true;
    }
  }
  addToCartModalClosed() {
    this.isModalMessage = false;
  }
  bulkRegistration() {
    if(this.qutexLearningSolutionsCategoryBulkReg == true){
      this.openGroupBookingModalBulkRegistration = true;
    } else {
    if(this.productCategory == 'Corporate Bundle'){
      assetRecordData({
        Pricebook2Id: this.productDetails.PricebookEntries[0].Pricebook2.Id
      })
      .then((results) => {
        this.assetAvailable = results.Remaining_Value__c;
          this.displayCsvBulkRegistration = true;
        
      })
      .catch((e) => {
        this.generateToast("Error.", LWC_Error_General, "error");
        console.log('This error');
        console.log(e);
      });
    }else{
      this.displayCsvBulkRegistration = true;

    }
  }
  }
  closeRegisterModal() {
          this.displayCsvBulkRegistration = false;
  }

    manageRegistrationLink(){
      // Navigate to a URL
      this[NavigationMixin.Navigate]({
       type: 'standard__webPage',
       attributes: {
           url: BasePath + '/manage-registrations'
       }
    });
    }


  publishLMS() {
    let paramObj = {
        categoryName: this.fromCategoryName
    };

    const message = {
        parameterJson: JSON.stringify(paramObj)
    };

    publish(this.messageContext, payloadContainerLMSsubMenuName, message);
  }
}