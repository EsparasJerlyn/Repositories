/**
 * @description A LWC component to display product child details
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | keno.domienri.dico        | May 24, 2022          | DEPP-2038            | Create payment method lwc                    |
 */
import { LightningElement, api } from 'lwc';
import Base_URL_SIT_UAT from "@salesforce/label/c.Base_URL_SIT_UAT";
import Base_URL_Prod from "@salesforce/label/c.Base_URL_Prod";
import Payment_GLCode from "@salesforce/label/c.Payment_GLCode";
import getCommunityUrl from '@salesforce/apex/RegistrationFormCtrl.getCommunityUrl';
 
// Base Urls
const baseUrlSIT = Base_URL_SIT_UAT;
const baseUrlProd = Base_URL_Prod;

export default class Payment extends LightningElement {
   
    /**
     * URL variables
     */
    typeURL = "SIT"; 
    getURL = window.location.origin;
    baseURL;
    formURL;

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
    glCode = Payment_GLCode; 

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

        /**
         * Set URL Type 
        */
        let domain;
        getCommunityUrl().then((res)=> {
            domain = res.comURL[0].Domain.split("-");
                       
            if('sit' == domain[0].toLowerCase()){
                this.typeURL = "SIT";
            }else if( 'uat' == domain[0].toLowerCase()){
                this.typeURL = "SIT"; 
            }else{
                this.typeURL = "PROD";
            }
        });    
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
        this.formURL = `tran-type=` + `OPE0001` + `&` +
        /** 
         * Passed Parameters 
         **/
            `OPETRANSACTIONID=` + this.cartExternalId + `&` + 
            `EMAIL=` + this.contactEmail.replace('@','%40') + `&` + 
            `FULLNAME=` + this.fullName + `&` + 
            `GLCODE=` + this.glCode + `&` + 
            `UNITAMOUNTINCTAX=` + this.total;
         

        if (this.typeURL = "SIT"){
            this.baseURL = baseUrlSIT;
        } else {
            this.baseURL = baseUrlProd;
        }

        this.dispatchEvent(new CustomEvent('paynow'));
        return this.baseURL + this.formURL;       
    }

    /**
     * Get Invoice button link
     */
    get invoiceURL(){
        this.formURL = `tran-type=` + `OPE0002` + `&` +  
        /** 
         * Passed Parameters 
         **/
            `OPETRANSACTIONID=` + this.cartExternalId + `&` + 
            `EMAIL=` + this.contactEmail.replace('@','%40') + `&` + 
            `FULLNAME=` + this.fullName + `&` + 
            `GLCODE=` + this.glCode + `&` + 
            `UNITAMOUNTINCTAX=` + this.total;
        
        if (this.typeURL = "SIT"){
            this.baseURL = baseUrlSIT;
        } else {
            this.baseURL = baseUrlProd;
        }

        return this.baseURL + this.formURL;        
    }

}