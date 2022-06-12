import { LightningElement, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { loadStyle } from "lightning/platformResourceLoader";
import customSR1 from "@salesforce/resourceUrl/QUTInternalCSS";
import getProductDataRelatedToProductRequest from "@salesforce/apex/ProductDetailsCtrl.getProductDataRelatedToProductRequest";

export default class ShowPreview extends LightningElement {
  @api recordId;
  @api productId;
  loading;
  productDetails;
  priceBookEntryList;
  deliveryOptions;
  product;
  showPrescribedProgram;
  showProductDetailsSingle;
  showProductDetailsDisplay;
  isNotFlexProgram;
  cProducts;
  isInternalUser;

  renderedCallback() {
    Promise.all([loadStyle(this, customSR1 + "/QUTInternalCSS.css")]);
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.recordId;
      this.isInternalUser = true;
    }
  }

  connectedCallback() {
    this.loading = true;
    this.showPrescribedProgram = false;
    this.showProductDetailsSingle = false;
    this.showProductDetailsDisplay = false;
    this.getProductData(this.recordId);
  }

  getProductData(productRequestId) {
    getProductDataRelatedToProductRequest({
      productRequestId: productRequestId
    })
      .then((result) => {
        let productType = result.productType;
        let productId = result.productId;
        this.product = {};
        if (productType == "Prescribed Program") {
          this.product.productDetails = result.product.productOnPage;
          this.product.programModules = result.product.moduleWrapperList;
          this.product.priceBookEntryList = result.product.pricebookWrapperList;
          this.product.deliveryOptions = result.product.deliveryWrapperList;
          this.product.programDeliveryAndOfferings =
            result.product.programDeliveryAndOfferingMap;
          this.showPrescribedProgram = true;
          this.showProductDetailsSingle = false;
          this.showProductDetailsDisplay = false;
          this.isNotFlexProgram = true;
        } else if (productType == "Flexible Program") {
          this.product.productDetails = result.product.productOnPage;
          this.product.priceBookEntryList = result.product.pricebookWrapperList;
          this.product.deliveryOptions = result.product.deliveryWrapperList;
          this.product.cProducts = result.product.childProductList;
          this.product.isNotFlexProgram = false;
          this.showPrescribedProgram = false;
          this.showProductDetailsSingle = false;
          this.showProductDetailsDisplay = true;
        } else if (productType == "Prescribed Program Module") {
          this.product.productDetails = result.product;
          this.product.parent = {};
          this.product.parent.productDetails = result.parent.productOnPage;
          this.product.parent.programModules = result.parent.moduleWrapperList;
          this.product.parent.priceBookEntryList =
            result.parent.pricebookWrapperList;
          this.product.parent.deliveryOptions =
            result.parent.deliveryWrapperList;
          this.product.parent.programDeliveryAndOfferings =
            result.parent.programDeliveryAndOfferingMap;
          this.showPrescribedProgram = false;
          this.showProductDetailsSingle = true;
          this.showProductDetailsDisplay = false;
          this.isNotFlexProgram = false;
        } else if (productType == "Single Product") {
          this.product.productDetails = result.product.productOnPage;
          this.product.priceBookEntryList = result.product.pricebookWrapperList;
          this.product.deliveryOptions = result.product.deliveryWrapperList;
          this.product.cProducts = result.product.childProductList;
          this.product.isNotFlexProgram = true;
          this.showPrescribedProgram = false;
          this.showProductDetailsSingle = false;
          this.showProductDetailsDisplay = true;
        }
      })
      .catch((error) => {
        console.log(error);
      })
      .finally(() => {
        this.loading = false;
      });
  }

  handleviewproduct(event) {
    let tempObj = this.product;
    this.product = {};
    this.product.productDetails = event.detail.value;
    this.product.parent = tempObj;
    this.showPrescribedProgram = false;
    this.showProductDetailsSingle = true;
  }

  handlebacktoprogram(event) {
    let tempObj = event.detail.value;
    this.product = tempObj.parent;
    this.showPrescribedProgram = true;
    this.showProductDetailsSingle = false;
  }

  addToCartItem(event) {}
}
