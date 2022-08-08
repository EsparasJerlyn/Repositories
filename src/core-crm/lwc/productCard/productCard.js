/**
 * @description A LWC component to display product child details
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | keno.domienri.dico        | April 29, 2022        | DEPP-2038            | Create child product display records                  |
      | mary.grace.li             | July 01, 2022         | DEPP-3124            | Updated product detail URL for SEO           |
      | john.bo.a.pineda          | July 04, 2022         | DEPP-3385            | Removed replaceAll spaces to "-"             |
 */

import { LightningElement, api } from "lwc";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import { NavigationMixin } from "lightning/navigation";
/**
 * An organized display of a single product card.
 *
 * @fires ProductCard#showdetail
 */
export default class ProductCard extends NavigationMixin(LightningElement){
  @api productDetails;
  @api readOnly = false;
  // Icons
  clipboard_icon;
  dollar_icon;
  location_icon;
  time_icon;
  // URL
  recordPageUrl;
  urlString;
  currentURL;
  productPath;
  baseUrl;
  cProductId;
  cProductName;
  detailUrl;

  // Navigate to the Single Product Page
  navigateToProductPage(event) {
    if (!this.readOnly) {
      this.cProductId = event.currentTarget.dataset.id;
      this.cProductName = event.currentTarget.dataset.name;
      this.detailUrl = event.currentTarget.dataset.url;
      this.productPath = window.location.pathname;
      this.baseUrl = window.location.origin;

      this.recordPageUrl = this.baseUrl + "/study/s/" + this.detailUrl;

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
  }
}