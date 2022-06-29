/**
 * @description A LWC component to display product child details
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 |---------------------------|-----------------------|----------------------|----------------------------------------------|
| keno.domienri.dico        | May 24, 2022          | DEPP-2038            | Create payment method lwc                    |
| marlon.vasquez            | June 10, 2022         | DEPP-2812            | Cart Summary Questionnaire                   |
| roy.nino.s.regala         | June 30, 2022         | DEPP-3157            | fixed questionnaire issues                   |

*/
import { LightningElement, api, wire, track } from 'lwc';
import getPaymentGatewaySettings from '@salesforce/apex/PaymentGatewayCtrl.getPaymentGatewaySettings';
import userId from "@salesforce/user/Id";
import { createRecord,updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PAYMENT_URL_FIELD from '@salesforce/schema/WebCart.Payment_URL__c';
import STATUS_FIELD from '@salesforce/schema/WebCart.Status';
import ID_FIELD from '@salesforce/schema/WebCart.Id';
import CART_PAYMENT_FIELD from '@salesforce/schema/WebCart.Cart_Payment__c';
import PAYMENT_METHOD from '@salesforce/schema/WebCart.Payment_Method__c';
import PAYMENT_STATUS_FIELD from '@salesforce/schema/Cart_Payment__c.Payment_Status__c';
import CARTPAYMENT_ID_FIELD from '@salesforce/schema/Cart_Payment__c.Id';
import getOPEProductCateg from "@salesforce/apex/PaymentConfirmationCtrl.getOPEProductCateg";
import saveCartSummaryQuestions from "@salesforce/apex/CartItemCtrl.saveCartSummaryQuestions";
import BasePath from "@salesforce/community/basePath";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
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
    @api discountApplied;
    @api cartItems;
    @api fromCartSummary;
    @api numberOfParticipants;
    @track prodCategId;
    responseDataList;
    fileUploadData = [];
    answerRecordsList = [];
    paymentCartItems = [];
    selectedCourseOffering;
    fullName; 
    processing = false;
    regQuestionsWithNoResponse = true;
    /**
     * Labels
     */ 
    header;
    subheader;
    payTitle;
    payLabel;
    invoiceTitle;
    invoiceLabel;
    cartPaymentId;

    /**
     * Payment Options
     */
    @api hasPayNow;
    @api hasInvoice;

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

    @wire(getOPEProductCateg)
    productCategData({ error, data }) { 
        if(data){

            this.prodCategId = data.Id;
            
        } else if (error) {
            console.log("getOPEProductCateg error");
            console.log(error);
        }
    }

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
        return this.disablePayment || this.processing || this.cartIsClosed || this.cartIsEmpty || this.questionsNotFilled;
    }

    get questionsNotFilled(){

        let cartItemsCopy = JSON.parse(JSON.stringify(this.cartItems));
        let noAnswer = false;
        if(cartItemsCopy && cartItemsCopy.length > 0 && this.fromCartSummary){
            cartItemsCopy.map((row) => {
                if( row.relatedAnswers && 
                    row.relatedAnswers.filter((item) => item.Answer == '') &&
                    row.relatedAnswers.filter((item) => item.Answer == '').length > 0){
                        noAnswer = true;
                }
            })
        }

        return noAnswer;
    }

    /**
     * Get Pay Now button link
     */
    get payURL(){
        this.formURL = `tran-type=` + this.transtypePayNow + `&` +  
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

    createAnswerRecord(questions) {
        let answerRecords = {};
        answerRecords = questions.map((item) => {
            let record = {};
            record.Related_Answer__c = item.Id;
            record.Response__c = item.Answer;
            record.Sequence__c = item.Sequence;
            record.Questionnaire__c = item.QuestionnaireId;
            return record;
        });
        return answerRecords;
    }

    createFileUploadMap(questions){
        let fileUpload = [];
        fileUpload = questions.map(item =>{
            if(item.IsFileUpload){
                let record = {};
                record.RelatedAnswerId = item.Id;
                record.Base64 = item.FileData.base64;
                record.FileName = item.FileData.filename;
                return record;
            }
        });
        
        return fileUpload.filter(key => key !== undefined)?fileUpload.filter(key => key !== undefined):fileUpload;
    }

    payNowClick(){
        this.processing = true;
        this.paymentCartItems = JSON.parse(JSON.stringify(this.cartItems));
        if(this.fromCartSummary){
            let questionnaireResponseDataList = [];
            let contactId = '';
            this.paymentCartItems.map((row)=>{
                let questionnaireResponseData = {};
                if(row.relatedAnswers && row.relatedAnswers.length > 0){
                    questionnaireResponseData['answerList'] = this.createAnswerRecord(row.relatedAnswers);
                    questionnaireResponseData['relatedAnswerList'] = row.relatedAnswers;
                
                    if(this.createFileUploadMap(row.relatedAnswers).length > 0){
                        questionnaireResponseData['fileUploadData'] = this.createFileUploadMap(row.relatedAnswers);
                    }else{
                        questionnaireResponseData['fileUploadData'] = [];
                    }

                    questionnaireResponseData['offeringId'] = row.courseOfferingId?row.courseOfferingId:row.programOfferingId;
                    questionnaireResponseData['isPrescribed'] = row.courseOfferingId?false:true;
                    
                    contactId = row.contactId;
                    questionnaireResponseDataList.push(questionnaireResponseData);
                }
                
            });

            if(questionnaireResponseDataList.length > 0){
                saveCartSummaryQuestions({questionnaireData:JSON.stringify(questionnaireResponseDataList),contactId:contactId}).then(()=>{
                })
                .catch((error) => {
                    this.processing = false;
                    console.log("createquestionnaireresponse error");
                    console.log(error);
                })
            }
        }

        let fields = {'Status__c' : 'Checkout','Discount_Applied__c' : this.discountApplied};
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
    }

    invoiceClick(){
        this.processing = true;
        //update the cart with the payment method selected
        this.paymentCartItems = JSON.parse(JSON.stringify(this.cartItems));
        if(this.fromCartSummary){
            let questionnaireResponseDataList = [];
            let contact = '';
            this.paymentCartItems.map((row)=>{
                let questionnaireResponseData = {};
                if(row.relatedAnswers && row.relatedAnswers.length > 0){
                    questionnaireResponseData['answerList'] = this.createAnswerRecord(row.relatedAnswers);
                    questionnaireResponseData['relatedAnswerList'] = row.relatedAnswers;
                
                    if(this.createFileUploadMap(row.relatedAnswers).length > 0){
                        questionnaireResponseData['fileUploadData'] = this.createFileUploadMap(row.relatedAnswers);
                    }else{
                        questionnaireResponseData['fileUploadData'] = [];
                    }

                    questionnaireResponseData['offeringId'] = row.courseOfferingId?row.courseOfferingId:row.programOfferingId;
                    questionnaireResponseData['isPrescribed'] = row.courseOfferingId?false:true;
                    
                    contact = row.contactId;
                    questionnaireResponseDataList.push(questionnaireResponseData);
                }
                
            });

            if(questionnaireResponseDataList.length > 0){
                saveCartSummaryQuestions({questionnaireData:JSON.stringify(questionnaireResponseDataList),contactId:contact}).then(()=>{
                })
                .catch((error) => {
                    this.processing = false;
                    console.log("createquestionnaireresponse error");
                    console.log(error);
                })
            }
        }
        
        let cartIds = []; 

        this.paymentCartItems.map(row => {
            cartIds.push(row.cartItemId);
        });

        //create cart payment records
        let fields = {'Status__c' : 'Invoiced', 'Discount_Applied__c' : this.discountApplied};
        let objRecordInput = {'apiName':'Cart_Payment__c',fields};
        createRecord(objRecordInput).then(response => {
            //update webcart and link the created cart payment record
            this.cartPaymentId = response.id;
            let fields = {};
            fields[ID_FIELD.fieldApiName] = this.cartId;
            fields[CART_PAYMENT_FIELD.fieldApiName] = this.cartPaymentId;
            fields[PAYMENT_URL_FIELD.fieldApiName] = this.invoiceURL;
            fields[PAYMENT_METHOD.fieldApiName] = 'Invoice';
            fields[STATUS_FIELD.fieldApiName] = 'Closed';
            let recordInput = {fields};
            updateRecord(recordInput)
            .then(()=>{
                //update payment status of cartpayment
                //so that cart payment trigger can proccess child cart items
                let fields = {};
                fields[CARTPAYMENT_ID_FIELD.fieldApiName] = this.cartPaymentId;
                fields[PAYMENT_STATUS_FIELD.fieldApiName] = 'Invoiced';
                let recordInput = {fields};
                updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new CustomEvent("cartchanged", {
                            bubbles: true,
                            composed: true
                        })
                    );

                    //redirect to for you page and open the xetta page in new tab
                    window.open(this.invoiceURL, '_blank');
                    window.location.href = BasePath + "/category/products/" + this.prodCategId;
                    
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