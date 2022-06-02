/**
 * @description A LWC component to display searched products
 *
 * @see ../classes/B2BSearchCtrl.cls
 * @see ../classes/B2BGetInfo.cls
 * @see ../classes/ProductCtrl.cls
 * 
 * @see searchResults
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | roy.nino.s.regala         | February 4, 2022      | DEPP-213             | Updated to adapt to API Method and guest user|
      | marygrace.j.li            | April 18, 2022        | DEPP-1269            | Updated to add DEPP-1121 & DEPP-1421 changes |
      | eugene.andrew.abuan       | May 02, 2022          | DEPP-1269            | Updated logic to match with the new UI       |
      | eugene.andrew.abuan       | May 12, 2022          | DEPP-1979            | Added Filter logic                           |
 */

import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { transformData } from "./dataNormalizer";
import { generateErrorMessage } from "c/commonUtils";
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

import communityId from "@salesforce/community/Id";
import productSearch from "@salesforce/apex/B2BSearchCtrl.searchProducts";
import getCartSummary from "@salesforce/apex/B2BGetInfo.getCartSummary";
import addToCart from "@salesforce/apex/B2BGetInfo.addToCart";
import isGuest from '@salesforce/user/isGuest';
import getProducts from '@salesforce/apex/ProductCtrl.getProducts';
import getFilteredProducts from '@salesforce/apex/ProductCtrl.getFilteredProducts';
import FIELD_TYPE from '@salesforce/schema/Product2.Product_Type__c';
import FIELD_STUDY_AREA from '@salesforce/schema/Product2.Study_Area__c';
import FIELD_DELIVERY_TYPE from '@salesforce/schema/Product2.Delivery__c';
import Product2 from '@salesforce/schema/Product2';

import qutResourceImg from "@salesforce/resourceUrl/QUTImages";

const STUDY_STORE = "study";
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const MSG_ERROR =
  "An error has been encountered. Please contact your Administrator.";
