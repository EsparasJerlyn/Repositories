/**
 * @description A LWC component to display product request records
 *
 * @see ../classes/ProductRequestListCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                        |
      |---------------------------|-----------------------|----------------------|---------------------------------------|
      | angelika.j.s.galang       | September 30, 2021    | DEPP-40,42           | Created file                          |
      | roy.nino.s.regala         | October 01,2021       | DEPP-40,42           | Updated to work with addProductRequest|
      | angelika.j.s.galang       | December 17, 2021     | DEPP-1088,1096       | Modified to handle OPE records        | 
      | roy.nino.s.regala         | March 05, 2022        | DEPP-1747            | Updated Parent to child relationship  |
      | eccarius.karl.munoz       | March 21, 2022        | DEPP-1888            | Modified to handle Not Proceeding     |
 */
import { LightningElement, wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import LWC_List_CCEParentFilter from '@salesforce/label/c.LWC_List_CCEParentFilter';
import LWC_List_CCEChildFilter from '@salesforce/label/c.LWC_List_CCEChildFilter';
import LWC_List_OPEParentFilter from '@salesforce/label/c.LWC_List_OPEParentFilter';
import LWC_List_OPEChildFilter from '@salesforce/label/c.LWC_List_OPEChildFilter';
import RT_ProductSpecification_OPEProgramSpecification from '@salesforce/label/c.RT_ProductSpecification_OPEProgramSpecification';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import getProductRequests from '@salesforce/apex/ProductRequestListCtrl.getProductRequests';
import updateProdReqToNotProceeding from '@salesforce/apex/ProductRequestListCtrl.updateProdReqToNotProceeding';
import PS_RECORD_TYPE from '@salesforce/schema/Product_Specification__c.RecordType.DeveloperName';
import PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Product_Request__c';
import getRecordTypes from '@salesforce/apex/AddProductRequestCtrl.getRecordTypes';

const COMMA = ',';
const PS_FILTER = LWC_List_CCEParentFilter.split(COMMA);
const PR_FILTER = LWC_List_CCEChildFilter.split(COMMA);
const PS_OPE_FILTER = LWC_List_OPEParentFilter.split(COMMA);
const PR_OPE_FILTER = LWC_List_OPEChildFilter.split(COMMA);
const ACCORDION_SECTION = 'Product Requests';
const OPE_ACCORDION_SECTION = 'Add Products';
const NOT_PROCEEDING_BUTTON_NAME = 'Not Proceeding';
const ADD_CHILD_BUTTON_NAME = 'Add Child';
const ERROR_TOAST_VARIANT = 'error';
const SUCCESS_TOAST_VARIANT = 'success';
const ERROR_TOAST_TITLE = 'Error';
const SUCCESS_TOAST_TITLE = 'Success!';

export default class ProductRequestList extends LightningElement {
    @api recordId;

    // definition of columns for the tree grid
    gridColumns;
    // data provided to the tree grid
    gridData = [];
    recordTypeFilter = [];
    isLoading = true;
    showProductRequest = false;
    errorMessage = '';
    recordTypeOrderMap;
    fieldLayoutMap;
    isAddExistingOpen = false;
    recordTypeMap;
    productRequestRowId;
    rowIsFlexibleProgram;
    rowRecordType;
    productSpecStage;
    rowProdReqStatus;
    
    /**
     * constructs the header of lightning data grid
     */
     constructor(){
        super();
        this.gridColumns = [
            {
                fieldName: 'idUrl',
                label: 'Product Name',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'productName'
                    }
                }
            },
            {
                fieldName: 'recordType',
                label: 'Record Type',
            },
            {
                fieldName: 'stage',
                label: 'Stage',
            },
            {  
                fieldName: 'ownerUrl',
                label: 'Owner',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'owner'
                    }
                }
            },
            {
                fieldName: 'notProceedingComments',
                label: 'Not Proceeding Comments'
            },
            { 
                type: 'action', 
                typeAttributes: {  
                    rowActions: this.getRowActions
                }
            }   
        ];
    }

    /**
     * sets name of accordion header
     */
    get accordionSection(){
        return this.isProdSpecOPE?OPE_ACCORDION_SECTION:ACCORDION_SECTION;
    }

    get activeSections(){
        return this.accordionSection ? [this.accordionSection] : [];
    }

    /**
     * checks if there are product requests
     */
    get haveRequests(){
        return this.gridData.length !== 0?true:false;
    }

    get isProdSpecOPE(){
        return this.prodSpecRecordType == RT_ProductSpecification_OPEProgramSpecification?true:false;
    }

    productRequests;
    @wire(getProductRequests, {productSpecificationId : '$recordId'})
    getProductRequests(result){
        if(result.data){
            this.productRequests = result;
            let parentProductRequests = this.formatData(this.productRequests.data.parentList); //all product requests that has a child
            if(this.productRequests.data.parentList.length != 0){
                this.productSpecStage = result.data.parentList[0].Product_Specification__r.Stage__c;
            }           
            let parentChildProductRequests = this.productRequests.data.parentChildMap; // map of product request to its children
            parentProductRequests.forEach(parentProdReq =>{
                let childProdReqs = 
                    parentChildProductRequests[parentProdReq.recordId] ?
                    this.formatData(parentChildProductRequests[parentProdReq.recordId]) : [];
                
                if(childProdReqs.length > 0){
                    parentProdReq._children = [...childProdReqs];
                }
                this.gridData = [parentProdReq, ...this.gridData];
            });
        }else if(result.error){
            this.generateToast(ERROR_TOAST_TITLE, LWC_Error_General, ERROR_TOAST_VARIANT);
        }
        this.isLoading = false;
    }

    prodSpecRecordType;
    @wire(getRecord, { recordId: '$recordId', fields: [PS_RECORD_TYPE] })
    handleProductSpecification(result){
        if(result.data){
           this.prodSpecRecordType = getFieldValue(result.data, PS_RECORD_TYPE);
           this.showProductRequest = true;
            getRecordTypes({
                objectType: PRODUCT_REQUEST_OBJECT.objectApiName
            })
            .then(result =>{
                this.recordTypeMap = [...result];
            })
            .catch(error =>{
                console.log(error);
                this.generateToast(ERROR_TOAST_TITLE, LWC_Error_General, ERROR_TOAST_VARIANT);
            });
        }else if(result.error){
            this.generateToast(ERROR_TOAST_TITLE, LWC_Error_General, ERROR_TOAST_VARIANT);
        }   
    }

    /*
    * formats the product request records for the customSearch lwc
    */
    formatSearchItem(item){
        let searchItem = {};
        searchItem.id = item.recordId;
        searchItem.label = item.courseName?item.courseName:'';
        searchItem.meta = item.recordType;
        return searchItem;
    }

    /**
     * formats the data from apex for the data grid
     */
     formatData(listToFormat){
        return listToFormat.map(item =>{
            let newItem = {};
            newItem.recordId = item.Id;
            newItem.id = item.Name;
            newItem.idUrl = '/' + item.Id;
            newItem.recordType = item.RecordType.Name;
            newItem.owner = item.Owner.Name;
            newItem.ownerUrl = '/' + item.OwnerId;
            newItem.stage = item.Product_Request_Status__c;
            newItem.notProceedingComments = item.Not_Proceeding_Comments__c;
            newItem.productName = 
                item.Courses__r && item.Courses__r[0] ? 
                item.Courses__r[0].Name : 
                item.Program_Plans__r && item.Program_Plans__r[0] ?
                item.Program_Plans__r[0].Name : 
                item.Product_Request_Name__c; 
            if(item.Program_Plans__r && item.Program_Plans__r[0] && item.Program_Plans__r[0].Program_Delivery_Structure__c === 'Flexible Program'){
                newItem.isFlexibleProgram = true;
            }
            if(item.Program_Plans__r && item.Program_Plans__r[0] && item.Program_Plans__r[0].Program_Delivery_Structure__c === 'Prescribed Program'){
                newItem.isPrescribedProgram = true;
            }
            if(item.Courses__r && item.Courses__r[0] && item.Courses__r[0].Name){
                newItem.courseName = item.Courses__r[0].Name;
            }           
            return newItem;
        });
    }

    /**
     * handles action and data when ADD CHILD/NOT PROCEEDING button is clicked 
     */
    handleRowAction(event){
        let buttonName = event.detail.action.name;
        const row = event.detail.row;
        if(buttonName === NOT_PROCEEDING_BUTTON_NAME){
            this.productRequestRowId = row.recordId;
            this.rowIsFlexibleProgram = row.isFlexibleProgram;
            this.rowRecordType = row.recordType;
            this.rowProdReqStatus = row.stage;
            if(this.productSpecStage!='Design'){
                this.generateToast(ERROR_TOAST_TITLE, 'Update after Product Specification Design stage is not allowed.', ERROR_TOAST_VARIANT);
            }else if(this.rowProdReqStatus!='Design' && this.rowProdReqStatus!='Release'){
                if(this.rowProdReqStatus == 'Not Proceeding'){
                    this.generateToast(ERROR_TOAST_TITLE, 'Stage is already not proceeding.', ERROR_TOAST_VARIANT);
                }else{
                    this.generateToast(ERROR_TOAST_TITLE, 'Update not allowed after release stage.', ERROR_TOAST_VARIANT);
                }                
            }else{
                this.template.querySelector("c-add-not-proceeding-comments").openSelectionModal(row.notProceedingComments);                
            }            
        }else if(buttonName === ADD_CHILD_BUTTON_NAME){  
            let filter = this.isProdSpecOPE ? PR_OPE_FILTER : PR_FILTER;
            let currentChildren = this.productRequests.data.parentChildMap[row.recordId]?this.productRequests.data.parentChildMap[row.recordId]:[];
            let newRecord = row.isFlexibleProgram?false:true;
            this.template.querySelector("c-add-product-request").openSelectionModal(newRecord,row,filter,currentChildren,true,this.prodSpecData());
        }
    }

    prodSpecData(){
        let productSpecObj = {};
        productSpecObj.recordType = this.prodSpecRecordType;
        productSpecObj.id = this.recordId;
        return productSpecObj;
    }
    
    /**
     * handles action and data when ADD button is clicked
     */
    handleAddButton(){
        let filter = this.isProdSpecOPE ? PS_OPE_FILTER : PS_FILTER;
        this.template.querySelector("c-add-product-request").openSelectionModal(true,[],filter,[],false,this.prodSpecData());
    }

    /**
     * refreshes table when a record is created
     */
    handleCreated(){
        this.isLoading = true;
        this.gridData = [];
        refreshApex(this.productRequests);
    }

    /**
     * handles Not Proceeding action
     */
    handleNotProceeding(event){
        
        this.isLoading = true;
        let notProceedingComments = event.detail;
        let response;
        let ifFlexibleProgram = this.rowIsFlexibleProgram? true : false;

        updateProdReqToNotProceeding({
            id : this.productRequestRowId,
            recordType : this.rowRecordType,
            notProceedingComment : notProceedingComments,
            ifFlexibleProgram : ifFlexibleProgram
        }).then((result) => {
            response = result;
        })
        .catch((error) => {
            response = error;
        })
        .finally(() => {            
            if(response === 'Success'){
                this.generateToast(SUCCESS_TOAST_TITLE, 'Record updated', SUCCESS_TOAST_VARIANT);
            } else {
                this.generateToast(ERROR_TOAST_TITLE, LWC_Error_General, ERROR_TOAST_VARIANT);
            }
            this.gridData = [];
            refreshApex(this.productRequests);
        });        
    }

    /**
     * sets the actions availability per row
     */
     getRowActions(row, doneCallback) {
        const actions = [{ 
            label: NOT_PROCEEDING_BUTTON_NAME, 
            name: NOT_PROCEEDING_BUTTON_NAME,
            title: NOT_PROCEEDING_BUTTON_NAME
        }];

        if(row.recordType === RT_ProductRequest_Program){
            actions.push({ 
                label: ADD_CHILD_BUTTON_NAME, 
                name: ADD_CHILD_BUTTON_NAME,
                title: ADD_CHILD_BUTTON_NAME
            });
        }
        doneCallback(actions);
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