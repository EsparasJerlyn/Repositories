import { LightningElement, api } from 'lwc';

// Base Urls
const baseUrlSIT = "https://qut-dev.xetta.com/onestopweb/qutopeintegration/tranadd?";
const baseUrlProd = "https://pay.qut.edu.au/qutopeintegration/tranadd?";


export default class Payment extends LightningElement {
    
    typeURL = "SIT"; // URL Type SIT/Prod
    baseURL;
    formURL;

    // Passed Parameters
    @api cartExternalId; // Cart.External_Id__c
    @api disablePayment;
    @api contactFname; // uncommented
    @api contactLname; // uncommented
    @api contactEmail;
    @api total; // from parameters

    fullName; // Contact.FirstName + Contact.LastName
    glCode = `182003-0001-2402-58-0-0-1`; 

    // Test Parameters
    stransID = `e971aeb5-52da-ddb3-4990-67d28804f10a`; // Cart.External_Id__c
    scEmail = `k.guy@qut.edu.au` //`k.guy%40qut.edu.au`; // Contact.Email
    sfullName = `Kate Hanrahan` //`Kate+Hanrahan`; // Contact.FirstName + Contact.LastName
    sglCode = `182003-0001-2402-58-0-0-1`; 
    sunitAmount = `5000.00`; // Amount Paid

    // Labels
    header;
    subheader;
    payTitle;
    payLabel;
    invoiceTitle;
    invoiceLabel;
    
    connectedCallback(){
        // Get texts
        this.header = 'Payment method';
        this.subheader = 'How would you like to pay?';
        this.payTitle = 'Pay now';
        this.payLabel = 'Submit your payment now';
        this.invoiceTitle = 'Invoice';
        this.invoiceLabel = 'Generate an invoice that you can send to your nominated payee';
        this.fullName = this.contactFname + ' ' + this.contactLname;

        console.log('email: ' + this.contactEmail);
        console.log('fname: ' + this.contactFname);
        console.log('lname: ' + this.contactLname);
        console.log('externalId: ' + this.cartExternalId);
        console.log('fromCartSummary: ' + this.fromCartSummary);
        
    }

    get isFromCartSummary(){
        return this.fromCartSummary;
    }

    get disableButton(){
        console.log('disablebutton: ' + this.disablePayment);
        return this.disablePayment;
    }

    get payURL(){
        this.formURL = `tran-type=` + `OPE0001` + `&` +
        /** Test Parameters   
            `OPETRANSACTIONID=` + this.stransID + `&` + 
            `EMAIL=` + this.scEmail.replace('@','%40') + `&` + 
            `FULLNAME=` + this.sfullName + `&` + 
            `GLCODE=` + this.sglCode + `&` + 
            `UNITAMOUNTINCTAX=` + this.sunitAmount;
        **/                
        /** Passed Parameters */
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

    //    console.log("PayURL:" + this.baseURL + this.formURL);
        this.dispatchEvent(new CustomEvent('paynow'));
        return this.baseURL + this.formURL;       
    }

    get invoiceURL(){
        this.formURL = `tran-type=` + `OPE0002` + `&` +

        /** Test Parameters *
            `OPETRANSACTIONID=` + this.stransID + `&` +
            `EMAIL=` + this.scEmail.replace('@','%40') + `&` +
            `FULLNAME=` + this.sfullName + `&` +
            `GLCODE=` + this.sglCode + `&` +
            `UNITAMOUNTINCTAX=` + this.sunitAmount;
        */            
        /** Passed Parameters */
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

    //    console.log("InvoiceURL:" + this.baseURL + this.formURL);
        return this.baseURL + this.formURL;        
    }

}