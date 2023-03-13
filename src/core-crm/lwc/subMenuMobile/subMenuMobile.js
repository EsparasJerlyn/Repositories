/**
 * @description A LWC component for sub menu mobile
 * 
 * @see ../classes/MainNavigationMenuCtrl.cls
 * @see subMenuMobile
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | marygrace.li              | September 07, 2022    | DEPP-2699            | Created                                      |
      | marygrace.li              | September 17, 2022    | DEPP-4355            | Added LMS to fetch category name             |
      | dodge.j.palattao          | September 26, 2022    | DEPP-2699            | Added messageChannel of BreadCrumbs          |
      | mary.grace.li             | November 22, 2022     | DEPP-4693            | Modified for Selected account logic          |
 */

import { LightningElement, wire, track } from 'lwc';
import basePath from "@salesforce/community/basePath";
import getStoreFrontCategoryMenu from '@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories';
import communityId from '@salesforce/community/Id';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import payloadContainerLMSsubMenuName from '@salesforce/messageChannel/SubMenu__c';
import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';
import payloadAcctContainerLMS from '@salesforce/messageChannel/AccountId__c';
const STORED_ACCTID = "storedAccountId";

export default class SubMenuMobile extends LightningElement {
    CategoriesNavigationMenuList;
    error;
    navTailoredExecEduc;
    navCorpBundle;
    navQUTeXLearn;
    @track categoryName;
    @track subMenuName;

    subscriptionBreadCrumbs;
    subscriptionSubMenuName;
    subscription;

    accountId;
    accountName;
    fullLabel;


    @wire(MessageContext)
    messageContext;


    connectedCallback(){
        this.subMenuNameSubscribeLMS();
        this.breadCrumbsSubscribeLMS();
        this.subscribeLMS();   
    }

    disconnectedCallback() {
        this.subMenuNameUnsubscribeLMS();
        this.breadCrumbsUnsubscribeLMS();
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

    subMenuNameUnsubscribeLMS(){
        unsubscribe(this.subscriptionSubMenuName);
        this.subscriptionSubMenuName = null;
    }

    breadCrumbsUnsubscribeLMS(){
        unsubscribe(this.subscriptionBreadCrumbs);
        this.subscription2 = null;
    }

    breadCrumbsSubscribeLMS() {
        if (!this.subscriptionBreadCrumbs) {
            this.subscriptionBreadCrumbs = subscribe(
                this.messageContext, 
                payloadContainerLMS, 
                (message) => this.breadCrumbsValidateValue(message));
        }
    }

    subMenuNameSubscribeLMS() {
        if (!this.subscriptionSubMenuName) {
            this.subscriptionSubMenuName = subscribe(
                this.messageContext, 
                payloadContainerLMSsubMenuName, 
                (message) => this.subMenuNameValidateValue(message));
        }
    }

    subMenuNameValidateValue(val) {
        if (val && val.parameterJson) {
            let newValObj = JSON.parse(val.parameterJson);
    
            this.categoryName = newValObj.categoryName;
        }
    }

    breadCrumbsValidateValue(val) {
        if (val && val.parameterJson) {
            let newValObj = JSON.parse(val.parameterJson);
    
            this.subMenuName = newValObj.productName;
        }
    }

    validateValue(val) {
        if (val && val.accountIdParameter) {
            let newValObj = JSON.parse(val.accountIdParameter);
    
               this.accountId = newValObj.accountId;
               this.accountName = newValObj.accountName;
               this.fullLabel = newValObj.fullLabel;

        }
    }

    //retrieve Category Link Menus
    @wire(getStoreFrontCategoryMenu,{communityId:communityId})
    handleGetStorefrontCategories(result){  
        if(result.data){
            if(result.data){
                this.CategoriesNavigationMenuList = result.data.forEach(Category => {
                    // gets the category details and create link
                    if(Category.SortOrder == '1'){
                        this.navTailoredExecEduc = basePath+'/category/'+Category.Name.replaceAll(' ','-').toLowerCase()+'/'+Category.Id.slice(0, -3);
                    } else if(Category.SortOrder == '2'){
                        this.navCorpBundle = basePath+'/category/'+Category.Name.replaceAll(' ','-').toLowerCase()+'/'+Category.Id.slice(0, -3);
                    } else if(Category.SortOrder == '3'){
                        this.navQUTeXLearn = basePath+'/category/'+Category.Name.replaceAll(' ','-').toLowerCase()+'/'+Category.Id.slice(0, -3);
                    }
                });
            } else if(error){
                this.error = error;
                console.log('Error:', this.error);
            }
        }
    }

    get subMenuHome(){
        let extendedBasePath1 = basePath + '/';
        let extendedBasePath2 = basePath + '/#';
        if(window.location.pathname == basePath || window.location.pathname == extendedBasePath1 || window.location.pathname == extendedBasePath2){
            return 'arrow-link active';
        } else {
            return 'arrow-link';
        }
    }

    get subMenuTailoredExecEduc(){
         if(this.categoryName === 'Tailored Executive Education' && window.location.pathname.includes('product')){
             return 'arrow-link active';
        }else if(this.subMenuName === 'Tailored Executive Education' && window.location.pathname.includes('category')){
            return 'arrow-link active';
        }else {
            return 'arrow-link';
        }
    }

    get subMenuCorpBundle(){
        if(this.categoryName === 'Corporate Bundle' && window.location.pathname.includes('product')){
             return 'arrow-link active';
        }else if(this.subMenuName === 'Corporate Bundle' && window.location.pathname.includes('category')){ 
            return 'arrow-link active';
        }else {
            return 'arrow-link';
        }
    }

    get subMenuQUTexLearning(){
        if(this.categoryName === 'QUTeX Learning Solutions' && window.location.pathname.includes('product')){
             return 'arrow-link active';
        }else if(this.subMenuName === 'QUTeX Learning Solutions' && window.location.pathname.includes('category')){
            return 'arrow-link active';
        } else {
            return 'arrow-link';
        }
    }

    get subMenuManageReg(){
        if(window.location.pathname.includes('manage-registrations')){
            return 'arrow-link active';
        } else {
            return 'arrow-link';
        }
    }

    get homeLink(){
        return basePath;
    }

    get tailoredExecEducLink(){
        return this.navTailoredExecEduc;
    }

    get corpBundleLink(){
        return this.navCorpBundle;
    }

    get qutexLearnLink(){
        return this.navQUTeXLearn;
    }

    get manageRegistrationLink(){
        return basePath + '/manage-registrations';
    }

    handleMenuClick(event){
		let activeMenu = event.currentTarget.closest('li a');
		let inactiveMenu = this.template.querySelectorAll('li a');
		this.navMenuId = activeMenu.dataset.id;
		this.navMenuName = activeMenu.dataset.name;
		// set navigation menu classes to default
		if(inactiveMenu){
			inactiveMenu.forEach( menu => {
				menu.setAttribute('class', 'arrow-link ');
			})
		}
		// set active navigation menu class to active
		if(activeMenu){
			activeMenu.setAttribute('class', 'arrow-link active');
		}	
	}
}