/**
 * @description A LWC component to display searched products
 *
 * @see ../classes/B2BSearchCtrl.cls
 * @see ../classes/B2BGetInfo.cls
 * @see searchResults
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | roy.nino.s.regala         | February 4, 2022      | DEPP-213             | Updated to adapt to API Method and guest user|
      | marygrace.j.li            | April 18, 2022        | DEPP-1269            | Updated to add DEPP-1121 & DEPP-1421 changes |
      | eugene.andrew.abuan       | May 02, 2022          | DEPP-1269            | Updated logic to match with the new UI       |

 */

import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import communityId from "@salesforce/community/Id";
import productSearch from "@salesforce/apex/B2BSearchCtrl.searchProducts";
import getCartSummary from "@salesforce/apex/B2BGetInfo.getCartSummary";
import addToCart from "@salesforce/apex/B2BGetInfo.addToCart";
import { transformData } from "./dataNormalizer";
import getSortCollections from "@salesforce/apex/B2BSearchCtrl.getSortRules";
import { generateErrorMessage } from "c/commonUtils";
import isGuest from '@salesforce/user/isGuest';
import getProducts from '@salesforce/apex/ProductCtrl.getProducts';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FIELD_TYPE from '@salesforce/schema/Product2.Product_Type__c';
import FIELD_STUDY_AREA from '@salesforce/schema/Product2.Study_Area__c';
//import FIELD_DELIVERY_TYPE from '@salesforce/schema/hed__Course_Offering__c.Delivery_Type__c';
import FIELD_DELIVERY_TYPE from '@salesforce/schema/Product2.Delivery__c';
import Product2 from '@salesforce/schema/Product2';
import hed__Course_Offering__c from '@salesforce/schema/hed__Course_Offering__c';
// import MIN_VALUE from '@salesforce/label/c.Pricing_Min_Value';
// import MAX_VALUE from '@salesforce/label/c.Pricing_Max_Value';

const MIN_VALUE='0';
const MAX_VALUE ='0';
const STUDY_STORE = "study";
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const MSG_ERROR =
  "An error has been encountered. Please contact your Administrator.";
const PAGE_SIZE = 6;
const DELAY = 300;
let i=0;


/**
 * A search resutls component that shows results of a product search or
 * category browsing.This component handles data retrieval and management, as
 * well as projection for internal display components.
 * When deployed, it is available in the Builder under Custom Components as
 * 'B2B Custom Search Results'
 */
export default class SearchResults extends NavigationMixin(LightningElement) {
  searchQuery;
  searchFilter;
  searchValue;
  errorMessage;

  // @api product2;
  // searchKey = '';
  @track error;
  //getProducts variables
  productInfoList;
  @track productListIds =[];
  
  // filteredList = [];
  // productListTemp = [];

  // displayDataHolder = null;

  // pickListTypeValuesList = [];
  // pickListStudyAreaValuesList =[];
  strSearch = '';

  @api
  get product() {
      return this._product;
  }
  set product(value) {
      this._product = value;
  }

  // listItemValue = [];
  // numberValue = 50;
  stringValue = '';
  startDate ='';
  endDate ='';

  // @track myProducts;
  records;
  // courseOfferings;
  // pricebookEntries;

  @track typeValues;
  @track studyAreaValues;
  @track deliveryTypeValues;
  
  @track selectedValues = [];
  @track studyAreaSelectedValues =[];
  @track deliveryTypeSelectedValues =[];
  @track index;
  @track indexStudyArea;
  @track indexDeliveryType;
  @api fieldName = FIELD_DELIVERY_TYPE;
  @api objectName = hed__Course_Offering__c;
  @track options;
  @track productRecordId;
  @track courseOfferingRecordId;
  @track items = []; 
  // @track pricebookOptions;
  @track value;
  // @track pricingValue = '';
  @track priceRangeValue = 0;
  @track start= MIN_VALUE;
  @track end= MAX_VALUE;
  @api startValue;
  @api endValue;
  // @api courseOfferingList;
  // @api priceBookEntryList;
  // @api allProducts;
  hasMorePages;
  // recordsToDisplay;
  // @track showPagination = false;

