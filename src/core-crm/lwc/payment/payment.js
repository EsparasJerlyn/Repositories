/**
 * @description A LWC component to display product child details
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 |---------------------------|-----------------------|----------------------|----------------------------------------------|
| keno.domienri.dico        | May 24, 2022          | DEPP-2038            | Create payment method lwc                    |
| marlon.vasquez            | June 10, 2022         | DEPP-2812            | Cart Summary Questionnaire                   |

*/
import { LightningElement, api, wire } from 'lwc';
import getPaymentGatewaySettings from '@salesforce/apex/PaymentGatewayCtrl.getPaymentGatewaySettings';
import updatePaymentMethod from "@salesforce/apex/CartItemCtrl.updatePaymentMethod";
import addRegistration from '@salesforce/apex/ProductDetailsCtrl.addRegistration';
import getCartItemsByCart from "@salesforce/apex/CartItemCtrl.getCartItemsByCart";
import userId from "@salesforce/user/Id";
import createCourseConnections from '@salesforce/apex/CartItemCtrl.createCourseConnection';
import { createRecord,updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PAYMENT_URL_FIELD from '@salesforce/schema/WebCart.Payment_URL__c';
import STATUS_FIELD from '@salesforce/schema/WebCart.Status';
import ID_FIELD from '@salesforce/schema/WebCart.Id';
import CART_PAYMENT_FIELD from '@salesforce/schema/WebCart.Cart_Payment__c';
import PAYMENT_METHOD from '@salesforce/schema/WebCart.Payment_Method__c';

export default class Payment extends LightningElement {

    /**
     * URL variables
     */
    getURL = window.location.origin;
    baseURL;
    formURL;
    error;

    /**
     * Static Parameters
     */
    glCode; 
    transtypeInvoice;
    transtypePayNow;

    /**
     *  Passed Parameters
     */ 
    @api cartId;
    @api cartExternalId; 
    @api disablePayment;
    @api contactFname; 
    @api contactLname; 
    @api contactEmail;
    @api total; 
    @api cartItems;
    @api fromCartSummary;
    @api numberOfParticipants;
    responseDataList;
    fileUploadData = [];
    answerRecordsList = [];
    paymentCartItems = [];
    selectedCourseOffering;
    fullName; 
    processing = false;
    /**
     * Labels
     */ 
    header;
    subheader;
    payTitle;
    payLabel;
    invoiceTitle;
    invoiceLabel;
    
    /**
     * Load Page labels
     */
    connectedCallback(){
        /**
         * Get texts
         */ 
        this.header = 'Payment method';
        this.subheader = 'How would you like to pay?';
        this.payTitle = 'Pay now';
        this.payLabel = 'Submit your payment now';
        this.invoiceTitle = 'Invoice';
        this.invoiceLabel = 'Generate an invoice that you can send to your nominated payee';
        this.fullName = this.contactFname + ' ' + this.contactLname;
    }

    @wire(getPaymentGatewaySettings)
    handleGetPaymentSettings(result){   
        if(result.data){
            this.baseURL = result.data.Payment_URL__c;
            this.glCode =  result.data.GL_Code__c;
            this.transtypeInvoice =  result.data.TransType_Invoice__c;
            this.transtypePayNow =  result.data.TransType_PayNow__c;
        } else {
            this.error = result.error;
        }
    }

    @wire(getRecord, { recordId: '$cartId', fields: [STATUS_FIELD]})
    currentCart;


    get cartIsClosed() {
        if(this.currentCart && this.currentCart.data){
            return getFieldValue(this.currentCart.data, STATUS_FIELD) === 'Closed'?true:false;
        }else{
            false;
        }
        
    }

    get cartIsEmpty() {
        //redirect to products if no more cart items
        if(this.cartItems.length == 0){
            return true;
        } else{
            return false;
        }
        
    }

    /**
     * Disable payment buttons if checkbox from Cart Summary is false
     */
    get disableButton(){
        return this.disablePayment || this.processing || this.cartIsClosed || this.cartIsEmpty;
    }

    /**
     * Get Pay Now button link
     */
    get payURL(){
        this.formURL = `tran-type=` + this.transtypePayNow + `&` +
        /** 
         * Passed Parameters 
         **/
            `OPETRANSACTIONID=` + this.cartExternalId + `&` + 
            `EMAIL=` + this.contactEmail.replace('@','%40') + `&` + 
            `FULLNAME=` + this.fullName.replace(/ /g,'%20') + `&` + 
            `GLCODE=` + this.glCode + `&` + 
            `UNITAMOUNTINCTAX=` + this.total;

        this.dispatchEvent(new CustomEvent('paynow'));
        return this.baseURL + this.formURL;       
    }

    /**
     * Get Invoice button link
     */
    get invoiceURL(){
        this.formURL = `tran-type=` + this.transtypeInvoice + `&` +  
        /** 
         * Passed Parameters 
         **/
            `OPETransactionID=` + this.cartExternalId + `&` + 
            `Email=` + this.contactEmail.replace('@','%40') + `&` + 
            `GLCode=` + this.glCode + `&`;

        //if from cart summary we are going to get the data for FullName from the passed parameter and adding in the URL only once
        if(this.fromCartSummary){
            this.formURL = this.formURL + `FullName=` + this.fullName.replace(/ /g,'%20') + `&`;
        }

        //looped url parameter based on the cart items
        let opeDescription = '';
        let cartItems;

        //get the cart items product properties
        cartItems = JSON.parse(JSON.stringify(this.cartItems));

        //loop on the cart items to get properties
        cartItems.forEach( currentCartItem => {

            //if not from cart summary, we have to get the contact name of the cart item from the Contact__c.Name
            if(!this.fromCartSummary){
                opeDescription = opeDescription + `FullName=` + currentCartItem.contactFullName.replace(/ /g,'%20') + `&`;
            }

            //populate string
            opeDescription = opeDescription + `OPEDescription=` + currentCartItem.productName.replace(/ /g,'%20') + `&` + 
            `UnitAmountIncTax=` + (currentCartItem.unitPrice - currentCartItem.unitDiscount)+ `&`;
            
        });

        return this.baseURL + this.formURL + opeDescription.slice(0, -1);        
    }

    payNowClick(){
        this.paymentCartItems = JSON.parse(JSON.stringify(this.cartItems));
        this.processing = true;
        if(this.fromCartSummary){
                let fields = {'Status__c' : 'Checkout'};
                let objRecordInput = {'apiName':'Cart_Payment__c',fields};
                createRecord(objRecordInput).then(response => {
                    let cartPaymentId = response.id;
                    let fields = {};
                    fields[ID_FIELD.fieldApiName] = this.cartId;
                    fields[CART_PAYMENT_FIELD.fieldApiName] = cartPaymentId;
                    fields[PAYMENT_URL_FIELD.fieldApiName] = this.payURL;
                    fields[PAYMENT_METHOD.fieldApiName] = 'Pay Now';
                    let recordInput = {fields};
                    updateRecord(recordInput).then(()=>{
                        window.location.href = this.payURL;
                    })
                })
                .catch((error) => {
                    this.processing = false;
                    console.log("create cartpayment error");
                    console.log(error);
                })
        }else{
            let fields = {'Status__c' : 'Checkout'};
                let objRecordInput = {'apiName':'Cart_Payment__c',fields};
                createRecord(objRecordInput).then(response => {
                    let cartPaymentId = response.id;
                    let fields = {};
                    fields[ID_FIELD.fieldApiName] = this.cartId;
                    fields[CART_PAYMENT_FIELD.fieldApiName] = cartPaymentId;
                    fields[PAYMENT_URL_FIELD.fieldApiName] = this.payURL;
                    fields[PAYMENT_METHOD.fieldApiName] = 'Pay Now';
                    let recordInput = {fields};
                    updateRecord(recordInput).then(()=>{
                        console.log(this.payURL);
                        window.location.href = this.payURL;
                    })
                })
                .catch((error) => {
                    this.processing = false;
                    console.log("create cartpayment error");
                    console.log(error);
                })
        }

        //update the cart with the payment method selected
        /*updatePaymentMethod({ cartId: this.cartId, paymentMethod: 'Pay Now' })
        .then(() => {
            window.location.href = this.payURL;
        })

            //code

        .catch((error) => {
            console.log("updatePaymentMethod error");
            console.log(error);
        });*/
    }

    invoiceClick(){

        //update the cart with the payment method selected
        this.paymentCartItems = JSON.parse(JSON.stringify(this.cartItems));
        this.processing = true;
        if(this.fromCartSummary){
            let cartIds = []; 
            let contactId;
            this.paymentCartItems.map(row => {
                cartIds.push(row.cartItemId);
                contactId = row.contactId;
            });
            let fields = {'Status__c' : 'Invoiced'};
            let objRecordInput = {'apiName':'Cart_Payment__c',fields};
            createRecord(objRecordInput).then(response => {
                let cartPaymentId = response.id;
                let fields = {};
                fields[ID_FIELD.fieldApiName] = this.cartId;
                fields[CART_PAYMENT_FIELD.fieldApiName] = cartPaymentId;
                fields[PAYMENT_URL_FIELD.fieldApiName] = this.invoiceURL;
                fields[PAYMENT_METHOD.fieldApiName] = 'Invoice';
                let recordInput = {fields};
                updateRecord(recordInput)
                .then(()=>{
                    let fields = {};
                    fields[ID_FIELD.fieldApiName] = this.cartId;
                    fields[STATUS_FIELD.fieldApiName] = 'Closed';
                    let recordInput = {fields};
                    updateRecord(recordInput)
                    .then(()=>{
                        createCourseConnections({cartItemIds:cartIds, contactId:contactId, paidInFull:'No', paymentMethod:'Invoice'})
                        .then(()=>{
                            this.dispatchEvent(
                                new CustomEvent("cartchanged", {
                                  bubbles: true,
                                  composed: true
                                })
                            );
                            window.location.href = this.invoiceURL;
                        })
                    })
                })
            })
            .catch((error) => {
                this.processing = false;
                console.log("createCourseConnections error");
                console.log(error);
            })
        }else{
            let cartIds = []; 
            let contactId;
            this.paymentCartItems.map(row => {
                cartIds.push(row.cartItemId);
                contactId = row.contactId;
            });
            let fields = {'Status__c' : 'Invoiced'};
            let objRecordInput = {'apiName':'Cart_Payment__c',fields};
            createRecord(objRecordInput).then(response => {
                let cartPaymentId = response.id;
                let fields = {};
                fields[ID_FIELD.fieldApiName] = this.cartId;
                fields[CART_PAYMENT_FIELD.fieldApiName] = cartPaymentId;
                fields[PAYMENT_URL_FIELD.fieldApiName] = this.invoiceURL;
                fields[PAYMENT_METHOD.fieldApiName] = 'Invoice';
                let recordInput = {fields};
                updateRecord(recordInput)
                .then(()=>{
                    let fields = {};
                    fields[ID_FIELD.fieldApiName] = this.cartId;
                    fields[STATUS_FIELD.fieldApiName] = 'Closed';
                    let recordInput = {fields};
                    updateRecord(recordInput)
                    .then(()=>{
                        createCourseConnections({cartItemIds:cartIds, contactId:contactId, paidInFull:'No', paymentMethod:'Invoice'})
                        .then(()=>{
                            this.dispatchEvent(
                                new CustomEvent("cartchanged", {
                                  bubbles: true,
                                  composed: true
                                })
                              );
                            window.location.href = this.invoiceURL;
                        })
                    })
                })
            })
            .catch((error) => {
                this.processing = false;
                console.log("createCourseConnections error");
                console.log(error);
            })
        }
    }

    saveRegistration(contact,courseOffering,relatedAnswer,answer,fileUpload){
        addRegistration({
            contactRecord:contact,
            courseOfferingId:courseOffering,
            relatedAnswerList:relatedAnswer,
            answerList:answer,
            fileUpload:fileUpload,
            forApplication:false
        })
        .then(() =>{
                this.generateToast(SUCCESS_TITLE, 'Successfully Submitted', SUCCESS_VARIANT);
                //refreshApex(this.tableData);
                
        })
        .finally(()=>{
    
        })
        .catch(error =>{
            
        });
    }
}