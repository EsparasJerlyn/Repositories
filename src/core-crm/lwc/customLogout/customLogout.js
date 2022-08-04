/**
 * @description A LWC component for Custom Logout
 *
 * @see ../classes/MainNavigationMenuCtrl.cls
 * @see customLogout
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | john.bo.a.pineda          | July 07, 2022         | DEPP-3136            | Modified to include Login when Guest User    |
      | john.bo.a.pineda          | July 15, 2022         | DEPP-3136            | Modified to include Register when Guest User |
*/
import { LightningElement, wire, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import isGuest from "@salesforce/user/isGuest";
import basePath from "@salesforce/community/basePath";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";
import communityId from "@salesforce/community/Id";
import getStudyStore from "@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories";
import getUserCartDetails from "@salesforce/apex/ProductDetailsCtrl.getUserCartDetails";
import closeCart from "@salesforce/apex/CartItemCtrl.closeCart";
import userId from "@salesforce/user/Id";

export default class CustomLogout extends LightningElement {
    @track openLoginModal = false;
    @track openRegisterModal = false;
    categoryId;
    recordPageUrl;
    startURL;

    get isGuest() {
        return isGuest;
    }

    /* Load Custom CSS */
    renderedCallback() {
        Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
    }

    //retrieve Category Link Menus
    @wire(getStudyStore, { communityId: communityId })
    wiredCategories(result) {
        if (result.data) {
            this.categoryId = result.data[0].Id;

            const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
            let returnUrl;

            returnUrl = basePath + "/category/products/" + this.categoryId;

            this.recordPageUrl =
                sitePrefix + "/secur/logout.jsp?retUrl=" + returnUrl;
        }
    }

    //when the user clicked on the logout button
    logoutClicked() {
        //get the current active cart of the user
        getUserCartDetails({
            userId: userId
        })
            .then((results) => {
                // Set Cart to Closed
                closeCart({ cartId: results.Id })
                    .then(() => {
                        //redirect after closing the cart
                        window.location.href = this.recordPageUrl;
                    })
                    .catch((error) => {
                        console.log(error);
                    });
            })
            .catch((e) => {
                console.log(e);
                this.generateToast("Error.", LWC_Error_General, "error");
            });
    }

    // Handle Login Modal Open
    handleLoginModalOpen() {
        this.openLoginModal = true;
        this.openRegisterModal = false;
    }

    // Handle Modal Close
    handleModalClose() {
        this.openLoginModal = false;
        this.openRegisterModal = false;
    }

    // Handle Register Modal Open
    handleRegisterModalOpen() {
        this.openLoginModal = false;
        this.openRegisterModal = true;
        // Set startURL for Register LWC
        this.startURL = window.location.pathname + window.location.search;
    }
}
