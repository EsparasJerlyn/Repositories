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
      | john.bo.a.pineda          | February  22, 2022    | DEPP-1791            | Modified logic to create Product Request after saving Related Object Name |
*/

import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord,updateRecord } from 'lightning/uiRecordApi';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Product_Request__c';
import COURSE_OBJECT from '@salesforce/schema/hed__Course__c';
import PROGRAM_PLAN_OBJECT from '@salesforce/schema/hed__Program_Plan__c';
import PP_PROGRAM_TYPE from '@salesforce/schema/hed__Program_Plan__c.Program_Type__c';
import PR_OPE_TYPE from '@salesforce/schema/Product_Request__c.OPE_Program_Plan_Type__c';
import PR_PARENT from '@salesforce/schema/Product_Request__c.Parent_Product_Request__c';
import NO_OF_TRIADS from '@salesforce/schema/Product_Request__c.Number_of_Triads__c';
import REQUEST_TYPE from '@salesforce/schema/Product_Request__c.Request_Type__c';
import getFieldLayoutSettings from '@salesforce/apex/AddProductRequestCtrl.getFieldLayoutSettings';
import getAccountId from '@salesforce/apex/AddProductRequestCtrl.getAccountId';
import getRecordTypes from '@salesforce/apex/AddProductRequestCtrl.getRecordTypes';

