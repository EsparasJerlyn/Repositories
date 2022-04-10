/**
 * @description A custom LWC for showing Pricebook and Pricing
 *
 * @see ../classes/PricebookEntry.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | marlon.vasquez            | April 07, 2022        | DEPP-2245           | Add Voucher button                                     |
      | arsenio.Jr.dayrit         | February 07, 2022     | DEPP-1406           | Created file                                           |
      | roy.nino.s.regala         | February 10, 2022     | DEPP-1773,1406,1257 | Added,create,edit,delete pricebook entries             |
      |                           |                       |                     |                                                        |
*/

import { LightningElement, wire, api,track } from 'lwc';
import getPricebookEntries from '@salesforce/apex/PricebookEntryCtrl.getPricebookEntries';
import upsertPricebookEntries from '@salesforce/apex/PricebookEntryCtrl.upsertPricebookEntries';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import { loadStyle } from 'lightning/platformResourceLoader';
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';
import { createRecord } from 'lightning/uiRecordApi';
import promotionId from '@salesforce/schema/Promotion.Id';
import promotionName from '@salesforce/schema/Promotion.Name';
import promotionDescription from '@salesforce/schema/Promotion.Description';
import promotionObjective from '@salesforce/schema/Promotion.Objective';
import promotionIsActive from '@salesforce/schema/Promotion.IsActive';
import { NavigationMixin } from 'lightning/navigation';
const columns = [
    {
        label: 'Price Book Selection', 
        fieldName: 'Pricebook2Id', 
        type: 'customSearch', 
        wrapText: true,
        typeAttributes: {
            icon: "standard:pricebook",
            parentId: {fieldName:'RowId'},
            placeholder: "Select a price book",
            lookupItems: {fieldName:'Pricebooks'},
            itemServerName:{fieldName:'PricebookServerName'},
            itemId:{fieldName:'Pricebook2Id'},
            objectLabelName:'Pricebook',
            newRecordAvailable:true
        },
        cellAttributes:{
            alignment: 'center',
            class: {fieldName:'PriceBookClass'}
        },
        editable:true
    },
    { 
        label: 'Discount Percentage', 
        fieldName: 'Discount__c', 
        type: 'text',
        typeAttributes: 
        {
            step: '0.001'
        },
        cellAttributes:{
            alignment: 'left'
        },
        editable:{fieldName:'NotStandard'}
    },
    { 
        label: 'List Price', 
        fieldName: 'UnitPrice', 
        type: 'currency', 
        typeAttributes: 
        {
            currencyCode:'AUD', 
            step: '0.001'
        },
        cellAttributes:{
            alignment: 'left'
        },
        editable:{fieldName:'HasNoDiscount'}
    },
    { 
        label: 'Early Bird No. of Days', 
        fieldName: 'Early_Bird_No_of_Days__c', 
        type: 'number', 
        cellAttributes:{
            alignment: 'left'
        },
        editable:{
            fieldName:'IsEarlyBird'
        }
    },
    { 
        label: 'Active', 
        fieldName: 'IsActive', 
        type: 'boolean',
        cellAttributes:{
            alignment: 'left'
        },
        editable:{fieldName:'editable'}
    },
    { 
        label: 'Action', 
        type: 'button-icon',
        initialWidth: 150,
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            disabled: {fieldName: 'DisableButton'}
        },
        
    }
];

export default class ProductPricing extends NavigationMixin(LightningElement) {

    priceBookEntryRecords = [];
    sortedPriceBooks = [];
    priceBooks = [];
    objectApiName = 'PricebookEntry';
    productId;
    isLoading = true;
    errorMessage = '';
    columns = columns;
    formattedPricebookEntries;
    draftValues = [];
    errors = {};
    standardPrice = 0;
    standardPriceDraft = 0;
    standardListPriceChanged = false;
    isCreateRecord = false;
    objApiName;
    prefields;
    
    @api recordId;
    /*  Voucher Modal */
    PromotionFieldList = [promotionId,promotionName,promotionDescription,promotionObjective,promotionIsActive];
   
    @track createVoucherForm = false; 
    ShowVoucherForm() {            
        this.createVoucherForm = true;
    }
    HideShowVoucherForm() {     
        this.createVoucherForm = false;
    }

