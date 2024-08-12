/**
 * @description A LWC component to display product details
 *
 * @see ../classes/ProductDetailsCtrl.cls
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
			| john.bo.a.pineda          | April 11, 2022        | DEPP-1211            | Modified logic for new UI                    |
			| keno.domienri.dico        | April 29, 2022        | DEPP-2038            | Added child product records                  |
			| burhan.m.abdul            | June 09, 2022         | DEPP-2811            | Added messageService                         |
			| john.bo.a.pineda          | June 27, 2022         | DEPP-3216            | Modified to add urlDefaultAddToCart parameter|
			| john.bo.a.pineda          | June 27, 2022         | DEPP-3385            | Modified to get recordId from url p param    |
			| john.m.tambasen           | July 29, 2022         | DEPP-3577            | early bird changes no of days                |
			| keno.domienri.dico        | August 03, 2022       | DEPP-3474            | CCE QUTex Learning added product category    |
			| keno.domienri.dico        | August 18, 2022       | DEPP-3765            | Added new Product category identifier        |
			|                           | August 24, 2022       |                      | Addded new method for CCE Product Details    |
			| mary.grace.li             | November 22, 2022     | DEPP-4693            | Modified for Selected account logic          |
			| mary.grace.li             | February 9, 2022      | DEPP-5157 / 5180     | Removed renderedCallback in CCE              |
			| sebastianne.k.trias       | May 15, 2024          | DEPP-8410            | Added showErrorMessageSetToTrue method       |
*/

import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import communityId from "@salesforce/community/Id";
import isGuest from "@salesforce/user/isGuest";
//kenn changes start
import getDesignationProdDetails from "@salesforce/apex/DesignationProductCtrl.getDesignationProductDetails";
//kenn changes end
import getProductDetails from "@salesforce/apex/ProductDetailsCtrl.getProductRelatedRecords";
import getCCEProductDetails from "@salesforce/apex/ProductDetailsCtrl.getCCEProductRelatedRecords";
import getOrCreateActiveCartSummary from "@salesforce/apex/B2BGetInfo.getOrCreateActiveCartSummary";
import getCartSummary from "@salesforce/apex/B2BGetInfo.getCartSummary";
import addToCartItem from "@salesforce/apex/ProductDetailsCtrl.addToCartItem";
import userId from "@salesforce/user/Id";
import BasePath from '@salesforce/community/basePath';
import { publish, MessageContext } from "lightning/messageService";
import payloadContainerLMS from "@salesforce/messageChannel/Breadcrumbs__c";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import payloadAcctContainerLMS from '@salesforce/messageChannel/AccountId__c';
import { subscribe, unsubscribe } from 'lightning/messageService';
const STORED_ACCTID = "storedAccountId";
const STORED_ASSETID = "storedAssetId";
const STORED_BUYERGROUPID = "storedBuyerGroupId";

const Tailored_Executive_Education = 'Tailored Executive Education';
const STOREPRODUCTCATEGORY = "product_category";
export default class ProductDetails extends NavigationMixin(LightningElement) {
  loading;
  productDetails;
  priceReadOnly;
  priceBookEntryList;
  deliveryOptions;
  product;
  showPrescribedProgram;
  showFlexibleProgram;
  showProductDetailsSingle;
  showProductDetailsDisplay;
  cProducts;
  isProgramFlex = false;
  availablePricings = [];
  recordNameId;
  fromCategoryName;
  fromCategoryId;
  ccePricebookEntryId;
  showErrorMessage = false;
  advancementProductDetails;

  amount1;
  amount2;
  amount3;
  amount4;

  tempAcct;
  subscription;
  accountId;
  productDetail;
  hasData = false;
  baseUrl;
  assetId;
  buyerGroupId;

  parameterObject = {
	accountId: '',
	productId: '', 
	categoryName: '', 
	userId: '',
	assetId: '',
	buyerGroupId: ''
  }

  tempParameterObject ={
	accountId: '',
	userId: ''
  }

	// Gets product Category
    @api productCategory; 
	@api productCategoryChild;

	// Gets & Sets the effective account - if any - of the user viewing the product.
	@api
	get effectiveAccountId() {
		return this._effectiveAccountId;
	}

	set effectiveAccountId(newId) {
		this._effectiveAccountId = newId;
		if (!isGuest) {
			this.updateCartInformation();
		}
	}

	// Gets or sets the unique identifier of a product.
	@api recordId;
	// Gets or sets the custom fields to display on the product in a comma-separated list of field names
	@api customDisplayFields;
	// The cart summary information
	cartSummary;

