/**
 * @description A LWC component to display product details for Prescribed Program
 *
 * @see ../classes/ProductDetailsCtrl.cls
 * @see PrescribedProgram
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | john.bo.a.pineda          | June 29, 2022         | DEPP-3323            | Modified logic for button display for Apply  |
      | mary.grace.li             | July 04, 2022         | DEPP-3184            | Replaced custom labels with constant         |
      | john.bo.a.pineda          | July 04, 2022         | DEPP-3385            | Changed ?param to &param                     |
      | john.bo.a.pineda          | July 15, 2022         | DEPP-3130            | Modified to include Login when Guest User    |
      | john.m.tambasen           | July 29, 2022         | DEPP-3577            | early bird changes no of days                |
      | julie.jane.alegre         | July 21, 2022         | DEPP-2608            | Add buttons for CCE store for the            |
      |                           |                       |                      | (Tailored Executive Program)                 |
      | eugene.andrew.abuan       | July 31, 2022         | DEPP-3534            | Added Do not show start date logic           |
      | eugene.andrew.abuan       | August 08, 2022       | DEPP-3708            | Updated openModal to openRegisterModal       |
      | julie.jane.alegre         | August 10, 2022       | DEPP-3475            | Add buttons for CCE store for the            |                                   |                      | (QUTeX Learning Solution)                    |
      | julie.jane.alegre         | August 10, 2022       | DEPP-2608            | Add buttons for CCE store (Corporate Bundle) |
      | eugene.andrew.abuan       | August 11, 2022       | DEPP-3472            | Added employee self reg logic                |
      | keno.domienri.dico        | August 25, 2022       | DEPP-3765            | Updates for product category                 |
      | julie.jane.alegre         | September 13, 2022    | DEPP-4247            | Fix bug for all CCE buttons                  |
      | mary.grace.li             | September 20, 2022    | DEPP-4370            | Fix bug for Self-reg button                  |
      | John Oliver Esguerra      | September 28, 2022    | DEPP-4465            | Rename bulk registration to Group registration|

*/
import { LightningElement, api, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import userId from "@salesforce/user/Id";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";
import insertExpressionOfInterest from "@salesforce/apex/ProductDetailsCtrl.insertExpressionOfInterest";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isGuest from "@salesforce/user/isGuest";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import getQuestions from "@salesforce/apex/ProductDetailsCtrl.getQuestions";
import { NavigationMixin,CurrentPageReference } from "lightning/navigation";
import BasePath from "@salesforce/community/basePath";
import sendEmployeeRegistrationEmail from "@salesforce/apex/EmployeeSelfRegistrationCtrl.sendEmployeeRegistrationEmail"
import assetRecordData from "@salesforce/apex/ProductDetailsCtrl.assetRecordData";
import { publish, MessageContext, subscribe, unsubscribe } from "lightning/messageService";
import payloadContainerLMS from "@salesforce/messageChannel/SubMenu__c";
import payloadAcctContainerLMS from '@salesforce/messageChannel/AccountId__c';

const INTEREST_EXISTS_ERROR =
  "You already registered your interest for this product.";
const DELIVERY= "Delivery";
const DELIVERY_PLACEHOLDER= "Choose delivery method";
const AVAILABLE_STARTDATES="Available start dates";
const AVAILABLE_STARTDATES_PLACEHOLDER="Choose start date";
const REGISTER_INTEREST="REGISTER INTEREST";
const PRICING="Pricing";
const PRICING_PLACEHOLDER="Choose pricing";
const ADD_TO_CART="ADD TO CART";
const Tailored_Executive_Education = 'Tailored Executive Education';
const Tailored_Executive_Program = 'Tailored Executive Program';
const Corporate_Bundle = 'Corporate Bundle';
const QUTeX_Learning_Solutions = 'QUTeX Learning Solutions';
const STORED_ACCTID = "storedAccountId";

export default class PrescribedProgram extends NavigationMixin(
  LightningElement
) {
  @api product;
  @api recordId;
  @api isInternalUser;
  @api productCategory;
  @api priceReadOnly;
  productDetails;
  programModules;
  priceBookEntries;
  professionalDevelopmentModuleDescription;
  showOverview;
  showEvolveWithQUTeX;
  showWhoShouldParticipate;
  showCoreConcepts;
  showMoreDetails
  showProgramModules;
  showProgramModulesList;

  @api productCategoryChild;

  @api ccePricebookEntryId;
  // group booking bulk registration
  @track openGroupBookingModalBulkRegistration;
  qutexLearningSolutionsCategoryBulkReg;

  deliveryTypeAndStartDates = {};
  @api availableDeliveryTypes = [];
  @api selectedDeliveryType;
  availableProgramOfferings = [];
  selectedProgramOffering = "";
  availablePricings = [];
  availablePricingsFiltered = [];
  selectedPricing = "";
  paramURL;
  getParamObj = {};
  setParamObj = {};
  onLoadTriggerBtn;
  onLoadTriggerRegInterest = false;
  urlDefaultAddToCart = false;

  @track disableDelivery = false;
  @track disableProgramOfferings = true;
  @track disablePricing = true;
  @track disableAddToCart = true;
  @track disableApply = true;
  @track displayAddToCart = true;
  @track displayQuestionnaire = false;
  @track openRegisterModal;
  @track openLoginModal;
  @track startURL;
  @track displayGroupRegistration = false;
  @track openGroupRegistration;
  @track openGroupBookingModal;
  @track displayGroupButton = false;
  @track isPrescribed = true;
  @track displayRegisterInterest;
  @track openAddToCartConfirmModal = false;
  @track displayPricing = true;
  @track displayBulkRegistration = false;
  @track displayEmployeeSelfRegistration = false;
  @track displayManageRegistration = false;
  @track disableBulkRegistration = true;
  @track disableEmployeeSelfRegistration = true;
  @track disableManageRegistration = false;
  @track displayCCEbtn = false;
  @track displayReadOnlyPricing = false;

  responseData = [];
  questions;
  openApplicationQuestionnaire = false;
  doNotShowStartDate = false;

  @track delivery;
  @track deliveryPlaceholder;
  @track availableStartDates;
  @track availableStartDatesPlaceholder;
  @track pricing;
  @track pricingPlaceholder;
  @track addToCart;
  @track registerInterest;

  subscription;
  accountId;

   //asset available credit
	assetAvailable;
  // csv bulk registration
  displayCsvBulkRegistration = false;
  //selected course offering
  programOffering;

    //Bulk Reg name to Group registration 
    groupBulkName;

  label = {
    delivery: DELIVERY,
    deliveryPlaceholder: DELIVERY_PLACEHOLDER,
    availableStartDates: AVAILABLE_STARTDATES,
    availableStartDatesPlaceholder: AVAILABLE_STARTDATES_PLACEHOLDER,
    pricing: PRICING,
    pricingPlaceholder: PRICING_PLACEHOLDER,
    addToCart: ADD_TO_CART,
    registerInterest: REGISTER_INTEREST
  };


  //parameters for modal message
  @api isRegModalMessage;
  @track message1;
  @track message2;
  @track isContinueToPayment;
  @track isContinueBrowsing;
  @track isOkay;

  @wire(MessageContext)
  messageContext;

  @wire(getRecord, { recordId: userId, fields: [CONTACT_ID] })
  user;

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

  get contactId() {
    return getFieldValue(this.user.data, CONTACT_ID);
  }

  renderedCallback() {
    Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
  }

  disconnectedCallback() {
    this.unsubscribeLMS();
  }

  connectedCallback() {
    this.subscribeLMS();
    this.productDetails = this.product.productDetails;
    this.programModules = this.product.programModules;
    this.priceBookEntries = this.product.priceBookEntryList;
    this.showOverview = this.product.productDetails.Overview__c ? true : false;
    this.showEvolveWithQUTeX = this.product.productDetails.Evolve_with_QUTeX__c ? true : false;
    this.showWhoShouldParticipate = this.product.productDetails.Who_Should_Participate__c ? true : false;
    this.showCoreConcepts = this.product.productDetails.Core_Concepts__c ? true : false;
    this.showMoreDetails = this.product.productDetails.More_Details__c ? true : false;
    this.showProgramModules = this.product.programModules ? true : false;
    this.professionalDevelopmentModuleDescription =
      "Each " +
      this.productDetails.Name +
      " Development Module is mandatory as part of this program.";
    let pricingsLocal = [];
    if(this.priceBookEntries){
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
            }),
            noOfDays: priceBookEntry.noOfDays
          });
        });
    }
  
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
    this.dollarIcon = qutResourceImg + "/QUTImages/Icon/dollar_icon.svg";

    if(this.isCCEPortal){
        if(this.productCategory == Tailored_Executive_Education || this.productCategory == Tailored_Executive_Program){
            this.groupBulkName ='Bulk Registration';
            this.displayReadOnlyPricing = false;
            this.displayBulkRegistration = true;
            this.displayEmployeeSelfRegistration = true;
            this.displayManageRegistration = true;
            this.disableBulkRegistration = true;
            this.disableEmployeeSelfRegistration = true;
            this.disableManageRegistration = false;
            this.qutexLearningSolutionsCategoryBulkReg = false;
        }
        else if(this.productCategory == Corporate_Bundle ){
          this.groupBulkName ='Bulk Registration';
            this.displayReadOnlyPricing = true;
            this.displayBulkRegistration = true;
            this.displayEmployeeSelfRegistration = true;
            this.displayManageRegistration = true;
            this.disableBulkRegistration = true;
            this.disableEmployeeSelfRegistration = true;
            this.disableManageRegistration = false;
            this.qutexLearningSolutionsCategoryBulkReg = false;
            this.displayRegisterInterest = false;
        }
        else if(this.productCategory == QUTeX_Learning_Solutions ){
          this.groupBulkName ='Group Registration';
          this.qutexLearningSolutionsCategoryBulkReg = true;
          this.displayReadOnlyPricing = true;
          this.displayBulkRegistration = true;
          this.displayEmployeeSelfRegistration = false;
          this.displayManageRegistration = true;
          this.disableBulkRegistration = true;
          this.disableEmployeeSelfRegistration = true;
          this.disableManageRegistration = false;
       }
       else{

          this.displayReadOnlyPricing = false;
       }
        this.displayRegisterInterest = false;
        this.displayGroupRegistration = false;
        this.displayQuestionnaire = false;
        this.disableApply = true;
        this.displayAddToCart = false;
        this.displayPricing = false;
    }
    else{
      this.displayBulkRegistration = false;
      this.displayEmployeeSelfRegistration = false;
      this.displayManageRegistration = false;
      this.displayRegisterInterest = false;
      this.displayGroupRegistration = false;
      this.displayQuestionnaire = false;
      this.displayAddToCart = true;
      this.displayPricing = true;
    }

    this.publishLMS();

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

          // Get Pre-selected Delivery and Start Date
          if (this.productDetails.Delivery__c) {
            let preselected = Object.keys(this.deliveryTypeAndStartDates)[0];
            this.handleDeliveryTypePreSelected(preselected);
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
            if(this.isCCEPortal ){
              this.displayQuestionnaire = false;
              this.displayAddToCart = false;
              this.disableBulkRegistration = true;
              this.disableEmployeeSelfRegistration = true;
              this.disableManageRegistration = false;
            }
            else{
              this.disableDelivery = true;
              this.displayAddToCart = false;
              this.displayQuestionnaire = false;
              this.displayRegisterInterest = false;
            }

          }
        });
    }

    //Populate Do not show start date
    if(this.productDetails.Do_not_Show_Start_Date__c){
      this.doNotShowStartDate = this.productDetails.Do_not_Show_Start_Date__c;
      this.disableDelivery = true;
    }

    if (this.onLoadTriggerRegInterest) {
      // Trigger Register Interest
      this.handleRegisterInterest();
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
    }else {

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
        //productSectionComponents[i].expand = "false";
        //productSectionComponents[i].showvalue = false;
      }
    }
  }

  /**
   * Pre-selected Delivery Type
   */
  handleDeliveryTypePreSelected(selected) {
    if (Object.keys(this.getParamObj).length > 0) {
      this.selectedDeliveryType = this.getParamObj.defDeliv;
    } else {
      this.selectedDeliveryType = selected;
    }
    let availableProgramOfferingsLocal = [];
    let programOfferingsLocal = [];
    programOfferingsLocal =
      this.deliveryTypeAndStartDates[this.selectedDeliveryType];

    if (programOfferingsLocal) {
      if(this.isCCEPortal){
        programOfferingsLocal.forEach(function (programOfferingLocal) {
          let meta = "";
          if ( programOfferingLocal.availableSeats > 0) {
            meta =
              programOfferingLocal.availableSeats + " seat left for this course";
          }
          availableProgramOfferingsLocal.push({
            label: programOfferingLocal.startDate,
            value: programOfferingLocal.id,
            meta: meta
          });
        });
      }else{
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
      }


      if(this.isCCEPortal){
        if(this.productCategory == Tailored_Executive_Education || this.productCategory == Tailored_Executive_Program){
          this.displayReadOnlyPricing = false;
          this.displayBulkRegistration = true;
          this.displayEmployeeSelfRegistration = true;
          this.displayManageRegistration = true;
          this.disableBulkRegistration = false;
          this.disableEmployeeSelfRegistration = false;
          this.disableManageRegistration = false;
          this.displayRegisterInterest = false;
        }
        else if(this.productCategory == Corporate_Bundle ){
          this.displayReadOnlyPricing = true;
          this.displayBulkRegistration = true;
          this.displayEmployeeSelfRegistration = true;
          this.displayManageRegistration = true;
          this.disableBulkRegistration = false;
          this.disableEmployeeSelfRegistration = false;
          this.disableManageRegistration = false;
        }
        else if(this.productCategory == QUTeX_Learning_Solutions ){
          this.displayReadOnlyPricing = true;
          this.displayBulkRegistration = true;
          this.displayEmployeeSelfRegistration = false;
          this.displayManageRegistration = true;
          this.disableBulkRegistration = false;
          this.disableEmployeeSelfRegistration = true;
          this.disableManageRegistration = false;
        }
        else{

          this.displayReadOnlyPricing = false;
        }
        this.displayAddToCart = false;
        this.displayGroupRegistration = false;
        this.displayQuestionnaire = false;
        this.displayRegisterInterest = false;
        this.availableProgramOfferings = availableProgramOfferingsLocal;
        this.disableProgramOfferings = false;
        this.selectedProgramOffering = undefined;
        this.disableApply = true;
      }
      //If in OPE
      else{

        this.availableProgramOfferings = availableProgramOfferingsLocal;
        this.disableProgramOfferings = false;
        this.selectedProgramOffering = undefined;
        this.selectedPricing = undefined;
        this.disablePricing = true;
        this.disableAddToCart = true;
        this.disableApply = true;

      }

      if (Object.keys(this.getParamObj).length > 0) {
        this.selectedProgramOffering = this.getParamObj.defCourseOff;
        this.selectedPricing = this.getParamObj.defPBEntry;
        this.onLoadTriggerBtn = this.getParamObj.triggerBtn;
        if (this.selectedPricing) {
          this.selectedPB = this.availablePricings.find(
            (item) => item.value === this.selectedPricing
          ).label;
        }
        this.disablePricing = false;
        this.disableAddToCart = false;
        if (this.selectedPB == "Group Booking") {
          this.displayAddToCart = false;
          this.displayGroupRegistration = true;
          if (this.hasQuestions) {
            this.displayQuestionnaire = true;
          } else {
            this.displayQuestionnaire = false;
          }
        } else {
          this.displayGroupRegistration = false;
          this.displayAddToCart = true;
          this.displayQuestionnaire = false;
          if (this.hasQuestions) {
            this.displayQuestionnaire = true;
            this.disableApply = false;
            this.displayAddToCart = false;
            if (!this.selectedPricing) {
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
        this.selectedProgramOffering = availableProgramOfferingsLocal[0].value;
        this.programOffering =  programOfferingsLocal[0];
        this.programOffering =  {...this.programOffering, value: this.programOffering.id}
        this.handleProgramOfferingPreSelected(this.selectedProgramOffering);
      }
    }
  }

  handleDeliveryTypeSelected(event) {
    this.selectedDeliveryType = event.detail.value;
    let availableProgramOfferingsLocal = [];
    let programOfferingsLocal = [];
    programOfferingsLocal =
      this.deliveryTypeAndStartDates[this.selectedDeliveryType];
      if(this.isCCEPortal){
        programOfferingsLocal.forEach(function (programOfferingLocal) {
          let meta = "";
          if ( programOfferingLocal.availableSeats > 0) {
            meta =
              programOfferingLocal.availableSeats + " seat left for this course";
          }
          availableProgramOfferingsLocal.push({
            label: programOfferingLocal.startDate,
            value: programOfferingLocal.id,
            meta: meta
          });
        });
      }else{
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
      }
    this.programOffering = programOfferingsLocal.filter(programOffrng => programOffrng.defDeliv == this.selectedDeliveryType)[0];
    //add value parameter
    this.programOffering =  {...this.programOffering, value: this.programOffering.id} 
    // this.programOffering = programOfferingLocal;
    if(this.isCCEPortal){
      if(this.productCategory == Tailored_Executive_Education || this.productCategory == Tailored_Executive_Program){
        this.displayReadOnlyPricing = false;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = true;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = true;
        this.disableEmployeeSelfRegistration = true;
        this.disableManageRegistration = false;
      }
      else if(this.productCategory == Corporate_Bundle ){
        this.displayReadOnlyPricing = true;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = true;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = true;
        this.disableEmployeeSelfRegistration = true;
        this.disableManageRegistration = false;
      }
      else if(this.productCategory == QUTeX_Learning_Solutions ){
        this.displayReadOnlyPricing = true;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = false;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = true;
        this.disableEmployeeSelfRegistration = true;
        this.disableManageRegistration = false;
      }
      else{

        this.displayReadOnlyPricing = false;
      }
      this.displayAddToCart = false;
      this.displayGroupRegistration = false;
      this.displayQuestionnaire = false;
      this.displayRegisterInterest = false;
      this.availableProgramOfferings = availableProgramOfferingsLocal;
      this.disableProgramOfferings = false;
      this.selectedProgramOffering = undefined;
      this.disableApply = true;
      this.displayGroupRegistration = false;
      this.displayQuestionnaire = false;
      this.disableApply = true;
      this.disableAddToCart = true;
      this.displayAddToCart = false;
      if (this.hasQuestions) {
        this.displayQuestionnaire = false;
        this.displayAddToCart = false;
      }
    }
    else{
      this.availableProgramOfferings = availableProgramOfferingsLocal;
      this.disableProgramOfferings = false;
      this.selectedProgramOffering = undefined;
      this.selectedPricing = undefined;
      this.disablePricing = true;
      this.displayGroupRegistration = false;
      this.displayQuestionnaire = false;
      this.disableApply = true;
      this.disableAddToCart = true;
      this.displayAddToCart = true;
      if (this.hasQuestions) {
        this.displayQuestionnaire = true;
        this.displayAddToCart = false;
      }
    }

  }

  handleProgramOfferingPreSelected(preselected) {
    if(this.isCCEPortal){
      if(this.productCategory == Tailored_Executive_Education || this.productCategory == Tailored_Executive_Program){
        this.displayReadOnlyPricing = false;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = true;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = false;
        this.disableEmployeeSelfRegistration = false;
        this.disableManageRegistration = false;
      }
      else if(this.productCategory == Corporate_Bundle ){
        this.displayReadOnlyPricing = true;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = true;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = false;
        this.disableEmployeeSelfRegistration = false;
        this.disableManageRegistration = false;
      }
      else if(this.productCategory == QUTeX_Learning_Solutions ){
        this.displayReadOnlyPricing = true;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = false;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = false;
        this.disableEmployeeSelfRegistration = true;
        this.disableManageRegistration = false;
      }
      else{

        this.displayReadOnlyPricing = false;
      }
      this.selectedPricing = undefined;
      this.disablePricing = true;
      this.disableApply = true;
      this.displayGroupRegistration = false;
      this.displayQuestionnaire = false;
      this.disableApply = true;
      this.disableAddToCart = true;
      this.displayAddToCart = false;
      if (this.hasQuestions) {
        this.displayQuestionnaire = false;
        this.displayAddToCart = false;
      }
    }
    else{
      this.selectedPricing = undefined;
      this.disablePricing = false;
      this.disableAddToCart = true;
      this.disableApply = true;
    }

    this.handleFilterPricing();
  }

  handleProgramOfferingSelected(event) {
    if(this.isCCEPortal){
      if(this.productCategory == Tailored_Executive_Education || this.productCategory == Tailored_Executive_Program){
        this.displayReadOnlyPricing = false;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = true;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = false;
        this.disableEmployeeSelfRegistration = false;
        this.disableManageRegistration = false;
      }
      else if(this.productCategory == Corporate_Bundle ){
        this.displayReadOnlyPricing = true;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = true;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = false;
        this.disableEmployeeSelfRegistration = false;
        this.disableManageRegistration = false;
      }
      else if(this.productCategory == QUTeX_Learning_Solutions ){
        this.displayReadOnlyPricing = true;
        this.displayBulkRegistration = true;
        this.displayEmployeeSelfRegistration = false;
        this.displayManageRegistration = true;
        this.disableBulkRegistration = false;
        this.disableEmployeeSelfRegistration = true;
        this.disableManageRegistration = false;
      }
      else{

        this.displayReadOnlyPricing = false;
      }
      this.selectedProgramOffering = event.detail.value;
      this.selectedPricing = undefined;
      this.disablePricing = false;
      this.displayGroupRegistration = false;
      this.displayQuestionnaire = false;
      this.disableApply = true;
      this.disableAddToCart = true;
      this.displayAddToCart = false;
      this.displayGroupRegistration = false;
      this.displayPricing = false;
      if (this.hasQuestions) {
        this.displayQuestionnaire = false;
        this.displayAddToCart = false;
      }

    }
    else{
      this.selectedProgramOffering = event.detail.value;
      this.selectedPricing = undefined;
      this.disablePricing = false;
      this.displayGroupRegistration = false;
      this.displayQuestionnaire = false;
      this.disableApply = true;
      this.disableAddToCart = true;
      this.displayAddToCart = true;
      if (this.hasQuestions) {
        this.displayQuestionnaire = true;
        this.displayAddToCart = false;
      }
    }

    this.handleFilterPricing();
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
      this.disableApply = false;
    }
  }

  //handles the filtering of prices
  handleFilterPricing(){
        //loop in available offerings to find the selected
    this.availableProgramOfferings.forEach((pOffer) => {
      if(pOffer.value === this.selectedProgramOffering) {

        //create temp array for pricebookentries
        let pbEntriesTemp = [...this.availablePricings];

        //loop on the price book entries
        pbEntriesTemp.forEach((item, index, arr) => {

          //find the early bird
          if (item.label === 'Early Bird') {

            //get and convert the date values
            let offeringDate = new Date(pOffer.label);
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
        this.availablePricingsFiltered = pbEntriesTemp;
      }
    });
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
          // this.generateToast("Success!", "Interest Registered", "success");
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
      this.setParamURL("regInt");
      this.openRegisterModal = true;
    }
  }

  handleEmployeeSelfRegistration(){
    let pbEId = '';
    if(this.productCategory != Tailored_Executive_Education){
      pbEId = this.ccePricebookEntryId ? this.ccePricebookEntryId: '';
    }

    let selfRegistrationParameters = {
      userId: userId,
      productId: this.productDetails.Id,
      selectedOffering : this.selectedProgramOffering,
      pricebookEntryId : pbEId
    };

    if(sessionStorage.getItem(STORED_ACCTID)){
      this.accountId =  sessionStorage.getItem(STORED_ACCTID);
    }

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

  notifyApply() {
    if (!isGuest) {
      this.openApplicationQuestionnaire = true;
    } else {
      // Display Custom Login Form LWC
      this.setParamURL("apply");
      this.openRegisterModal = true;
    }
  }

  notifyAddToCart() {
    if (!isGuest) {
      this.urlDefaultAddToCart = false;
      this.dispatchAddToCartEvent();
    } else {
      this.setParamURL("addCart");
      this.openRegisterModal = true;
    }
  }

  dispatchAddToCartEvent() {
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: {
          programOfferingId: this.selectedProgramOffering,
          pricebookEntryId: this.selectedPricing,
          urlDefaultAddToCart: this.urlDefaultAddToCart
        }
      })
    );
    this.openAddToCartConfirmModal = true;
    this.message1 = "Product is added successfully to the cart.";
    this.message2 = "How would you like to proceed?";
    this.isContinueBrowsing = true;
    this.isContinueToPayment = true;
    this.isOkay = false;
  }

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
  groupRegistrationModalClosed() {
    this.openGroupRegistration = false;
    this.openGroupBookingModalBulkRegistration = false;

  }
  groupRegistration() {
    if (!isGuest) {
      this.openGroupRegistration = true;
    } else {
      this.setParamURL("groupReg");
      this.openRegisterModal = true;
    }
  }

  applicationQuestionnaireClosed() {
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

  bulkRegistration() {
    if(this.qutexLearningSolutionsCategoryBulkReg == true){
      this.openGroupBookingModalBulkRegistration = true;

    } else {
		if(this.productCategory == Corporate_Bundle){
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


  setParamURL(btn) {
    // Set Button to Trigger on Load
    this.setParamObj.triggerBtn = btn;
    // Set Delivery default
    if (this.selectedDeliveryType) {
      this.setParamObj.defDeliv = this.selectedDeliveryType;
    }

    // Set Offering default
    if (this.selectedProgramOffering) {
      this.setParamObj.defCourseOff = this.selectedProgramOffering;
    }

    // Set Price default
    if (this.selectedPricing) {
      this.setParamObj.defPBEntry = this.selectedPricing;
    }
    this.paramURL = "?param=" + btoa(JSON.stringify(this.setParamObj));
  }
  //Check if CCE portal
  get isCCEPortal() {
    return BasePath.toLowerCase().includes("cce");
  }

  //opens bulk registration modal
  bulkRegistration() {
    if(this.qutexLearningSolutionsCategoryBulkReg == true){
      this.openGroupBookingModalBulkRegistration = true;
    } else if(this.productCategory == Corporate_Bundle){
			assetRecordData({
				Pricebook2Id: this.productDetails.PricebookEntries[0].Pricebook2.Id
			})
			.then((results) => {
				this.assetAvailable = results.Remaining_Value__c;
				this.displayCsvBulkRegistration = true;
			})
			.catch((e) => {
				this.generateToast("Error.", LWC_Error_General, "error");
				console.log(e);
			});
		}else{
			this.displayCsvBulkRegistration = true;
		}
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
  closeRegisterModal() {
    this.displayCsvBulkRegistration = false;
  }

  publishLMS() {
    let paramObj = {
        categoryName: this.productCategory
    };

    const message = {
        parameterJson: JSON.stringify(paramObj)
    };

    publish(this.messageContext, payloadContainerLMS, message);
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
      }
  }

  unsubscribeLMS(){
    unsubscribe(this.subscription);
    this.subscription = null;
  }
}