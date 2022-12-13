/**
 * @description A LWC component to display product listing page
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                         |
	  |---------------------------|-----------------------|----------------------|--------------------------------------------------------|
	  | Tiffany.Zhang             | July 28, 2022         | DEPP-1469            | Create portal listing page component                   |
	  | eugene.john.basilan       | July 28, 2022         | DEPP-2724            | Merge changes and added dynamic value                  |
	  | jessel.bajao              | August 12, 2022       | DEPP-3483            | Added code for saving specific product                 |
	  |                           |                       |                      | category                                               |
	  | keno.domienri.dico        | August 25, 2022       | DEPP-3765            | Added product category per user                        |
	  | dodge.j.palattao          | September 26, 2022    | DEPP-2699            | Added messageChannel for SubMenu active category       |
	  | keno.domienri.dico		  | September 28, 2022	  | DEPP-4459 & 4461	 | Remove Product Type Grouping and added search filter	  |
	  | julie.jane.alegre         | December  12, 2022    | DEPP-4667            | Add Corporate Bundle info in product listing page      |
 */

	  import { LightningElement ,wire, track, api} from 'lwc';
	  import getProductsByCategory from '@salesforce/apex/ProductCtrl.getProductsByCategory';
	  import getStoreFrontCategoryMenu from '@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories';
	  import communityId from '@salesforce/community/Id';
	  import BasePath from "@salesforce/community/basePath";
	  import userId from "@salesforce/user/Id";

	  import { publish, MessageContext } from 'lightning/messageService';
	  import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';
	  import payloadContainerLMSsubMenuName from '@salesforce/messageChannel/SubMenu__c';

	  const CURRENTPRODUCTCATEGORY = "current_product_category";
	  const DELAY = 300;
	  export default class PortalListingPage extends LightningElement {
		  //variables
		  stringValue = '';
		  filterKey = this.stringValue;
		  categoryId;
		  navMenuName;
		  className;
		  productCategory;
		  _isLoading = true;
		  _recordId;
		  @track productInfoList = [];
		  isCorporateBundle;
		  assetList;
	  
		  get isLoading() {
			  return this._isLoading;
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
		  }
		  //check if in CCE Portal
		  get isCCEPortal() {
		  return BasePath.toLowerCase().includes("cce");
		  }
	  
		  @wire(MessageContext)
		  messageContext;
	  
		  //retrieve Category Link Menus
		  @wire(getStoreFrontCategoryMenu,{communityId:communityId})
		  handleGetStorefrontCategories(result){  
			  if(result.data){
				  result.data.forEach((category, index) => {
					  let check = category.Id.includes(this.recordId);
					  
					  if(check){
						  this.productCategory = category.Name;
						  this.categoryId = category.Id;
						  //gets isTailoredExecEduc value to store in session storage if in CCE Portal
						  if(this.isCCEPortal){
						  let currentProductCategory = {
							  category: this.productCategory
							  };
							  sessionStorage.setItem(
								  CURRENTPRODUCTCATEGORY,
								  JSON.stringify(currentProductCategory)
							  );
						  }
						  
					  }
				  })
				  // get products list
				  this.getProducts();    
			  }
		  }
	  
		  get isTailoredExecEduc(){
			  return this.productCategory === 'Tailored Executive Education';
		  }
	  
		  backToTop() {
			  window.scrollTo({top: 0, behavior: 'smooth'});
		  }

		  // handles keyword search
		  handleSearchKeyword(event){
			this.stringValue = event.target.value;
			window.clearTimeout(this.delayTimeout);
			this.delayTimeout = setTimeout(() => {
				this.filterKey = this.stringValue;
				this.getProducts();
				if(this.stringValue.length == 0 ){
					this.filterKey = '';
					this.getProducts();
				}
			}, DELAY);
		}
		  
		  // Get the Products per category menu
		  getProducts(){
			  getProductsByCategory({
				  categoryId : this.categoryId,
				  userId : userId,
				  keyword : this.filterKey
			  }).then((result) => {
				  this.productInfoList = [];
				  let productsGroup = [];
				  if(this.productCategory == 'Corporate Bundle'){
					this.isCorporateBundle = true;
					this.assetList = result.assetList[0];
				  }
				  else{
					this.isCorporateBundle = false;
				  }
				  result.productList.forEach((p) => {
					//   var type = p.childProdType;
					  var type = '';
					  var exsitTypeGroup = productsGroup.find(p => p.type === type);
	  
					  if(!!exsitTypeGroup){
						  exsitTypeGroup.products.push(p);
					  } else {
						  productsGroup.push({
							  type: type,
							  products: [p],
						  });
					  }
				  });
	  
				  productsGroup.sort((a,b) => {
					  if(a.type < b.type) return -1;
					  if(a.type > b.type) return 1;
					  return 0;
				  });
				  
				  this.productInfoList = productsGroup.map( p => {
					  p.products.sort((a,b) => {
						  if(!!a.childProdOfferingDate && !!b.childProdOfferingDate && (Date.parse(a.childProdOfferingDate) < Date.parse(b.childProdOfferingDate))) return -1;						  
						  if(!!a.childProdOfferingDate && !!b.childProdOfferingDate && (Date.parse(a.childProdOfferingDate) > Date.parse(b.childProdOfferingDate)))  return 1;
						  if((!!a.childProdOfferingDate && !!b.childProdOfferingDate && (a.childProdOfferingDate == b.childProdOfferingDate)) || (!a.childProdOfferingDate || !b.childProdOfferingDate)){                     
						  if(!!a.childProdOfferingDate && !b.childProdOfferingDate) return -1;
						  if(!a.childProdOfferingDate && !!b.childProdOfferingDate) return 1;
							  if(a.childProdName < b.childProdName) return -1;
							  if(a.childProdName > b.childProdName) return 1;
							  return 0;
						  }
						  return 0;
						  
					  });
					  return p;
				  });
				  this._isLoading = false;
				  this.publishLMS();
			  }).catch((error) => {
				  this.error = error;
				  this._isLoading = false;
				  this.productInfoList = [];
			  });
		  }
		  publishLMS() {
			  let paramObj = {
				  productId: 1,
				  productName: this.productCategory,
				  clearOtherMenuItems: true
			  }
		  
			  const payLoad = {
				  parameterJson: JSON.stringify(paramObj)
			  };
		  
			  publish(this.messageContext, payloadContainerLMS, payLoad);
			  publish(this.messageContext, payloadContainerLMSsubMenuName, payLoad);
		  }  
	  }