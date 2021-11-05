/**
 * @description An LWC component for creating products and offerings
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | October 18, 2021      | DEPP-425 DEPP-476  | Created
      |                           |                       |                      |                              | 
 */
import { LightningElement,wire,api} from 'lwc';
import getCourses from '@salesforce/apex/CreateProductsAndOfferingsCtrl.getRelatedCourse';
import COURSE_OFFERING_SCHEMA from '@salesforce/schema/hed__Course_Offering__c';
import PRODUCT_SCHEMA from '@salesforce/schema/Product2';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {createRecord, updateRecord } from 'lightning/uiRecordApi';

const MSG_ERROR = "An error has been encountered. Please contact your Administrator.";
const TITLE_BOLD = "slds-text-title_bold";

export default class CreateProductsAndOfferings extends LightningElement{
    courses;
    isCreateProduct=true;
    isCreateOfferings=false;
    isDisable=false;
    createRecord=false;
    editRecord=false;
    multiCreate = false;
    prefields = {};
    pbentries = {};
    productId;
    recordid;
    offeringClass;
    hasProductOnRender=false;
    hasOfferingsOnRender = false;
    markedAsComplete=false;
    markedAsCompleteOffering=false;
    coursesData = [];
    onRender = true;
    onRenderOffering = true;
    @api recordId;

    /*
    *gets courses, products and offerings
    */
    listCourses;
    @wire(getCourses,{productRequestId: '$recordId'})
    relatedCourse(result){
        if(result.data)
        {
            this.listCourses = result;
            let coursesList = this.listCourses.data.courseList;
            let productTemp = this.listCourses.data.productMap;
            let offeringsTemp = this.listCourses.data.offeringMap;
            this.hasProductOnRender = this.listCourses.data.courseList.length === Object.keys(this.listCourses.data.productMap).length?true:false;
            this.hasOfferingsOnRender = this.listCourses.data.courseList.length === Object.keys(this.listCourses.data.offeringMap).length?true:false;

            coursesList.forEach(course =>{
                let courseTemp = {};
                courseTemp.recordId = course.Id;
                courseTemp.recordUrl = '/' + course.Id;
                    courseTemp.fields = [
                                            { label:"Course Name"   , value: course.Name,showCol : true,isUrl: true},
                                            { label:"Record Type"   , value: course.RecordType?course.RecordType.Name:'',showCol : true},
                                            { label:"Start Date"    , value: course.Start_Date__c},
                                            { label:"End Date"      , value: course.End_Date__c}
                                        ];
                                        
                    let childOfferings =  offeringsTemp[course.Id] ?  this.formatOfferingData(offeringsTemp[course.Id]) : [];
                    let childProduct = productTemp[course.Id] ? this.formatProductData(productTemp[course.Id]):[] ;
                    if(childOfferings.length > 0){
                        courseTemp.offerings = [...childOfferings];
                    }
                    if(childProduct.length > 0)
                    {
                        courseTemp.hasProduct = true;
                        courseTemp.products =[...childProduct];
                    }
                    this.coursesData = [courseTemp, ...this.coursesData];
            });    
        }
        else if(result.error)
        {
            this.generateToast('Error!',MSG_ERROR,'error');
        }
    }

    /*
    *getter for create button label
    */
    get createLabel(){
        return this.isCreateProduct?"Create Product":"Create Offering";
    }

    /*
    *getter for create product bread crumb class
    */
    get createProductClass(){
        return this.isCreateProduct?TITLE_BOLD:"";
    }
    
    /*
    *getter for create offering bread crumb class
    */
    get createOfferingClass(){
        return  this.markedAsComplete || (this.onRender && this.hasProductOnRender)?this.offeringClass:"noclick";
    }

    /*
    *getter for disabling mark as complete on create product page
    */
    get isDisabled(){
        return ((this.markedAsComplete || this.onRender) && this.hasProductOnRender) || !this.hasProductOnRender?true:false;
    }

    /*
    *getter for disabling mark as complete on create offering page
    */
    get isDisableOffering(){
        return  ((this.markedAsCompleteOffering || this.onRenderOffering) && this.hasOfferingsOnRender) || !this.hasOfferingsOnRender?true:false
    }

    /*
    *getter for spinner
    */
    get isLoading(){
        return this.coursesData.length > 0?false:true;
    }

    /*
    *getter for isInitialRender
    */
    get isInitialRender(){
        return  this.onRender && this.onRenderOffering ?true:false;
    }

