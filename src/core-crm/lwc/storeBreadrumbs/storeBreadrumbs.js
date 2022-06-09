import { LightningElement, wire, api,track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import communityId from '@salesforce/community/Id';
import basePath from '@salesforce/community/basePath';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import getStudyProducts from '@salesforce/apex/MainNavigationMenuCtrl.getStudyProducts';
//import getProducts from '@salesforce/apex/ProductCtrl.getProducts';

import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';
const STOREBREADCRUMBS_PARENTLIST = 'storeBreadrumbs_parentList';
export default class StoreBreadrumbs extends LightningElement {

    @api recordId;
    @track categoryId;
    categoryName;
    error;
    forYouLink;
    // dataName;
    subscription;
    menuList = [];
    parentProductList = [];

    @wire(MessageContext)
    messageContext;

    /**
     * fetches product data
     */
    @wire(getRecord, { recordId:'$recordId', fields: [NAME_FIELD]})
    product;

    connectedCallback() {
        this.iconhome = qutResourceImg + "/QUTImages/Icon/icon-home-blue.svg";
        // this.init();
        this.getSsItem();
        this.subscribeLMS();
    }

    disconnectedCallback() {
        this.unsubscribeLMS();
    }

    unsubscribeLMS(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
    // async init() {
    //     this.recordId = await this.getRecordId();
    //     let productIds =  [
    //         this.recordId
    //     ];
    //     getProducts({
    //         productIds: productIds
    //     }).then(result => {
    //         if(result.productList.length > 0){
    //             this.dataName = result.productList[0].childProdName;
    //         }
    //     });
    // }

    getRecordId(){
        let currentUrl = window.location.href;
        return currentUrl.substr(currentUrl.length - 18);
    }

    // get nameFind() {
    //     if(this.dataName){
    //             return this.dataName;
    //     } else {
    //         return '';
    //     }
    // }
    
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

    subscribeLMS() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, payloadContainerLMS, (message) => this.validateValue(message));
        }
    }

    validateValue(val) {
        if (val && val.parameterJson) {
            let newValObj = JSON.parse(val.parameterJson);

            //check if the payload contains clearMenuList from searchResult.js then clear the list
            let clearMenuList = newValObj.clearMenuList ? String(newValObj.clearMenuList).toUpperCase() == 'TRUE' : false;
            if(clearMenuList){
                this.clearMenuList();
                return;
            }

            //check if the payload contains clearOtherMenuItems from cartDetails.js / paymentConfirmation.js then clear the list but conrinue adding an item
            let clearOtherMenuItems = newValObj.clearOtherMenuItems ? String(newValObj.clearOtherMenuItems).toUpperCase() == 'TRUE' : false;
            if(clearOtherMenuItems){
                this.clearMenuList();
            }

            newValObj.isProgramFlex = newValObj.isProgramFlex ? String(newValObj.isProgramFlex).toUpperCase() == 'TRUE' : false;

            this.addToMenuList(newValObj);
            this.setProductUrl();
        }
    }

    addToMenuList(newValObj){
        this.getSsItem();
        let productArr = this.parentProductList.filter(e => e.productId == newValObj.productId);
        
        //check for duplicate product name
        if (productArr && productArr[0]) {
            let existingParentArr = this.menuList.filter(e => e.productId == productArr[0].parentId);
            
            if (!existingParentArr || (existingParentArr && !existingParentArr[0])) {
                //build object for parent
                let parentObj = {
                    productId: productArr[0].parentId,
                    productName: productArr[0].parentName,
                    productUrl: productArr[0].parentUrl
                };
                
                this.menuList = [...this.menuList, parentObj];
            }
            
            let existingProductArr = this.menuList.filter(e => e.productId == newValObj.productId);
            if (!existingProductArr || (existingProductArr && !existingProductArr[0])) {
                this.menuList = [...this.menuList, newValObj];
            }
        } else {
            this.menuList = [...this.menuList, newValObj];
        }
    }

    clearMenuList() {
        this.menuList = [];
    }

    setProductUrl() {
        let urlRecordId = window.location.pathname ? window.location.pathname.substring(window.location.pathname.lastIndexOf('/') + 1) : undefined;
        
        let tempList = [];
        if (urlRecordId) {
            this.menuList.forEach(e => {
                if (e.productId == urlRecordId && e.isProgramFlex) {
                    e.productUrl = window.location.pathname;
                    
                    if(e.children && Array.isArray(e.children) && e.children.length > 0){
                        e.children.forEach(j => {
                            let obj = {
                                productId: j.childProdId,
                                productName: j.childProdName,
                                parentId: e.productId,
                                parentName: e.productName,
                                parentUrl: e.productUrl
                            };

                            let existingArr = tempList.filter(k => k.productId == obj.productId);
                            if(!existingArr || (existingArr && !existingArr[0])){
                                tempList = [...tempList, obj];
                            }
                        });
                    }
                }
            });
        }
        
        if(tempList.length > 0){
            this.setSsItem(JSON.stringify(tempList));
        }
        
        if (this.menuList.length == 1) {
            this.menuList[0].productUrl = undefined;
        }
    }

    handleMenuClick(event) {
        let menuRecordId = event.target.dataset.productid;
        
        if (menuRecordId) {
            this.removeChildrenFromMenuList(menuRecordId);
        }
    }

    removeChildrenFromMenuList(productId){
        let index = this.menuList.findIndex(e => e.productId == productId);

        if(index > -1){
            //remove all preceding array elements after this matching element
            this.menuList = this.menuList.slice(0, index + 1);

            this.setProductUrl();
        }
    }

    getSsItem(){
        let strJson = sessionStorage.getItem(STOREBREADCRUMBS_PARENTLIST);
        if(strJson){
            this.parentProductList = JSON.parse(strJson);
        }
    }
    
    setSsItem(val){
        sessionStorage.setItem(STOREBREADCRUMBS_PARENTLIST, val);
    }
}