	@wire(MessageContext)
	messageContext;

	accountSelectionSubscription;

	disconnectedCallback() {
        this.unsubscribeLMS();
    }

	unsubscribeLMS(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }



	// Get param from URL
	@wire(CurrentPageReference)
	getpageRef(pageRef) {
		if (pageRef && pageRef.state && pageRef.state.p) {
			this.recordId = pageRef.state.p.substring(
				pageRef.state.p.lastIndexOf("_") + 1
			);
			this.recordNameId = pageRef.state.p;
		}
	}
	// The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
	connectedCallback() {
		this.loading = true;
		this.showPrescribedProgram = false;
		this.showFlexibleProgram = false;
		this.showProductDetailsSingle = false;
		this.showProductDetailsDisplay = false;

		if(this.isCCEPortal){
			this.subscribeLMS();
			this.getCCEProductDetails(this.recordId);
		}

		if(this.isOPEPortal){
			//this.getProductDetailsApex(this.recordId);
			//kenn changes start
			this.getDesignationProdDetailsApex('01t9r000005drWDAAY');
			//kenn changes end
		}
		// if(this.isOPEPortal){
		// 	if (!isGuest) {
		// 		this.updateCartInformation();
		// 	}
		// 	this.dispatchEvent(
		// 		new CustomEvent("cartchanged", {
		// 			bubbles: true,
		// 			composed: true
		// 		})
		// 	);
		// }else{
		// 	if (!isGuest) {
				
		// 		getOrCreateActiveCartSummary({
		// 		  communityId: communityId,
		// 		  effectiveAccountId: this.resolvedEffectiveAccountId
		// 		})
		// 		.then((result) => {
		// 			this.updateCartInformation();
		// 		})
		// 		.catch((e) => {
		// 			console.log(e);
		// 		});
		// 	}
		// }
	}

	// For CCE Product Details
	get isCCEPortal() {
		return BasePath.toLowerCase().includes("cce");
	}

	// For OPE Product Details
	get isOPEPortal() {
		return BasePath.toLowerCase().includes("study");
	}

	getProductDetailsApex(productId) {
		// For Study 
		getProductDetails({ productId: productId })
		.then((result) => {
			this.isProgramFlex = !result.isNotFlexProgram;
			this.productDetails = result.productOnPage;
			this.priceBookEntryList = result.pricebookWrapperList;
			this.deliveryOptions = result.deliveryWrapperList;
			this.product = {};
			this.product.productDetails = result.productOnPage;
			this.product.programModules = result.moduleWrapperList;
			this.product.priceBookEntryList = result.pricebookWrapperList;
			let pricingsLocal = [];
			this.product.priceBookEntryList.forEach(function (priceBookEntry) {
				pricingsLocal.push({
					label:
						priceBookEntry.label === "Standard Price Book"
							? priceBookEntry.label.slice(0, 8)
							: priceBookEntry.label,
					value: priceBookEntry.value,
					meta: parseInt(priceBookEntry.meta).toLocaleString("en-US", {
						style: "currency",
						currency: "USD",
						minimumFractionDigits: 0
					}),
					noOfDays: priceBookEntry.noOfDays
				});
			});
			this.availablePricings = pricingsLocal;
			this.product.deliveryOptions = result.deliveryWrapperList;
			this.product.programDeliveryAndOfferings =
				result.programDeliveryAndOfferingMap;
			if (this.product.productDetails.Program_Plan__r == undefined) {
				this.showPrescribedProgram = false;
				this.showFlexibleProgram = true;
				this.showProductDetailsSingle = false;
				this.showProductDetailsDisplay = true;
			} else if (
				this.product.productDetails.Program_Plan__r
					.Program_Delivery_Structure__c == "Prescribed Program"
			) {
				this.showPrescribedProgram = true;
				this.showFlexibleProgram = false;
				this.showProductDetailsSingle = false;
				this.showProductDetailsDisplay = false;
			} else if (
				this.product.productDetails.Program_Plan__r
					.Program_Delivery_Structure__c == "Flexible Program"
			) {
				this.showPrescribedProgram = false;
				this.cProducts = result.childProductList;
				this.showFlexibleProgram = false;
				this.showProductDetailsSingle = false;
				this.showProductDetailsDisplay = true;
			} else {
				this.showPrescribedProgram = false;
				this.showFlexibleProgram = true;
				this.showProductDetailsSingle = false;
				this.showProductDetailsDisplay = true;
			}

			this.showProductDetailsDisplay = true;

			this.loading = false;
			this.publishLMS();
		})
		.catch((error) => {
			console.log(error);
			this.showErrorMessageSetToTrue();
		})
		.finally(() => {
			this.loading = false;
		});
	}

