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
	  | mary.grace.li             | November 22, 2022     | DEPP-4693            | Modified for Selected account logic                    |
 */

	  import { LightningElement ,wire, track, api} from 'lwc';
	  import getProductsByCategory from '@salesforce/apex/ProductCtrl.getProductsByCategory';
	  import getStoreFrontCategoryMenu from '@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories';
	  import getProductSpecsByAccount from '@salesforce/apex/ProductCtrl.getProductSpecsByAccount';
	  import getBuyerGroupMembers from '@salesforce/apex/ProductCtrl.getBuyerGroupMembers';
	  import getAssetsByAccount from '@salesforce/apex/ProductCtrl.getAssetsByAccount';
	  import communityId from '@salesforce/community/Id';
	  import BasePath from "@salesforce/community/basePath";
	  import userId from "@salesforce/user/Id";

	  import { publish, MessageContext } from 'lightning/messageService';
	  import { subscribe, unsubscribe } from 'lightning/messageService';
	  import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';
	  import payloadContainerLMSsubMenuName from '@salesforce/messageChannel/SubMenu__c';
	  import payloadAcctContainerLMS from '@salesforce/messageChannel/AccountId__c';

	  const CURRENTPRODUCTCATEGORY = "current_product_category";
	  const DELAY = 300;
	  const STORED_ACCTID = "storedAccountId";
	  const STORED_ASSETID = "storedAssetId";
	  const STORED_BUYERGROUPID = "storedBuyerGroupId";
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
		  accountId;
		  accountName;
		  fullLabel;
		  subscription;
		  prodSpecList = [];
		  prodSpecValue = '';
		  prodSpecId = '';
		  assets = [];

		  @track productInfoList = [];
		  isCorporateBundle;
		  assetList;

		  parameterObject = {
			userId: userId,
			categoryId : '', 
			accountId: '',
			accountName: '',
			fullLabel: '',
			prodSpecId: '',
			assetId: '',
			buyerGroupId: ''
		  }
	  
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
	  

		  renderedCallback(){
			this.subscribeLMS();
		  }
		  
		  //retrieve Category Link Menus
		  @wire(getStoreFrontCategoryMenu,{communityId:communityId})
		  handleGetStorefrontCategories(result){  
			  if(result.data){
				  result.data.forEach((category, index) => {
					  let check = category.Id.includes(this.recordId);
					  
					  if(check){
						  this.productCategory = category.Name;
						  this.categoryId = category.Id;

						  if(sessionStorage.getItem(STORED_ACCTID)){
						 	 this.accountId =  sessionStorage.getItem(STORED_ACCTID);
						  }

						  this.parameterObject = {
							userId : userId,
							categoryId : this.categoryId,
							accountId: this.accountId,
							accountName: this.accountName,
							fullLabel: this.fullLabel,
							prodSpecId: this.prodSpecId,
							assetId: this.selectedAssetId,
							buyerGroupId: this.selectedBuyerGroupId
						  }
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

		  get hasAsset(){
				return this.isCorporateBundle && this.assetOptions.length > 0;
		  }

		  get hasBuyerGroups(){
				return this.productCategory === 'QUTeX Learning Solutions' && this.buyerGroupOptions.length > 0;
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

		disableProdSpecList = true;

		@wire(getProductSpecsByAccount, { accountId : '$accountId' })
		getProductSpecsByAccount(result) {		
			this.prodSpecs = result.data;
			if(result.data){
				if(this.prodSpecs.length > 1){
					this.disableProdSpecList = false;
				}
				const options = result.data.map( res => {
					return {
						label: res.Program_Name__c,
						value: res.Id
					}
				});
				this.prodSpecList = options;
				this.prodSpecValue = options[0].value;
				this.prodSpecId = this.prodSpecValue;
				this.getProducts();
			}    
		}

		handleProdSpecChange(event){
			this.prodSpecId = event.detail.value;
			this.getProducts();
		}

		disableAssetSelection = true;
		assetOptions = [];
		selectedAssetId;

		@wire(getAssetsByAccount, { accountId : '$accountId' })
		getAssetsByAccount(result) {
			this.assets = result.data;
			if(this.assets && this.assets.length > 0){
				if(this.assets.length > 1){
					this.disableAssetSelection = false;
				}

				const options = result.data.map( res => {
					return {
						label: res.Name,
						value: res.Id
					}
				});

				this.assetOptions = options;

				if(sessionStorage.getItem(STORED_ASSETID)){
					this.selectedAssetId =  sessionStorage.getItem(STORED_ASSETID);
				}else{
					this.selectedAssetId = options[0].value;
				}
				
				this.parameterObject = {
					userId : userId,
					categoryId : this.categoryId,
					accountId: this.accountId,
					accountName: this.accountName,
					fullLabel: this.fullLabel,
					prodSpecId: this.prodSpecId,
					assetId: this.selectedAssetId,
					buyerGroupId: this.selectedBuyerGroupId
				}

				sessionStorage.setItem(
					STORED_ASSETID,
					this.selectedAssetId
				);
				
				this.getProducts();
			}
		}

		handleAssetChange(event){
			this.selectedAssetId = event.detail.value;
			sessionStorage.setItem(
				STORED_ASSETID,
				this.selectedAssetId
			);
			this.parameterObject = {
				userId : userId,
				categoryId : this.categoryId,
				accountId: this.accountId,
				accountName: this.accountName,
				fullLabel: this.fullLabel,
				assetId: this.selectedAssetId
			}
			this.getProducts();
		}


		disableBuyerGroupSelection = true;
		buyerGroupOptions = [];
		selectedBuyerGroupId;
		buyerGroups;

		@wire(getBuyerGroupMembers, { accountId : '$accountId' })
		getBuyerGroupMembers(result) {
			this.buyerGroups = result.data;
			if(this.buyerGroups && this.buyerGroups.length > 0){
				if(this.buyerGroups.length > 1){
					this.disableBuyerGroupSelection = false;
				}

				const options = result.data.map( res => {
					return {
						label: res.BuyerGroup.Name,
						value: res.BuyerGroupId
					}
				});

				this.buyerGroupOptions = options;

				if(sessionStorage.getItem(STORED_BUYERGROUPID)){
					this.selectedBuyerGroupId =  sessionStorage.getItem(STORED_BUYERGROUPID);
				}else{
					this.selectedBuyerGroupId= options[0].value;
				}
				
				this.parameterObject = {
					userId : userId,
					categoryId : this.categoryId,
					accountId: this.accountId,
					accountName: this.accountName,
					fullLabel: this.fullLabel,
					prodSpecId: this.prodSpecId,
					assetId: this.selectedAssetId,
					buyerGroupId: this.selectedBuyerGroupId
				}
				sessionStorage.setItem(
					STORED_BUYERGROUPID,
					this.selectedBuyerGroupId
				);
				this.getProducts();
			}
		}

		handleBuyerGroupChange(event){
			this.selectedBuyerGroupId = event.detail.value;
			sessionStorage.setItem(
				STORED_BUYERGROUPID,
				this.selectedBuyerGroupId
			);
			this.parameterObject = {
				userId : userId,
				categoryId : this.categoryId,
				accountId: this.accountId,
				accountName: this.accountName,
				fullLabel: this.fullLabel,
				prodSpecId: this.prodSpecId,
				assetId: this.selectedAssetId,
				buyerGroupId: this.selectedBuyerGroupId
			}
			this.getProducts();
		}
		  
		  // Get the Products per category menu
		  getProducts(){
			  getProductsByCategory({
				  acctFilterDataWrapper: this.parameterObject,
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
				   this.accountName = newValObj.accountName;
				   this.fullLabel = newValObj.fullLabel;
	
					this.parameterObject = {
						userId : userId,
						categoryId : this.categoryId,
						accountId: this.accountId,
						accountName: this.accountName,
						fullLabel: this.fullLabel,
						prodSpecId: this.prodSpecId,
						assetId: this.selectedAssetId,
						buyerGroupId: this.selectedBuyerGroupId
					}

				  	this.getProducts();
			}
		}
	  }