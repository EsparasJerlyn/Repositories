import { LightningElement, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import communityId from '@salesforce/community/Id';
import productSearch from '@salesforce/apex/B2BSearchCtrl.productSearch';
import { transformData } from './dataNormalizer';
import getSortCollections from '@salesforce/apex/B2BSearchCtrl.getSortCollections';
import { generateErrorMessage } from 'c/commonUtils';
const STUDY_STORE = 'Study';
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const MSG_ERROR = "An error has been encountered. Please contact your Administrator.";

/**
 * A search resutls component that shows results of a product search or
 * category browsing.This component handles data retrieval and management, as
 * well as projection for internal display components.
 * When deployed, it is available in the Builder under Custom Components as
 * 'B2B Custom Search Results'
 */
export default class SearchResults extends NavigationMixin(LightningElement) {

  searchQuery;
  
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

  /**
   * Triggering the product search query
   */
  async triggerProductSearch() {
   
      if(this.sortRuleId == undefined) {
          await this.findSortCollections();
      }
      const searchQuery = JSON.stringify({
          searchTerm: this.term,
          categoryId: this.recordId,
          refinements: this._refinements,
          // use fields for picking only specific fields
          // using ./dataNormalizer's normalizedCardContentMapping
          //fields: normalizedCardContentMapping(this._cardContentMapping),
          page: this._pageNumber - 1,
          includePrices: true,
          sortRuleId: this.sortRuleId
      });

      this._isLoading = true;

      productSearch({
          communityId: communityId,
          searchQuery: searchQuery,
          effectiveAccountId: this.resolvedEffectiveAccountId
      })
      .then((result) => {
          this.displayData = result;
          this.products = result.productsPage.products;
          this._isLoading = false;
      })
      .catch((error) => {
          this._isLoading = false;
          this.showToast(ERROR_TITLE,MSG_ERROR + generateErrorMessage(error),ERROR_VARIANT);
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

      if(this._shouldKeepCatList){
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
      const totalItemCount = this.displayData.total;
      const pageSize = this.displayData.pageSize;

      if (totalItemCount > 1) {
          const startIndex = (this._pageNumber - 1) * pageSize + 1;

          const endIndex = Math.min(
              startIndex + pageSize - 1,
              totalItemCount
          );

          text = `Displaying ${startIndex} - ${endIndex} of ${totalItemCount} courses`;
      } else if (totalItemCount === 1) {
          text = '1 Result';
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
      const effectiveAcocuntId = this.effectiveAccountId || '';
      let resolved = null;

      if (
          effectiveAcocuntId.length > 0 &&
          effectiveAcocuntId !== '000000000000000'
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
      return cartStatus === 'Processing' || cartStatus === 'Checkout';
  }

  /**
   * Handles a user request to navigate to the product detail page.
   *
   * @private
   */
  handleShowDetail(evt) {
      evt.stopPropagation();

      this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: evt.detail.productId,
              actionName: 'view'
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
      this.triggerProductSearch();
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
   * Handles a user request to show a selected category from facet section.
   *
   * @private
   */
  handleCategoryUpdate(evt) {
      evt.stopPropagation();

      this._recordId = evt.detail.categoryId;
      this._pageNumber = 1;

      this._shouldKeepCatList = (evt.detail.shouldKeepCatList) ? evt.detail.shouldKeepCatList : false
      this.triggerProductSearch();
  }

  get sortRuleId() {
      return this._sortRuleId;
  }

  set sortRuleId( value ) {
      this._sortRuleId = value;
  }

  /**
   * Handles sort
   */
  async findSortCollections() {
      await getSortCollections({
          communityId: communityId
      }).then(result => {
          result.sortRules.forEach(element => {
                  this.sortRuleId = element.sortRuleId;
          });
      }).catch(error => {
          this.showToast(ERROR_TITLE,MSG_ERROR + generateErrorMessage(error),ERROR_VARIANT);
      });
  }

  /**
   * Handles hiding of filter section if store is not OPE/Study
   */
    get showFiltersIfStudy(){
        return (window.location.href.indexOf(STUDY_STORE) > -1 ? true : false);
    }

    //shows success or error messages
    showToast(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

  _shouldKeepCatList = false;
  _displayData;
  _isLoading = true;
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
}