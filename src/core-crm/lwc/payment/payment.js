/**
 * @description A LWC component to display product child details
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
	  |---------------------------|-----------------------|----------------------|----------------------------------------------|
	  | keno.domienri.dico        | May 24, 2022          | DEPP-2038            | Create payment method lwc                    |
 */
import { LightningElement, api, wire } from 'lwc';
import getPaymentGatewaySettings from '@salesforce/apex/PaymentGatewayCtrl.getPaymentGatewaySettings';

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
    @api cartExternalId; 
    @api disablePayment;
    @api contactFname; 
    @api contactLname; 
    @api contactEmail;
    @api total; 
    fullName; 

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
        this.fullName = this.contactFname + '+' + this.contactLname;
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

    /**
     * Disable payment buttons if checkbox from Cart Summary is false
     */
    get disableButton(){
        console.log('disablebutton: ' + this.disablePayment);
        return this.disablePayment;
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
            `FULLNAME=` + this.fullName + `&` + 
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
            `OPETRANSACTIONID=` + this.cartExternalId + `&` + 
            `FULLNAME=` + this.fullName + `&` + 
            `GLCODE=` + this.glCode + `&` + 
            `UNITAMOUNTINCTAX=` + this.total;
        return this.baseURL + this.formURL;        
    }

}
      