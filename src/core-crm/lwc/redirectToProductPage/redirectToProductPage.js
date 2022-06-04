import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import isGuest from "@salesforce/user/isGuest";
import basePath from "@salesforce/community/basePath";
import communityId from '@salesforce/community/Id';
import getStudyStore from '@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories';

export default class RedirectToProductPage extends NavigationMixin(LightningElement){

    categoryUrl;
    categoryId;

    get isGuest() {
        return isGuest;
    }

     //retrieve Category Link Menus
     @wire(getStudyStore,{communityId:communityId})
     wiredCategories(result) {
         if(result.data){      
             this.categoryId = result.data[0].Id; 
             const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"      

             let returnUrl;
     
             returnUrl =
                 basePath +
                 "/category/products/" + 
                 this.categoryId;
                 console.log("URL: " + returnUrl);
     
                 this.categoryUrl = returnUrl;  
                 this.navigateToWebPage();
         }
     }

    // Navigation to web page 
    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.categoryUrl
            }
        });
    }
}