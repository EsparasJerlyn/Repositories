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
*/

import { LightningElement, api } from "lwc";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import { NavigationMixin } from "lightning/navigation";
import BasePath from '@salesforce/community/basePath';
import customSR from "@salesforce/resourceUrl/QUTInternalCSS";
import { loadStyle } from "lightning/platformResourceLoader";
const STOREPRODUCTCATEGORY = "product_category";
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

  renderedCallback(){
    Promise.all([loadStyle(this, customSR + "/QUTInternalCSS.css")]);
  }

  // For CCE Product Details
  get isCCEPortal() {
    return BasePath.toLowerCase().includes("cce");
  }

  // For OPE Product Details
  get isOPEPortal() {
    return BasePath.toLowerCase().includes("study");
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
  }

  // Get Icons from Static Resources
  getIcons() {
    this.clipboard_icon = qutResourceImg + "/QUTImages/Icon/clipboard_icon.svg";
    this.dollar_icon = qutResourceImg + "/QUTImages/Icon/dollar_icon.svg";
    this.time_icon = qutResourceImg + "/QUTImages/Icon/time_icon.svg";
    this.location_icon = qutResourceImg + "/QUTImages/Icon/location_icon.svg";
    this.total_course_icon = qutResourceImg + "/QUTImages/Icon/total_course_icon.svg";
  }
}
