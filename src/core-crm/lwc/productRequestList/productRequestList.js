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
import PS_RECORD_TYPE from '@salesforce/schema/Product_Specification__c.RecordType.DeveloperName';
import getFieldLayoutSettings from '@salesforce/apex/AddProductRequestCtrl.getFieldLayoutSettings';
import PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Product_Request__c';
import getRecordTypes from '@salesforce/apex/AddProductRequestCtrl.getRecordTypes';

const COMMA = ',';
const PS_FILTER = LWC_List_CCEParentFilter.split(COMMA);
const PR_FILTER = LWC_List_CCEChildFilter.split(COMMA);
const PS_OPE_FILTER = LWC_List_OPEParentFilter.split(COMMA);
const PR_OPE_FILTER = LWC_List_OPEChildFilter.split(COMMA);
const ACCORDION_SECTION = 'Product Requests';
const OPE_ACCORDION_SECTION = 'Add Products';

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
    recordTypeOrderMapOpe;
    recordTypeOrderMapCce;
    
    /**
     * constructs the header of lightning data grid
     */
     constructor(){
        super();
        this.gridColumns = [
            {
                fieldName: 'idUrl',
                label: 'Product Request ID',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'id'
                    }
                }
            },
            {
                fieldName: 'recordType',
                label: 'Record Type',
            },
            {
                fieldName: 'name',
                label: 'Product Request Name',
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
                type: 'button',
                typeAttributes: {
                    iconName: 'utility:add',
                    iconPosition: 'right',
                    label: 'ADD CHILD',
                    name: 'ADD CHILD',
                    title: 'ADD CHILD',
                    disabled: false,
                    variant: 'brand',
                    class: {fieldName:'addChildButton'},
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
            let parentChildProductRequests = this.productRequests.data.parentChildMap; // map of product request to its children
            parentProductRequests.forEach(parentProdReq =>{
                let childProdReqs = 
                    parentChildProductRequests[parentProdReq.recordId] ?
                    this.formatData(parentChildProductRequests[parentProdReq.recordId],true) : [];
                
                if(childProdReqs.length > 0){
                    parentProdReq._children = [...childProdReqs];
                }
                this.gridData = [parentProdReq, ...this.gridData];
            });
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
        this.isLoading = false;
    }

    prodSpecRecordType;
    @wire(getRecord, { recordId: '$recordId', fields: [PS_RECORD_TYPE] })
    handleProductSpecification(result){
        if(result.data){
           this.prodSpecRecordType = getFieldValue(result.data, PS_RECORD_TYPE);
           this.showProductRequest = true;
            if(!this.isProdSpecOPE){
                getFieldLayoutSettings({
                    objectString: PRODUCT_REQUEST_OBJECT.objectApiName,
                    forOpe: this.isProdSpecOPE
                })
                .then(result =>{
                    this.recordTypeOrderMapCce = this.sortMap(result.recordTypeOrderedList);
                    this.fieldLayoutMap = result.fieldLayoutMap;
                })
                .catch(error =>{
                    console.log(error);
                    this.generateToast('Error.',LWC_Error_General,'error');
                }); 
            }else{
                getRecordTypes({
                    objectType: PRODUCT_REQUEST_OBJECT.objectApiName
                })
                .then(result =>{
                    this.recordTypeOrderMapOpe = [...result];
                })
                .catch(error =>{
                    console.log(error);
                    this.generateToast('Error.',LWC_Error_General,'error');
                });
            }
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
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

    //sorts list by order field
    sortMap(dataMap){
        let sortByOrder = dataMap.slice(0);
        if(sortByOrder.length > 0){
            sortByOrder.sort((a,b)  => {
                return a.order - b.order;
            });
        }
        return sortByOrder;
    }

    /**
     * formats the data from apex for the data grid
     */
     formatData(listToFormat,isChild){
        return listToFormat.map(item =>{
            let newItem = {};
            newItem.recordId = item.Id;
            newItem.id = item.Name;
            newItem.idUrl = '/' + item.Id;
            newItem.recordType = item.RecordType.Name;
            newItem.name = item.Product_Request_Name__c;
            newItem.owner = item.Owner.Name;
            newItem.ownerUrl = '/' + item.OwnerId;
            if(item.Program_Plans__r && item.Program_Plans__r[0] && item.Program_Plans__r[0].Program_Delivery_Structure__c === 'Flexible Program'){
                newItem.isFlexibleProgram = true;
            }
            if(item.Courses__r && item.Courses__r[0] && item.Courses__r[0].Name){
                newItem.courseName = item.Courses__r[0].Name;
            }
            newItem.addChildButton = 
                !isChild && 
                item.RecordType.DeveloperName === RT_ProductRequest_Program 
                ?  'slds-show': 'slds-hide';
            return newItem;
        });
    }

    /**
     * handles action and data when ADD CHILD button is clicked 
     */
    handleRowAction(event){
        const row = event.detail.row;
        let filter = this.isProdSpecOPE ? PR_OPE_FILTER : PR_FILTER;
        let currentChildren = this.productRequests.data.parentChildMap[row.recordId]?this.productRequests.data.parentChildMap[row.recordId]:[];
        let newRecord = row.isFlexibleProgram?false:true;
        this.template.querySelector("c-add-product-request").openSelectionModal(newRecord,row,filter,currentChildren,true,this.prodSpecData());
        
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