    @api PromotionObjectApiName='Promotion';

   
    createVoucher(event){

      this.createVoucherForm = false;   
        const evt = new ShowToastEvent({
            title:'Voucher Added',
            message: event.detail.fields.Name.value + ' is successfully added',
            variant:'success',
          });
          this.dispatchEvent(evt);   
          
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApname : 'Promotion',
                actionName: 'view'
            },
           });         
    }   

    /*  */
    /* get Pricebook Entry record */

  
    @api isStatusCompleted;

    pbEntries;
    @wire(getPricebookEntries, {prodReqId : "$recordId"})
    wiredpbEntries(result) {
        this.pbEntries = result;
        if (result.data) {
            this.isLoading = false;
            this.priceBookEntryRecords = result.data.priceBookEntries;
            this.priceBooks = result.data.priceBooks;
            this.formattedPricebooks = this.formatPriceBooks(result.data.priceBooks);
            this.formattedPricebookEntries = this.formatPriceBookEntries(JSON.parse(JSON.stringify(this.priceBookEntryRecords)));
            //get the unit price of the standard pricebook
            if(this.formattedPricebookEntries.find(key => key.NotStandard === false)){
                this.standardPrice = this.formattedPricebookEntries.find(key => key.NotStandard === false).UnitPrice;
            }else{
                this.standardPrice = 0;
            }

            this.sortedPriceBooks = this.priceBooks.map(key =>{
                return {
                    label : key.Name,
                    value : key.Id,
                    isStandard: key.IsStandard,
                    isDisabled: !key.IsStandard
                }
            });

            this.productId = result.data.product.Id;
        } else if (result.error) {
            this.isLoading = false;
            this.priceBookEntryRecords = undefined;
            this.priceBooks = undefined;
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    connectedCallback(){
        Promise.all([
            loadStyle(this, customDataTableStyle)
        ]).then(() => {
        });
    }

    /**
     * getter to check if record has related pricebook entries
     * 
     */
    get hasPbEntries(){
        return this.formattedPricebookEntries?this.formattedPricebookEntries.length > 0?true:false:false;
    }

    /*
    * getter to disable add pricing button
    */
    get disableAddPricing(){
        if(
            (this.formattedPricebookEntries &&
            this.formattedPricebookEntries.length === 1 &&
            this.formattedPricebookEntries[0].Id === undefined) ||
            this.isStatusCompleted
        ){
            return true;
        }else{
            return false;
        }
    }
    
    /**
     * getter to check if early bird pricebook is selected
     * 
     */
    formatPriceBookEntries(pricebookEntries){
        return pricebookEntries.map((item,index) =>{
            let newItem = {};
            newItem = item;
            newItem.RowId = 'row-' + index;
            newItem.Discount__c = newItem.Discount__c? newItem.Discount__c + '%':null;
            newItem.Pricebooks = this.formattedPricebooks;
            newItem.PriceBookClass = 'slds-cell-edit';
            newItem.PricebookServerName = item.Pricebook2?item.Pricebook2.Name:undefined;
            newItem.NotStandard = item.Pricebook2.IsStandard || this.isStatusCompleted?false:true;
            newItem.IsEarlyBird = item.Pricebook2.Name === 'Early Bird' && !this.isStatusCompleted?true:false;
            newItem.DisableButton = true;
            newItem.HasNoDiscount = item.Discount__c || this.isStatusCompleted?false:true;
            newItem.editable = this.isStatusCompleted?false:true;
            return newItem;
        });
    }

    /*
    * format a single pricebook to be readable for custom search 
    */
    formatPricebook(pricebook){
        let newItem = {};
            newItem.id = pricebook.Id;
            newItem.label = pricebook.Name;
        return newItem;
    }
    /*
    * format pricebookds to be readable for custom search 
    */
    formatPriceBooks(priceBook){
        return priceBook.map(item =>{
            let newItem = {};
            newItem.id = item.Id;
            newItem.label = item.Name;
            return newItem;
        })
    }

    /**
     * handle action when add price book button is clicked
     * 
     */
    handleAddPriceBooks(){
        if(this.formattedPricebookEntries.length === 0){
            this.constructPricebookEntry(true);
        }else{
            this.constructPricebookEntry(false);
        }
        this.errors = {};
    }

    /*
    * constructs new row for the the datatable
    * creates a shell standard and non standard pricebook entry
    */
    constructPricebookEntry(isStandard){
        let newItem = {};
        newItem.RowId = 'row-' + this.formattedPricebookEntries.length;
        newItem.Discount__c = undefined;
        newItem.Early_Bird_No_of_Days__c = undefined;
        newItem.Id = undefined;
        newItem.IsActive = isStandard?true:false;
        newItem.IsEarlyBird = undefined;
        newItem.NotStandard = isStandard?false:true;
        newItem.UnitPrice = undefined;
        newItem.Number_of_Days__c = undefined;
        newItem.Pricebook2 = undefined;
        newItem.Pricebook2Id = isStandard?this.priceBooks.find(item => item.IsStandard === true).Id:undefined;
        newItem.PricebookServerName = isStandard?this.priceBooks.find(item => item.IsStandard === true).Name:undefined;
        newItem.PriceBookClass = 'slds-cell-edit';
        newItem.Pricebooks = this.formattedPricebooks;
        newItem.Product2Id = isStandard?this.productId:undefined;
        newItem.DisableButton = false;
        newItem.HasNoDiscount = true;
        this.formattedPricebookEntries = [...this.formattedPricebookEntries, newItem];
        if(isStandard){
            let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
            let updateItem = {};
            updateItem.id = newItem.RowId;
            updateItem.UnitPrice = '';
            this.draftValues = [...copyDraftValues,updateItem];
        }
        
    }

    /*
    * handle action when a price book is selected
    */
    handleItemSelect(event){
        
        //removes the selected pricebook from the pricebook selection for future rows
        this.formattedPricebooks = this.formattedPricebooks.filter((filterKey)=> filterKey.id !== event.detail.value);
        //update the data of the row of selected pricebook
        this.formattedPricebookEntries = this.formattedPricebookEntries.map(item =>{
            if(item.RowId === event.detail.parent){
                item.Pricebook2Id = event.detail.value;
                item.Product2Id = this.productId;
                item.PriceBookClass = 'slds-cell-edit slds-is-edited';
                item.IsEarlyBird = this.priceBooks.find(item => item.Id === event.detail.value).Name === 'Early Bird'?true:false;
            }
            //updates the pricebook selection of existing rows
            if(item.Pricebook2Id !== event.detail.value){
                item.Pricebooks = item.Pricebooks.filter((filterKey)=> filterKey.id !== event.detail.value);
            }
            return item;
        });

        //construct draft data
        let newItem = {};
        newItem.id = event.detail.parent;
        newItem.Pricebook2Id = event.detail.value;
        this.updateDraftValues(newItem);
        
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

        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));

        //append % if none to sting if discount is populated
        if(updateItem.Discount__c){
            updateItem.Discount__c = updateItem.Discount__c.includes('%')?updateItem.Discount__c:updateItem.Discount__c + '%';
        }

        //
        if( updateItem.UnitPrice && 
            this.formattedPricebookEntries.find(key => 
                key.RowId === updateItem.id).NotStandard === false && 
                updateItem.UnitPrice != this.standardPrice){

            this.standardListPriceChanged = true;
            this.standardPriceDraft = updateItem.UnitPrice;

        }
        //loop through the old draftvalues and update based on the new row updated(updateItem)
        copyDraftValues.forEach((item) => {
            //if row is updated again
            if (item.id === updateItem.id) {
                //update the old draftvalues column if column is newly updated
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                if((updateItem.Discount__c && 
                    updateItem.Discount__c.length > 0) || 
                    updateItem.Discount__c === ''){
                    this.updateListPrice(updateItem);
                    item.UnitPrice = '';
                }
                
                draftValueChanged = true; 
            }
        });
        if (draftValueChanged) {
            this.draftValues = this.sortDraftValues([...copyDraftValues]);
        //if row is newly updated
        } else {
            if((updateItem.Discount__c && 
                updateItem.Discount__c.length > 0) || 
                updateItem.Discount__c === ''){
                this.updateListPrice(updateItem);
                updateItem.UnitPrice = '';
            }
            //add the new draft as new row 
            this.draftValues = this.sortDraftValues([...copyDraftValues, updateItem]);
        }
    }

    /*
    * handles action for list price when discount is populated
    */
    updateListPrice(draft){
        //if discount is updated/populated calculate old draft list price
        if(draft.Discount__c && draft.Discount__c.length > 0){
            this.setListPriceEditablity(draft.id,false);
        //if discount is removed, remove the list price
        }else if(draft.Discount__c === ''){
            this.setListPriceEditablity(draft.id,true);
        }
    }


    /*
    * updates the table data and
    * sets editablity of list price.
    * if discount is populated, list price is uneditable
    */
    setListPriceEditablity(itemId,hasDiscount){
        for(const obj of this.formattedPricebookEntries){
            if(obj.RowId === itemId){
                obj.HasNoDiscount = hasDiscount;
                break;
            }
        }
    }


    /*
    * sort the draft values
    */
    sortDraftValues(draftValues){
        if(draftValues){
            return draftValues.sort((a, b) => a.id.localeCompare(b.id));
        }else{
            return draftValues;
        }
    }

    /*
    *handles action when selected pricebook is removed
    */
    handleItemRemove(event){
        //adds the pricebook back to selection
        this.formattedPricebooks = this.addPriceBooktoSelection(event.detail.value);

        //update the data of the row of removed pricebook
        this.formattedPricebookEntries = this.formattedPricebookEntries.map(item =>{
            if(item.Pricebook2Id === event.detail.value){
                item.Pricebook2Id = undefined;
                item.Product2Id = this.productId;
                item.IsEarlyBird = undefined;
                item.PriceBookClass = 'slds-cell-edit';
            }
            //update other existing row's pricebook selection
            if(item.Pricebook2Id && 
                item.Pricebook2Id !== event.detail.value && 
                item.PricebookServerName === undefined){
                item.Pricebooks = this.addPriceBooktoSelection(item.Pricebook2Id);
            }else{
                item.Pricebooks = this.formattedPricebooks;
            }
            return item;
        });
        
        //remove the pricebook in the draftvalues
        this.draftValues = this.sortDraftValues(
            this.draftValues.filter(item => 
            item.Pricebook2Id != event.detail.value)
            );
    }

    /*
    *add a pricebook to selection and sort by label
    */
    addPriceBooktoSelection(pricebookId){
        let tempPricebook = this.priceBooks.find(item => 
            item.Id === pricebookId
            );

        let newItem = this.formatPricebook(tempPricebook); 
        return [...this.formattedPricebooks,newItem].sort((a, b) => a.label.localeCompare(b.label));
    }

    /*
    * handle save action
    */
    handleSave(event){
        let draftValuesTemp = event.detail.draftValues;
        let recordToUpsertTemp = this.buildRecordToUpsert(draftValuesTemp);
        this.errors = this.validateData(recordToUpsertTemp);

        if(Object.keys(this.errors).length === 0){
            //check if standardprice is updated
            if(this.standardListPriceChanged){
                //calculate all list prices of non standard with discounts
                recordToUpsertTemp = this.calculateListPrices(recordToUpsertTemp);
            }

            upsertPricebookEntries({pbToUpsert:recordToUpsertTemp.map(key => { 
                delete key.RowId; 
                if(key.Discount__c){
                    key.Discount__c = key.Discount__c.includes('%')?parseInt(key.Discount__c.slice(0,-1)):parseInt(key.Discount__c);
                }
                return key; 
            })})
            .then(()=>{
                this.isLoading = true;
                refreshApex(this.pbEntries)
                .finally(()=>{
                    this.standardListPriceChanged = false;
                    this.standardPriceDraft = 0;
                    this.isLoading = false;
                    this.generateToast('Success!','Price Book Entry Saved','success');
                    this.draftValues = [];
                    this.errrors ={};
                });
            })
            .catch((error)=>{
                console.log(error);
                this.generateToast('Error.',LWC_Error_General,'error');
            })
        }
    } 
    
    /*
    *calculates the discounted unit price of non standard pricebook entries
    */
    calculateListPrices(tempRecord){
        //get all rowid from drafts merged with datatable
        let rowIds = tempRecord.map(key => {
            return key.RowId;
        });

        //get all data from datatable that has a discount and rowids not in drafts
        let filteredRecords = this.formattedPricebookEntries.filter(key => key.Discount__c && !rowIds.includes(key.RowId));

        if(filteredRecords){
            //update the unitprice and add it to the records to upsert
            filteredRecords.map(key => {
                let newItem = {};
                let newUnitPrice_temp = this.standardPriceDraft - (this.standardPriceDraft * (parseInt(key.Discount__c.slice(0,-1))/100)); 
                newItem.Discount__c = key.Discount__c;
                newItem.UnitPrice = newUnitPrice_temp.toFixed();
                newItem.RowId = key.RowId;
                newItem.Id = key.Id;
                tempRecord = [...tempRecord,newItem];
            });
        }

        return tempRecord;
    }
    /*
    *validates data to upsert
    */
    validateData(pricebookentry){
        let rowsValidation={};
        let errors = {};
        let percentRegex = /^\d{0,18}%$/;
        pricebookentry.map(item => {
            let fieldNames = [];
            let messages = [];
            if(!item.Pricebook2Id){
                messages.push('Price book is required.');
                fieldNames.push('customSearch');
                for(const obj of this.formattedPricebookEntries){
                    if(obj.RowId === item.RowId){
                        obj.PriceBookClass = 'slds-cell-edit slds-is-edited slds-has-error';
                        break;
                    }
                }
            }
            if((!item.UnitPrice ||(item.UnitPrice && item.UnitPrice <= 0)) && !item.Discount__c){
                messages.push('List Price is required.');
                fieldNames.push('UnitPrice');
            }
            if( 
                item.Pricebook2Id && 
                ((this.formattedPricebookEntries.find(key => key.Pricebook2Id === item.Pricebook2Id) && 
                this.formattedPricebookEntries.find(key => key.Pricebook2Id === item.Pricebook2Id).PricebookServerName === 'Early Bird') ||
                (this.priceBooks.find(key => key.Id === item.Pricebook2Id) &&
                this.priceBooks.find(key => key.Id === item.Pricebook2Id).Name === 'Early Bird')) && 
                (!item.Early_Bird_No_of_Days__c || (item.Early_Bird_No_of_Days__c && item.Early_Bird_No_of_Days__c == 0))){
                messages.push('Early Bird No of Days is required for this Price book.');
                fieldNames.push('Early_Bird_No_of_Days__c');
            }

            if(item.Discount__c && !percentRegex.test(item.Discount__c)){
                messages.push('Please follow correct percent format (e.g. 50%)');
                fieldNames.push('Discount__c');
            }

            if(fieldNames.length > 0){
                rowsValidation[item.RowId] ={
                    title: 'We found an error/s.',
                    messages,
                    fieldNames
                };
            }

        });
        if(Object.keys(rowsValidation).length !== 0){
            errors = { rows:rowsValidation };
        }
        return errors;
       
    }

    /*
    * builds the records to be upserted
    */
    buildRecordToUpsert(draftData){

        let newRecordToUpsert = draftData.map(item =>{
            let newItem = {};
            let priceBookTemp = this.formattedPricebookEntries.find(key => key.RowId === item.id);
            newItem.RowId = item.id;
            
            if(priceBookTemp.Id){
                newItem.Id = priceBookTemp.Id;
            }

            if(item.Discount__c === undefined && priceBookTemp.Discount__c){
                newItem.Discount__c = priceBookTemp.Discount__c;
            }else{
                newItem.Discount__c = item.Discount__c;
            }

            newItem.IsActive = item.IsActive === undefined?priceBookTemp.IsActive:item.IsActive;
            newItem.Early_Bird_No_of_Days__c = item.Early_Bird_No_of_Days__c === undefined?priceBookTemp.Early_Bird_No_of_Days__c:item.Early_Bird_No_of_Days__c;
            newItem.Pricebook2Id = item.Pricebook2Id ===undefined?priceBookTemp.Pricebook2Id:item.Pricebook2Id;
            //make sure that discount is populated 
            //make sure that price is greater than 0
            if(newItem.Discount__c && newItem.Discount__c.length > 0 && 
                (this.standardPrice !== 0 || (this.standardListPriceChanged && this.standardPriceDraft))){
                    if(this.standardListPriceChanged){
                        newItem.UnitPrice = this.standardPriceDraft - (this.standardPriceDraft * (parseInt(newItem.Discount__c.slice(0,-1))/100));
                    }else{
                        newItem.UnitPrice = this.standardPrice - (this.standardPrice * (parseInt(newItem.Discount__c.slice(0,-1))/100))
                    }
            }else{
                newItem.UnitPrice = item.UnitPrice === undefined?priceBookTemp.UnitPrice:item.UnitPrice;
            }
            newItem.UnitPrice = newItem.UnitPrice .toFixed();
            newItem.Product2Id = item.Product2Id === undefined?priceBookTemp.Product2Id:item.Product2Id;
            return newItem;
        });

      return newRecordToUpsert; 
    }

    /*
    *handles delete action
    */
    handleRowActions(event){
        let actionName = event.detail.action.name;
        if(actionName === 'delete'){
            this.deleteRow(event.detail.row);
        }   
    }

    /*
    * handles action when cancel button is clicked
    */
    handleCancel() {
        //remove edit highlights
        //remove pricebook ids on search boxes
        //removes errors
        this.formattedPricebookEntries = this.formattedPricebookEntries.map(key => {
            key.PriceBookClass = 'slds-cell-edit';
            if(this.draftValues.find(item => item.id === key.RowId && item.Pricebook2Id)){
                key.Pricebook2Id = undefined;
            }
            return key;
        });
        this.standardListPriceChanged = false;
        this.standardPriceDraft = 0;
        this.errors ={};
        this.draftValues = [];
    }

    /*
    *handles action when user wants to create a new pricebook
    */
    handleCreate(event){
        this.rowOfNewPricebook = event.detail.parent;
        this.prefields = {IsActive:true};
        this.isCreateRecord = true;
        this.objApiName = 'Pricebook2';
    }

    /*
    * closes pricebook creation modal
    */
    handleCloseModal(){
        this.isCreateRecord = false;
    }

    /*
    *handles action when a new pricebook is created
    */
    handleNewPricebookSave(event){
        let fields = event.detail;
        let objRecord = {'apiName':'Pricebook2',fields};

        createRecord(objRecord).then(response =>{
            this.generateToast('Success!','Price Book Saved','success');
            //only add to selection if Pricebook is set to active.
            if(event.detail.IsActive === true){
                let newSelection = {};
                newSelection.Id = response.id;
                newSelection.IsStandard = false;
                newSelection.Name = event.detail.Name;
                this.addNewPriceBookToSelection(newSelection);
            }
        }).catch(error => {
            console.log(error);
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        
    }

    /*
    *Adds newly created pricebook to selection
    *and updates the draftvalues to show the search box is filled and edited
    */
    addNewPriceBookToSelection(selection){
        this.priceBooks = [...this.priceBooks,selection];
        let formatPb= this.formatPricebook(selection);

        for(const obj of this.formattedPricebookEntries){
            if(obj.RowId === this.rowOfNewPricebook){
                obj.Pricebook2Id = selection.Id;
                obj.Product2Id = this.productId;
                obj.PriceBookClass = 'slds-cell-edit slds-is-edited';
                obj.Pricebooks = [...this.formattedPricebooks,formatPb];
                break;
            }
        }

        let newItem = {};
        newItem.id = this.rowOfNewPricebook;
        newItem.Pricebook2Id = selection.Id;
        this.updateDraftValues(newItem);
    }


    /**
     * deletes the pricebokentry selected
     */
    deleteRow(priceBookEntryRow){
 
        this.formattedPricebookEntries = this.formattedPricebookEntries.filter(key => key.RowId != priceBookEntryRow.RowId);

        //if row has selected pricebook add back the pricebook to the selection
        if(priceBookEntryRow.Pricebook2Id){
            this.formattedPricebooks = this.addPriceBooktoSelection(priceBookEntryRow.Pricebook2Id);
        }

        //reorder the pricebookentries since rowid is changed
        this.formattedPricebookEntries = this.formattedPricebookEntries.map((item,index) =>{
            item.RowId = 'row-'+ index;
            //if on a row with a selected pricebook 
            //update its pricebook selection + current selected pricebook
            if(item.Pricebook2Id && item.Pricebook2Id !== priceBookEntryRow.Id && item.PricebookServerName === undefined){
                item.Pricebooks = this.addPriceBooktoSelection(item.Pricebook2Id);
            }else{
            //update pricebook selecteion - all selected pricebooks
                item.Pricebooks = this.formattedPricebooks;
            }
            return item;
        });

        //sort the drafvalues
        this.draftValues = this.sortDraftValues(this.draftValues.filter(key => key.id != priceBookEntryRow.RowId)).map(item =>{
            //if removed row is lesser than the current draft row
            if(parseInt(priceBookEntryRow.RowId.slice(-1)) < parseInt(item.id.slice(-1))){
                //decrement the row number to match the current number of rows
                let number = parseInt(item.id.slice(-1));
                let decrementValue = number - 1;
                item.id = 'row-' + decrementValue;
            }
            return item;
        });
        this.errors = {};
    }

    /**
     * creates toast notification
     */
     generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}