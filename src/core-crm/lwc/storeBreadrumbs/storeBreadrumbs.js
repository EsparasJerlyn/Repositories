import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";

export default class StoreBreadrumbs extends LightningElement {

    @api
    recordId;

    /**
     * fetches product data
     */
    @wire(getRecord, { recordId:'$recordId', fields: [NAME_FIELD]})
    product;


    connectedCallback() {
        //this._resolveConnected();
        //Promise.all([loadStyle(this, QUTMainCSS + "/QUTMainCSS.css")]);
        this.iconhome = qutResourceImg + "/QUTImages/Icon/icon-home.svg";	
    } 

    /**
     * gets product name
     */
     get prodName() {
        return getFieldValue(this.product.data, NAME_FIELD);
    }

    changeTextDecorNone(event){
        const el = event.target;
        el.setAttribute('style', 'text-decoration:none');
    }

    changeTextDecorUnderline(event){
        const el = event.target;
        el.setAttribute('style', 'text-decoration:underline');
    }

     

}