/**
 * @description A custom LWC for Main Navigation
 *
 * @see ../classes/MainNavigationMenuCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
	  |---------------------------|-----------------------|--------------|--------------------------------------------------------|
	  | aljohn.motas              | January 14, 2022      | DEPP-1392    | Created Custom Navigation Menu                         |
	  | keno.domienri.dico        | July 5, 2022          | DEPP-2699 AC1| Updates for CCE                                        |
	  | keno.domienri.dico        | August 18, 2022       | DEPP-3765    | Updated Product Category method                        |
	  | marygrace.li              | September 7, 2022     | DEPP-2699    | Added homepage mobile view                             |
	  | keno.domienri.dico		  | September 28, 2022	  | DEPP-4459	 | Added search filter in getProducts method			  |
*/

import { LightningElement, wire, track, api } from 'lwc';
import getNavigationMenu from '@salesforce/apex/MainNavigationMenuCtrl.defaultMenu';
import getStoreFrontCategoryMenu from '@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories';
import getOpportunityContractType from '@salesforce/apex/MainNavigationMenuCtrl.getOpportunityContractType';
import getProductsByCategory from '@salesforce/apex/ProductCtrl.getProductsByCategory';
import communityId from '@salesforce/community/Id';
import basePath from '@salesforce/community/basePath';
import userId from '@salesforce/user/Id';
import USER_ID from '@salesforce/user/Id';
import customSR from "@salesforce/resourceUrl/QUTInternalCSS";
import { loadStyle } from "lightning/platformResourceLoader";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";

const STORE_FRONT_CATEGORY = 'StorefrontCategories';
const LOGIN_REQUIRED = 'LoginRequired';
const AVAILABLE_TO_BUY = 'Available to Buy';
const CONTRACT_TYPE = 'Standing Offer Arrangement';
const HOME_HEADER = 'For your organisation';
const DEFAULT_CATEGORY = 'Tailored Executive Education'
export default class MainNavigationMenu extends LightningElement {

	NavigationMenuList;
	CategoriesNavigationMenuList;
	OpportunityList;
	OpportunityContractType;

	//variables
	navMenuId;
	navMenuName;
	className;
	@track productInfoList = [];
	@track isTailoredExecEduc;
	accordionIcon;
	activeSections = [DEFAULT_CATEGORY];
	accordionIsClicked = false;

	renderedCallback() {
		Promise.all([loadStyle(this, customSR + "/QUTInternalCSS.css")]);
	}

	//retrieve Opportunity Contract Type
	@wire(getOpportunityContractType, { userId: USER_ID })
	handleGetOpportunityContractType(result) {
		if (result.data) {
			this.OpportunityList = result.data.map(Opportunity => {
				this.OpportunityContractType = Opportunity.Contract_Type__c;
			});
		} else {
			this.OpportunityContractType = null;
		}
	}

	//retrieve navigation Menu
	@wire(getNavigationMenu)
	handleGetNavigationMenuList(result){    
		if(result.data){
			this.NavigationMenuList = result.data.map(linkSets => {
				if(userId!=null || linkSets.AccessRestriction==LOGIN_REQUIRED) {
					if(linkSets.Label == AVAILABLE_TO_BUY){
						if(this.OpportunityContractType == CONTRACT_TYPE){
							return {
								Target:basePath+linkSets.Target,
								Id:linkSets.Id,
								Label:linkSets.Label,
								isStorefrontCategories:(linkSets.Target==STORE_FRONT_CATEGORY)
							};                            
						}
					}else if(linkSets.Label != AVAILABLE_TO_BUY){
						return {
							Target:basePath+linkSets.Target,
							Id:linkSets.Id,
							Label:linkSets.Label,
							isStorefrontCategories:(linkSets.Target==STORE_FRONT_CATEGORY)
						};
					}
				}
			});
		}
	}

    //retrieve Category Link Menus
    @wire(getStoreFrontCategoryMenu,{communityId:communityId})
    handleGetStorefrontCategories(result){  
        if(result.data){
            this.CategoriesNavigationMenuList = result.data.map(Category => {
                // sets the first navigation menu as active
                if(Category.SortOrder == '1'){
                    this.className = 'slds-tabs_default__item slds-is-active';
                    this.navMenuId = Category.Id;
                } else {
                    this.className = 'slds-tabs_default__item';
                }
                return {
                    Target: '#',
                    Id:Category.Id,
                    Label:Category.Name,
					Value: Category.Name + '_' + Category.Id,
					Sort: Category.SortOrder,
					Class: this.className
				};
			});
			// get products list
			this.getProducts();
		}
	}

