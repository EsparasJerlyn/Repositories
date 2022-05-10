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
 */

import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import communityId from "@salesforce/community/Id";
import isGuest from "@salesforce/user/isGuest";
import getProductDetails from "@salesforce/apex/ProductDetailsCtrl.getProductRelatedRecords";
import getCartSummary from "@salesforce/apex/B2BGetInfo.getCartSummary";
import addToCartItem from "@salesforce/apex/ProductDetailsCtrl.addToCartItem";

export default class ProductDetails extends LightningElement {
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

  // Get Product Details
  @wire(getProductDetails, {
    productId: "$recordId"
  })
  productDetails;

  // The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
  connectedCallback() {
    if (!isGuest) {
      this.updateCartInformation();
    }
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

  // Gets whether product information has been retrieved for display.
  get hasProduct() {
    return this.productDetails.data !== undefined;
    /* return this.productDetails.data
    ? this.productDetails.data.productOnPage
    : []; */
  }

  // Gets priceBookEntries related to the product
  get priceBookEntryList() {
    return this.productDetails.data
      ? this.productDetails.data.pricebookWrapperList
      : [];
  }

  // Gets Delivery Options related to the product
  get deliveryOptions() {
    return this.productDetails.data
      ? this.productDetails.data.deliveryWrapperList
      : [];
  }

  // Gets Product Fields
  get productOnPage() {
    return this.productDetails.data
      ? this.productDetails.data.productOnPage
      : [];
  }

  // Gets Product Fields
  get isNotFlexProgram() {
    return this.productDetails.data
      ? this.productDetails.data.isNotFlexProgram
      : [];
  }

  // Gets List oc Child Products
  get cProducts() {
    // console.log('productDetails: ' + JSON.stringify(this.productDetails));
    return this.productDetails.data
      ? this.productDetails.data.childProductList
      : [];
  }

  // Gets whether the cart is currently locked
  get _isCartLocked() {
    const cartStatus = (this.cartSummary || {}).status;
    return cartStatus === "Processing" || cartStatus === "Checkout";
  }

  //Custom
  addToCartItem(event) {
    addToCartItem({
      communityId: communityId,
      productId: this.recordId,
      effectiveAccountId: this.resolvedEffectiveAccountId,
      productName: this.productDetails.data.productOnPage.Name,
      courseOfferingId: event.detail.courseOfferingId,
      pricebookEntryId: event.detail.pricebookEntryId
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
      .catch(() => {
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

  
  /*   handleRefresh() {
    refreshApex(this.productDetails);
  } */
}