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
 */
import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
/* Images */
import Facilitator from '@salesforce/resourceUrl/Facilitator';
import Recently1 from '@salesforce/resourceUrl/Recently1';
import Recently2 from '@salesforce/resourceUrl/Recently2';
import Recently3 from '@salesforce/resourceUrl/Recently3';
import BasePath from '@salesforce/community/basePath';
import insertExpressionOfInterest from '@salesforce/apex/ProductDetailsCtrl.insertExpressionOfInterest'
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';
import isGuest from '@salesforce/user/isGuest';

// A fixed entry for the home page.
const homePage = {
  name: "Home",
  type: "standard__namedPage",
  attributes: {
    pageName: "home"
  }
};

const MSG_ERROR = LWC_Error_General;
const INTEREST_EXISTS_ERROR = 'You already registered your interest for this product.';

/**
 * An organized display of product information.
 *
 * @fires ProductDetailsDisplay#addtocart
 * @fires ProductDetailsDisplay#createandaddtolist
 */
export default class ProductDetailsDisplay extends NavigationMixin(
  LightningElement
) {
  facilitator = Facilitator;
  image1 = Recently1;
  image2 = Recently2;
  image3 = Recently3;
  selectedOfferingId = "";
  selectedDate;
  @api recordId;
  @api objectApiName;

  //product fields to display
  @api overview;
  @api whoShouldParticipate;
  @api coreConcepts;
  @api moreDetails;
  @api evolveWithQutex;
  @api registerInterestAvailable;

  @api courseOfferings;
  @api priceBookEntries;
  @api productOnPage;

  clickedRegisterLabel = 'ADD TO CART';
  clickedShowLabel = 'SHOW MORE';
  showVisible = false;

  /**
   * A product image.
   * @typedef {object} Image
   *
   * @property {string} url
   *  The URL of an image.
   *
   * @property {string} alternativeText
   *  The alternative display text of the image.
   */

  /**
   * A product category.
   * @typedef {object} Category
   *
   * @property {string} id
   *  The unique identifier of a category.
   *
   * @property {string} name
   *  The localized display name of a category.
   */

  /**
   * A product price.
   * @typedef {object} Price
   *
   * @property {string} negotiated
   *  The negotiated price of a product.
   *
   * @property {string} currency
   *  The ISO 4217 currency code of the price.
   */

  /**
   * A product field.
   * @typedef {object} CustomField
   *
   * @property {string} name
   *  The name of the custom field.
   *
   * @property {string} value
   *  The value of the custom field.
   */

  /**
   * An iterable Field for display.
   * @typedef {CustomField} IterableField
   *
   * @property {number} id
   *  A unique identifier for the field.
   */

  /**
   * Gets or sets which custom fields should be displayed (if supplied).
   *
   * @type {CustomField[]}
   */
  @api customFields;

  /**
   * Gets or sets whether the cart is locked
   *
   * @type {boolean}
   */
  @api cartLocked;

  /**
   * Gets or sets the name of the product.
   *
   * @type {string}
   */
  @api description;

  /**
   * Gets or sets the product image.
   *
   * @type {Image}
   */
  @api image;

  /**
   * Gets or sets whether the product is "in stock."
   *
   * @type {boolean}
   */
  @api inStock = false;

  /**
   * Gets or sets the name of the product.
   *
   * @type {string}
   */
  @api name;

  /**
   * Gets or sets the price - if known - of the product.
   * If this property is specified as undefined, the price is shown as being unavailable.
   *
   * @type {Price}
   */
  @api price;

  bulkRegister = false;

  _invalidQuantity = false;
  _quantityFieldValue = 1;
  _categoryPath;
  _resolvedCategoryPath = [];

  // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
  // which the NavigationMixin implicitly requires to function properly.
  _resolveConnected;
  _connected = new Promise((resolve) => {
    this._resolveConnected = resolve;
  });

  connectedCallback() {
    this._resolveConnected();
  }

  disconnectedCallback() {
    this._connected = new Promise((resolve) => {
      this._resolveConnected = resolve;
    });
  }

  /**
   * Gets or sets the ordered hierarchy of categories to which the product belongs, ordered from least to most specific.
   *
   * @type {Category[]}
   */
  @api
  get categoryPath() {
    return this._categoryPath;
  }

  set categoryPath(newPath) {
    this._categoryPath = newPath;
    this.resolveCategoryPath(newPath || []);
  }

  /**
   * Getter that indicates that product has a price
   *
   * @type {Category[]}
   */
  get hasPrice() {
    return ((this.price || {}).negotiated || "").length > 0;
  }

  /**
   * Updates the breadcrumb path for the product, resolving the categories to URLs for use as breadcrumbs.
   *
   * @param {Category[]} newPath
   *  The new category "path" for the product.
   */
  openRegisterModal() {
    if (this.isCCEPortal) {
      this.bulkRegister = true;
    }
  }

  closeModal() {
    this.bulkRegister = false;
  }

  get isCCEPortal() {
    return BasePath.toLowerCase().includes("cce");
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
  }

  /**
   * Emits a notification that the user wants to add the item to their cart.
   *
   * @fires ProductDetailsDisplay#addtocart
   * @private
   */
  notifyAddToCart() {
    let quantity = this._quantityFieldValue;
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: {
          quantity
        }
      })
    );
    this.openRegisterModal();
  }

  resolveCategoryPath(newPath) {
    const path = [homePage].concat(
      newPath.map((level) => ({
        name: level.name,
        type: "standard__recordPage",
        attributes: {
          actionName: "view",
          recordId: level.id
        }
      }))
    );

    this._connected
      .then(() => {
        const levelsResolved = path.map((level) =>
          this[NavigationMixin.GenerateUrl]({
            type: level.type,
            attributes: level.attributes
          }).then((url) => ({
            name: level.name,
            url: url
          }))
        );

        return Promise.all(levelsResolved);
      })
      .then((levels) => {
        this._resolvedCategoryPath = levels;
      });
  }

  /**
   * handles show button
   */
  handleShowClick(event) {
    const labelShow = event.target.label;

    if (labelShow === "SHOW MORE") {
      this.clickedShowLabel = "HIDE";
      this.showVisible = true;
    } else if (labelShow === "HIDE") {
      this.clickedShowLabel = "SHOW MORE";
      this.showVisible = false;
    }
  }

  registerInterest(){
    if(!isGuest){
        insertExpressionOfInterest({
          userId:userId, 
          productId:this.productOnPage.Id
      })
      .then(()=>{
          this.generateToast(
              'Success!',
              'Interest Registered',
              'success')
      })
      .catch(error=>{
          console.log(error);
          if(error.body.message == 'Register Interest Exists'){
            this.generateToast(
              'Error.',
              INTEREST_EXISTS_ERROR,
              'error'
            );
          }else{
            this.generateToast(
              'Error.',
              MSG_ERROR,
              'error'
            );
          }
          
      })
    }else{
      window.location.replace(BasePath + 'login/');
    }
    
}

  /**
   * Getter of selected course offering
   *
   * @type {Object}
   */
  get selectedCourseOffering() {
    let foundCourseOffering = this.courseOfferings.find(
      (key) => key.Id === this.selectedOfferingId
    );
    return foundCourseOffering ? foundCourseOffering : {};
  }

  /**
   * Indicates that user selected a course offering/date
   *
   * @type {Boolean}}
   */
  get hasSelectedCourseOffering() {
    return this.selectedCourseOffering.Id ? true : false;
  }

  /**
   * Shows the enroll/register button
   *
   * @type {Boolean}}
   */
  get showEnrollButton() {
    return this.selectedCourseOffering.Available_Seats__c > 0;
  }

  get showRegisterInterestButton() {
    if (
      !this.showEnrollButton &&
      this.hasNoRelatedCourseOfferings &&
      this.registerInterestAvailable === "true" &&
      this.isOPEPortal
    ) {
      return true;
    } else {
      return false;
    }
  }

  get availableSeats() {
    let availableSeatsTemp =
      this.selectedCourseOffering.Available_Seats__c > 0
        ? this.selectedCourseOffering.Available_Seats__c
        : 0;
    let onHoldSeatsTemp =
      this.selectedCourseOffering.On_Hold_Seat__c > 0
        ? this.selectedCourseOffering.On_Hold_Seat__c
        : 0;
    let seats = availableSeatsTemp - onHoldSeatsTemp;
    return seats > 0 ? seats : 0;
  }

  get plural() {
    return this.availableSeats > 1 ? "s" : "";
  }

  /**
   * Indicates that product has no related couse offering
   *
   * @type {Boolean}}
   */
  get hasNoRelatedCourseOfferings() {
    return this.pickOptions.length === 0;
  }

  /**
   * Gets the prices and st
   *
   * @type {Object}}
   */
  get prices() {
    let pricesObj = [];
    if (this.priceBookEntries && this.priceBookEntries.length > 0) {
      pricesObj = this.priceBookEntries
        .filter((filterKey) => filterKey.UnitPrice)
        .map((key) => {
          return {
            priceBookName: key.Pricebook2.Name,
            unitPrice: parseInt(key.UnitPrice).toLocaleString("en-US", {
              style: "currency",
              currency: "USD"
            })
          };
        });
      return pricesObj;
    }
    return pricesObj;
  }

  get optionsPlaceholder() {
    return this.hasNoRelatedCourseOfferings ? "NO OFFERING AVAILABLE" : "SELECT A DATE";
  }

  get pickOptions() {
    if (this.courseOfferings && this.courseOfferings.length > 0) {
      let options = this.courseOfferings
        .filter((filterKey) => filterKey.hed__Start_Date__c)
        .map((key) => {
          return {
            label:
              this.ordinal(
                new Date(key.hed__Start_Date__c).toLocaleDateString("en-US", {
                  day: "numeric"
                })
              ) +
              " " +
              new Date(key.hed__Start_Date__c).toLocaleDateString("en-US", {
                month: "long"
              }) +
              " " +
              new Date(key.hed__Start_Date__c).toLocaleDateString("en-US", {
                year: "numeric"
              }),
            value: key.Id
          };
        });
      return options;
    } else {
      return [];
    }
  }

  /*
   *adds suffix to the day of a date
   */
  ordinal(day) {
    var s = ["th", "st", "nd", "rd"];
    var v = day % 100;
    return day + (s[(v - 20) % 10] || s[v] || s[0]);
  }

  /*
   * handles process when an offering is selected
   */
  handlePickChange(event) {
    this.selectedDate = event.target.options.find(
      (opt) => opt.value === event.detail.value
    ).label;
    this.selectedOfferingId = event.detail.value;
  }

  /**
     * creates toast notification
     */
   generateToast(_title,_message,_variant){
    const evt = new ShowToastEvent({
        title: _title,
        message: _message,
        variant: _variant,
    });
    this.dispatchEvent(evt);
  }

}
