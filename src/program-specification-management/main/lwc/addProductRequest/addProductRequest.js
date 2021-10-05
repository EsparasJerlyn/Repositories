/**
 * @description A LWC component for creation of Product Request Record 
 *
 * @see ../classes/AddProductRequestCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                              |
      |---------------------------|-----------------------|--------------|-------------------------------------------------------------|
      | roy.nino.s.regala         | September 27, 2021    | DEPP-40,42   | Created file                                                | 
 */

import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Product_Request__c';
import getFieldLayoutSettings from '@salesforce/apex/AddProductRequestCtrl.getFieldLayoutSettings';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PR_PARENT from '@salesforce/schema/Product_Request__c.Parent_Product_Request__c';

const PROD_REQUEST = "Product Request";
const PROD_REQUESTS = "Product Requests";
const CHILD_PROD_REQUEST = "Child Product Requests";
const RECORD_TYPE_LABEL = "Record Type";
const SUCCESS_TITLE = 'Success!';
const SUCCESS_MESSAGE = 'Record has been created!';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';
const MSG_ERROR = 'An error has been encountered. Please contact your Administrator.';
const RECORD_TYPE_ERROR = 'No record types found';

export default class AddProductRequest extends LightningElement {

recordTypeMap = [];
isLoading = true;
sortedRecordTypeMap = [];
recordTypeOrderMap;
fieldLayoutMap;
layoutMapping;
activeSections;
selectedRecordType;
selectedRecordTypeName;
isSelectionModalOpen = false;
isCreationModalOpen = false;
errorMessage = '';

recordTypeLabel = RECORD_TYPE_LABEL;

//data from parent
parentId; 
parentfield;
parentName;


    //gets record type and layout mapping
    connectedCallback() {
        getFieldLayoutSettings({objectString: PROD_REQUEST})
        .then(result =>{
            this.recordTypeOrderMap = this.sortMap(result.recordTypeOrderedList);
            this.fieldLayoutMap = result.fieldLayoutMap;
        })
        .catch(error =>{
            this.showToast(ERROR_TITLE,MSG_ERROR + this.generateErrorMessage(error),ERROR_VARIANT);
        });
    }

    //gets object info of product request object
    //used to get recordtypes
    @wire(getObjectInfo, { objectApiName: PRODUCT_REQUEST_OBJECT })
    objectInfo;

    //sets record type options for the radio group
    get optionsMap(){
        return this.sortedRecordTypeMap;
    }

    //disables button if there are no selected recordtype
    get disableButton(){
        return this.selectedRecordType?false:true;
    }

    //sets header on modal
    get modalName(){
        return this.parentField === PR_PARENT.fieldApiName?CHILD_PROD_REQUEST:PROD_REQUESTS;
    }

    //checks if user tries to creates a child of prod request
    get isChild(){
        return this.parentField === PR_PARENT.fieldApiName?true:false;
    }

    //opens selection modal
    //sort,filter and show recordtypes for seletion
    @api openSelectionModal(filter,parentid,parentfield,parentname) {
        if(this.recordTypeOrderMap){
            const recordTypeInfo = this.objectInfo.data.recordTypeInfos;
            this.isLoading = true;
            this.parentId = parentid;
            this.parentField = parentfield;
            this.parentName = parentname;
            let recordTypeInfoMap = {};
            //make a map where key is record type name and value is its id
            Object.keys(recordTypeInfo).filter(filterKey => !filter.includes(recordTypeInfo[filterKey].name)).map(key => {
                recordTypeInfoMap[recordTypeInfo[key].name] = recordTypeInfo[key].recordTypeId;
            });
            //makes a list of sorted recordtype
            this.sortedRecordTypeMap = this.recordTypeOrderMap.filter(filterKey => !filter.includes(filterKey.recordTypeName)).map(key =>{
                return {
                    label : key.recordTypeName,
                    value : recordTypeInfoMap[key.recordTypeName]
                }
            });
            this.isSelectionModalOpen = true;
        }else{
            this.showToast(ERROR_TITLE,MSG_ERROR + RECORD_TYPE_ERROR,ERROR_VARIANT);
        }
    }

    closeSelectionModal() {
        this.isSelectionModalOpen = false;
        this.setRecordTypeDetails('');
    }

    openCreationModal() {
        this.isSelectionModalOpen = false;
        this.isCreationModalOpen = true;
        this.layoutMapping = this.sortMap(this.fieldLayoutMap[this.selectedRecordTypeName]);
        const sectionNames = [];
        this.layoutMapping.map(key => {
            sectionNames.push(key.label);
        })
        this.activeSections = sectionNames;
    }

    closeCreationModal() {
        this.isCreationModalOpen = false;
        this.errorMessage = '';
        this.setRecordTypeDetails('');
    }

    sortMap(dataMap){
        let sortByOrder = dataMap.slice(0);
        sortByOrder.sort((a,b)  => {
            return a.order - b.order;
        });
        return sortByOrder;
    }

    getRadioValue(event){
        this.setRecordTypeDetails(event.target.value);
    }

    setRecordTypeDetails(type){
        this.selectedRecordType = type;
        this.selectedRecordTypeName =  this.selectedRecordType === ''?'':this.sortedRecordTypeMap.find(item => item.value === this.selectedRecordType).label;
    }

    handleSuccess(){
        this.showToast(SUCCESS_TITLE,SUCCESS_MESSAGE,SUCCESS_VARIANT);
        this.dispatchEvent(new CustomEvent('created'));
        this.closeCreationModal();
    }

    handleError(event) {
        const errorMessages = event.detail.output.errors;
        this.errorMessage = '';
        if(errorMessages){
            errorMessages.forEach(element => {
                this.errorMessage += element.message;
            });
        }
    }

    handleLoad(){
        this.isLoading = false;
    }

    //shows success or error messages
    showToast(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
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