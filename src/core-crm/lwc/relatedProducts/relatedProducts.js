/**
 * @description Lightning Web Component for creation of Associated Product record from Product Request record page.
 * 
 * @see ../classes/AddAssociatedProductsCtrl.cls
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
 |---------------------------|-----------------------|----------------------|------------------------------|
| eccarius.karl.munoz       | November 09, 2021     | DEPP-671             | Created file                 | 
|                           |                       |                      |                              | 
*/

import { LightningElement, api, wire, track} from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getProducts from '@salesforce/apex/RelatedProductsCtrl.getProducts';
import addAssociatedProduct from '@salesforce/apex/AddAssociatedProductsCtrl.addAssociatedProduct';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PR_RECORD_TYPE from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';

const NO_REC_FOUND = 'No record(s) found.';
const DISPLAY_TBL_ERROR = 'Unable to display record(s).';
const SUCCESS_MSG = 'Record(s) successfully saved.';
const NO_CHANGES_TITLE = 'No product(s) to associate.';
const SUCCESS_RESPONSE = 'Success';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';

export default class RelatedProducts extends LightningElement {

    @api recordId;
    @api tab;

    productName ='';
    isLoading = false;
    noUnRelatedProducts = false;
    noRelatedProducts = false;
    error;  
    searchedProductList = [];   
    searchedProductListTemp = [];   
    productsToAssociate = [];  
    sortBy = 'isActive';
    sortDirection ='desc'; 
    activeSections = 'Related Products';
    errors;
    displayTableError;
    addOPEProducts = false;
    recordTypes = [];
    recordType = '';
    productRequestRecordType = '';
    enteredDiscount = '';
    productsToDiscount = [];
    @track isStatusCompleted;
    cceTableName = 'CCE Products';
    opeTableName = 'OPE Products';
    opeFilter = true;
    cceFilter = false;
    cceChildSelected = [];
    opeChildSelected = [];
    isSoa;

    opeColumns = [
        {
            fieldName: 'idUrl',
            label: 'Name',
            type: 'url',
            sortable:true,
            typeAttributes: {
                label: {
                    fieldName: 'productName'
                }
            }
        },
        {   label: 'Record Type', 
            fieldName: 'courseRecordType', 
            type: 'text',
            sortable:true
        },
        {   label: 'Status', 
            fieldName: 'status', 
            type: 'text',
            sortable:true
        },
        {   label: 'Start Date', 
            fieldName: 'startDate', 
            type: 'date',
            sortable:true
        },
        {   label: 'Active', 
            fieldName: 'isActive', 
            type: 'boolean',
            sortable:true,
            editable: {fieldName:"isEditable"}
        },
        {   label: 'Standard Price', 
            fieldName: 'standardPrice', 
            type: 'currency',
            sortable:true,
            typeAttributes: 
            {
                currencyCode:'AUD', 
                step: '0.001'
            }
        },
        {   label: 'Percentage Discount', 
            fieldName: 'formattedDiscount', 
            type: 'text',
            sortable:true,
            typeAttributes: 
            {
                step: '0'
            },
            editable: {fieldName:"isEditable"}
        },
        {   label: 'Final Discounted Price', 
            fieldName: 'ccePrice', 
            type: 'currency',
            sortable:true,
            typeAttributes: 
            {
                currencyCode:'AUD', 
                step: '0.001'
            },
            editable: {fieldName:"isEditable"}
        }
    ];

    cceColumns = [
        {
            fieldName: 'idUrl',
            label: 'Name',
            type: 'url',
            sortable:true,
            typeAttributes: {
                label: {
                    fieldName: 'productName'
                }
            }
        },
        {   label: 'Record Type', 
            fieldName: 'courseRecordType', 
            type: 'text',
            sortable:true
        },
        {   label: 'Status', 
            fieldName: 'status', 
            type: 'text',
            sortable:true
        },
        {   label: 'Start Date', 
            fieldName: 'startDate', 
            type: 'date',
            sortable:true
        },
        {   label: 'Standard Price', 
            fieldName: 'standardPrice', 
            type: 'currency',
            sortable:true,
            typeAttributes: 
            {
                currencyCode:'AUD', 
                step: '0.001'
            }
        },
        {   label: 'Percentage Discount', 
            fieldName: 'formattedDiscount', 
            type: 'text',
            sortable:true,
            typeAttributes: 
            {
                step: '0'
            },
            editable: {fieldName:"isEditable"}
        },
        {   label: 'Final Discounted Price', 
            fieldName: 'ccePrice', 
            type: 'currency',
            sortable:true,
            typeAttributes: 
            {
                currencyCode:'AUD',
                step: '0.001'
            },
            editable: {fieldName:"isEditable"}
        }
    ];

