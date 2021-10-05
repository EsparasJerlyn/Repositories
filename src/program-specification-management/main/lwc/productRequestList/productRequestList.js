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
      |                           |                       |                      |                                       | 
 */
import { LightningElement, wire,api } from 'lwc';
import getProductRequests from '@salesforce/apex/ProductRequestListCtrl.getProductRequests';
import PR_PARENT from '@salesforce/schema/Product_Request__c.Parent_Product_Request__c';
import PS_PARENT from '@salesforce/schema/Product_Request__c.Program_Specification__c';
import { refreshApex } from '@salesforce/apex';

const PS_FILTER = ['Diagnostic Tool Request'];
const PR_FILTER = ['Program Request','Stand-Alone Unit / Module Request','Professional Advantage Request'];
const ACCORDION_SECTION = "Product Requests";
const MSG_ERROR = 'An error has been encountered. Please contact your Administrator.';

export default class ProductRequestList extends LightningElement {
    @api recordId;
    
    activeSections = [ACCORDION_SECTION];
    // definition of columns for the tree grid
    gridColumns;
    // data provided to the tree grid
    gridData = [];
    recordTypeFilter = [];
    isLoading = true;
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
        return ACCORDION_SECTION;
    }
    /**
     * checks if there are product requests
     */
    get haveRequests(){
        return this.gridData.length !== 0?true:false;
    }

    productRequests;
    @wire(getProductRequests, {programSpecificationId : '$recordId'})
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
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(result.error);
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
            newItem.addChildButton = isChild ? 'slds-hide' : 'slds-show';

            return newItem;
        });
    }

    /**
     * handles action and data when ADD CHILD button is clicked 
     */
    handleRowAction(event){
        const row = event.detail.row;
        this.openChildModal(PR_FILTER,row.recordId,PR_PARENT.fieldApiName,row.id);
    }

    /**
     * handles action and data when ADD button is clicked
     */
    handleAddButton(){
        this.openChildModal(PS_FILTER,this.recordId,PS_PARENT.fieldApiName,'');
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
     * concatenates error name and message
     */
     generateErrorMessage(err){
        let _errorMsg = ' (';

        _errorMsg += err.name && err.message ? err.name + ': ' + err.message : err.body.message;
        _errorMsg += ')';

        return _errorMsg;
    }
}