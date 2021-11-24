/**
 * @description A custom LWC for creating Asset under Product Request
 *
 * @see ../classes/createAssetCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | adrian.c.habasa           | November 11, 2021     | DEPP-664     | Created file                                           | 
      |                           |                       |              |                                                        |
*/
import { LightningElement,wire,api, track } from 'lwc';
import{getRecord, updateRecord,createRecord} from "lightning/uiRecordApi";
import getLayoutMapping from '@salesforce/apex/CreateAssetCtrl.getLayoutMapping';
import getRelatedRecords from '@salesforce/apex/CreateAssetCtrl.getRelatedRecords';
import { refreshApex } from '@salesforce/apex';
import ASSET_OBJECT from "@salesforce/schema/Asset";
import PRODUCT_REQUEST_NAME from "@salesforce/schema/Product_Request__c.Product_Request_Name__c";
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PRODUCT_SPEC from "@salesforce/schema/Product_Request__c.Product_Specification__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateAsset extends LightningElement {
    @api objectApiName;
    @api recordId;

    isLoading = true;
    layoutMapping=[];
    layoutToDisplay=[];
    objectName= ASSET_OBJECT;
    @track assetRecordId='';
    @track accountRecordId='';
    viewMode= true;

    /**
     * gets the UI to be rendered
     */
    formatLayoutMapping(){
        getLayoutMapping({objApiName:ASSET_OBJECT.objectApiName})
        .then(result => {
            this.layoutMapping = [...result];
            this.formatLayoutToDisplay();
        })
        .catch(error =>{
            this.generateToast('Error.',ERROR_MSG,'error');
        })
        .finally(() => {
            refreshApex(this.relatedAssetRecords);
            this.isLoading = false;
        });
    }

    /**
     * formats layout columns for UI rendering
     */
    formatLayoutToDisplay(){
        let listToFormat = this.layoutMapping;
        this.layoutToDisplay = listToFormat.map(layout => {
            let layoutItem = {};

            layoutItem.sectionLabel = layout.MasterLabel;
            layoutItem.leftColumn = layout.Left_Column_Long__c ? this.formatFieldProperties(JSON.parse(layout.Left_Column_Long__c)) : null;
            layoutItem.rightColumn = layout.Right_Column_Long__c ? this.formatFieldProperties(JSON.parse(layout.Right_Column_Long__c)) : null;
            layoutItem.singleColumn = layout.Single_Column_Long__c ? JSON.parse(layout.Single_Column_Long__c) : null;
            
            return layoutItem;
        });
     }

     /**
     * pre-populates specified fields if in create mode
     */
     formatFieldProperties(listToFormat){
        return listToFormat.length ? listToFormat.map(item => {
            let _field = {...item}; 

            //if in create mode
            if(!this.assetRecordId){
                if(item.field == 'Name'){
                    _field.value = this.productRequestName;
                }else if( item.field == 'AccountId'){
                    _field.value = this.accountRecordId;
                }
            }

            return _field;
        }) : [];
    }


    /**
     * gets the value from Product Request Fields
     */
    productSpecId;
    productRequestName;
    productRequestStatus;
    productRequestRecord;
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [PRODUCT_REQUEST_NAME,
                PR_STATUS,
                PRODUCT_SPEC]
    })
    productRequestRecordResult(result)
    {
        if(result.data){
            this.productRequestRecord = result;
            this.productRequestName = result.data.fields.Product_Request_Name__c.value;
            this.productRequestStatus = result.data.fields.Product_Request_Status__c.value;
            this.productSpecId = result.data.fields.Product_Specification__c.value;
         
        }
    }
    
    /**
     * gets Asset Id and Related Account Id
     */
    relatedAssetRecords;
    @wire(getRelatedRecords,{productRequestId: '$recordId', productSpecificationId : '$productSpecId'})
    relatedRecords(result)
    {
        if(result.data)
        {
            this.relatedAssetRecords = result;
            this.assetRecordId = result.data['assetId'];
            this.accountRecordId = result.data['accountId'];
            this.formatLayoutMapping();
        }
        else if(result.error)
        {
            this.generateToast('Error.',ERROR_MSG,'error');
        }
    }

    /**
     * updates status to Release if mark as completed button is clicked
     */
    handleMarkAsComplete()
    {
        if(this.assetRecordId != null)
        {
            const fields = {};
            fields.Id = this.recordId;
            fields.Product_Request_Status__c = 'Release';
            this.handleUpdateRecord(fields,true);
        }
    }

    

     /**
     * prevents default edit form submission
     * stores draft and fires an event to pass it
     */
    handleSubmit(event)
    {
        event.preventDefault();
        let fields = event.detail.fields;
        this.viewMode=true;
        if(this.assetRecordId)
        {
            fields.Id = this.assetRecordId;
            this.handleUpdateRecord(fields,false);

        }
        else
        {
            fields.Product_Request__c = this.recordId;
            this.handleCreateRecord(ASSET_OBJECT.objectApiName,fields);
        }
    }

    /**
     * creates record given object api name and fields
     */
    handleCreateRecord(objApiName,fieldsToCreate)
    {
        this.isLoading = true;
        const fields = {...fieldsToCreate};
        const recordInput = { apiName: objApiName, fields};

        createRecord(recordInput)
        .then(record => {
            this.generateToast('Success!','Record created.','success');
        })
        .catch(error => {
            this.generateToast('Error.',ERROR_MSG,'error');
        })
        .finally(() => {
            this.isLoading = false;
            refreshApex(this.relatedAssetRecords);
        });
        
    }
    
    /**
     * updates record given fields
     * fieldsToUpdate are fields that will be updated
     * forProductRequest is a boolean to check if record being updated is of type Product Request
     */
     handleUpdateRecord(fieldsToUpdate,forProductRequest){
        this.isLoading = true;
        const fields = {...fieldsToUpdate};
        const recordInput = {fields};

        updateRecord(recordInput)
        .then(()=> {
            if(forProductRequest)
            {
                this.generateToast('Success!','Design marked as completed.','success');
            }
            else{
                this.generateToast('Success!','Record Updated.','success');
            }
        })
        .catch(error => {
            this.generateToast('Error.',ERROR_MSG,'error');
        })
        .finally(() => { 
            this.isLoading = false;
        });
    }

    /**
     * Enables edit mode
     */
    handleEditAsset()
    {
        this.viewMode= false;
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

    /**
     * Turns off spinner when saving a record is a Success 
     */
    handleSuccess()
    {
        this.isLoading = false;
    }

    /**
     * Resets the input field when cancelled
     */
    handleCancelButton()
    {
        this.viewMode = true;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if(inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
 
    /**
     * returns boolean that determines of mark as complete button should be disabled
     */
     get disableMarkAsComplete(){
        return this.viewMode == false || this.assetRecordId == null || this.productRequestStatus !== 'Design' ? true : false;
    }

    /**
     * returns boolean that determines if Edit button should be visible
     */
    get editableField()
    {
        return this.productRequestStatus == 'Design' ? true :  false;
    }
}