  parameterObject = {
      strSearchkey: this.stringValue,
      strStartDate: this.startDate,
      strEndDate: this.endDate,
      // strPricebook: this.pricingValue,
      minUnitPrice: this.start,
      maxUnitPrice: this.end,
      typeList: [],
      studyAreaList: [],
      deliveryTypeList: []
  };
  @track filters;
  @track selectedFilters;
  @track filterCollections;
  
  /**
   * Gets the effective account - if any - of the user viewing the product.
   *
   * @type {string}
   */
  @api
  get effectiveAccountId() {
    console.log(this._effectiveAccountId);
    return this._effectiveAccountId;
  }

  /**
   * Sets the effective account - if any - of the user viewing the product
   * and fetches updated cart information
   */
  set effectiveAccountId(newId) {
    this._effectiveAccountId = newId;
    if(!isGuest){
     this.updateCartInformation();
    }
  }

  /**
   *  Gets or sets the unique identifier of a category.
   *
   * @type {string}
   */
  @api
  get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
    this._landingRecordId = value;
    this.triggerProductSearch();
  }

  /**
   *  Gets or sets the search term.
   *
   * @type {string}
   */
  @api
  get term() {
    return this._term;
  }
  set term(value) {
    this._term = value;
    if (value) {
      this.triggerProductSearch();
    }
  }

  get products() {
    return this._products;
  }
  set products(value) {
    this._products = value;
  }

  /**
   *  Gets or sets fields to show on a card.
   *
   * @type {string}
   */
  @api
  get cardContentMapping() {
    return this._cardContentMapping;
  }
  set cardContentMapping(value) {
    this._cardContentMapping = value;
  }

  /**
   *  Gets or sets the layout of this component. Possible values are: grid, list.
   *
   * @type {string}
   */
  @api
  resultsLayout;

  /**
   *  Gets or sets whether the product image to be shown on the cards.
   *
   * @type {string}
   */
  @api
  showProductImage;

  // Gets all result based on the list of Ids from productSearch
  getAllProducts(){
    getProducts({ 
              productIds: JSON.stringify(this.productListIds),
          })
              .then((result) => {
                this.productInfoList = result.productList;
              })
              .catch((error) => {
                  this.error = error;
                  this.records = undefined;
              });
    } 

  /*@wire(getObjectInfo, { objectApiName: hed__Course_Offering__c })
  objectInfo;*/

  @wire(getObjectInfo, { objectApiName: Product2 })
  objectInfo2;

  @wire(getPicklistValues, { 
        recordTypeId: '$objectInfo2.data.defaultRecordTypeId',
        fieldApiName: FIELD_TYPE })
    typePicklistValues({ data, error }) {
        if (data) {
            this.typeValues = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.typeValues = undefined;
        }
    }
    
    //gets the picklist values for Filters
    @wire(getPicklistValues, { 
        recordTypeId: '$objectInfo2.data.defaultRecordTypeId',
        fieldApiName: FIELD_STUDY_AREA })
    studyAreaPicklistValues({ data, error }) {
        if (data) {
            this.studyAreaValues = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.studyAreaValues = undefined;
        }
    }

   @wire(getPicklistValues, { 
       recordTypeId: '$objectInfo2.data.defaultRecordTypeId',
       fieldApiName: FIELD_DELIVERY_TYPE })
    deliveryTypePicklistValues({ data, error }) {
        if (data) {
            this.deliveryTypeValues = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.deliveryTypeValues = undefined;
        }
    }
   
  handleSearchKeyword(event) {
    this.parameterObject = {
        ...this.parameterObject,
        strSearchkey: (this.stringValue = event.target.value)
    };
    if(this.productListIds.length > 0){
        this.getAllProducts();
    }
  }

  handleTypePicklist(event) {    
    if (event.target.checked) {
        this.selectedValues.push(event.target.value);
    } else {
        try {
            this.index = this.selectedValues.indexOf(event.target.value);
            this.selectedValues.splice(this.index, 1);

            const checkboxes = this.template.querySelectorAll('.chk-type-all');//'[data-id="chk-type-all"]'
            for (const elem of checkboxes) {
                elem.checked=false;
            }

        } catch (error) {
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
        }
    }
    this.setPickList();
 }

    handleStudyAreaPicklist(event) {
        if (event.target.checked) {
            this.studyAreaSelectedValues.push(event.target.value);
        } else {
            try {
                this.indexStudyArea = this.studyAreaSelectedValues.indexOf(event.target.value);
                this.studyAreaSelectedValues.splice(this.indexStudyArea, 1);

                const checkboxes = this.template.querySelectorAll('.chk-studyarea-all');//[data-id="chk-studyarea-all"]
                for (const elem of checkboxes) {
                    elem.checked=false;
                }

            } catch (error) {
                this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
            }
        }
        this.setPickList();
    }

    handleDeliveryTypePicklist(event) {
        if (event.target.checked) {
            this.deliveryTypeSelectedValues.push(event.target.value);
        } else {
            try {
                this.indexDeliveryType = this.deliveryTypeSelectedValues.indexOf(event.target.value);
                this.deliveryTypeSelectedValues.splice(this.indexDeliveryType, 1);

                const checkboxes = this.template.querySelectorAll('.chk-deliverytype-all');//[data-id="chk-deliverytype-all"]
                for (const elem of checkboxes) {
                    elem.checked=false;
                }

            } catch (error) {
                this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
            }
        }
        this.setPickList();
    }

    handleChangeStartDate(event){
        this.parameterObject = {
            ...this.parameterObject,
            strStartDate: (this.startDate = event.target.value)
        };
        if(this.productListIds.length > 0){
            this.getAllProducts();
        }
    }

    handleChangeEndDate(event){
        this.parameterObject = {
            ...this.parameterObject,
            strEndDate: (this.endDate = event.target.value)
        };
        if(this.productListIds.length > 0){
            this.getAllProducts();
        }
    }

    // handleChangePricebook(event) {
    //     this.parameterObject = {
    //         ...this.parameterObject,
    //         strPricebook: (this.pricingValue = event.detail.value)
    //     };
    //     if(this.productListIds.length > 0){
    //         this.getAllProducts();
    //     }
    // }

    // handlePriceRangeValueChange(event) {
    //     this.parameterObject = {
    //         ...this.parameterObject,
    //         strPricebook: this.pricingValue,
    //         minUnitPrice: (this.start = event.detail.start),
    //         maxUnitPrice: (this.end = event.detail.end)
    //     };
    //     if(this.productListIds.length > 0){
    //         this.getAllProducts();
    //     }
    //   }

     handleSelectAllTypes(event) {
        this.selectedValues =[];

        if (event.target.checked) {
            const checkboxes = this.template.querySelectorAll('.chk-types');
            for (const elem of checkboxes) {
                    elem.checked=true;
            }
            for(const types of this.typeValues){
                this.selectedValues.push(types.value);
            }
            this.setPickList();   
        } else {
            try {
                const checkboxes = this.template.querySelectorAll('.chk-types');
                for (const elem of checkboxes) {
                        elem.checked=false;
                }
                this.selectedValues =[];
                this.setPickList();   
            } catch (error) {
                this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
            }
        }  
    }

    handleSelectAllStudyAreas(event) {
        this.studyAreaSelectedValues =[];
       
        if (event.target.checked) {
            const checkboxes = this.template.querySelectorAll('.chk-studyarea');
            for (const elem of checkboxes) {
                    elem.checked=true;
            }
            for(const types of this.studyAreaSelectedValues){
                this.studyAreaSelectedValues.push(types.value);
            }
            this.setPickList();   
        } else {
            try {
                const checkboxes = this.template.querySelectorAll('.chk-studyarea');
                for (const elem of checkboxes) {
                        elem.checked=false;
                }
                this.studyAreaSelectedValues =[];
                this.setPickList();   
            } catch (error) {
                this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
            }
        }  
    }

    handleSelectAllDeliveryTypes(event) {
        this.deliveryTypeSelectedValues =[];
      
        if (event.target.checked) {
            const checkboxes = this.template.querySelectorAll('.chk-delivery-type');
            for (const elem of checkboxes) {
                    elem.checked=true;
            }
            for(const types of this.deliveryTypeSelectedValues){
                this.deliveryTypeSelectedValues.push(types.value);
            }
            this.setPickList();   
        } else {
            try {
                const checkboxes = this.template.querySelectorAll('.chk-delivery-type');
                for (const elem of checkboxes) {
                        elem.checked=false;
                }
                this.deliveryTypeSelectedValues =[];
                this.setPickList();   
            } catch (error) {
                this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
            }
        }  
    }

    setPickList(){
        this.parameterObject = {
            ...this.parameterObject,
            typeList: this.selectedValues,
            studyAreaList: this.studyAreaSelectedValues,
            deliveryTypeList: this.deliveryTypeSelectedValues
        };
        
        if(this.productListIds.length > 0){
            this.getAllProducts();
        }
    }

    clearFilters(){
        this.parameterObject = {
            ...this.parameterObject,
            strSearchkey: this.stringValue,
            strStartDate: this.strStartDate,
            strEndDate: this.strEndDate,
            // strPricebook: this.pricingValue,
            minUnitPrice: this.startValue,
            maxUnitPrice: this.endValue,
            typeList: [],
            studyAreaList: [],
            deliveryTypeList: []
        };
        if(this.productListIds.length > 0){
            this.getAllProducts();
        }
    }

   handleClearAll(){
   
    const checkboxes = this.template.querySelectorAll('[data-id="checkbox"]');
    for(const elem of checkboxes){
        elem.checked=false;
    }
   
    this.stringValue ='';
    this.strStartDate ='';
    this.strEndDate ='';
    // this.pricingValue = this.pricebookOptions[0].value;
    this.template.querySelector('c-slider').setDefaultValues();
    this.startValue = 0;
    this.endValue = 1000;
    this.clearFilters();   
   } 


  //  updateProductHandler(event){
  //    this.recordsToDisplay =[...event.detail.records]
  //    console.log(event.detail.records);
  //    this.showPagination = true;
  //  }

  /**
   * Triggering the product search query
   */
   async triggerProductSearch() {
    if (this.sortRuleId == undefined) {
       await this.findSortCollections();
    }

   const searchQuery = {
      searchTerm: this.term,
      categoryId: this.recordId,
      refinements: this._refinements,
      // use fields for picking only specific fields
      // using ./dataNormalizer's normalizedCardContentMapping
      //fields: normalizedCardContentMapping(this._cardContentMapping),
      page: this._pageNumber - 1,
      pageSize: 6,
      includePrices: true,
      sortRuleId: this.sortRuleId
    };

    this._isLoading = true;
    

    // Executes during On load
    // Calls API from B2BSearch Ctrl
    productSearch({
      communityId: communityId,
      effectiveAccountId: this.resolvedEffectiveAccountId,
      searchQuery: searchQuery
    })
      .then((result) => {
        this.displayData = result;
        console.log('Result from Product Search', result);
        this.products = result.productsPage.products;
        this._isLoading = false;
        console.log('result product page total', result.productsPage.total);
        this.hasMorePages = result.productsPage.total > PAGE_SIZE;
        console.log('has more pages', this.hasMorePages);

         //store product id
         result.productsPage.products.forEach((product) => {
          this.productListIds.push(product.id);
         });
         console.log('productListIds ' , this.productListIds); 

          if(this.productListIds.length > 0){
            console.log('calls get products');
            this.getAllProducts();
            //this.retrieveProducts();
          }
      })
      .catch((error) => {
        this._isLoading = false;
        this.showToast(
          ERROR_TITLE,
          MSG_ERROR + generateErrorMessage(error),
          ERROR_VARIANT
        );
      });
  }
  /**
   * Gets the normalized component configuration that can be passed down to
   *  the inner components.
   *
   * @type {object}
   * @readonly
   * @private
   */
  get config() {
    return {
      layoutConfig: {
        resultsLayout: this.resultsLayout,
        cardConfig: {
          showImage: this.showProductImage,
          resultsLayout: this.resultsLayout,
          actionDisabled: this.isCartLocked
        }
      }
    };
  }

  /**
   * Gets or sets the normalized, displayable results for use by the display components.
   *
   * @private
   */
  get displayData() {
    return this._displayData || {};
  }
  set displayData(data) {
    let theProducts = transformData(data, this._cardContentMapping);

    for(const prod of theProducts.layoutData) {
      const product = data.productsPage.products.find(theProd => {
          return theProd.id == prod.id;
      });

      prod.productCode = product.fields.ProductCode.value;

    }

    if (this._shouldKeepCatList) {
      theProducts.categoriesData = this._displayData.categoriesData;
    }
    this._displayData = theProducts;
  }

  /**
   * Gets whether product search is executing and waiting for result.
   *
   * @type {Boolean}
   * @readonly
   * @private
   */
  get isLoading() {
    return this._isLoading;
  }

  /**
   * Gets whether results has more than 1 page.
   *
   * @type {Boolean}
   * @readonly
   * @private
   */
  get hasMorePages() {
    return this.displayData.total > this.displayData.pageSize;
  }

  /**
   * Gets the current page number.
   *
   * @type {Number}
   * @readonly
   * @private
   */
  get pageNumber() {
    return this._pageNumber;
  }

  /**
   * Gets the header text which shows the search results details.
   *
   * @type {string}
   * @readonly
   * @private
   */
  get headerText() {
      let text = '';
      //from the API return
      const totalItemCount = this.displayData.total;
      const pageSize = this.displayData.pageSize;
  
    if (totalItemCount > 1) {
      const startIndex = (this._pageNumber - 1) * pageSize + 1;

      const endIndex = Math.min(startIndex + pageSize - 1, totalItemCount);

      text = `Displaying ${startIndex} - ${endIndex} of ${totalItemCount} courses`;
    } else if (totalItemCount === 1) {
      text = "1 Result";
    }

    return text;
  }

  /**
   * Gets the normalized effective account of the user.
   *
   * @type {string}
   * @readonly
   * @private
   */
  get resolvedEffectiveAccountId() {
    const effectiveAcocuntId = this.effectiveAccountId || "";
    let resolved = null;

    if (
      effectiveAcocuntId.length > 0 &&
      effectiveAcocuntId !== "000000000000000"
    ) {
      resolved = effectiveAcocuntId;
    }
    return resolved;
  }

  /**
   * Gets whether the cart is currently locked
   *
   * Returns true if the cart status is set to either processing or checkout (the two locked states)
   *
   * @readonly
   */
  get isCartLocked() {
    const cartStatus = (this._cartSummary || {}).status;
    return cartStatus === "Processing" || cartStatus === "Checkout";
  }

  /**
   * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
   */
  connectedCallback() {
   if(!isGuest){
      this.updateCartInformation();
    }
  }

  /**
   * Handles a user request to add the product to their active cart.
   *
   * @private
   */
  handleAction(evt) {
    evt.stopPropagation();

    addToCart({
      communityId: communityId,
      productId: evt.detail.productId,
      quantity: "1",
      effectiveAccountId: this.resolvedEffectiveAccountId
    })
      .then(() => {
        this.dispatchEvent(
          new CustomEvent("cartchanged", {
            bubbles: true,
            composed: true
          })
        );
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Your cart has been updated.",
            variant: "success",
            mode: "dismissable"
          })
        );
      })
      .catch(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message:
              "{0} could not be added to your cart at this time. Please try again later.",
            messageData: [evt.detail.productName],
            variant: "error",
            mode: "dismissable"
          })
        );
      });
  }

  /**
   * Handles a user request to navigate to the product detail page.
   *
   * @private
   */
  handleShowDetail(evt) {
    evt.stopPropagation();

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: evt.detail.productId,
        actionName: "view"
      }
    });
  }

  /**
   * Handles a user request to navigate to previous page results page.
   *
   * @private
   */
  handlePreviousPage(evt) {
      evt.stopPropagation();
      this._pageNumber = this._pageNumber - 1;
      this.productListIds = [];
      // this.pageNumber = this.pageNumber - 1;
      this.triggerProductSearch();
  }

  /**
   * Handles a user request to navigate to next page results page.
   *
   * @private
   */
  handleNextPage(evt) {
      evt.stopPropagation();
      this._pageNumber = this._pageNumber + 1;
      this.productListIds = [];
      //this.triggerProductSearch();
      // this.pageNumber = this.pageNumber + 1;
      this.triggerProductSearch();
  }

  handleSelectedPage(evt){
    evt.stopPropagation();
    // this.selectedPage = evt.detail;
    this._pageNumber = evt.detail;
    console.log('Page from selected page', this._pageNumber);

    this.productListIds = [];
    this.triggerProductSearch();
  }

  /**
     * Gets the product details
     *
     * @type {Object}}
     */
   get productDetails() {
    let prodObj = [];
    if (this.records && this.records.length > 0) {
        prodObj = this.records.filter((filterKey) => filterKey.Id).map(key => {
            return {
                id: key.Id,
                name: key.Name,
                description: key.Description
            }
        });
        return prodObj;
    }
    return prodObj;
}

  /**
   * Handles a user request to filter the results from facet section.
   *
   * @private
   */
  handleFacetValueUpdate(evt) {
    evt.stopPropagation();

    this._refinements = evt.detail.refinements;
    this._pageNumber = 1;
    this.triggerProductSearch();
  }

  /**
   * Handles a user request to filter the results.
   *
   * @private
   */
  handleFilterValueUpdate(evt) {
    evt.stopPropagation();
    let doFilterSearch = false;
    let filterCollections = evt.detail.filter;

    console.log('filterCollections', filterCollections);

    //this._isLoading = true;

    filterCollections.forEach((filters, i) => {
        if(filters.Filter.length > 0) {
            doFilterSearch = true;
        }
    });

    //this.sortBy = '';
    this.searchQuery = '';
    this.searchValue = '';
    this.searchFilter = [];

    if(doFilterSearch) {
        this.searchFilter = filterCollections;
        // this.pageNumber = 1;
        this.triggerProductSearch();
    }
    else {
        // this.pageNumber = 1;
        this.triggerProductSearch();
    }
}

  /**
   * Handles a user request to show a selected category from facet section.
   *
   * @private
   */
  handleCategoryUpdate(evt) {
    evt.stopPropagation();

    this._recordId = evt.detail.categoryId;
    this._pageNumber = 1;

    this._shouldKeepCatList = evt.detail.shouldKeepCatList
      ? evt.detail.shouldKeepCatList
      : false;
    this.triggerProductSearch();
  }

  /**
   * Ensures cart information is up to date
   */
  updateCartInformation() {
    getCartSummary({
      communityId: communityId,
      effectiveAccountId: this.resolvedEffectiveAccountId
    })
      .then((result) => {
        this._cartSummary = result;
      })
      .catch((e) => {
        // Handle cart summary error properly
        // For this sample, we can just log the error
        console.log(e);
      });
  }

  get sortRuleId() {
    return this._sortRuleId;
  }

  set sortRuleId(value) {
    this._sortRuleId = value;
  }

  /**
   * Handles sort
   */
  async findSortCollections() {
    await getSortCollections({
      communityId: communityId
    })
      .then((result) => {
        result.sortRules.forEach((element) => {
          this.sortRuleId = element.sortRuleId;
        });
      })
      .catch((error) => {
        this.showToast(
          ERROR_TITLE,
          MSG_ERROR + generateErrorMessage(error),
          ERROR_VARIANT
        );
      });
  }

  /**
   * Handles hiding of filter section if store is not OPE/Study
   */
  get showFiltersIfStudy() {
    return window.location.href.indexOf(STUDY_STORE) > -1 ? true : false;
  }

  //shows success or error messages
  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

     /**
     * concatenates error name and message
     */
      generateErrorMessage(err){
        let _errorMsg = ' (';

        _errorMsg += err.name && err.message ? err.name + ': ' + err.message : err.body.message;
        _errorMsg += ')';

        return _errorMsg;
    }


  _shouldKeepCatList = false;
  _displayData;
  //_isLoading = true;
  _pageNumber = 1;
  _refinements = [];
  _term;
  _recordId;
  _landingRecordId;
  _cardContentMapping;
  _effectiveAccountId;
  /**
   * The cart summary information
   * @type {ConnectApi.CartSummary}
   */
  _cartSummary;
  _sortRuleId;
  _products = [];
  _filteredProducts = [];
  _filteredResults = [];
  _getProducts =[];
}