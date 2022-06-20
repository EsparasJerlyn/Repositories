import { LightningElement, api, track, wire } from "lwc";
import getOPEProductCateg from "@salesforce/apex/PaymentConfirmationCtrl.getOPEProductCateg";
import getCartData from "@salesforce/apex/PaymentConfirmationCtrl.getCartData";
import createCourseConnection from "@salesforce/apex/PaymentConfirmationCtrl.createCourseConnection";
import updateWebCart from "@salesforce/apex/PaymentConfirmationCtrl.updateWebCart";
import {updateRecord } from 'lightning/uiRecordApi';
import BasePath from "@salesforce/community/basePath";
import userId from "@salesforce/user/Id";
import checkCartOwnerShip from "@salesforce/apex/PaymentConfirmationCtrl.checkCartOwnerShip";

import { publish, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';
import PAYMENT_STATUS_FIELD from '@salesforce/schema/Cart_Payment__c.Payment_Status__c';
import INVOICE_FIELD from '@salesforce/schema/Cart_Payment__c.Invoice_Number__c';
import RECEIPT_FIELD from '@salesforce/schema/Cart_Payment__c.Receipt_Number__c';
import AMOUNT_PAID from '@salesforce/schema/Cart_Payment__c.Amount_Paid__c';
import STATUS_FIELD from '@salesforce/schema/Cart_Payment__c.Status__c';
import EMAIL_FIELD from '@salesforce/schema/Cart_Payment__c.Email__c';
import ID_FIELD from '@salesforce/schema/Cart_Payment__c.Id';

export default class PaymentConfirmation extends LightningElement {
    @api recordId;
    @track prodCategId;
    @track subHeader;
    @track subHeaderClass = 'heading2 pb2 subheader-color-err';
    @track paymentApproved = false;
    @track buttonLabel = 'Return cart summary';
    @track contactEmail; 
    
    cartId;
    cartItems = [];
    paymentStatus;
    subTotal;
    discountTotal;
    grandTotal;
    paymentMethod;
    cartPayment;
    paidInFull = 'No';
    parameters = {};
    isLoading = true;

    //to get the product category Id
    @wire(getOPEProductCateg)
    productCategData;

    @wire(MessageContext)
    messageContext;

    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    connectedCallback() {

        //get the parameters from the url
        this.parameters = this.getQueryParameters();
        
        //set the subheader based on the status returned by QUT Pay
        if(this.parameters.Status == 'A'){
            this.subHeader = 'Your purchase was successful!';
            this.paymentApproved = true;
            this.subHeaderClass = 'heading2 pb2 subheader-color-suc';
            this.buttonLabel = 'Browse more courses'
            this.paymentStatus = "Approved";

        } else if(this.parameters.Status == 'D'){
            this.subHeader = 'Your payment was declined. Please check your payment details.';
            this.paymentStatus = "Declined";

        } else if(this.parameters.Status == 'C'){
            this.subHeader = 'Your payment was cancelled. Please check your payment details.';
            this.paymentStatus = "Cancelled Payment";

        } else if(this.parameters.Status == 'V'){
            this.subHeader = 'Your payment has a validation failure. Please check your payment details.';
            this.paymentStatus = "Validation Failure";
        }

        checkCartOwnerShip({externalId: this.parameters.WebcartExternal_ID__c, userId: userId}).then((data) => {
            if(!data){
                window.location.href = BasePath + "/error";
            }else{  
                this.isLoading = false
            }
        });

        //get the the WebCart data
        getCartData({ externalId: this.parameters.WebcartExternal_ID__c, userId: userId }).then((data) => {
            this.contactEmail = this.parameters.Email?this.parameters.Email:data.contactEmail;
            this.cartId = data.cartId;
            this.cartItems = data.cartItemsList;
            this.subTotal = data.subTotal;
            this.discountTotal = data.discountTotal?data.discountTotal:0;
            this.grandTotal = data.grandTotal;
            this.paymentMethod = data.paymentMethod;
            this.cartPayment = data.cartPayment;

            //check if the full amount was paid for Pay Now method
            if( this.paymentMethod == 'Pay Now' && this.parameters.TotalAmount == this.grandTotal) {
                this.paidInFull = 'Yes';
            }


            //update the WebCart
            updateWebCart({ 
                cartId: this.cartId, 
                paymentStatus: this.paymentStatus, 
                invoice: this.parameters.InvoiceNo,
                receipt: this.parameters.ReceiptNo,
                amountPaid: this.parameters.TotalAmount,
                paymentUrl: window.location.href,
                email: this.parameters.Email
            }).then((data) => {
                this.dispatchEvent(
                    new CustomEvent("cartchanged", {
                      bubbles: true,
                      composed: true
                    })
                  );
            }).catch((error) => {
                console.log("updateWebCart error");
                console.log(error);
            });

            // //if the payment is approved
            //only add course connection when cart is updated to close
            if(this.parameters.Status == 'A'){
                //create course connection record
                createCourseConnection({ 
                    cartId: this.cartId, 
                    userId: userId, 
                    amount: parseFloat(this.parameters.TotalAmount), 
                    tranId: this.parameters.WebcartExternal_ID__c,
                    paymentMethod: this.paymentMethod,
                    paidInFull: this.paidInFull
                }).then(() => {
                }).catch((error) => {
                    console.log("createCourseConnection error");
                    console.log(error);
                });
            }

            let fields = {};
            fields[ID_FIELD.fieldApiName] = this.cartPayment;
            fields[PAYMENT_STATUS_FIELD.fieldApiName] = this.paymentStatus;
            fields[EMAIL_FIELD.fieldApiName] = this.parameters.Email?this.parameters.Email:this.contactEmail;
            fields[INVOICE_FIELD.fieldApiName] = this.parameters.InvoiceNo;
            fields[RECEIPT_FIELD.fieldApiName] = this.parameters.ReceiptNo;
            fields[STATUS_FIELD.fieldApiName] = 'Closed';
            fields[AMOUNT_PAID.fieldApiName] = this.parameters.TotalAmount;
            let recordInput = {fields};
            updateRecord(recordInput)

        }).catch((error) => {
            console.log("getCartData error");
            console.log(error);
        });

        this.publishLMS();
    }

    //function to get the parameters from the url
    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        //converts the url after the '?' to a json
        if (search) {

            //replace to remove . in json key 
            search = search.replace(/Webcart.External_ID__c/g, 'WebcartExternal_ID__c');

            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }
    
    //button at the bottom is clicked
    buttonClicked(){

        //if payment is approved, button will redirect to the products page
        if(this.paymentApproved){
            window.location.href = BasePath + "/category/products/" + this.productCategData.data.Id;

        //else button will redirect to cart summary 
        } else {
            window.location.href = BasePath + "/cart/" + this.cartId;
        }
    }

    publishLMS() {
      let paramObj = {
        productId: 1,
        productName: 'Payment confirmation',
        clearOtherMenuItems: true
      }
      
      const payLoad = {
        parameterJson: JSON.stringify(paramObj)
      };
  
      publish(this.messageContext, payloadContainerLMS, payLoad);
    }
}