	//kenn changes start
	getDesignationProdDetailsApex(productId){
		getDesignationProdDetails({ productId: productId })
		.then((result) => {
			this.advancementProductDetails = result.productOnPage;

			this.amount1 = '$' + result.productOnPage.Predefined_Amount_1__c;
			this.amount2 = '$' + result.productOnPage.Predefined_Amount_2__c;
			this.amount3 = '$' + result.productOnPage.Predefined_Amount_3__c;
			this.amount4 = '$' + result.productOnPage.Predefined_Amount_4__c;

			this.showProductDetailsDisplay = true;

			this.loading = false;
		})
		.catch((error) => {
		  console.log(error);
		});
	  }
	  //kenn changes end

	// Gets the normalized effective account of the user.
	get resolvedEffectiveAccountId() {
		const effectiveAccountId = this.effectiveAccountId || "";
		let resolved = null;

		if (
			effectiveAccountId.length > 0 &&
			effectiveAccountId !== "000000000000000"
		) {
			resolved = effectiveAccountId;
		}
		return resolved;
	}

	// Gets Product Fields
	/*get isNotFlexProgram() {
		return this.productDetails.data
			? this.productDetails.data.isNotFlexProgram
			: [];
	}*/

	// Gets List oc Child Products
	/*get cProducts() {
		// console.log('productDetails: ' + JSON.stringify(this.productDetails));
		return this.productDetails.data
			? this.productDetails.data.childProductList
			: [];
	}*/

	// Gets whether the cart is currently locked
	get _isCartLocked() {
		const cartStatus = (this.cartSummary || {}).status;
		return cartStatus === "Processing" || cartStatus === "Checkout";
	}

