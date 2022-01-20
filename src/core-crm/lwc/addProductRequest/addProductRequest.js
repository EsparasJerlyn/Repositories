/**
 * @description A LWC component for creation of Product Request Record 
 *
 * @see ../classes/AddProductRequestCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                                            |
      |---------------------------|-----------------------|----------------------|---------------------------------------------------------------------------|
      | roy.nino.s.regala         | September 27, 2021    | DEPP-40,42           | Created file                                                              | 
      | roy.nino.s.regala         | October   06, 2021    | DEPP-176             | Added functionality to show no of triads field depending on request type  |
      | angelika.j.s.galang       | December  17, 2021    | DEPP-1088,1096       | Modified to handle OPE records                                            |  
      | adrian.c.habasa           | January   20, 2022    | DEPP-1471            | Added a pop up to input course/program plan name                          |  
*/

import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord,updateRecord } from 'lightning/uiRecordApi';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getFieldLayoutSettings from '@salesforce/apex/AddProductRequestCtrl.getFieldLayoutSettings';
import getAccountId from '@salesforce/apex/AddProductRequestCtrl.getAccountId';
import PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Product_Request__c';
import COURSE_OBJECT from '@salesforce/schema/hed__Course__c';
import PROGRAM_PLAN_OBJECT from '@salesforce/schema/hed__Program_Plan__c';
import PR_PARENT from '@salesforce/schema/Product_Request__c.Parent_Product_Request__c';
import NO_OF_TRIADS from '@salesforce/schema/Product_Request__c.Number_of_Triads__c';
import REQUEST_TYPE from '@salesforce/schema/Product_Request__c.Request_Type__c';

const PROD_REQUESTS = "Product Requests";
const CHILD_PROD_REQUEST = "Child Product Requests";
const RECORD_TYPE_LABEL = "Record Type";
const SUCCESS_TITLE = "Success!";
const SUCCESS_MESSAGE = "Record has been created!";
const SUCCESS_VARIANT = "success";
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const RECORD_TYPE_ERROR = "No record types found.";
const TRAIDS = "Triads";
const SHOW_FIELD = "slds-show slds-form-element slds-form-element_stacked";
const HIDE_FIELD = "slds-hide slds-form-element slds-form-element_stacked";
const PROG_PLAN_REQUEST= "OPE Program Request";

export default class AddProductRequest extends NavigationMixin(LightningElement) {
    @api productRequestForOpe;

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
    isRelatedModalOpen=false;
    accountId='';

    recordTypeLabel = RECORD_TYPE_LABEL;

    //data from parent
    parentId; 
    parentField;
    parentName;


    //gets record type,layout mapping and accountId
    connectedCallback() {
        let objectToCreate = this.productRequestForOpe ? COURSE_OBJECT.objectApiName : PRODUCT_REQUEST_OBJECT.objectApiName;
        getFieldLayoutSettings({objectString: objectToCreate, forOpe: this.productRequestForOpe})
        .then(result =>{
            this.recordTypeOrderMap = this.sortMap(result.recordTypeOrderedList);
            this.fieldLayoutMap = result.fieldLayoutMap;
        })
        .catch(error =>{
            this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
        });

        
    }

    //gets object info of product request object
    //used to get recordtypes
    @wire(getObjectInfo, { objectApiName: PRODUCT_REQUEST_OBJECT})
    objectInfo;

    //get object info of course object
    //used to get recordtyeps
    @wire(getObjectInfo, { objectApiName: COURSE_OBJECT})
    courseObjectInfo;

    //get object info of program plan object
    //used to get recordtyeps
    @wire(getObjectInfo, { objectApiName: PROGRAM_PLAN_OBJECT})
    programPlanObjectInfo;

    
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

    //sets the Object to be Created
    get objectToBeCreated()
    {
        return this.prodReqSelectedRecType == PROG_PLAN_REQUEST ? PROGRAM_PLAN_OBJECT.objectApiName: COURSE_OBJECT.objectApiName;
    }

