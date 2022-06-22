/**
 * @description A LWC component to display product details
 *
 * @see ../classes/ProductDetailsCtrl.cls
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
      | john.bo.a.pineda          | April 11, 2022        | DEPP-1211            | Modified logic for new UI                    |
      | keno.domienri.dico        | April 29, 2022        | DEPP-2038            | Added child product records                  |
      | burhan.m.abdul            | June 09, 2022         | DEPP-2811            | Added messageService                         |
 */

import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import communityId from "@salesforce/community/Id";
import isGuest from "@salesforce/user/isGuest";
import getProductDetails from "@salesforce/apex/ProductDetailsCtrl.getProductRelatedRecords";
import getCartSummary from "@salesforce/apex/B2BGetInfo.getCartSummary";
import addToCartItem from "@salesforce/apex/ProductDetailsCtrl.addToCartItem";
import userId from "@salesforce/user/Id";

import { publish, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';

export default class ProductDetails extends LightningElement {
  loading;
  productDetails;
  priceBookEntryList;
  deliveryOptions;
  product;
  showPrescribedProgram;
  showFlexibleProgram;
  showProductDetailsSingle;
  showProductDetailsDisplay;
  cProducts;
  isProgramFlex = false;
  availablePricings =[];
    // Gets & Sets the effective account - if any - of the user viewing the product.
  @api
  get effectiveAccountId() {
    return this._effectiveAccountId;
  }

  set effectiveAccountId(newId) {
    this._effectiveAccountId = newId;
    if (!isGuest) {
      this.updateCartInformation();
    }
  }

  // Gets or sets the unique identifier of a product.
  @api recordId;
  // Gets or sets the custom fields to display on the product in a comma-separated list of field names
  @api customDisplayFields;
  // The cart summary information
  cartSummary;

  @wire(MessageContext)
  messageContext;

  // The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
  connectedCallback() {
    this.loading = true;
    this.showPrescribedProgram = false;
    this.showFlexibleProgram = false;
    this.showProductDetailsSingle = false;
    this.showProductDetailsDisplay = false;
    this.getProductDetailsApex(this.recordId);
    if (!isGuest) {
      this.updateCartInformation();
    }
    this.dispatchEvent(
      new CustomEvent("cartchanged", {
        bubbles: true,
        composed: true
      })
    );
  }

  getProductDetailsApex(productId){
    getProductDetails({productId: productId})
      .then( (result) => {
        this.isProgramFlex = !result.isNotFlexProgram;
        this.productDetails = result.productOnPage;
        this.priceBookEntryList = result.pricebookWrapperList;
        this.deliveryOptions = result.deliveryWrapperList;
        this.product = {};
        this.product.productDetails = result.productOnPage;
        this.product.programModules = result.moduleWrapperList;
        this.product.priceBookEntryList = result.pricebookWrapperList;
        let pricingsLocal = [];
        this.product.priceBookEntryList.forEach(function (priceBookEntry) {
          pricingsLocal.push({
            label: priceBookEntry.label === 'Standard Price Book'? priceBookEntry.label.slice(0, 8): priceBookEntry.label,
            value: priceBookEntry.value,
            meta: parseInt(priceBookEntry.meta).toLocaleString('en-US', { style: 'currency', currency: 'USD',  minimumFractionDigits: 0 })
          });
        });
        this.availablePricings = pricingsLocal;
        this.product.deliveryOptions = result.deliveryWrapperList;
        this.product.programDeliveryAndOfferings = result.programDeliveryAndOfferingMap;      
        console.log('testing: ' + this.product);   
        if(this.product.productDetails.Program_Plan__r == undefined){
          this.showPrescribedProgram = false;
          this.showFlexibleProgram = true;
          this.showProductDetailsSingle = false;
          this.showProductDetailsDisplay = true;
        } else  if(this.product.productDetails.Program_Plan__r.Program_Delivery_Structure__c == 'Prescribed Program'){ 
          this.showPrescribedProgram = true;
          this.showFlexibleProgram = false;
          this.showProductDetailsSingle = false;
          this.showProductDetailsDisplay = false;
        } else if(this.product.productDetails.Program_Plan__r.Program_Delivery_Structure__c == 'Flexible Program'){ 
          this.showPrescribedProgram = false;
          this.cProducts = result.childProductList;
          this.showFlexibleProgram = false;
          this.showProductDetailsSingle = false;
          this.showProductDetailsDisplay = true;
        } else {
          this.showPrescribedProgram = false;
          this.showFlexibleProgram = true;
          this.showProductDetailsSingle = false;
          this.showProductDetailsDisplay = true;
        }
        this.loading = false;

        this.publishLMS();
      })
      .catch( (error)=>{
        console.log(error);
      }).finally(()=> {
        this.loading = false;
      })
      
  }

  // Gets the normalized effective account of the user.
  get resolvedEffectiveAccountId() {
    const effectiveAccountId = this.effectiveAccountId || "";
    let resolved = null;

    if (
      effectiveAccountId.length > 0 &&
      effectiveAccountId !== "000000000000000"
    ) {
      resolved = effectiveAccountId;
    }
    return resolved;
  }

  // Gets Product Fields
  /*get isNotFlexProgram() {
    return this.productDetails.data
      ? this.productDetails.data.isNotFlexProgram
      : [];
  }*/

  // Gets List oc Child Products
  /*get cProducts() {
    // console.log('productDetails: ' + JSON.stringify(this.productDetails));
    return this.productDetails.data
      ? this.productDetails.data.childProductList
      : [];
  }*/

  // Gets whether the cart is currently locked
  get _isCartLocked() {
    const cartStatus = (this.cartSummary || {}).status;
    return cartStatus === "Processing" || cartStatus === "Checkout";
  }

  //Custom
  addToCartItem(event) {
    let courseOfferingId = '';
    let programOfferingId = '';
    if(event.detail.courseOfferingId!=undefined){
      courseOfferingId = event.detail.courseOfferingId;
    }
    if(event.detail.programOfferingId!=undefined){
      programOfferingId = event.detail.programOfferingId;
    }
    addToCartItem({
      communityId: communityId,
      productId: this.recordId,
      effectiveAccountId: this.resolvedEffectiveAccountId,
      productName: this.productDetails.Name,
      courseOfferingId: courseOfferingId,
      programOfferingId: programOfferingId,
      pricebookEntryId: event.detail.pricebookEntryId,
      userId : userId
    })
      .then((result) => {
        console.log(JSON.stringify(result));
        this.dispatchEvent(
          new CustomEvent("cartchanged", {
            bubbles: true,
            composed: true
          })
        );
        /* this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Your cart has been updated.",
            variant: "success",
            mode: "dismissable"
          })
        ); */
      })
      .catch((e) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message:
              "{0} could not be added to your cart at this time. Please try again later.",
            messageData: [this.productDetails.data.productOnPage.Name],
            variant: "error",
            mode: "dismissable"
          })
        );
      });
  }

  // Ensures cart information is up to date
  updateCartInformation() {
    getCartSummary({
      communityId: communityId,
      effectiveAccountId: this.resolvedEffectiveAccountId
    })
      .then((result) => {
        this.cartSummary = result;
      })
      .catch((e) => {
        // Handle cart summary error properly
        console.log(e);
      });
  }

  handleviewproduct(event){
    let tempObj = this.product;
    this.product = {};
    this.product.productDetails = event.detail.value;
    this.product.parent = tempObj;
    this.showPrescribedProgram = false;
    this.showFlexibleProgram = false;
    this.showProductDetailsSingle = true;
  }

  handlebacktoprogram(event){
    let tempObj = event.detail.value;
    this.product = tempObj.parent;
    this.showPrescribedProgram = true;
    this.showFlexibleProgram = false;
    this.showProductDetailsSingle = false;
  }
  
  /*   handleRefresh() {
    refreshApex(this.productDetails);
  } */

  //burhan
  publishLMS() {
    let paramObj = {
      productId: this.productDetails.Id,
      productName: this.productDetails.Name,
      isProgramFlex: this.isProgramFlex,
      children: this.cProducts,
      clearOtherMenuItems: true
    }
    
    const payLoad = {
      parameterJson: JSON.stringify(paramObj)
    };

    publish(this.messageContext, payloadContainerLMS, payLoad);
  }
}