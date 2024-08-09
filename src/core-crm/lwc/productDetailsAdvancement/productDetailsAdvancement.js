/**
 * @description A LWC component to display product details advancement
 *
 * @see ../classes/ProductController.cls
 * @see productDetailsDisplayAdvancement
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | richard.a.santos             | July 4, 2024      | DEPP-9140             | Add New Component                            |
*/
import { LightningElement, api, track } from "lwc";

// import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
// import insertExpressionOfInterest from "@salesforce/apex/ProductDetailsCtrl.insertExpressionOfInterest";
// import getRelatedCourseOffering from "@salesforce/apex/ProductDetailsCtrl.getCourseOfferingRelatedRecords";
// import getQuestions from "@salesforce/apex/ProductDetailsCtrl.getQuestions";
// import assetRecordData from "@salesforce/apex/ProductDetailsCtrl.assetRecordData";

//import getDesignationProdDetails from "@salesforce/apex/DesignationProductCtrl.getDesignationProductDetails"

export default class ProductDetailsAdvancement extends LightningElement {

  @api productDetails;
  @track isPopupOpen = false;
  product;

  @api advancementProductDetails;

  openPopup(event) {
    event.preventDefault();
    this.isPopupOpen = true;
  }

  closePopup() {
    this.isPopupOpen = false;
  }

  renderedCallback() {
    this.template.querySelector('.open-popup').addEventListener('click', (event) => this.openPopup(event));
  }

  isMobile = false;

  connectedCallback() {
    this.updateIsMobile();
    window.addEventListener('resize', this.updateIsMobile.bind(this));

    //this.getDesignationProdDetails(this.recordId);
  }

  disconnectedCallback() {
      window.removeEventListener('resize', this.updateIsMobile.bind(this));
  }

  updateIsMobile() {
      this.isMobile = window.innerWidth <= 768; // Define your mobile breakpoint here
  }

  // getDesignationProdDetails(productId){
  //   getDesignationProdDetails({ productId: productId })
  //   .then((result) => {
  //     this.product = result;
  //     console.log(this.product);
  //   })
  //   .catch((error) => {
  //     console.log(error);
  //   });
  // }
}