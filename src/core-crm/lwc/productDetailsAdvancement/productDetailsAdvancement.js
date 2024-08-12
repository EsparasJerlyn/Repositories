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

 import getDesignationProdDetails from "@salesforce/apex/DesignationProductCtrl.getDesignationProductDetails"

export default class ProductDetailsAdvancement extends LightningElement {

  //productDetails;
  @track isPopupOpen = false;
  product;

  @api advancementProductDetails;
  @api amount1;
  @api amount2;
  @api amount3;
  @api amount4;
  
  @api recordId;

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
  
    //console.log('Record Id: ' + this.recordId);
   // this.getDesignationProdDetails('01t9r000005drWDAAY');
  }

  disconnectedCallback() {
      window.removeEventListener('resize', this.updateIsMobile.bind(this));
  }

  updateIsMobile() {
      this.isMobile = window.innerWidth <= 768; // Define your mobile breakpoint here
  }

  getDesignationProdDetails(productId){
    getDesignationProdDetails({ productId: productId })
    .then((result) => {
      if(result){
        this.advancementProductDetails = result;
        //this.advancementProductDetails = result.productOnPage;
        //console.log('advancementProductDetails ' + this.advancementProductDetails);
        console.log('result.productOnPage: ' + JSON.stringify(result.productOnPage));
        console.log('result: ' + JSON.stringify(result));
      }
    })
    .catch((error) => {
      console.log(error);
    });
  }
}