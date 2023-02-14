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
      | john.m.tambasen           | July 05, 2022         | DEPP-2590            | SOA product request                                                       | 
      | eccarius.munoz            | July 11, 2022         | DEPP-2035            | Added handling for Educational Consultancy                                | 
      | john.m.tambasen           | July 28, 2022         | DEPP-3480            | Corporate Bundle product request                                          |
      | alexander.cadalin         | August 04, 2022       | DEPP-2498            | SOA PR Buyer Group and Entitlement                                        |
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
import RT_PR_DIAGNOSTIC_TOOL from '@salesforce/label/c.RT_ProductRequest_Diagnostic_Tool';
import RT_ProductRequest_SOA from '@salesforce/label/c.RT_ProductRequest_SOA';
import RT_ProductRequest_Educ_Consultancy from '@salesforce/label/c.RT_ProductRequest_Educ_Consultancy';
import RT_ProductRequest_Corporate_Bundle from '@salesforce/label/c.RT_ProductRequest_Corporate_Bundle';
import PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Product_Request__c';
import RELATED_PRODUCT_REQUEST_OBJECT from '@salesforce/schema/Related_Product_Request__c';
import COURSE_OBJECT from '@salesforce/schema/hed__Course__c';
import PROGRAM_PLAN_OBJECT from '@salesforce/schema/hed__Program_Plan__c';
import BUYER_GROUP_OBJECT from '@salesforce/schema/BuyerGroup';
import EDUC_CONSULTANCY_OBJ from '@salesforce/schema/Consultancy__c';
import ASSET_OBJ from '@salesforce/schema/Asset';
import PR_OPE_TYPE from '@salesforce/schema/Product_Request__c.OPE_Program_Plan_Type__c';
import PROD_SPEC_APINAME from '@salesforce/schema/Product_Request__c.Product_Specification__c';
import getAccountId from '@salesforce/apex/AddProductRequestCtrl.getAccountId';
import getSearchedProductRequests from '@salesforce/apex/AddProductRequestCtrl.getSearchedProductRequests';
import getSearchedUsers from '@salesforce/apex/AddProductRequestCtrl.getSearchedUsers';
import RT_ProductRequest_Program_Without_Pathway from '@salesforce/label/c.RT_ProductRequest_Program_Without_Pathway';
import PRIMARY_ACC_ID_FIELD from '@salesforce/schema/Product_Specification__c.Opportunity_Name__r.AccountId';
import PRIMARY_ACC_NAME_FIELD from '@salesforce/schema/Product_Specification__c.Opportunity_Name__r.Account.Name';
import createBuyerGroupAndEntitlement from '@salesforce/apex/AddProductRequestCtrl.createBuyerGroupAndEntitlement';
// import BG_MEMBER_OBJECT from '@salesforce/schema/BuyerGroupMember';
// import WEB_STORE_BG_OBJECT from '@salesforce/schema/WebStoreBuyerGroup';
// import COMMERCE_ENTITLEMENT_OBJECT from '@salesforce/schema/CommerceEntitlementPolicy';
// import COMMERCE_ENTITLEMENT_BG_OBJECT from '@salesforce/schema/CommerceEntitlementBuyerGroup';

const PROD_REQUESTS = "Product Requests";
const CHILD_PROD_REQUEST = "Child Product Requests";
const RECORD_TYPE_LABEL = "Record Type";
const SUCCESS_VARIANT = "success";
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const PROG_PLAN_REQUEST= RT_ProductRequest_Program;
const PROG_PLAN_WITHOUT_PATHWAY = RT_ProductRequest_Program_Without_Pathway;
const SOA_REQUEST = RT_ProductRequest_SOA;
const EDUC_CONSULTANCY_REQ = RT_ProductRequest_Educ_Consultancy;
const CORPORATE_BUNDLE_REQ = RT_ProductRequest_Corporate_Bundle;

