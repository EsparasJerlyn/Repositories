import { LightningElement, api, track, wire } from "lwc";
import getOPEProductCateg from "@salesforce/apex/PaymentConfirmationCtrl.getOPEProductCateg";
import getCartData from "@salesforce/apex/PaymentConfirmationCtrl.getCartData";
import createCourseConnection from "@salesforce/apex/PaymentConfirmationCtrl.createCourseConnection";
import BasePath from "@salesforce/community/basePath";
import userId from "@salesforce/user/Id";

export default class PaymentConfirmation extends LightningElement {
    @api recordId;
    @track prodCategId;
    @track subHeader;
    @track subHeaderClass = 'heading2 pb2 subheader-color-err';
    @track paymentApproved = false;
    @track buttonLabel = 'Return cart summary'
    
    cartId;
    cartItems = [];
    subTotal;
    discountTotal;
    grandTotal;
    parameters = {};

    //to get the product category Id
    @wire(getOPEProductCateg)
    productCategData;

    connectedCallback() {

        //get the parameters from the url
        this.parameters = this.getQueryParameters();
        
        //set the subheader based on the status returned by QUT Pay
        if(this.parameters.Status == 'A'){
            this.subHeader = 'Your purchase was successful!';
            this.paymentApproved = true;
            this.subHeaderClass = 'heading2 pb2 subheader-color-suc';
            this.buttonLabel = 'Browse more courses'

        } else if(this.parameters.Status == 'D'){
            this.subHeader = 'Your payment was declined. Please check your payment details.';

        } else if(this.parameters.Status == 'C'){
            this.subHeader = 'Your payment was cancelled. Please check your payment details.';

        } else if(this.parameters.Status == 'V'){
            this.subHeader = 'Your payment has a validation failure. Please check your payment details.';

        }

        //get the the WebCart data
        getCartData({ externalId: this.parameters.TransactionID }).then((data) => {
            this.cartId = data.cartId;
            this.cartItems = data.cartItemsList;
            this.subTotal = data.subTotal;
            this.discountTotal = data.discountTotal;
            this.grandTotal = data.grandTotal;

            //if the payment is approved
            if(this.parameters.Status == 'A'){

                //create course connection record
                createCourseConnection({ cartId: this.cartId, userId: userId, amount: parseFloat(this.parameters.TotalAmount), tranId: this.parameters.TransactionID }).then((data) => {

                    //code

                }).catch((error) => {
                    console.log("createCourseConnection error");
                    console.log(error);
                });
            }

        }).catch((error) => {
            console.log("getCartData error");
            console.log(error);
        });
    }

    //function to get the parameters from the url
    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        //converts the url after the '?' to a json
        if (search) {
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
}