let PAGE_SIZE = 6;
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
  errorMessage;
  @track error;
  productInfoList;
  @track productListIds =[];
  pageSize;
  records;
  typeValues;
  studyAreaValues;
  deliveryTypeValues;
  //variables to get the values from filter UI
  @track selectedValues = [];
  @track studyAreaSelectedValues =[];
  @track deliveryTypeSelectedValues =[];
  index;
  indexStudyArea;
  indexDeliveryType;
  newListProducts= [];
  allProductId = [];
  hasMorePages;
  stringValue = '';
  startDate ='';
  endDate ='';
  sortBy = '';
  keyword;
  startValue ;
  endValue ;
  strStartDate;
  strEndDate;
  //@track sortCourseBy = 'comingUp';
  value = 'comingUp';
  parameterObject = {
    searchKey : this.stringValue, 
    studyArea: [] , 
    deliveryType:[] , 
    productType: [] ,
    minUnitPrice: this.startValue, 
    maxUnitPrice: this.endValue, 
    startDate: this.strStartDate,
    endDate: this.strEndDate,
    // sortBy: this.value
  }

  // Sort Combobox
  get options(){
    return [
        { label: 'Coming Up', value: 'comingUp' },
        { label: 'Newly Added', value: 'newlyAdded' },
        { label: 'Price low to high', value: 'priceLowToHigh' },
        { label: 'Price high to low', value: 'priceHighToLow' }
    ];
  }
  openModal = false;

  /* B2B QUICK START VARIABLES */
  @api
  get product() {
      return this._product;
  }
  set product(value) {
      this._product = value;
  }
  
  /**
   * Gets the effective account - if any - of the user viewing the product.
   *
   * @type {string}
   */
  @api
  get effectiveAccountId() {
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

  // ------------------------------------------------- FILTER --------------------------
  @wire(getObjectInfo, { objectApiName: Product2 })
  objectInfo2;

  //gets the picklist values for Product Type
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
    
  //gets the picklist values for Study Area
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

  //gets the picklist values for Delivery Type
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

  // handles sort course combobox
  // hanldeSortCourseValueChange(event) {
  //   //this.sortCourseBy = event.detail;
  //   this.value = event.detail.value;
  //   this.parameterObject.sortBy = this.value;
  //   console.log('sort: parameter object', this.parameterObject);
  //   this.setPickList();
  // }

  // handles keyword search
  handleSearchKeyword(event){
    this.stringValue = event.target.value;
    if(this.stringValue.length > 3){
      console.log('String Value from Search ->', this.stringValue);
      this.parameterObject.searchKey = this.stringValue;
      console.log('Parameter Object in keyword search', this.parameterObject);
      this.getFilterList();
    }
    if(this.stringValue.length == 0 ){
      this.parameterObject.searchKey = '';
      this.getFilterList();
    }

    console.log(this.stringValue.length);
  }
  
  // Handles the Product Type Filter when clicked Individually
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

  // Handles the Study Area Filter when Clicked Individually
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

  // Handles Delivery Filter when clicked Individually
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

  //Handles Start date filter when selected
  handleChangeStartDate(event){
    let sDate = '';
    this.strStartDate = event.target.value;
    console.log('Start date event', this.strStartDate);
    sDate = this.strStartDate.split("-").reverse().join("-").replace(/-/g,"/");
    console.log('Start Date', sDate);
    this.parameterObject.startDate = sDate;
    this.checkDateInput();
    console.log('hello start date');
  }

  //Handle End date filter when selected
  handleChangeEndDate(event){
    let eDate = '';
    this.strEndDate = event.target.value;
    console.log('End date event', this.strEndDate);
    eDate = this.strEndDate.split("-").reverse().join("-").replace(/-/g,"/");
    console.log('End Date', eDate);
    this.parameterObject.endDate = eDate;
    this.checkDateInput();
    console.log('hello end date');
  }
  
  //Checks the input of the Start Date and End Date
  checkDateInput()
  {
    console.log('Enters check Date Input');
    if(this.strStartDate != null && this.strEndDate != null){
      console.log('date is not null filterList');
      this.getFilterList();
    }
    if(this.strStartDate == null && this.strEndDate === null){
      console.log('All date is Null');
      this.triggerProductSearch();
    }
  }

  //Handles the value of the pricing slider
  handlePriceRangeValueChange(event){
    this.startValue = event.detail.start;
    this.endValue = event.detail.end;
    this.parameterObject.minUnitPrice = this.startValue
    this.parameterObject.maxUnitPrice = this.endValue
    this.getFilterList();
    }

  //Handles Product Type Filter Select All;
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

  //Handles Study Area Filter Select All
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

  //Handles Delivery Type Filter Select All
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

  // handles Clear All filters
  handleClearAll(){
    const checkboxes = this.template.querySelectorAll('[data-id="checkbox"]');
    for(const elem of checkboxes){
        elem.checked=false;
    }
    console.log('Calls clear all')
    this.stringValue ='';
    this.strStartDate ='';
    this.strEndDate ='';
    this.startValue ='';
    this.endValue = '';
    this.progressValue ='comingUp';
    this.studyAreaSelectedValues = [];
    this.selectedValues = [];
    this.deliveryTypeSelectedValues = [];
    this.template.querySelector('c-slider').setDefaultValues();
    this.newListProducts = [];
    this.productListIds = [];
    this.triggerProductSearch();   
   } 
   


  // Function that calls the getFilteredProducts returns me a list of Id;
  setPickList(){    
    console.log('set picklist');
    this.parameterObject.studyArea = this.studyAreaSelectedValues;
    this.parameterObject.productType = this.selectedValues;
    this.parameterObject.deliveryType = this.deliveryTypeSelectedValues;
    // this.parameterObject.sortBy = this.value;
    console.log('parameter object', this.parameterObject);
    this.getFilterList();
  }

  //function that executes the filter apex class
   async getFilterList(){
    this._isLoading = true;
     console.log('Calls Filter list');
     console.log('Product IDs to Sort: ' + JSON.stringify(this.allProductId));
     getFilteredProducts({
      productAllId : JSON.stringify(this.allProductId),
      filterData : this.parameterObject
     }).then((result) => {
       this.productListIds = [];
       this.newListProducts = [];
       this.totalItemCount = result.listFilteredProductId.length;
       this.hasMorePages = this.totalItemCount > PAGE_SIZE;
       let arrBySix = [];
       let count = 1;

       //Arrage the Products by 6 -> [0] [1 2 3 5 5 6]
       result.listFilteredProductId.forEach((p, i) => {
         if(count > PAGE_SIZE ){
           count = 1;
           this.newListProducts.push(arrBySix);
           arrBySix=[];
         }
         arrBySix.push(p);
         count ++;
         if(i == result.listFilteredProductId.length -1 ){
           count = 1;
           this.newListProducts.push(arrBySix);
           arrBySix=[];
         }
        });
        console.log('new list array in filter: ' , this.newListProducts);

        //Checks if result is null or zero
        if(result.listFilteredProductId.length > 0){
          this.displayProductsListingPage(0);
        }else{
          console.log('zero is the result of the array');
          this.productListIds = [];
          this.newListProducts = [];
          this.getAllProducts();
        }
        this._isLoading = false;
        this._pageNumber = 1;
     }).catch((error) => {
      this._isLoading = false;
      this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
    });
   }
   

   //---------------------------------------------Listing Page ---------------------------

  /**
   * Triggering the product search query, Perfprms on load
   */
   async triggerProductSearch() {
    // if (this.sortRuleId == undefined) {
    //    await this.findSortCollections();
    // }
    //B2B QUICK START CODE 
    // Reference https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_connectapi_input_product_search.html
    //Fields that are commented in searchQuery are optional
   const searchQuery = {
      // searchTerm: this.term,
      categoryId: this.recordId,
      // refinements: this._refinements,
      // use fields for picking only specific fields
      // using ./dataNormalizer's normalizedCardContentMapping
      // fields: normalizedCardContentMapping(this._cardContentMapping),
      // page: this._pageNumber - 1,
      pageSize: 200,
      // includePrices: true,
      sortRuleId: this.sortRuleId
    };

    this._isLoading = true;
    
    productSearch({
      communityId: communityId,
      effectiveAccountId: this.resolvedEffectiveAccountId,
      searchQuery: searchQuery
    })
      .then((result) => {
        this.newListProducts = [];
        this.allProductId = [];
        this.displayData = result;
        console.log('Result from Product Search', result);
        this.products = result.productsPage.products;
        console.log('result product page total', result.productsPage.total);
        this.hasMorePages = result.productsPage.total > PAGE_SIZE;
        this.pageSize = PAGE_SIZE;
        console.log('has more pages', this.hasMorePages);
        this.totalItemCount = result.productsPage.total;
        console.log('length of all product' , this.totalItemCount);

        // Store all Id
        this.products.forEach((productId) => {
          this.allProductId.push(productId.id);
        });
        console.log('All Product Id', this.allProductId);

        //Arrage the Products by 6 -> [0] [1 2 3 5 5 6]
        let arrBySix = [];
        let count = 1;
        this.products.forEach((p, i) => {
          if(count > PAGE_SIZE ){
            count = 1;
            this.newListProducts.push(arrBySix);
            arrBySix=[];
          }
          arrBySix.push(p.id);
          count ++;
          if(i == this.totalItemCount-1 ){
            count = 1;
            this.newListProducts.push(arrBySix);
            arrBySix=[];
          }

        });
        console.log('new Array list', this.newListProducts);
        console.log('new Array list zero', this.newListProducts[0]);
        console.log('Lenght of new list products',this.newListProducts.length);
        this.displayProductsListingPage(0);
          this._isLoading = false;
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

  // Gets all result based on the list of Ids from productSearch
  getAllProducts(){
    console.log('Stringfy Id', JSON.stringify(this.productListIds) )
    getProducts({ 
        productIds: JSON.stringify(this.productListIds)
        // sortCourse: this.value
      }).then((result) => {
          console.log(result);
          this.productInfoList = result.productList;
          console.log('Product List from getAll Products', this.productInfoList);
        })
        .catch((error) => {
            this.error = error;
            this.records = undefined;
            console.log('Error on getProducts method: ' + this.error);
        });
  } 

  /**
 * Displays the products based on the value
 *
 * @param value - Value of the curent Array user wants to access
 */
  async displayProductsListingPage(value){
    this.newListProducts[value].forEach((prodLoad) =>{
      this.productListIds.push(prodLoad);
    });
    console.log('Call getAll Products')
    this.getAllProducts();
  }


    //----------------------------Paginator------------------------------------
  /**
   * Handles a user request to navigate to previous page results page.
   *
   * @private
   */
   handlePreviousPage(evt) {
    evt.stopPropagation();
    this._pageNumber = this._pageNumber - 1;
    this.productListIds = [];
    console.log("Page Number Previous page" ,this._pageNumber);
    this.displayProductsListingPage(this._pageNumber -1);
    // this.pageNumber = this.pageNumber - 1;
    // this.triggerProductSearch();
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
    console.log("Page Number Next page" ,this._pageNumber);
    this.displayProductsListingPage(this._pageNumber -1);
}

//Handles Selected page in Pagination
  handleSelectedPage(evt){
    evt.stopPropagation();
    this._pageNumber = evt.detail;
    console.log('Page from selected page', this._pageNumber);
    this.productListIds = [];
    this.displayProductsListingPage(this._pageNumber -1);
  }

  /* B2B QUICK START CODE*/
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
    return this.displayData.total > this.newListProducts.length;
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
      //change that makes this dynamic -> displayData.total
      const totalItemCount = this.totalItemCount;
      const pageSize = PAGE_SIZE;

      // const totalItemCount = this.productListTotal;
      // const pageSize = this.pageSize;
  
    if (totalItemCount > 1) {
      const startIndex = (this._pageNumber - 1) * pageSize + 1;

      const endIndex = Math.min(startIndex + pageSize - 1, totalItemCount);

      text = `Displaying ${startIndex} - ${endIndex} of ${totalItemCount} courses`;
    } else if (totalItemCount === 1) {
      text = "1 Result";
    }else{
      text = " No Results Found."
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

    this.vectorIcon = qutResourceImg + "/QUTImages/Icon/icon-Vector.png";
    this.accordionClose = qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
    this.filterFilled = qutResourceImg + "/QUTImages/Icon/icon-filter-filled.svg";
    this.value = 'comingUp';

   if(!isGuest){
      this.updateCartInformation();
    }
  }

  handleAccordionToggle(event) {
    // Get Aria Expanded value
    let accordionAriaExpanded = event.currentTarget;
    // Get Closest Section Element
    let accordionSection = event.currentTarget.closest("section");
    // Get Content Element
    let accordionContent = accordionSection.querySelector(".accordionContent");
    // Get Button Icon Element
    let vectorIcon = accordionSection.querySelector(".slds-button__icon");
  
    // Toggle Values
    accordionSection.classList.toggle("slds-is-open");
    if (accordionAriaExpanded.getAttribute("aria-expanded") == "true") {
      accordionAriaExpanded.setAttribute("aria-expanded", "false");
      accordionContent.setAttribute("hidden");
      vectorIcon.setAttribute(
        "src",
        qutResourceImg + "/QUTImages/Icon/icon-Vector.png"
      );
    } else {
      accordionAriaExpanded.setAttribute("aria-expanded", "true");
      accordionContent.removeAttribute("hidden");
      /*accordionIcon.setAttribute(
        "src",
        qutResourceImg + "/QUTImages/Icon/accordionOpen.svg"
      );*/
      
    }
  }

  /*
  * Closes Modal
  */
  handleModalClosed() {
    this.openModal = false;
  }
  
  
  /*
  * Opens Modal Onclick 
  */
  handleModalOpen(){
    this.openModal = true;
    console.log('Handle Open Modal', this.openModal);
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
   * Handles hiding of filter section if store is not OPE/Study
   */
     get showFiltersIfStudy() {
      return window.location.href.indexOf(STUDY_STORE) > -1 ? true : false;
    }

    /**
   * Ensures cart information is up to date
   * concatenates error name and message
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
        this.errorMessage = MSG_ERROR + this.generateErrorMessage(e);
      });
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

  // Attributes from Getter
  _shouldKeepCatList = false;
  _displayData;
  _isLoading = true;
  _pageNumber = 1;
  _refinements = [];
  _term;
  _recordId;
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