export default class AddProductRequest extends NavigationMixin(LightningElement) {
    @api productRequestForOpe;
    @api recordTypeMap;
    @api fieldLayoutMap;
    @api recordId;
    @api productSpecId;

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
    primaryAccountId;
    primaryAccountName;
    lastModifiedDateProdReq;

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
        return this.selectedRecordTypeName == PROG_PLAN_REQUEST || this.selectedRecordTypeName.replace(/ /g,'_') == PROG_PLAN_WITHOUT_PATHWAY; 
    }

    //checks if user selected Standing Offer Arrangement 
    get isSOASelected(){
        return this.selectedRecordTypeName.replace(/ /g,'_') == SOA_REQUEST;
    }

    //checks if user selected Educational Consultancy 
    get isEducConsultancy(){
        return this.selectedRecordTypeName.replace(/ /g,'_') == EDUC_CONSULTANCY_REQ;
    }

    //checks if user selected Corporate Bundle
    get isCorporateBundleSelected(){
        return this.selectedRecordTypeName.replace(/ /g,'_') == CORPORATE_BUNDLE_REQ;
    }

    //sets the Object to be Created
    get objectToBeCreated(){
        if(this.isProgramSelected){

            return PROGRAM_PLAN_OBJECT.objectApiName;
        }else if (this.isSOASelected){

            return BUYER_GROUP_OBJECT.objectApiName;
        }else if (this.isEducConsultancy){

            return EDUC_CONSULTANCY_OBJ.objectApiName;
        }else if (this.isCorporateBundleSelected){

            return ASSET_OBJ.objectApiName;
        }else{

            return COURSE_OBJECT.objectApiName;
        }
    }

    get isDiagnosticTool(){
        return this.selectedRecordTypeName.replace(/ /g,'_') == RT_PR_DIAGNOSTIC_TOOL;
    }

    //gets the Object Name
    get objectLabel(){
    
        if(this.isProgramSelected){

            return this.programPlanObjectInfo.data.label;
            

        } else if(this.isSOASelected){

            return this.buyerGroupObjectInfo.data.label;

        } else if(this.isEducConsultancy){

            return this.educConsultancyObjectInfo.data.label;
        } else if(this.isCorporateBundleSelected){

            return this.assetObjectInfo.data.label;
        }else{

            return this.courseObjectInfo.data.label;
        }
    }

    get disableAddExistingButton(){
        return this.existingProdReqId == '' || this.savingExistingPR?true:false; 
    }

    get disableProgramStructure(){
        if(this.parentRecord.isSOA){
            return true;
        }else{
            return false;
        }
    }

    get searchLabel(){

        //if parent is SOA add the lalbel with program
        if(this.parentRecord.isSOA){
            return "Course/Program Product Request";
        } else{
            return "Course Product Request";
        }
    }

    get isParentSOA(){
        
        if(this.parentRecord.isSOA){
            return true;
        } else{
            return false;
        }
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

    //get object info of buyer group object
    //used to get recordtyeps
    @wire(getObjectInfo, { objectApiName: BUYER_GROUP_OBJECT})
    buyerGroupObjectInfo;

    //get object info of consultancy object
    //used to get recordtyeps
    @wire(getObjectInfo, { objectApiName: EDUC_CONSULTANCY_OBJ})
    educConsultancyObjectInfo;

    //get object info Asset object
    //used to get recordtyeps
    @wire(getObjectInfo, { objectApiName: ASSET_OBJ})
    assetObjectInfo;

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

    @wire(getRecord, { recordId: '$productSpecId', fields: [PRIMARY_ACC_ID_FIELD,PRIMARY_ACC_NAME_FIELD] })
    prodSpecData({error, data}) {
        if (data) {
            this.primaryAccountId = data.fields.Opportunity_Name__r.value.fields.AccountId.value;
            this.primaryAccountName = data.fields.Opportunity_Name__r.value.fields.Account.value.fields.Name.value;

        } else if (error) {
            console.log(error);
            this.generateToast(ERROR_TOAST_TITLE, LWC_Error_General, ERROR_TOAST_VARIANT);
        }
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
        getSearchedProductRequests({
            filterString: event.detail.filterString,
            filterPRList:this.currentChildren,
            prodSpecRecordType:this.prodSpecData.recordType,
            isSOA: this.isParentSOA
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
        } else if(item.Program_Plans__r && item.Program_Plans__r[0] && item.Program_Plans__r[0].Name){
            searchItem.label = item.Program_Plans__r[0].Name;
        } else{
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
                this.lastModifiedDateProdReq = record.lastModifiedDate;
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
        let formattedDate = this.lastModifiedDateProdReq.substring(0,19).replace('T',' ');
       
        //if Standing Offer Arrangement record is selected
        if(this.isSOASelected){
            fields.Name = fields.Name + ' ' + formattedDate;
            if(fields.Name.length > 80){
                fields.Name = fields.Name.substring(0,80) + ' ' + formattedDate;
            }
            fields.Product_Request__c = this.prodReqId;
            fields.Start_Date__c = this.lastModifiedDateProdReq;
            fields.Primary_Account__c = this.primaryAccountId;

        } else if (this.isEducConsultancy) {
            fields.Product_Request__c = this.prodReqId;
            fields.Start_Date__c = this.lastModifiedDateProdReq;
            
        } else if (this.isCorporateBundleSelected) {
            fields.Product_Request__c = this.prodReqId;
            fields.AccountId = this.primaryAccountId;
            fields.Start_Date__c = this.lastModifiedDateProdReq;
            
        } else if(!this.isProgramSelected){
            fields.ProductRequestID__c = this.prodReqId;
            fields.RecordTypeId=Object.keys(courseRtis).find(rti => courseRtis[rti].name == this.selectedRecordTypeName);
            fields.hed__Account__c=this.accountId;
            fields.Start_Date__c = this.lastModifiedDateProdReq;

        } else{
            fields.Product_Request__c = this.prodReqId;
            fields.RecordTypeId=Object.keys(programPlanRtis).find(rti => programPlanRtis[rti].name == this.selectedRecordTypeName);
            this.programDeliveryStructure = fields.Program_Delivery_Structure__c;
            fields.hed__Start_Date__c = this.lastModifiedDateProdReq;
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    //updates product request status after course/program plan insert to avoid hitting validation rules
    //navigates to updated product request after
    updateProductRequestStatusAndRedirect(event){

        //if corporate bundle need to create these records
        if (this.isCorporateBundleSelected || this.isSOASelected) {
            // Get Product Category Id
            createBuyerGroupAndEntitlement({
                productRequestId: this.prodReqId,
                accountId: this.primaryAccountId, 
                accountName: this.primaryAccountName,
                isCorporateBundle: this.isCorporateBundleSelected,
                isSoa: this.isSOASelected
            })
            .then((result) => {
                //code
            })
            .catch((error) => {
                this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
                console.log("error createBuyerGroupEntitlement");
                console.log(error);
            });
            
            // //create BuyerGroup
            // let bgFields = {};
            // bgFields.Name = this.primaryAccountName;
            // const fields = {...bgFields};
            // const recordInput = { apiName: BUYER_GROUP_OBJECT.objectApiName, fields};
            // createRecord(recordInput)
            // .then(bgRecord => {

            //     //create BuyerGroupMember
            //     let bgMemberFields = {};
            //     bgMemberFields.BuyerGroupId = bgRecord.Id;
            //     bgMemberFields.BuyerId = this.primaryAccountId;
            //     const fields = {...bgMemberFields};
            //     const recordInput = { apiName: BG_MEMBER_OBJECT.objectApiName, fields};
            //     createRecord(recordInput)
            //     .then(bgMemberRecord => {
            //         //code
            //     })
            //     .catch(error => {
            //         this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
            //         console.log("error BuyerGroupMember");
            //         console.log(error);
            //     });

            //     //create CommerceEntitlementPolicy
            //     let commerceEntitlementFields = {};
            //     commerceEntitlementFields.CanViewPrice = true;
            //     commerceEntitlementFields.CanViewProduct = true;
            //     commerceEntitlementFields.IsActive = true;
            //     commerceEntitlementFields.Name = this.primaryAccountName;
            //     const fieldsEnt = {...commerceEntitlementFields};
            //     const recordInputEnt = { apiName: COMMERCE_ENTITLEMENT_OBJECT.objectApiName, fieldsEnt};
            //     createRecord(recordInputEnt)
            //     .then(commerceEntitlementRecord => {

            //         //create CommerceEntitlementBuyerGroup
            //         let commerceEntitlementBGFields = {};
            //         commerceEntitlementBGFields.BuyerGroupId = bgRecord.Id;
            //         commerceEntitlementBGFields.PolicyId = commerceEntitlementRecord.Id;
            //         const fieldsEnt = {...commerceEntitlementFields};
            //         const recordInputEnt = { apiName: COMMERCE_ENTITLEMENT_BG_OBJECT.objectApiName, fieldsEnt};
            //         createRecord(recordInputEnt)
            //         .then(record => {
            //             //code
            //         })
            //         .catch(error => {
            //             this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
            //             console.log("error CommerceEntitlementBuyerGroup");
            //             console.log(error);
            //         });

            //     })
            //     .catch(error => {
            //         this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
            //         console.log("error CommerceEntitlementPolicy");
            //         console.log(error);
            //     });   
            // })
            // .catch(error => {
            //     this.showToast(ERROR_TITLE,LWC_Error_General,ERROR_VARIANT);
            //     console.log("error BuyerGroup");
            //     console.log(error);
            // });
            
        }

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