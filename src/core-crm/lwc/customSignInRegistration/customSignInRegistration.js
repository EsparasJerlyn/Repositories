/**
 * @description A LWC component container for Custom Sign in and Registration
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | mary.grace.j.li           | August 9, 2022        | DEPP-3720            | Created File                                 |
*/
import { LightningElement, wire, track } from "lwc";
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/SignIn__c';

export default class CustomSignInRegistration extends LightningElement {
    @track openLoginModal = false;
    @track openRegisterModal = false;
    startURL;

    subscription;

    @wire(MessageContext)
    messageContext;


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

    connectedCallback(){
        this.subscribeLMS();
    }

    disconnectedCallback() {
        this.unsubscribeLMS();
    }

    unsubscribeLMS(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Close Modal
    closeModal() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    subscribeLMS() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext, 
                payloadContainerLMS, 
                (message) => this.validateValue(message));
        }
    }

    // Handler for message received by component
    handleMessage(message) {
        this.msg = message.parameterJson;
    }

    validateValue(val) {
        if (val && val.parameterJson) {
            let newValObj = JSON.parse(val.parameterJson);
    
            this.openLoginModal = newValObj.openLogin ? String(newValObj.openLogin).toUpperCase() == 'TRUE' : false;
            this.openRegisterModal = newValObj.openRegister ? String(newValObj.openRegister).toUpperCase() == 'TRUE' : false;
        }
    }
}