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
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord, updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CURRENT_USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_DIVISION from '@salesforce/schema/User.Division';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Product_Request__c';
import RELATED_PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Related_Product_Request__c';
import COURSE_OBJECT from '@salesforce/schema/hed__Course__c';
import PROGRAM_PLAN_OBJECT from '@salesforce/schema/hed__Program_Plan__c';
import PR_OPE_TYPE from '@salesforce/schema/Product_Request__c.OPE_Program_Plan_Type__c';
import PROD_SPEC_APINAME from '@salesforce/schema/Product_Request__c.Product_Specification__c';
import getAccountId from '@salesforce/apex/AddProductRequestCtrl.getAccountId';
import getSearchedCourseProductRequests from '@salesforce/apex/AddProductRequestCtrl.getSearchedCourseProductRequests';
import getSearchedUsers from '@salesforce/apex/AddProductRequestCtrl.getSearchedUsers';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const PROD_REQUESTS = "Product Requests";
const CHILD_PROD_REQUEST = "Child Product Requests";
const RECORD_TYPE_LABEL = "Record Type";
const SUCCESS_VARIANT = "success";
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const PROG_PLAN_REQUEST= RT_ProductRequest_Program;

export default class AddProductRequest extends NavigationMixin(LightningElement) {
    @api productRequestForOpe;
    @api recordTypeMap;
    @api fieldLayoutMap;
    @api recordId;

    recordTypeMap = [];
    isLoading = true;
    sortedRecordTypeMap = [];
    layoutMapping;
    activeSections;
    selectedRecordType;
    selectedRecordTypeName;
    isSelectionModalOpen = false;
    isCreationModalOpen = false;
    isAddExistingModal = false;
    errorMessage = '';
    isRelatedModalOpen=false;
    accountId='';
    saveInProgress = false;
    existingProdReqId='';
    savingExistingPR = false;
    lookupItemsFormatted = [];
    searchInProgress = false;
    objectLabelName = 'Product Request';
    prodReqId;
    programDeliveryStructure;

    recordTypeLabel = RECORD_TYPE_LABEL;

    //data from parent
    parentRecord;
    isChild;
    currentChildren;
    prodSpecData;
    recordTypeFilter;
    parentField = PROD_SPEC_APINAME.fieldApiName;

    //sets record type options for the radio group
    get optionsMap(){
        return this.sortedRecordTypeMap;
    }

    //disables button if there are no selected recordtype
    get disableButton(){
        return this.selectedRecordTypeName === ''?true:false;
    }

    //sets header on modal
    get modalName(){
        return this.isChild?CHILD_PROD_REQUEST:PROD_REQUESTS;
    }
    
    //checks if user selected Program 
    get isProgramSelected(){
        return this.selectedRecordTypeName == PROG_PLAN_REQUEST;
    }

    //sets the Object to be Created
    get objectToBeCreated(){
        return this.isProgramSelected ? PROGRAM_PLAN_OBJECT.objectApiName: COURSE_OBJECT.objectApiName;
    }

    //gets the Object Name
    get objectLabel(){
        return this.isProgramSelected ? this.programPlanObjectInfo.data.label : this.courseObjectInfo.data.label;
    }

