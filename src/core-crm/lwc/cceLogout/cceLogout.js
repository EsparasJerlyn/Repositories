/**
 * @description A LWC component to display product details for Prescribed Program
 *
 * @see ..
 * @see cceLogout
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | julie.jane.alegre         | September 13, 2022    | DEPP-4270            | Created file                                 |
      | marygrace.li              | September 24, 2022    | DEPP-4414            | Customized user profile menu and logout      |
      | mary.grace.li             | November 22, 2022     | DEPP-4693            | Modified for Selected account logic          |
      | eugene.andrew.abuan       | March 02, 2023        | DEPP-5266            | Added null checker for wiredContact          |
*/

import { LightningElement, wire } from "lwc";
import isGuest from "@salesforce/user/isGuest";
import basePath from "@salesforce/community/basePath";
import customSR from "@salesforce/resourceUrl/QUTCustomLwcCss";
import { getRecord } from "lightning/uiRecordApi";
import userId from "@salesforce/user/Id";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from "lightning/navigation";
//Contact fields
const CONTACT_FIELDS = [
    "User.ContactId",
    "User.Contact.FirstName",
    "User.Contact.LastName",
    "User.Contact.Registered_Email__c"
  ];

  const STORED_CONTACTNAME ="storedContactName";

export default class CceLogout extends NavigationMixin(LightningElement) {

    contactName;
    firstName;
    lastName;
    loginPageUrl;

    showLogout =false;

    @wire(getRecord, { recordId: userId, fields: CONTACT_FIELDS })
    wiredContact({ data }) {
        if(data){
            this.firstName = data.fields.Contact.value == null ? '' : data.fields.Contact.value.fields.FirstName.value;
            this.lastName = data.fields.Contact.value == null ? '' : data.fields.Contact.value.fields.LastName.value;
            let contactName = this.firstName + ' ' + this.lastName;

            sessionStorage.setItem(STORED_CONTACTNAME,contactName);
        }
       
        if(sessionStorage.getItem(STORED_CONTACTNAME)){
            this.contactName = sessionStorage.getItem(STORED_CONTACTNAME);
        }
    }

    /* Load Custom CSS */
    renderedCallback() {
        Promise.all([loadStyle(this, customSR + "/qutCustomLwcCss.css")]);
    }


    get isGuest() {
        return isGuest;
    }

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
       
        this.loginPageUrl = sitePrefix + "/secur/logout.jsp";

        return this.loginPageUrl;
    }


    handleLogoutClicked(){
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: this.loginPageUrl
            }
        });
        sessionStorage.clear();
    }

    handleToggle(){
        this.showLogout = !this.showLogout;
    }
}