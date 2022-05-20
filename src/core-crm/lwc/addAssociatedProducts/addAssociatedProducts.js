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

import { LightningElement, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getProducts from '@salesforce/apex/AddAssociatedProductsCtrl.getProducts';
import addAssociatedProduct from '@salesforce/apex/AddAssociatedProductsCtrl.addAssociatedProduct';
import getCourseRecordTypes from '@salesforce/apex/AddAssociatedProductsCtrl.getCourseRecordTypes';

const ASSOCIATED_PRODUCTS_TITLE = 'Associated Products';
const NO_REC_FOUND = 'No record(s) found.';
const DISPLAY_TBL_ERROR = 'Unable to display record(s).';
const SUCCESS_MSG = 'Record(s) successfully saved.';
const NO_CHANGES_TITLE = 'No product(s) to associate.';
const SUCCESS_RESPONSE = 'Success';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';

export default class AddAssociatedProducts extends LightningElement {

    @api recordId;

    productName ='';
    recordType = '';
    isLoading = false;
    empty = false;
    error;
    recordTypes; 
    productList = [];   
    productListTemp = [];    
    productsToAssociate = [];  
    sortBy;
    sortDirection;   

    columns = [
        { label: 'Name', fieldName: 'productName', type: 'text' },
        { label: 'Record Type', fieldName: 'courseRecordType', type: 'text' },
        { label: 'Start Date', fieldName: 'startDate', type: 'date' },
        { label: 'End Date', fieldName: 'endDate', type: 'date' },
        { label: 'Standard Price', fieldName: 'standardPrice', type: 'currency', sortable: "true" }
    ];

    //Retrieves list of active OPE products
    products;
    @wire(getProducts, {recordId : "$recordId"})
    wiredProducts(result) {
        this.isLoading = true;
        this.products = result;
        if(result.data){            
            this.productList = result.data;
            this.productListTemp = result.data;
            if(this.productList.length === 0){
                this.empty = true;
            }
            this.error = undefined;
            this.isLoading = false;
        } else if(result.error){
            this.productList = undefined;
            this.productListTemp = undefined;
            this.error = result.error;
            this.isLoading = false;
        }    
    }

    //Retrieves Record Types
    @wire(getCourseRecordTypes)
    getCourseRecType(result){
        if(result.data) {
            const resp = result.data;
            this.recordTypes = resp.map(type => {
                return { label: type,  value: type };
            });            
            this.recordTypes.unshift({ label: 'Program Plan', value: 'Program Plan' });
            this.recordTypes.unshift({ label: 'All', value: '' });
        }
    }    

    //Handles search filters for Product Name and Record Type     
    searchHandler(){
        if(this.productName || this.recordType){
            this.empty = false;
            this.productList = [...this.productListTemp];
            this.productList = this.productList
                .filter( product => product.productName.toLowerCase().includes(this.productName.toLowerCase()))
                .filter( product => product.courseRecordType && product.courseRecordType.includes(this.recordType)
            );
            if(this.productList.length === 0){
                this.empty = true;
            }
        }else{
            this.empty = false;
            this.productList = [...this.productListTemp];          
        }
    }

    //Search function for Product Name
    handleProductNameSearch(event){        
        this.productName = event.target.value; 
        this.searchHandler();
    }

    //Search function for Record Type
    handleRecordTypeSearch (event){ 
        this.recordType = event.detail.value; 
        this.searchHandler();
    }

    //Row selection function for the datatable
    handelSelectedRows(event){
        this.productsToAssociate = event.detail.selectedRows;             
    }

    //Handles creation of Associated Product(s) based on the selected rows
    handleAssociateProduct(){
        this.isLoading = true;
        let response;
        let productIds = this.productsToAssociate.map(p => { 
            return p.id 
        });
        if(this.productsToAssociate.length > 0){
           addAssociatedProduct({ productIds: productIds, productRequestId : this.recordId })
                .then((result) => {
                    response = result;
                })
                .catch((error) => {                    
                    response = error;
                })
                .finally(() => {
                    this.isLoading = false;   
                    if(response === SUCCESS_RESPONSE){
                        this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
                    }else{
                        this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                    }
                    this.clearFields();
                    refreshApex(this.products);
                });
        }else{
            this.isLoading = false;
            this.generateToast(NO_CHANGES_TITLE, '', ERROR_VARIANT);
        }
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

    sortData(fieldname, direction) {        
        let parseData = JSON.parse(JSON.stringify(this.productList));       
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.productList = parseData;
    }

    //Getters for constants
    get associatedProductTitle(){ return ASSOCIATED_PRODUCTS_TITLE;}
    get noRecordsFound(){ return NO_REC_FOUND;}
    get displayTableError(){ return DISPLAY_TBL_ERROR;}
    get disableAssociateProducts(){ return !HAS_PERMISSION;}

}