    get disableAddExistingButton(){
        return this.existingProdReqId == '' || this.savingExistingPR?true:false; 
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

    //opens selection modal
    //sort,filter and show recordtypes for seletion
    @api openSelectionModal(newRecord,row,filter,currentChildren,isChild,prodSpec) {
        this.prodSpecData = prodSpec;
        this.isLoading = true;
        this.parentRecord = row;
        this.isChild = isChild;
        this.currentChildren = currentChildren;
        this.recordTypeFilter = filter;
        this.isAddExistingModal = !newRecord;
        this.setRecordTypeSelection(filter);
    }

    setRecordTypeSelection(filter){
        if(this.recordTypeMap){
            this.sortedRecordTypeMap = this.recordTypeMap.filter(filterKey => filter.includes(filterKey.label)).sort((a, b) => 
                    filter.indexOf(a.label) - filter.indexOf(b.label)
                );
            this.isSelectionModalOpen = true;
        }
    }

    //closes main selection modal
    closeSelectionModal() {
        this.resetSelectionModalFlags();
    }

    handleCreateNewRecord(){
        this.openSelectionModal(true,this.parentRecord,this.recordTypeFilter,[],true,this.prodSpecData);
    }

    resetSelectionModalFlags(){
        this.isSelectionModalOpen = false;
        this.isAddExistingModal = false;
        this.existingProdReqId = '';
        this.savingExistingPR = false;
        this.setRecordTypeDetails('');
        this.lookupItemsFormatted = [];
    }
    
    handleSearch(event){
        this.searchInProgress = true;
        getSearchedCourseProductRequests({
            filterString: event.detail.filterString,
            filterPRList:this.currentChildren,
            prodSpecRecordType:this.prodSpecData.recordType
        })
        .then(result =>{
            if(result){
                this.lookupItemsFormatted = result.map(item => {
                    return this.formatSearchItem(item);
                })
            }else{
                this.lookupItemsFormatted = [];
            }
        })
        .finally(()=>{
            this.searchInProgress = false;
        })
        .catch(error =>{
            this.showToastoast('Error.',LWC_Error_General,'error');
        });
    }

     /*
    * formats the product request records for the customSearch lwc
    */
     formatSearchItem(item){
        let searchItem = {};
        searchItem.id = item.Id;
        if(item.Courses__r && item.Courses__r[0] && item.Courses__r[0].Name){
            searchItem.label = item.Courses__r[0].Name;
        }else{
            searchItem.label = '';
        }
        searchItem.meta = item.Name + ' • ' + item.RecordType.Name;
        return searchItem;
    }

    handleLookupSelect(event){
        this.existingProdReqId = event.detail.value;
    }

    handleLookupRemove(){
        this.existingProdReqId = '';
        this.lookupItemsFormatted = [];
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

    /* ------- Product Request Create Methods Start (CCE) ------- */

    //opens create form for CCE
    //opens course/program plan name form for OPE
    openCreationModal() {
        this.isSelectionModalOpen = false;
        this.isRelatedModalOpen=true;   
    }

    //custom user lookup variables
    userSearchItems = [];
    showOwnerError = false;
    searchUserInProgress = false;
    selectedUserId;
    
    //gets current user details
    userResult;
    @wire(getRecord, { recordId: CURRENT_USER_ID, fields: [USER_NAME,USER_DIVISION] })
    handleUserRecord(result){
        if(result.data){
            this.userResult = result.data;
            this.assignCurrentUserDetails();
        }
    }

    assignCurrentUserDetails(){
        this.selectedUserId = CURRENT_USER_ID;
        this.userSearchItems = [{
            id:CURRENT_USER_ID,
            label:getFieldValue(this.userResult,USER_NAME),
            meta:getFieldValue(this.userResult,USER_DIVISION)
        }];
    }

    //gets QUTeX id on form load 
    handleCreateLoad(){
        getAccountId()
        .then(result =>{
            this.accountId = result;
        });
    }

    //returns list of users based on input
    handleUserSearch(event){
        this.searchUserInProgress = true;
        getSearchedUsers({ filterString: event.detail.filterString })
        .then(result =>{
            this.userSearchItems = result;
        })
        .finally(()=>{
            this.searchUserInProgress = false;
        })
        .catch(error =>{
            this.showToastoast('Error.',LWC_Error_General,'error');
        });
    }

    //sets selected user id
    handleUserSelect(event){
        this.showOwnerError = false;
        this.selectedUserId = event.detail.value;
    }

    //removes selected user
    handleUserRemove(){
        this.selectedUserId = undefined;
        this.userSearchItems = [];
    }

    //creates product request on save
    createProductRequest(event){
        event.preventDefault();
        if(!this.selectedUserId){
            this.showOwnerError = true;
        }else{
            this.saveInProgress = true;

            const prRtis = this.objectInfo.data.recordTypeInfos;
            let productRequestfields = {};
            productRequestfields.Product_Specification__c  = this.prodSpecData.id;
            productRequestfields.RecordTypeId = Object.keys(prRtis).find(rti => prRtis[rti].name == this.selectedRecordTypeName);

            const fields = {...productRequestfields};
            const recordInput = { apiName: PRODUCT_REQUEST_OBJECT.objectApiName, fields};
            createRecord(recordInput)
            .then(record => {
                this.prodReqId=record.id;
                this.showToast('Product Request created.',this.selectedRecordTypeName,SUCCESS_VARIANT);
               
                this.handleSubmit(event);
            })
            .catch(error => {
                this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
            });
        }
    }

    //adds existing product request under a parent
    handleAddExistingProductRequest(){
        this.savingExistingPR = true;
        this.createRelatedProdRequest(this.existingProdReqId);
    }

    //creates related product request record on added existing 
    createRelatedProdRequest(prodReqId){
      
        let relatedProdFields = {};
        relatedProdFields.Program__c = this.parentRecord.recordId;
        relatedProdFields.Course__c = prodReqId;
        const fields = {...relatedProdFields};
        const recordInput = { apiName: RELATED_PRODUCT_REQUEST_OBJECT.objectApiName, fields};
        createRecord(recordInput)
        .then(() => {
            if(this.isAddExistingModal && this.productRequestForOpe){
                this.showToast('Product Request added.',this.selectedRecordTypeName,SUCCESS_VARIANT);
                this.dispatchEvent(new CustomEvent('created'));
            }else if(!this.productRequestForOpe){
                this.dispatchEvent(new CustomEvent('created'));
            }
        })
        .catch(error => {
            this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
        })
        .finally(() =>{
            this.resetSelectionModalFlags();
        })
    }

    //creates course/program plan on save
    handleSubmit(event){
        const programPlanRtis = this.programPlanObjectInfo.data.recordTypeInfos;
        const courseRtis = this.courseObjectInfo.data.recordTypeInfos;

        let fields = event.detail.fields;
        let today = new Date();
        let todayDate=today.toISOString();
       
        if(!this.isProgramSelected){
            fields.ProductRequestID__c = this.prodReqId;
            fields.RecordTypeId=Object.keys(courseRtis).find(rti => courseRtis[rti].name == this.selectedRecordTypeName);
            fields.hed__Account__c=this.accountId;
            fields.Start_Date__c = todayDate;
        }
        else{
            fields.Product_Request__c = this.prodReqId;
            fields.RecordTypeId=Object.keys(programPlanRtis).find(rti => programPlanRtis[rti].name == this.selectedRecordTypeName);
            this.programDeliveryStructure = fields.Program_Delivery_Structure__c;
            fields.hed__Start_Date__c = todayDate;
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    //updates product request status after course/program plan insert to avoid hitting validation rules
    //navigates to updated product request after
    updateProductRequestStatusAndRedirect(event){
        let productReqfields = {};
        if(this.isChild){
            this.createRelatedProdRequest(this.prodReqId);
            productReqfields.Child_of_Prescribed_Program__c = this.parentRecord.isPrescribedProgram;
        }
        productReqfields.Id= this.prodReqId;
        productReqfields.Product_Request_Status__c = 'Design';
        productReqfields.OwnerId = this.selectedUserId;
        if(this.isProgramSelected){
            productReqfields[PR_OPE_TYPE.fieldApiName] = this.programDeliveryStructure;
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
            this.dispatchEvent(new CustomEvent('created'));
            this.closeRecordCreation();
        });
    }

    //shows toast on error upon saving the course/program plan
    handleRecordError(event){
        this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
    }

    //closes course/program plan name form modal
    closeRecordCreation(){
        this.showOwnerError = false;
        this.isRelatedModalOpen = false;
        this.programDeliveryStructure = undefined;
        this.assignCurrentUserDetails();
        this.setRecordTypeDetails('');
    }

    /* ------- Course / Program Plan Create Methods End (OPE) ------- */

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