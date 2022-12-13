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
      | john.m.tambasen           | July 05, 2022         | DEPP-2590            | SOA product request                   | 
      | eccarius.karl.munoz       | July 11, 2022         | DEPP-2035            | Added Educational Consultancy handling| 
      | john.m.tambasen           | July 26, 2022         | DEPP-3480            | Corporate Bundle product request      | 
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
import LWC_List_SOA_ChildFilter from '@salesforce/label/c.LWC_List_SOA_ChildFilter';
import RT_ProductSpecification_OPEProgramSpecification from '@salesforce/label/c.RT_ProductSpecification_OPEProgramSpecification';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import RT_ProductRequest_SOA from '@salesforce/label/c.RT_ProductRequest_SOA';
import RT_ProductRequest_PWP from '@salesforce/label/c.RT_ProductRequest_Program_Without_Pathway';;
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
const PR_SOA_FILTER = LWC_List_SOA_ChildFilter.split(COMMA);
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

            let stringData = JSON.stringify(result.data).replace(/{"children":/g,'{"_children":');
            let jsonData = JSON.parse(stringData);
            this.gridData = jsonData.productRequestData;
            this.productSpecStage = this.productRequests.data.productSpecStage;

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
            if(this.productSpecStage=='Not Proceeding' || this.productSpecStage=='Completed'){
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
            let filter;
            let newRecord;
            let currentChildren= []; 

            //check the parent-child map
            if(this.productRequests.data.parentChildPRMap[row.recordId]){
                currentChildren = this.productRequests.data.parentChildPRMap[row.recordId];

            //also check for child-grandchild map
            } else if(this.productRequests.data.childGrandchildPRMap[row.recordId]){
                currentChildren = this.productRequests.data.childGrandchildPRMap[row.recordId];
            }
        
            //if OPE, use OPE PR filter
            if(this.isProdSpecOPE){   
                filter = PR_OPE_FILTER;
            //else CCE
            } else{

                //check if parent is SOA, then we use the filter that we allow to add program as child
                if(row.isSOA){
                    filter = PR_SOA_FILTER;
                } else{
                    filter = PR_FILTER;
                }
            }

            //dont show the new record modal if record rtype is flexible or standing offer arrangement
            if(row.isFlexibleProgram){
                newRecord = false;
            } else{
                newRecord = true;
            }
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
        let actions = [];
       
        actions = [{ 
            label: NOT_PROCEEDING_BUTTON_NAME, 
            name: NOT_PROCEEDING_BUTTON_NAME,
            title: NOT_PROCEEDING_BUTTON_NAME
        }];

        if(
            row.recordType === RT_ProductRequest_Program || 
            row.recordType.replace(/ /g,'_') === RT_ProductRequest_SOA ||
            row.recordType.replace(/ /g,'_') === RT_ProductRequest_PWP
        ){
            actions.push({ 
                label: ADD_CHILD_BUTTON_NAME, 
                name: ADD_CHILD_BUTTON_NAME,
                title: ADD_CHILD_BUTTON_NAME
            });
        }else{
            actions.push({ 
                label: ADD_CHILD_BUTTON_NAME, 
                name: ADD_CHILD_BUTTON_NAME,
                title: ADD_CHILD_BUTTON_NAME,
                disabled:true
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