	//Custom
	addToCartItem(event) {
		let courseOfferingId = "";
		let programOfferingId = "";
		if (event.detail.courseOfferingId != undefined) {
			courseOfferingId = event.detail.courseOfferingId;
		}
		if (event.detail.programOfferingId != undefined) {
			programOfferingId = event.detail.programOfferingId;
		}
		addToCartItem({
			communityId: communityId,
			productId: this.recordId,
			effectiveAccountId: this.resolvedEffectiveAccountId,
			productName: this.productDetails.Name,
			courseOfferingId: courseOfferingId,
			programOfferingId: programOfferingId,
			pricebookEntryId: event.detail.pricebookEntryId,
			userId: userId,
			urlDefaultAddToCart: event.detail.urlDefaultAddToCart
		})
			.then((result) => {
				this.dispatchEvent(
					new CustomEvent("cartchanged", {
						bubbles: true,
						composed: true
					})
				);
				/* this.dispatchEvent(
					new ShowToastEvent({
						title: "Success",
						message: "Your cart has been updated.",
						variant: "success",
						mode: "dismissable"
					})
				); */
			})
			.catch((e) => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error",
						message:
							"{0} could not be added to your cart at this time. Please try again later.",
						messageData: [this.productDetails.data.productOnPage.Name],
						variant: "error",
						mode: "dismissable"
					})
				);
			});
	}

	// Ensures cart information is up to date
	updateCartInformation() {
		getCartSummary({
			communityId: communityId,
			effectiveAccountId: this.resolvedEffectiveAccountId
		})
			.then((result) => {
				this.cartSummary = result;
			})
			.catch((e) => {
				// Handle cart summary error properly
				console.log(e);
			});
	}

	handleviewproduct(event) {
		let tempObj = this.product;
		this.product = {};
		this.product.productDetails = event.detail.value;
		this.product.parent = tempObj;
		this.showPrescribedProgram = false;
		this.showFlexibleProgram = false;
		this.showProductDetailsSingle = true;
	}

	handlebacktoprogram(event) {
		let tempObj = event.detail.value;
		this.product = tempObj.parent;
		this.showPrescribedProgram = true;
		this.showFlexibleProgram = false;
		this.showProductDetailsSingle = false;
	}

  //burhan
  publishLMS() {
    let currentProductCategory = JSON.parse(
        sessionStorage.getItem(STOREPRODUCTCATEGORY)
    );
    if(!!currentProductCategory){
      this.fromCategoryName = currentProductCategory.fromCategoryName;
      this.fromCategoryId = currentProductCategory.fromCategoryId;
    }
    
    let paramObj = {
      productId: this.productDetails.Id,
      productName: this.productDetails.Name,
      isProgramFlex: this.isProgramFlex,
      children: this.cProducts,
      clearOtherMenuItems: true,
      fromCategoryName: this.fromCategoryName,
      fromCategoryId: this.fromCategoryId,
    };

		const payLoad = {
			parameterJson: JSON.stringify(paramObj)
		};

		publish(this.messageContext, payloadContainerLMS, payLoad);
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

			   sessionStorage.setItem(STORED_ACCTID,this.accountId);
        }
    }
	getCCEProductDetails(productId){
		let currentProductCategory = JSON.parse(
			sessionStorage.getItem(STOREPRODUCTCATEGORY)
		);
		this.productCategory = currentProductCategory.fromCategoryName;
		this.fromCategoryId = currentProductCategory.fromCategoryId;
		
		if(sessionStorage.getItem(STORED_ACCTID)){
			this.accountId =  sessionStorage.getItem(STORED_ACCTID);
		}

		if(sessionStorage.getItem(STORED_ASSETID)){
			this.assetId =  sessionStorage.getItem(STORED_ASSETID);
		}

		if(sessionStorage.getItem(STORED_BUYERGROUPID)){
			this.buyerGroupId =  sessionStorage.getItem(STORED_BUYERGROUPID);
		}

		this.parameterObject = {
			accountId: this.accountId,
			productId: productId, 
			categoryName: this.productCategory, 
			userId: userId,
			assetId: this.assetId,
			buyerGroupId: this.buyerGroupId
		}

		getCCEProductDetails({ 
			productDetailsDataWrapper: this.parameterObject
		})
		.then((result) => {
			
			this.hasData = result.productOnPage ? true : false;
			this.isProgramFlex = !result.isNotFlexProgram;
			this.productDetails = result.productOnPage;
			this.ccePricebookEntryId = result.pricebookEntryIdCCE;
			this.priceReadOnly = parseInt(result.priceCCE).toLocaleString("en-US", {
														style: "currency",
														currency: "USD",
														minimumFractionDigits: 0
													});
			this.priceBookEntryList = result.pricebookWrapperList;
			this.deliveryOptions = result.deliveryWrapperList;
			this.product = {};
			this.product.productDetails = result.productOnPage;
			this.product.programModules = result.moduleWrapperList;
			this.product.deliveryOptions = result.deliveryWrapperList;
			this.product.programDeliveryAndOfferings = result.programDeliveryAndOfferingMap;
			if (this.product.productDetails.Program_Plan__r == undefined) {
				this.showPrescribedProgram = false;
				this.showFlexibleProgram = true;
				this.showProductDetailsSingle = false;
				this.showProductDetailsDisplay = true;
			} else if (
				this.product.productDetails.Program_Plan__r
					.Program_Delivery_Structure__c == "Prescribed Program"
			) {
				this.showPrescribedProgram = true;
				this.showFlexibleProgram = false;
				this.showProductDetailsSingle = false;
				this.showProductDetailsDisplay = false;
			} else if (
				this.product.productDetails.Program_Plan__r
					.Program_Delivery_Structure__c == "Flexible Program"
			) {
				this.showPrescribedProgram = false;
				this.cProducts = result.childProductList;
				this.showFlexibleProgram = false;
				this.showProductDetailsSingle = false;
				this.showProductDetailsDisplay = true;
			} else {
				this.showPrescribedProgram = false;
				this.showFlexibleProgram = true;
				this.showProductDetailsSingle = false;
				this.showProductDetailsDisplay = true;
			}

			this.loading = false;	
			this.publishLMS();
		})
		.catch((error) => {
			console.log(error);
		})
		.finally(() => {
			this.loading = false;

			if(!this.hasData){
				this.redirectToListingPage();
			}
		});
	}

	showErrorMessageSetToTrue(){
		this.showProductDetailsDisplay = false;
		this.showPrescribedProgram = false;
		this.showProductDetailsSingle = false;
		this.showErrorMessage = true;
	}


	/**
	 * navigate to Product Listing page if product is not available on that account
	 */
	redirectToListingPage(){
		let currentProductCategory = JSON.parse(
			sessionStorage.getItem(STOREPRODUCTCATEGORY)
		);
		
		this.listingPageUrl = BasePath + "/category/" + currentProductCategory.fromCategoryId;

		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url: this.listingPageUrl
			}
		});
	}
}