import { LightningElement, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getProductsWithPricing from '@salesforce/apex/RelatedProductsCtrl.getProductsWithPricing';
import upsertPricebookEntries from '@salesforce/apex/RelatedProductsCtrl.upsertPricebookEntries';
import upsertAssociatedProducts from '@salesforce/apex/RelatedProductsCtrl.upsertAssociatedProducts';
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';

const NO_REC_FOUND = 'No record(s) found.';

export default class RelatedProductsTable extends LightningElement {

    @api recordId;
    @api isStatusCompleted;
    @api enteredDiscount;
    @api tableName;
    @api recordTypeFilter;
    @api columns;
    @api showPricingTable;
    
    productName ='';
    isLoading = true;
    noUnRelatedProducts = false;
    noRelatedProducts = false;
    error;  
    sortBy = '';
    sortDirection ='desc'; 
    draftValues = [];
    errors;
    productList;
    productListTemp;
    processingApplyDiscount = false;
    productsToDiscount = [];


    //Retrieves list of active OPE products
    productsWithPricing;
    @wire(getProductsWithPricing, {recordId : "$recordId"})
    wiredProductsWithPricing(result) {
        this.isLoading = true;
        this.productsWithPricing = result;
        if(result.data){     
            if(JSON.parse(JSON.stringify(result.data)).filter(key => key.isOPE == this.recordTypeFilter)){
                this.productList = JSON.parse(JSON.stringify(result.data)).filter(key => key.isOPE == this.recordTypeFilter).map(row => {
                    row.isEditable = HAS_PERMISSION && !row.isStatusCompleted?true:false;
                    row.formattedDiscount = row.discount?row.discount + '%':undefined;
                    return row;
                }); 
            }
            this.isLoading = false;
            this.productListTemp = this.productList;
            if(this.productList.length === 0){
                this.noRelatedProducts = true;
            }else{
                if(this.recordTypeFilter){
                    this.sortBy = 'isActive';
                }else{
                    this.sortBy = 'productName';
                }
                this.noRelatedProducts = false;
                this.sortData(this.sortBy,this.sortDirection);
            }
            this.error = undefined;
        } else if(result.error){
            this.isLoading = false;
            this.error = result.error;
            this.productList = undefined;
            this.productListTemp = undefined;
        }    
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

    //Row selection function for the datatable
    handelSelectedRows(event){
        this.productsToDiscount = event.detail.selectedRows; 
        this.dispatchEvent(new CustomEvent('rowselect', {detail: {
            isOpe:this.recordTypeFilter,
            selectedRows:this.productsToDiscount
        }}));
    }

    /*
    * hanndle action when a cell is updated
    */
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

     /*
    * updates single draft row
    */
     updateDraftValues(updateItem) {
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        let draftValueChanged = false;
        //append % if none to sting if discount is populated
        if(updateItem.formattedDiscount){
            updateItem.formattedDiscount = updateItem.formattedDiscount.includes('%')?updateItem.formattedDiscount:updateItem.formattedDiscount + '%';
        }

        //loop through the old draftvalues and update based on the new row updated(updateItem)
        copyDraftValues.forEach((item) => {
            //if row is updated again
            if (item.id === updateItem.id) {
                //update the old draftvalues column if column is newly updated
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true; 
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        //if row is newly updated
        } else {
            //add the new draft as new row 
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    handleSave(event){
        let draftValuesTemp = event.detail.draftValues;
        this.errors  = this.validateData(draftValuesTemp);
        
        if(Object.keys(this.errors).length === 0){
            this.isLoading = true;
            let pbEntryToUpsert = this.buildPbEntryRecord(draftValuesTemp);
            let assocProdToUpsert = this.buildAssocProdRecord(draftValuesTemp);

            upsertAssociatedProducts({assocProdToUpsert:assocProdToUpsert})
            .then(()=>{
                if(pbEntryToUpsert){
                    return upsertPricebookEntries({pbToUpsert:pbEntryToUpsert});
                }
            })
            .then(()=>{
                this.generateToast('Success!','Product updated','success');
                return refreshApex(this.productsWithPricing);
            })
            .finally(()=>{
                this.resetData();
            })
            .catch((error) => {
                this.generateToast('Error!',LWC_Error_General,'error');
                this.isLoading = false;
            })
            
        }  
    }

    resetData(){
        this.errors ={};
        this.productsToDiscount = [];
        this.processingApplyDiscount = false;
        this.isLoading = false;
        this.template.querySelector('lightning-datatable').selectedRows=[];
        this.draftValues = [];
    }

    @api refreshListingData(){
        return refreshApex(this.productsWithPricing);
    }


    buildPbEntryRecord(draftValues){
        let pbRecords = [];
        draftValues.map(row =>{
            let record = {};
            record.Id = this.productList.find(item => item.id == row.id) && this.productList.find(item => item.id == row.id).ccePriceBookEntryId!== undefined?this.productList.find(item => item.id == row.id).ccePriceBookEntryId:null;
            
            record.IsActive = true;
            record.Product2Id = row.id;
            record.Pricebook2Id = this.productList.find(item => item.id == row.id)?this.productList.find(item => item.id == row.id).priceBookId:null;
            let standardPrice = this.productList.find(item => item.id == row.id)?this.productList.find(item => item.id == row.id).standardPrice:0;
            if(this.processingApplyDiscount){
                record.Discount__c = this.enteredDiscount;
                record.UnitPrice = (standardPrice - (standardPrice * (parseInt(this.enteredDiscount)/100)));
            }else if(row.formattedDiscount){
                record.Discount__c = row.formattedDiscount.slice(0,-1);
                record.UnitPrice = (standardPrice - (standardPrice * (parseInt(row.formattedDiscount.slice(0,-1))/100)));
            }
            if(record.UnitPrice != undefined){
                pbRecords = [...pbRecords,record];
            }
        })

        return pbRecords;
    }

    
    buildAssocProdRecord(draftValues){
        let assocRecord = [];
        draftValues.map(row =>{
            if(row.isActive != undefined){
                let record = {};
                record.Id = this.productList.find(item => item.id == row.id) && this.productList.find(item => item.id == row.id).assocProdId!== undefined?this.productList.find(item => item.id == row.id).assocProdId:null;
                
                record.IsActive__c = row.isActive;
                assocRecord = [...assocRecord,record];
            }
        })
        return assocRecord;
    }


    handleCancel(){
        this.resetData();
    }

    //Sorts column for datatable
    handleSort(event) {
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection; 
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    @api applyDiscount(){
        this.processingApplyDiscount = true;
        this.isLoading = true;
        let pbEntryToUpsert = this.buildPbEntryRecord(this.productsToDiscount);
        upsertPricebookEntries({pbToUpsert:pbEntryToUpsert})
        .then(()=>{
            return refreshApex(this.productsWithPricing);
        })
        .finally(()=>{
            this.generateToast('Success!','Pricing updated','success');
            this.dispatchEvent(new CustomEvent('resetdiscount'));
            this.resetData();
        })
        .catch((error) => {
            this.isLoading = false;
        })
    }


    validateData(draftPBEntry){
        let rowsValidation={};
        let errors = {};
        let percentRegex = /^\d{0,18}%$/;
        draftPBEntry.map(row => {
            let fieldNames = [];
            let messages = [];

            if(row.formattedDiscount && !percentRegex.test(row.formattedDiscount)){
                messages.push('Please follow correct percent format (e.g. 50%)');
                fieldNames.push('formattedDiscount');
            }

            if(fieldNames.length > 0){
                rowsValidation[row.id] ={
                    title: 'We found an error/s.',
                    messages,
                    fieldNames
                };
            }
        })

        if(Object.keys(rowsValidation).length !== 0){
            errors = { rows:rowsValidation };
        }
        return errors;

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

    get noRecordsFound(){ return NO_REC_FOUND;}

    get editing(){
        return this.draftValues && this.draftValues.length > 0?true:false;
    }

    get hideCheckBoxCol(){
        return this.editing || !this.enteredDiscount?true:false;
    }

    get listSize(){
        return this.productList?this.productList.length:0;
    }

}