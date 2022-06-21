import { LightningElement, wire } from 'lwc';
import isGuest from "@salesforce/user/isGuest";
import basePath from "@salesforce/community/basePath";
import communityId from '@salesforce/community/Id';
import getStudyStore from '@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories';
import getUserCartDetails from '@salesforce/apex/ProductDetailsCtrl.getUserCartDetails';
import closeCart from "@salesforce/apex/CartItemCtrl.closeCart";
import userId from "@salesforce/user/Id";

export default class CustomLogout extends LightningElement {

    categoryId;
    recordPageUrl;

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
    
                this.recordPageUrl = sitePrefix + "/secur/logout.jsp?retUrl="+returnUrl;       
        }
    }

    //when the user clicked on the logout button
    logoutClicked(){

        //get the current active cart of the user
        getUserCartDetails({
            userId: userId
          })
            .then((results) => {

                // Set Cart to Closed
                closeCart({ cartId: results.Id})
                .then(() => {

                    //redirect after closing the cart
                    window.location.href = this.recordPageUrl;

                })
                .catch((error) => {
                    console.log("cart update error");
                    console.log(error);
                });

            })
            .catch((e) => {
              console.log(e);
              this.generateToast("Error.", LWC_Error_General, "error");
        });

    }
}