    searchColumns = [
        { label: 'Name', fieldName: 'productName', type: 'text', sortable: true},
        { label: 'Record Type', fieldName: 'courseRecordType', type: 'text',sortable: true},
        { label: 'Start Date', fieldName: 'startDate', type: 'date',sortable: true },
        { label: 'End Date', fieldName: 'endDate', type: 'date',sortable:true }
    ];

    /**
     * gets product request details
    */
     @wire(getRecord, {recordId: "$recordId",fields: [PR_RECORD_TYPE,PR_STATUS]})
     productRequestRecordResult(result)
     {
         if(result.data){
             this.productRequestRecordType =  getFieldValue(result.data, PR_RECORD_TYPE);
             this.isSoa = this.productRequestRecordType == 'Standing_Offer_Arrangement';
             this.isStatusCompleted =  getFieldValue(result.data, PR_STATUS) == PL_ProductRequest_Completed;
         }else if(result.error){
             this.generateToast('Error.',LWC_Error_General,'error');
         }
     }
     

    //Retrieves list of active OPE products
    searchedProducts;
    @wire(getProducts, {recordId : "$recordId"})
    wiredProducts(result) {
        this.isLoading = true;
        this.searchedProducts = result;
        if(result.data){            
            this.searchedProductList = JSON.parse(JSON.stringify(result.data));
            this.searchedProductListTemp = result.data;
            if(this.searchedProductList.length === 0){
                this.noUnRelatedProducts = true;
            }else{
                this.noUnRelatedProducts = false;
                for(let i in this.searchedProductList) {
                    if(!this.recordTypes.find(element => element.value == this.searchedProductList[i].courseRecordType )) {
                        this.recordTypes.push({ label: this.searchedProductList[i].courseRecordType, value: this.searchedProductList[i].courseRecordType });
                    }
                }
                this.recordTypes.sort();
                this.recordTypes.unshift({ label: 'All', value: '' });
            }

            this.error = undefined;
            this.isLoading = false;
        } else if(result.error){
            this.searchedProductList = undefined;
            this.searchedProductListTemp = undefined;
            this.error = result.error;
            this.isLoading = false;
        }    
    } 
    

    //Handles search filters for Product Name and Record Type     
    searchHandler(){
        if(this.productName || this.recordType){
            this.empty = false;
            this.searchedProductList = [...this.searchedProductListTemp];
            this.searchedProductList = this.searchedProductList
                .filter( product => product.productName.toLowerCase().includes(this.productName.toLowerCase()))
                .filter( product => product.courseRecordType && product.courseRecordType.includes(this.recordType)
            );
            if(this.searchedProductList.length === 0){
                this.empty = true;
            }
        }else{
            this.empty = false;
            this.searchedProductList = [...this.searchedProductListTemp];          
        }
    }

    //Search function for Product Name
    handleProductNameSearch(event){        
        this.productName = event.target.value; 
        this.searchHandler();
    }

    handleEnterDiscount(event){
        this.enteredDiscount = event.target.value;
    }

    //Row selection function for the datatable
    handelSelectedRowsOnSearch(event){
        this.productsToAssociate = event.detail.selectedRows;        
    }

    //Search function for Record Type
    handleRecordTypeSearch (event){ 
        this.recordType = event.detail.value; 
        this.searchHandler();
    }

    handleAddOPEProducts(){
        this.addOPEProducts = true;
        refreshApex(this.searchedProducts);
    }

