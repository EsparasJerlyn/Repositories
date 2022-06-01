import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import getProducts from '@salesforce/apex/ProductCtrl.getProducts';

export default class StoreBreadrumbs extends LightningElement {

    @api
    recordId;
    dataId;
    dataName;
    forYouLink;

    connectedCallback() {
        this.iconhome = qutResourceImg + "/QUTImages/Icon/icon-home-blue.svg";
        let currentUrl = window.location.href;
        this.recordId = currentUrl.substr(currentUrl.length - 18);
        let productIds =  [
            this.recordId
        ];
        getProducts({
            productIds: productIds
        }).then(result => {
            if(result.productList.length > 0){
                this.dataName = result.productList[0].childProdName;
            }
        }).catch(
            // do nothing
        );
        this.forYouLink = document.referrer;
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