import { LightningElement, api, track, wire } from "lwc";
import getOPEProductCateg from "@salesforce/apex/PaymentConfirmationCtrl.getOPEProductCateg";
import getCartData from "@salesforce/apex/PaymentConfirmationCtrl.getCartData";
import createCourseConnection from "@salesforce/apex/PaymentConfirmationCtrl.createCourseConnection";
import updateWebCart from "@salesforce/apex/PaymentConfirmationCtrl.updateWebCart";
import BasePath from "@salesforce/community/basePath";
import userId from "@salesforce/user/Id";
import checkCartOwnerShip from "@salesforce/apex/PaymentConfirmationCtrl.checkCartOwnerShip";

import { publish, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';

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
    paidInFull = 'No';
    parameters = {};
    isLoading = true;

    //to get the product category Id
    @wire(getOPEProductCateg)
    productCategData;

    @wire(MessageContext)
    messageContext;

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
            this.contactEmail = data.contactEmail;
            this.cartId = data.cartId;
            this.cartItems = data.cartItemsList;
            this.subTotal = data.subTotal;
            this.discountTotal = data.discountTotal?data.discountTotal:0;
            this.grandTotal = data.grandTotal;
            this.paymentMethod = data.paymentMethod;

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
                paymentUrl: window.location.href
            }).then((data) => {
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
                    }).then((data) => {
    
                        //code
    
                    }).catch((error) => {
                        console.log("createCourseConnection error");
                        console.log(error);
                    });
                }

            }).catch((error) => {
                console.log("updateWebCart error");
                console.log(error);
            });

            // //if the payment is approved
            

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