const PROD_REQUESTS = "Product Requests";
const CHILD_PROD_REQUEST = "Child Product Requests";
const RECORD_TYPE_LABEL = "Record Type";
const SUCCESS_TITLE = "Success!";
const SUCCESS_MESSAGE = "Record has been created!";
const SUCCESS_VARIANT = "success";
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const TRAIDS = "Triads";
const SHOW_FIELD = "slds-show slds-form-element slds-form-element_stacked";
const HIDE_FIELD = "slds-hide slds-form-element slds-form-element_stacked";
const PROG_PLAN_REQUEST= RT_ProductRequest_Program;

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
    prodReqId;
    isSelectionModalOpen = false;
    isCreationModalOpen = false;
    errorMessage = '';
    isRelatedModalOpen=false;
    accountId='';
    programTypeDefaultValue='';
    saveInProgress = false;

    recordTypeLabel = RECORD_TYPE_LABEL;

    //data from parent
    parentId;
    parentField;
    parentName;

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
    get objectToBeCreated(){
        return this.selectedRecordTypeName == PROG_PLAN_REQUEST ? PROGRAM_PLAN_OBJECT.objectApiName: COURSE_OBJECT.objectApiName;
    }

    //gets the Object Name
    get objectLabel(){
        return this.selectedRecordTypeName == PROG_PLAN_REQUEST? this.programPlanObjectInfo.data.label : this.courseObjectInfo.data.label;
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

    //gets picklist values of program type field
    @wire(getPicklistValues, { recordTypeId: '$programPlanObjectInfo.data.defaultRecordTypeId', fieldApiName: PP_PROGRAM_TYPE })
    handleProgramTypes(result){
        if(result.data){
            this.programTypeDefaultValue = result.data.defaultValue.value;
        }else if(result.error){
            this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
        }
    }

    //gets record type,layout mapping and accountId
    connectedCallback() {
        if(!this.productRequestForOpe){
            getFieldLayoutSettings({
                objectString: PRODUCT_REQUEST_OBJECT.objectApiName,
                forOpe: this.productRequestForOpe
            })
            .then(result =>{
                this.recordTypeOrderMap = this.sortMap(result.recordTypeOrderedList);
                this.fieldLayoutMap = result.fieldLayoutMap;
            })
            .catch(error =>{
                this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
            });
        }
    }

    /* ------- Product Request Selection Methods Start ------- */
    
    //opens selection modal
    //sort,filter and show recordtypes for seletion
    @api openSelectionModal(filter,parentid,parentfield,parentname) {
        this.isLoading = true;
        this.parentId = parentid;
        this.parentField = parentfield;
        this.parentName = parentname;

        const recordTypeInfo = this.objectInfo.data.recordTypeInfos;
        let filteredKeys = Object.keys(recordTypeInfo).filter(filterKey => filter.includes(recordTypeInfo[filterKey].name));

        if(this.recordTypeOrderMap){
            let recordTypeInfoMap = {};
            //make a map where key is record type name and value is its id
            filteredKeys.map(key => {
                recordTypeInfoMap[recordTypeInfo[key].name] = recordTypeInfo[key].recordTypeId;
            });
            //makes a list of sorted recordtype
            let filteredRecordTypes = this.recordTypeOrderMap.filter(filterKey => filter.includes(filterKey.recordTypeName)); 
            filteredRecordTypes = this.sortMap(filteredRecordTypes);
            this.sortedRecordTypeMap = filteredRecordTypes.map(key =>{
                return {
                    label : key.recordTypeName,
                    description : key.description,
                    value : recordTypeInfoMap[key.recordTypeName]
                }
            });
            this.isSelectionModalOpen = true;
        }else{
            getRecordTypes({
                objectType: PRODUCT_REQUEST_OBJECT.objectApiName,
                filter: filteredKeys
            })
            .then(result =>{
                this.sortedRecordTypeMap = [...result].sort((a, b) => 
                    filter.indexOf(a.label) - filter.indexOf(b.label)
                );
                this.isSelectionModalOpen = true;
            })
            .catch(error =>{
                this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
            });
        }
    }

    //closes main selection modal
    closeSelectionModal() {
        this.isSelectionModalOpen = false;
        this.setRecordTypeDetails('');
    }

    //handler for radio button change event
    getRadioValue(event){
        this.setRecordTypeDetails(event.target.value);
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

    //sets selected product request record type
    setRecordTypeDetails(type){
        this.selectedRecordType = type;
        this.selectedRecordTypeName =  this.selectedRecordType === ''?'':this.sortedRecordTypeMap.find(item => item.value === this.selectedRecordType).label;
    }

    /* ------- Product Request Selection Methods End ------- */

    /* ------- Product Request Create Methods Start (CCE) ------- */

    //opens create form for CCE
    //opens course/program plan name form for OPE
    openCreationModal() {
        this.isSelectionModalOpen = false;

        if(this.productRequestForOpe){
            this.isRelatedModalOpen=true;
        }else{
            this.isCreationModalOpen = true;
            this.layoutMapping = this.sortMap(this.fieldLayoutMap[this.selectedRecordTypeName]);

            const sectionNames = [];
            this.layoutMapping.map(key => {
                sectionNames.push(key.label);
            })
            this.activeSections = sectionNames;
        }
    }

    //closes record input form
    closeCreationModal() {
        this.isCreationModalOpen = false;
        this.errorMessage = '';
        this.setRecordTypeDetails('');
    }

    //handles successful product request save
    handleSuccess(){
        this.showToast(SUCCESS_TITLE,SUCCESS_MESSAGE,SUCCESS_VARIANT);
        this.dispatchEvent(new CustomEvent('created'));
        this.closeCreationModal();
    }

    //handles product request errors on save
    handleError(event) {
        const errorMessages = event.detail.output.errors;
        this.errorMessage = '';
        if(errorMessages){
            errorMessages.forEach(element => {
                this.errorMessage += element.message;
            });
        }
    }

    //hides dependent fields on form load
    handleLoad(){
        this.setFieldVisibility('');
        this.isLoading = false;
    }

    //handles product request create form change
    handleChange(event){
        if(event.target.fieldName === REQUEST_TYPE.fieldApiName){
            this.setFieldVisibility(event.target.value);
        }
    }

    //shows the dependent field if conditions satisfy
    setFieldVisibility(requestType){
        [...this.template.querySelectorAll('lightning-input-field')]
        .filter( element => element.fieldName === NO_OF_TRIADS.fieldApiName)
        .forEach(element => {
            element.className = requestType === TRAIDS?SHOW_FIELD:HIDE_FIELD; //show field if triads is selected
            element.value = requestType === TRAIDS?element.value:null; //reset value when request type is not triads
            element.required = requestType === TRAIDS?true:false;
        });
    }

    /* ------- Product Request Create Methods Start (CCE) ------- */

    /* ------- Course / Program Plan Create Methods Start (OPE) ------- */

    //gets QUTeX id on form load
    handleCreateLoad(){
        getAccountId()
        .then(result =>{
            this.accountId = result;
        });
    }

    //creates product request on save
    createProductRequest(event){
        event.preventDefault();
        this.saveInProgress = true;

        const prRtis = this.objectInfo.data.recordTypeInfos;
        let productRequestfields = {};
        productRequestfields.Parent_Product_Request__c = this.parentField == PR_PARENT.fieldApiName ? this.parentId : '';
        productRequestfields.Product_Specification__c = this.parentField !== PR_PARENT.fieldApiName ? this.parentId : '';
        productRequestfields.RecordTypeId = Object.keys(prRtis).find(rti => prRtis[rti].name == this.selectedRecordTypeName);

        const fields = {...productRequestfields};
        const recordInput = { apiName: PRODUCT_REQUEST_OBJECT.objectApiName, fields};

        createRecord(recordInput)
        .then(record => {
            this.prodReqId=record.id;
            this.dispatchEvent(new CustomEvent('created'));
            this.showToast('Product Request created.',this.selectedRecordTypeName,SUCCESS_VARIANT);
            this.handleSubmit(event);
        })
        .catch(error => {
            this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
        });
    }

    //creates course/program plan on save
    handleSubmit(event){
        const programPlanRtis = this.programPlanObjectInfo.data.recordTypeInfos;
        const courseRtis = this.courseObjectInfo.data.recordTypeInfos;

        let fields = event.detail.fields;

        if(this.selectedRecordTypeName != PROG_PLAN_REQUEST){
            fields.ProductRequestID__c = this.prodReqId;
            fields.RecordTypeId=Object.keys(courseRtis).find(rti => courseRtis[rti].name == this.selectedRecordTypeName);
            fields.hed__Account__c=this.accountId;
        }
        else{
            fields.Product_Request__c = this.prodReqId;
            fields.RecordTypeId=Object.keys(programPlanRtis).find(rti => programPlanRtis[rti].name == this.selectedRecordTypeName);
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    //updates product request status after course/program plan insert to avoid hitting validation rules
    //navigates to updated product request after
    updateProductRequestStatusAndRedirect(){
        let productReqfields = {};
        productReqfields.Id= this.prodReqId;
        productReqfields.Product_Request_Status__c = 'Design';
        if(this.selectedRecordTypeName == PROG_PLAN_REQUEST){
            productReqfields[PR_OPE_TYPE.fieldApiName] = this.programTypeDefaultValue;
        }
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
        })
        .finally(() => {
            this.saveInProgress = false;
            this.isRelatedModalOpen=false;
            this.setRecordTypeDetails('');
        });
    }

    //shows toast on error upon saving the course/program plan
    handleRecordError(event){
        this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
    }

    //closes course/program plan name form modal
    closeRecordCreation(){
        this.isRelatedModalOpen=false;
        this.setRecordTypeDetails('');
    }

    /* ------- Course / Program Plan Create Methods End ------- */

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