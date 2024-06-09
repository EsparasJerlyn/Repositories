/**
 * @description A LWC component to display product child details
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | keno.domienri.dico        | April 29, 2022        | DEPP-2038            | Create child product display records         |
      | mary.grace.li             | July 01, 2022         | DEPP-3124            | Updated product detail URL for SEO           |
      | john.bo.a.pineda          | July 04, 2022         | DEPP-3385            | Removed replaceAll spaces to "-"             |
      | keno.domienri.dico        | July 14, 2022         | DEPP-2699/DEPP-3420  | Added logic for CCE or OPE environment option|
      | jessel.bajao              | August 2, 2022        | DEPP-3476            | Added code to get current product category   |
      | mary.grace.li             | November 22, 2022     | DEPP-4693            | Added Selected account logic                 |
*/

import { LightningElement, api, wire } from "lwc";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import { NavigationMixin } from "lightning/navigation";
import customSR from "@salesforce/resourceUrl/QUTInternalCSS";
import { loadStyle } from "lightning/platformResourceLoader";
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import payloadAcctContainerLMS from '@salesforce/messageChannel/AccountId__c';
const STOREPRODUCTCATEGORY = "product_category";
const STORED_ACCTID = "storedAccountId";
/**
 * An organized display of a single product card.
 *
 * @fires ProductCard#showdetail
 */

export default class ProductCard extends NavigationMixin(LightningElement) {
  @api isTailoredExecEduc;
  @api productDetails;
  @api productDetail;
  @api readOnly = false;
  @api fromCategoryName;
  @api fromCategoryId;
  // Icons
  clipboard_icon;
  dollar_icon;
  location_icon;
  time_icon;
  total_course_icon;
  // URL
  recordPageUrl;
  urlString;
  currentURL;
  productPath;
  baseUrl;
  cProductId;
  cProductName;
  detailUrl;

  subscription;
  accountId;
  basePath;

  @wire(MessageContext)
  messageContext;

  renderedCallback(){
   // Promise.all([loadStyle(this, customSR + "/QUTInternalCSS.css")]);
    this.subscribeLMS();   
  }

  // For CCE Product Details
  get isCCEPortal() {
    return this.basePath ? this.basePath.toLowerCase().includes("cce"): '';
  }

  // For OPE Product Details
  get isOPEPortal() {
    return this.basePath ? this.basePath.toLowerCase().includes("study") : '';
  }

  // Navigate to the Single Product Page
  navigateToProductPage(event) {
    if (!this.readOnly) {
      this.cProductId = event.currentTarget.dataset.id;
      this.cProductName = event.currentTarget.dataset.name;
      this.detailUrl = event.currentTarget.dataset.url;
      this.productPath = window.location.pathname;
      this.baseUrl = window.location.origin;

      if(this.isOPEPortal){
        this.recordPageUrl = this.baseUrl + "/study/s/" + this.detailUrl;
      }else{
        this.recordPageUrl = this.baseUrl + "/cce/s/" + this.detailUrl;
      }
      //gets isTailoredExecEduc value to store in session storage if CCE Portal
      if(this.isCCEPortal){
        let currentProductCategory = {
          isTailoredExecEduc: this.isTailoredExecEduc,
          fromCategoryName: this.fromCategoryName,
          fromCategoryId: this.fromCategoryId,
        };
        sessionStorage.setItem(
          STOREPRODUCTCATEGORY,
          JSON.stringify(currentProductCategory)
        );
      }

      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: this.recordPageUrl
        }
      });
    }
  }

  connectedCallback() {
    // Get icons
    this.getIcons();
    this.basePath = window.location.href;
  }

  // Get Icons from Static Resources
  getIcons() {
    this.clipboard_icon = qutResourceImg + "/QUTImages/Icon/clipboard_icon.svg";
    this.dollar_icon = qutResourceImg + "/QUTImages/Icon/dollar_icon.svg";
    this.time_icon = qutResourceImg + "/QUTImages/Icon/time_icon.svg";
    this.location_icon = qutResourceImg + "/QUTImages/Icon/location_icon.svg";
    this.total_course_icon = qutResourceImg + "/QUTImages/Icon/total_course_icon.svg";
  }

  disconnectedCallback() {
    this.unsubscribeLMS();
  }

  unsubscribeLMS(){
      unsubscribe(this.subscription);
      this.subscription = null;
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
}