    //Clears the fields after saving
    clearFields(){
        const recordType = this.template.querySelector("lightning-combobox");
        if(recordType){
            recordType.value = '';
        }
        this.productName = '';
        this.productsToAssociate = [];
    }

    //Handles creation of Associated Product(s) based on the selected rows
    handleAssociateProduct(){

        let response;
        let productIds = this.productsToAssociate.map(p => { 
            return p.id; 
        });
        if(this.productsToAssociate.length > 0){
            this.isLoading = true;
            addAssociatedProduct({ productIds : productIds, productRequestId : this.recordId })
                .then((result) => {
                    return response = result;
                })
                .then(()=>{
                    return refreshApex(this.searchedProducts);
                })
                .catch((error) => {                    
                    response = error;
                })
                .finally(() => {  
                    if(response === SUCCESS_RESPONSE){
                        this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
                    }else{
                        this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                    }
                    this.isLoading = false;
                });
        }else{
            this.generateToast(NO_CHANGES_TITLE, '', ERROR_VARIANT);
        }
    }

    //Function to generate toastmessage
    generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    //Sorts column for datatable
    handleSort(event) {
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection; 
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    handleCancel(){
        this.resetData()
        this.refreshChildData();
    }

    refreshChildData(){
        if(this.template.querySelectorAll("c-related-products-table")){
            this.template
            .querySelectorAll("c-related-products-table")
            .forEach((element) => {
            element.refreshListingData();
            });
        }
    }

    sortData(fieldname, direction) {        
        let parseData = JSON.parse(JSON.stringify(this.searchedProductList));       
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
            parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.searchedProductList = parseData;
    }

    resetData(){
        this.addOPEProducts = false;
        this.errors ={};
        this.productsToAssociate = [];
        this.productsToDiscount = [];
        this.isLoading = false;
        this.template.querySelector('lightning-datatable').selectedRows=[];
        this.enteredDiscount = '';
        this.opeChildSelected = [];
        this.cceChildSelected = [];
    }

    handleChildRowSelect(event){
        if(event.detail.isOpe){
            this.opeChildSelected = event.detail.selectedRows;
        }else{
            this.cceChildSelected = event.detail.selectedRows;
        }

    }

    handleApplyDiscount(){
        if(this.template.querySelectorAll("c-related-products-table")){
            this.template
            .querySelectorAll("c-related-products-table")
            .forEach((element) => {
            element.applyDiscount();
            });
        }
    }

    resetDiscount(){
        this.enteredDiscount = '';
        this.opeChildSelected = [];
        this.cceChildSelected = [];
        this.productsToDiscount = [];
    }

    //Getters for constants
    get associatedProductTitle(){ return ASSOCIATED_PRODUCTS_TITLE;}
    get noRecordsFound(){ return NO_REC_FOUND;}
    get displayTableError(){ return DISPLAY_TBL_ERROR;}

    get showProductPricing(){
        return !this.addOPEProducts;
    }

    get showAssociateProducts(){
        return this.addOPEProducts && this.showAddProductsButton;
    }

    get showAddProductsButton(){
        return this.tab && this.tab.split(',').includes('Product Management') && !this.isStatusCompleted;
    }

    get hasNoSelectedProducts(){
        if(this.productsToAssociate && this.productsToAssociate.length > 0){
            return false;
        }else{
            return true;
        }
    }

    get hasNoStandardPrice(){
        let noPrice = false;

        if(this.cceChildSelected && this.cceChildSelected.find(row => !row.standardPrice)){
            return noPrice = true;
        }

        if(this.opeChildSelected && this.opeChildSelected.find(row => !row.standardPrice)){
            return noPrice = true;
        }

        return noPrice;
    }

    get applyDiscountDisable(){
        return !this.hasNoStandardPrice && this.enteredDiscount && ((this.cceChildSelected && this.cceChildSelected.length > 0)  || (this.opeChildSelected && this.opeChildSelected.length > 0))?false:true;
    }

    get hideCheckBoxCol(){
        return this.editing || !this.enteredDiscount?true:false;
    }

    get hasAccess(){
        return HAS_PERMISSION;
    }
}