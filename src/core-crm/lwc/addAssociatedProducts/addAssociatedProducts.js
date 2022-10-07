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
      | alexander.cadalin         | July 27, 2022         | DEPP-2498            |                              | 
 */

import { LightningElement, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getProducts from '@salesforce/apex/AddAssociatedProductsCtrl.getProducts';
import addAssociatedProduct from '@salesforce/apex/AddAssociatedProductsCtrl.addAssociatedProduct';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
// import getCourseRecordTypes from '@salesforce/apex/AddAssociatedProductsCtrl.getCourseRecordTypes';

const ASSOCIATED_PRODUCTS_TITLE = 'Related Products';
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
    isAssociating = false;
    empty = false;
    error;
    recordTypes = [];
    productList = [];   
    productListTemp = [];    
    productsToAssociate = []; 
    productsToRemove = []; 
    sortBy = 'productName';
    sortDirection = 'asc';
    productsToRetrieve = 'associated';  
    addAssocBtnLabel = 'Add OPE Products';
    addAssocBtnVariant = 'neutral';
    addAssocBtnIcon = 'utility:add';
    productRequestStatus;
    columns = [
        { label: 'Name', fieldName: 'productName', type: 'text', sortable: 'true' },
        { label: 'Record Type', fieldName: 'courseRecordType', type: 'text', sortable: 'true' },
        { label: 'Start Date', fieldName: 'startDate', type: 'date', sortable: 'true' },
        { label: 'End Date', fieldName: 'endDate', type: 'date', sortable: 'true' }
    ];

    connectedCallback() {
        this.populateTableWithProducts();
    }

    @wire(getRecord, {recordId : '$recordId', fields : [PR_STATUS]})
    getProductRequestRecord(result) {
        if(result.data) {
            this.productRequestStatus = getFieldValue(result.data, PR_STATUS);
        } else if(result.error) {
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }
    //Retrieves list of active OPE products
    // products;
    // @wire(getProducts, {recordId : '$recordId'})
    // wiredProducts(result) {
    //     this.isLoading = true;
    //     this.products = result;
    //     if(result.data){            
    //         this.productList = result.data;
    //         this.productListTemp = result.data;
    //         if(this.productList.length === 0){
    //             this.empty = true;
    //         }
    //         this.error = undefined;
    //         this.isLoading = false;
    //     } else if(result.error){
    //         this.productList = undefined;
    //         this.productListTemp = undefined;
    //         this.error = result.error;
    //         this.isLoading = false;
    //     }    
    // }
    
    populateTableWithProducts() {
        this.isLoading = true;
        getProducts({ recordId : this.recordId, allOrAssociated : this.productsToRetrieve })
            .then(result => {
                this.productList = result;
                this.productListTemp = result;
                this.recordTypes = [];
                if(this.productList.length === 0) { 
                    this.empty = true; 
                } else {
                    this.empty = false;
                    for(let i in this.productList) {
                        if(!this.recordTypes.find(element => element.value == this.productList[i].courseRecordType )) {
                            this.recordTypes.push({ label: this.productList[i].courseRecordType, value: this.productList[i].courseRecordType });
                        }
                    }
                    this.recordTypes.sort();
                }
                this.recordTypes.unshift({ label: 'All', value: '' });
                this.error = undefined;
            })
            .catch(error => {
                this.productList = undefined;
                this.productListTemp = undefined;
                this.error = error;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    //Retrieves Record Types
    // @wire(getCourseRecordTypes)
    // getCourseRecType(result){
    //     if(result.data) {
    //         const resp = result.data;
    //         this.recordTypes = resp.map(type => {
    //             return { label: type,  value: type };
    //         });            
    //         this.recordTypes.unshift({ label: 'Program Plan', value: 'Program Plan' });
    //         this.recordTypes.unshift({ label: 'All', value: '' });
    //     }
    // }    

    //Handles search filters for Product Name and Record Type     
    searchHandler(){
        if(this.productName || this.recordType){
            //this.empty = false;
            this.productList = [...this.productListTemp];
            this.productList = this.productList
                .filter( product => product.productName.toLowerCase().includes(this.productName.toLowerCase()))
                .filter( product => product.courseRecordType && product.courseRecordType.includes(this.recordType)
            );
            if(this.productList.length === 0){
                this.empty = true;
            } else {
                this.empty = false;
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
    handleSelectedRows(event){
        if(this.isAssociating) {
            this.productsToAssociate = event.detail.selectedRows;             
        }
    }

    //Handles creation of Associated Product(s) based on the selected rows
    handleAssociateProduct(){
        if(!this.isAssociating) {
            this.toggleMode();
        } else {
            let response;
            let productIds = this.productsToAssociate.map(p => { 
                return p.id; 
            });
            if(this.productsToAssociate.length > 0){
                this.isLoading = true;
                addAssociatedProduct({ productIds : productIds, productRequestId : this.recordId })
                    .then((result) => {
                        response = result;
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
                        this.toggleMode();
                    });
            }else{
                this.generateToast(NO_CHANGES_TITLE, '', ERROR_VARIANT);
            }
        }
    }

    // Stop associating products and return to associated products view
    toggleMode() {
        if(this.isAssociating) {
            this.addAssocBtnLabel = 'Add OPE Products';
            this.addAssocBtnVariant = 'neutral';
            this.addAssocBtnIcon = 'utility:add';
            this.productsToRetrieve = 'associated';
        } else {
            this.addAssocBtnLabel = 'Associate Products';
            this.addAssocBtnVariant = 'brand';
            this.addAssocBtnIcon = 'utility:link';
            this.productsToRetrieve = 'all';
        }
        this.isAssociating = !this.isAssociating;
        this.populateTableWithProducts();
        this.clearFields();
    }
    
    // Handle cancel button when clicked
    handleCancel() {
        this.toggleMode();
    }

    //Clears the fields after saving
    clearFields(){
        const recordType = this.template.querySelector("lightning-combobox");
        if(recordType){
            recordType.value = '';
        }
        this.productName = '';
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.productsToAssociate = [];
        this.productsToRemove = [];
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

    get hideCheckbox() { return !this.isAssociating; }

    //Getters for constants
    get associatedProductTitle(){ return ASSOCIATED_PRODUCTS_TITLE;}
    get noRecordsFound(){ return NO_REC_FOUND;}
    get displayTableError(){ return DISPLAY_TBL_ERROR;}
    get disableAssociateProducts(){ return !HAS_PERMISSION || this.productRequestStatus != 'Design';}
}