	connectedCallback() {
		this.isTailoredExecEduc = true;
		this.navMenuName = 'Tailored Executive Education';
		this.accordionIcon = qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
		this.accordionClose = qutResourceImg + "/QUTImages/Icon/accordionClose.svg";
	}

	// get header text
	get headerHome() {
		return HOME_HEADER;
	}

	// click event for menu
	handleMenuClick(event) {
		this.onPageLoad = false;
		let activeMenu = event.currentTarget.closest('li');
		let inactiveMenu = this.template.querySelectorAll('li');
		this.navMenuId = activeMenu.dataset.id;
		this.navMenuName = activeMenu.dataset.name;

		// set navigation menu classes to default
		if (inactiveMenu) {
			inactiveMenu.forEach(menu => {
				menu.setAttribute('class', 'slds-tabs_default__item');
			})
		}

		// set active navigation menu class to active
		if (activeMenu) {
			activeMenu.setAttribute('class', 'slds-tabs_default__item slds-is-active');
		}
		// check if Tailored Executive Education
		if (this.navMenuName == 'Tailored Executive Education') {
			this.isTailoredExecEduc = true;
		} else {
			this.isTailoredExecEduc = false;
		}
		// get products list
		this.getProducts();
	}

	// URL for the View all course button
	get viewAllCourses() {
		if (this.navMenuName && this.navMenuId) {
			return basePath + '/category/' + this.navMenuName.replaceAll(' ', '-').toLowerCase() + '/' + this.navMenuId.slice(0, -3);
		} else {
			return '#';
		}
	}

	// Get the Products per category menu
	getProducts() {
		getProductsByCategory({
			categoryId : this.navMenuId,
			userId : USER_ID,
			keyword : ''
		}).then((result) => {
			let prodList = [];
			this.productInfoList = [];
			let count = 1;
			prodList = result.productList;
			prodList = prodList.slice().sort(function (futureDate, pastDate) {
				if (!!futureDate.childProdOfferingDate && !!pastDate.childProdOfferingDate && (Date.parse(futureDate.childProdOfferingDate) < Date.parse(pastDate.childProdOfferingDate))) return -1;
				if (!!futureDate.childProdOfferingDate && !!pastDate.childProdOfferingDate && (Date.parse(futureDate.childProdOfferingDate) > Date.parse(pastDate.childProdOfferingDate))) return 1;
				if ((!!futureDate.childProdOfferingDate && !!pastDate.childProdOfferingDate && (futureDate.childProdOfferingDate == pastDate.childProdOfferingDate)) || (!futureDate.childProdOfferingDate || !pastDate.childProdOfferingDate)) {
					if (!!futureDate.childProdOfferingDate && !pastDate.childProdOfferingDate) return 1;
					if (!futureDate.childProdOfferingDate && !!pastDate.childProdOfferingDate) return -1;
					if (futureDate.childProdName < pastDate.childProdName) return -1;
					if (futureDate.childProdName > pastDate.childProdName) return 1;
					return 0;
				}
				return 0;
			});

			// Limit to 2 Products to display
			let totalProdDisplayed = 0;
			let today = new Date();

			if(prodList.length > 2) {
				prodList.forEach((p) => {
					if(totalProdDisplayed < 2) {
						if(!p.isProgramFlex){
							if(p.childProdOfferingDate){
								this.productInfoList.push(p);
								totalProdDisplayed++;
							}
						}
					}
				});
			} else {
				this.productInfoList = prodList;
			}
		}).catch((error) => {
			this.error = error;
		});
	}

	handleSectionToggle(event) {
		this.activeSections = event.detail.openSections;
		const sections = event.detail.openSections.split("_");

		this.navMenuName = sections[0];
		this.navMenuId = sections[1];
		
		this.accordionIsClicked == true;

		// check if Tailored Executive Education
		if(this.navMenuName == 'Tailored Executive Education'){
			this.isTailoredExecEduc = true;
		} else {
			this.isTailoredExecEduc = false;
		}

		// get products list
		this.getProducts();
	}
}