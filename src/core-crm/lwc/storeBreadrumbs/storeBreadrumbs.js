import { LightningElement, wire, api,track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import communityId from '@salesforce/community/Id';
import basePath from '@salesforce/community/basePath';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import getStudyProducts from '@salesforce/apex/MainNavigationMenuCtrl.getStudyProducts';
import getProducts from '@salesforce/apex/ProductCtrl.getProducts';

export default class StoreBreadrumbs extends LightningElement {

    @api recordId;
    @track categoryId;
    categoryName;
    error;
    forYouLink;
    dataName;

    /**
     * fetches product data
     */
    @wire(getRecord, { recordId:'$recordId', fields: [NAME_FIELD]})
    product;

    connectedCallback() {
        this.iconhome = qutResourceImg + "/QUTImages/Icon/icon-home-blue.svg";
        this.init();   
    } 
    async init() {
        this.recordId = await this.getRecordId();
        let productIds =  [
            this.recordId
        ];
        getProducts({
            productIds: productIds
        }).then(result => {
            console.log('bread crumbs', result);
            if(result.productList.length > 0){
                this.dataName = result.productList[0].childProdName;
            }
        });
        
    }
    getRecordId(){
        let currentUrl = window.location.href;
        return currentUrl.substr(currentUrl.length - 18);
    }
    get nameFind() {
        if(this.dataName){
                return this.dataName;
        } else {
            return '';
        }
    }
    get forYouURL() {
        if(this.categoryName && this.categoryId){
            return basePath+'/category/'+this.categoryName.replaceAll(' ','-').toLowerCase()+'/'+this.categoryId.slice(0, -3);
        } else {
            return '#';
        }
    }
    changeTextDecorNone(event){
        const el = event.target;
        el.setAttribute('style', 'text-decoration:none');
    }
    changeTextDecorUnderline(event){
        const el = event.target;
        el.setAttribute('style', 'text-decoration:underline');
    }
    @wire(getStudyProducts,{communityId:communityId})
    handleGetStudyProducts(result){    
        if(result.data){
            this.categoryName = result.data[0].Name;
            this.categoryId = result.data[0].Id;
        } else {
        }
    }
}