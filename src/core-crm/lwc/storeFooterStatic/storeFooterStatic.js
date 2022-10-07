/**
 * @description A LWC component to Footer
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                         |
	  |---------------------------|-----------------------|----------------------|--------------------------------------------------------|
	  | dodge.j.palattao          | September 26, 2022    | DEPP-2699            | Delete getter method for Active Category               |
 */

import { LightningElement, track, wire } from 'lwc';
import getStoreFrontCategoryMenu from '@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories';
import basePath from '@salesforce/community/basePath';
import communityId from '@salesforce/community/Id';

const onlineLink = 'https://qutex@qut.edu.au';
const legalLink = 'https://www.qut.edu.au/additional';
const privacyLink = 'https://www.qut.edu.au/additional/privacy';

export default class StoreFooterStatic extends LightningElement {
    
    @track
    IsProductDetailDisplay = false;
    CategoriesNavigationMenuList;
    error;
    navTailoredExecEduc;
    navCorpBundle;
    navQUTeXLearn;

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
 
    get isCCELogin() {
        return basePath.toLowerCase().includes("login");
    }

    get legal_Link(){
        return legalLink;
    }

    get privacy_Link(){
        return privacyLink;
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
  
    handleMenuClick(event){
		let activeMenu = event.currentTarget.closest('li a');
		let inactiveMenu = this.template.querySelectorAll('li  a');
		this.navMenuId = activeMenu.dataset.id;
		this.navMenuName = activeMenu.dataset.name;
		if(inactiveMenu){
			inactiveMenu.forEach( menu => {
				menu.setAttribute('class', 'arrow-link ');
			})
		}
		if(activeMenu){
			activeMenu .setAttribute('class', 'arrow-link active');
		}

        this.template.querySelector('c-sub-menu').handleMenuClick(event);
	}
}