    /*
    *function that formats the structure for oferrings data
    */
    formatOfferingData(listToFormat){
        return listToFormat.map(item =>{
            let newItem = {};

            newItem.recordId = item.Id;
            newItem.recordUrl = '/' + item.Id;
            newItem.fields = [
                                {label:   "Course Offering Name"    , value: item.Name,isUrl: true},
                                {label:   "Record Type"             , value: item.hed__Course__r.RecordType?item.hed__Course__r.RecordType.Name:''},
                                {label:   "Start Date"              , value: item.hed__Start_Date__c},
                                {label:   "End Date"                , value: item.hed__End_Date__c}
                            ];

            return newItem;
        });

    }
    
    /*
    *function that formats the structure for product data
    */
    formatProductData(listToFormat)
    {
        return listToFormat.map(item =>{
            let newItem = {};

            newItem.recordId = item.Id;
            newItem.recordUrl = '/' + item.Id;
            newItem.fields = [
                        {label: "Product Name"  , value: item.Name,isUrl: true},
                        {label: "Start Date"    , value: item.Start_Date__c},
                        {label: "End Date"      , value: item.End_Date__c},
            ];
            return newItem;
        });
    }

    /*
    *function that handles data needed to create product
    */
    handleProductInsert(event){
        this.prefields = {Course__c:event.target.value};
        this.objApiName = PRODUCT_SCHEMA.objectApiName;
        this.createRecord = true;
        this.multiCreate = false;
        
    }

    /*
    *function that handles data need to edit product
    */
    handleProductEdit(event){
        this.recordid = event.target.value;
        this.editRecord = true;
        this.objApiName = PRODUCT_SCHEMA.objectApiName;
    }

    /*
    *function that handles data needed to create offerings
    */
    handleOfferingInsert(event){
        this.prefields = {hed__Course__c:event.target.value};
        this.multiCreate = true;
        this.objApiName = COURSE_OFFERING_SCHEMA.objectApiName;
        this.createRecord = true;
    }

    /*
    *function that handles data needed to edit offerings
    */
    handleOfferingEdit(event){
        this.recordid = event.target.value;
        this.editRecord = true;
        this.objApiName = COURSE_OFFERING_SCHEMA.objectApiName;
    }

    /*
    *function that shows or hide create product page
    */
    handleCreateProducts()
    {
         this.isCreateProduct=true;
         this.isCreateOfferings=false;
         this.offeringClass = "";
    }

    /*
    *function that shows or hide create offerings page
    */
    handleCreateOfferings()
    {
        this.isCreateProduct=false;
        this.isCreateOfferings=true;
        this.offeringClass = TITLE_BOLD;
    }

    /*
    *function that handles mark as complete button on create product page
    */
    markAsComplete()
    {
        this.markedAsComplete=true;
    }

    /*
    *function that handles mark as complete button on create offering page
    */
    markAsCompleteOffering(){
        this.markedAsCompleteOffering = true;
    }

    /*
    *function that closes the modal
    */
    closeModal(){
        this.createRecord = false;
        this.editRecord = false;
    }
    
    /*
    *function that handles save button 
    */
    handleSave(event){
        this.upsertRecords(event.detail);          
    }

    /*
    *function that refreshes the course,offering, and product data
    */
    refreshData(){
        if(this.isCreateProduct){
            this.onRender = false;
            this.markedAsComplete = false;
        }else{
            this.onRenderOffering = false;
        }
        this.coursesData = [];
    }

    /*
    *function that handles what upsert method to call
    */
    upsertRecords(record){
        if(record.Id){
            this.handleUpdateRecord(record);
        }else{
            this.handleCreateRecord(record);
        }
    }



    /**
     * creates record given object api name and fields
     */
     handleCreateRecord(fieldsToCreate){
        const fields = {...fieldsToCreate};
        const recordInput = { apiName: this.objApiName, fields };

        createRecord(recordInput)
        .then(() => {
            this.refreshData();
            this.generateToast('Success!','Record created.','success');
        })
        .catch(() => {
            this.generateToast('Error.',MSG_ERROR,'error');
        })
        .finally(() => {
            refreshApex(this.listCourses);
        });
    }

     /**
     * updates record given fields
     */
      handleUpdateRecord(fieldsToUpdate){
        const fields = {...fieldsToUpdate};
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.refreshData();
            this.generateToast('Success!','Record updated.','success');
        })
        .catch(() => {
            this.generateToast('Error.',MSG_ERROR,'error');
        })
        .finally(() => {
            refreshApex(this.listCourses);
        });
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