    //gets the Object Name
    get objectLabel()
    {
        return this.prodReqSelectedRecType == PROG_PLAN_REQUEST? this.programPlanObjectInfo.data.label : this.courseObjectInfo.data.label;
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
            let filteredKeys = this.productRequestForOpe ?
            Object.keys(recordTypeInfo).filter(filterKey => filter.includes(recordTypeInfo[filterKey].name)) :
            Object.keys(recordTypeInfo).filter(filterKey => !filter.includes(recordTypeInfo[filterKey].name));
            
            filteredKeys.map(key => {
                recordTypeInfoMap[recordTypeInfo[key].name] = recordTypeInfo[key].recordTypeId;
            });
            //makes a list of sorted recordtype
            let filteredRecordTypes = this.productRequestForOpe ?
            this.recordTypeOrderMap.filter(filterKey => filter.includes(filterKey.recordTypeName)) :
            this.recordTypeOrderMap.filter(filterKey => !filter.includes(filterKey.recordTypeName));
            this.sortedRecordTypeMap = filteredRecordTypes.map(key =>{
                return {
                    label : key.recordTypeName,
                    description : key.description,
                    value : recordTypeInfoMap[key.recordTypeName]

                }
            });
            this.isSelectionModalOpen = true;
        }else{
            this.showToast(ERROR_TITLE,LWC_Error_General + RECORD_TYPE_ERROR,ERROR_VARIANT);
        }
    }

    closeSelectionModal() {
        this.isSelectionModalOpen = false;
        this.setRecordTypeDetails('');
    }

    openCreationModal() {
        if(this.productRequestForOpe){
            this.createAndRedirectToProductRequest();
        }else{
            this.isSelectionModalOpen = false;
            this.isCreationModalOpen = true;
            this.layoutMapping = this.sortMap(this.fieldLayoutMap[this.selectedRecordTypeName]);
            
            const sectionNames = [];
            this.layoutMapping.map(key => {
                sectionNames.push(key.label);
            })
            this.activeSections = sectionNames;
        }
    }

    prodReqId;
    prodReqSelectedRecType;
    createAndRedirectToProductRequest(){
        const prRtis = this.objectInfo.data.recordTypeInfos;
        let productRequestfields = {};
        productRequestfields.Parent_Product_Request__c = this.parentField == PR_PARENT.fieldApiName ? this.parentId : '';
        productRequestfields.Product_Specification__c = this.parentField !== PR_PARENT.fieldApiName ? this.parentId : '';
        productRequestfields.RecordTypeId = Object.keys(prRtis).find(rti => prRtis[rti].name == this.selectedRecordTypeName); 

        const fields = {...productRequestfields};
        const recordInput = { apiName: PRODUCT_REQUEST_OBJECT.objectApiName, fields};
        
        createRecord(recordInput)
        .then(record => {
            this.showToast('Product Request created.',this.selectedRecordTypeName,'success');
            this.prodReqId=record.id;
            this.prodReqSelectedRecType=this.selectedRecordTypeName;
            this.closeSelectionModal();
            this.openRecordCreation();
        })
        .catch(error => {
            this.showToast('Error.',LWC_Error_General,'error');
        });
    }

    prRecordType;
    handleSubmit(event){
        event.preventDefault();
        const programPlanRtis = this.programPlanObjectInfo.data.recordTypeInfos;
        const courseRtis = this.courseObjectInfo.data.recordTypeInfos;
        
        let fields = event.detail.fields;
        this.prRecordType = this.prodReqSelectedRecType.includes('OPE Activity Request') ? this.prodReqSelectedRecType.replace(' Request','') : this.prodReqSelectedRecType;

        if(this.prodReqSelectedRecType != PROG_PLAN_REQUEST)
        {
            fields.ProductRequestID__c = this.prodReqId;
            fields.RecordTypeId=Object.keys(courseRtis).find(rti => courseRtis[rti].name == this.prRecordType);
            fields.hed__Account__c=this.accountId;
        }
        else
        {
            fields.Product_Request__c = this.prodReqId;
            fields.RecordTypeId=Object.keys(programPlanRtis).find(rti => programPlanRtis[rti].name == this.prRecordType);
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);       
    }
    
    
    updateProductRequestStatusAndRedirect()
    {
        let productReqfields = {};
        productReqfields.Id= this.prodReqId;
        productReqfields.Product_Request_Status__c = 'Design';
        const fields = {...productReqfields};
        const recordInput = {fields};
        updateRecord(recordInput).then((record) => {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: record.id,
                    objectApiName: PRODUCT_REQUEST_OBJECT.objectApiName,
                    actionName: 'view'
                }
            })
          });
    }

    handleCreateLoad()
    {
        getAccountId()
        .then(result =>{
            this.accountId = result;
        });
    }

    handleRecordCreation()
    {
        this.isRelatedModalOpen=false;
        this.dispatchEvent(new CustomEvent('created'));
        this.updateProductRequestStatusAndRedirect();
    }

    handleRecordError()
    {
        this.showToast('Error.',LWC_Error_General,'error');
        this.isRelatedModalOpen=false;
        this.dispatchEvent(new CustomEvent('created'));
    }
    
    openRecordCreation()
    {
        this.isRelatedModalOpen=true;
    }

    closeCreationModal() {
        this.isCreationModalOpen = false;
        this.errorMessage = '';
        this.setRecordTypeDetails('');
    }

    sortMap(dataMap){
        let sortByOrder = dataMap.slice(0);
        if(sortByOrder.length > 0){
            sortByOrder.sort((a,b)  => {
                return a.order - b.order;
            });
        }
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
        this.setFieldVisibility('');
        this.isLoading = false;
    }

    handleChange(event){
        if(event.target.fieldName === REQUEST_TYPE.fieldApiName){
            this.setFieldVisibility(event.target.value);
        }
    }
    
    setFieldVisibility(requestType){
        [...this.template.querySelectorAll('lightning-input-field')]
        .filter( element => element.fieldName === NO_OF_TRIADS.fieldApiName)
        .forEach(element => {
            element.className = requestType === TRAIDS?SHOW_FIELD:HIDE_FIELD; //show field if triads is selected
            element.value = requestType === TRAIDS?element.value:null; //reset value when request type is not triads
            element.required = requestType === TRAIDS?true:false;
        });
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
}