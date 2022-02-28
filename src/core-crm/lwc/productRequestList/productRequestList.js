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
import PR_PARENT from '@salesforce/schema/Product_Request__c.Parent_Product_Request__c';
import PS_PARENT from '@salesforce/schema/Product_Request__c.Product_Specification__c';

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
        return this.prodSpecRecordType == RT_ProductSpecification_OPEProgramSpecification;
    }


    prodSpecRecordType;
    @wire(getRecord, { recordId: '$recordId', fields: [PS_RECORD_TYPE] })
    handleProductSpecification(result){
        if(result.data){
           this.prodSpecRecordType = getFieldValue(result.data, PS_RECORD_TYPE);
           this.showProductRequest = true;
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    productRequests;
    @wire(getProductRequests, {productSpecificationId : '$recordId'})
    getProductRequests(result){
        if(result.data){
            this.productRequests = result;
            let parentProductRequests = this.formatData(this.productRequests.data.parentList);
            let parentChildProductRequests = this.productRequests.data.parentChildMap;
            parentProductRequests.forEach(parentProdReq =>{
                let childProdReqs = 
                    parentChildProductRequests[parentProdReq.recordId] ?
                    this.formatData(parentChildProductRequests[parentProdReq.recordId],true) : [];
                
                if(childProdReqs.length > 0){
                    parentProdReq._children = [...childProdReqs];
                }

                this.gridData = [parentProdReq, ...this.gridData];
            });
            this.isLoading = false;
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
            this.isLoading = false;
        }
    }

    /**
     * formats the data from apex for the data grid
     */
     formatData(listToFormat,isChild){
        return listToFormat.map(item =>{
            let newItem = {};

            newItem.recordId = item.Id;
            newItem.parentId = item.Parent_Product_Request__c;
            newItem.id = item.Name;
            newItem.idUrl = '/' + item.Id;
            newItem.recordType = item.RecordType.Name;
            newItem.name = item.Product_Request_Name__c;
            newItem.owner = item.Owner.Name;
            newItem.ownerUrl = '/' + item.OwnerId;
            newItem.addChildButton = 
                !isChild && 
                item.RecordType.DeveloperName === RT_ProductRequest_Program 
                ? 'slds-show' : 'slds-hide';

            return newItem;
        });
    }

    /**
     * handles action and data when ADD CHILD button is clicked 
     */
    handleRowAction(event){
        const row = event.detail.row;
        let filter = this.isProdSpecOPE ? PR_OPE_FILTER : PR_FILTER;
        this.openChildModal(filter,row.recordId,PR_PARENT.fieldApiName,row.id);
    }

    /**
     * handles action and data when ADD button is clicked
     */
    handleAddButton(){
        let filter = this.isProdSpecOPE ? PS_OPE_FILTER : PS_FILTER;
        this.openChildModal(filter,this.recordId,PS_PARENT.fieldApiName,'');
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
     * opens recordtype selection modal of addProductRequest child compoent
     * passes needed data as well
     */
    openChildModal(filter,id,field,name){
        this.template.querySelector("c-add-product-request").openSelectionModal(filter,id,field,name);
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