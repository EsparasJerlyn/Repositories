/**
 * @description A custom LWC for showing Course layout on Product Request 
 *
 * @see ../classes/CourseDetailFieldsCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA            | Change Summary                                         |
      |---------------------------|-----------------------|-----------------|--------------------------------------------------------|
      | angelika.j.s.galang       | December 21, 2021     | DEPP-838,1299   | Created file                                           |
      | eccarius.munoz            | January 21, 2022      | DEPP-1344, 1303,| Added handling for OPE Design Completion               |
      |                           |                       | 1222            |                                                        | 
*/
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PR_RT_NAME from '@salesforce/schema/Product_Request__c.RecordType.Name';
import PR_RT_DEV_NAME from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import COURSE_OBJECT from '@salesforce/schema/hed__Course__c';
import OPE_DESIGN_COMPLETE from '@salesforce/schema/hed__Course__c.OPE_Design_Complete__c';
import getLayoutMapping from '@salesforce/apex/CourseDetailFieldsCtrl.getLayoutMapping';
import getCourseId from '@salesforce/apex/CourseDetailFieldsCtrl.getCourseId';

const EXCLUDED_PR_RTs = ['OPE_Program_Request'];
export default class CourseDetailFields extends LightningElement {
    @api recordId;

    activeSections = [];
    layoutMapping = [];
    layoutToDisplay = [];
    isLoading = false;
    editMode = false;
    showPopoverIcon = false;
    showPopoverDialog = false;
    popoverFields = [];

    /**
     * gets product request details
     */
    courseRecordTypeName;
    @track productRequestRecord = {};
    @wire(getRecord, { recordId: '$recordId', fields: [PR_STATUS,PR_RT_NAME,PR_RT_DEV_NAME] })
    handleProductRequest(result){
        if(result.data){
            this.productRequestRecord.status = getFieldValue(result.data,PR_STATUS);
            this.productRequestRecord.rtName = getFieldValue(result.data,PR_RT_NAME);
            this.productRequestRecord.rtDevName = getFieldValue(result.data,PR_RT_DEV_NAME);
            this.courseRecordTypeName = this.productRequestRecord.rtName.includes(' Request') ? 
                this.productRequestRecord.rtName.replace(' Request','') : this.productRequestRecord.rtName;
            this.getRecordLayout();
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * for record types of course object
     */
    @wire(getObjectInfo, { objectApiName: COURSE_OBJECT })
    objectInfo;

    /**
     * gets related Course ID
     */
    courseId;
    @wire(getCourseId, {productRequestId : '$recordId'})
    handleGetCourseId(result){
        if(result.data){
            this.courseId = result.data;
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    @wire(getRecord, { recordId: '$courseId', fields: [OPE_DESIGN_COMPLETE] })
    course;

    get opeDesignComplete() {
        console.log('test');
        if(this.productRequestRecord.status !== 'Design'){
            return true;
        }
        return getFieldValue(this.course.data, OPE_DESIGN_COMPLETE) ? false : true;
    }

    get displayNote(){
        if(this.productRequestRecord.status !== 'Design' || getFieldValue(this.course.data, OPE_DESIGN_COMPLETE)){
            return '';
        }
        return 'Note: Please input required fields for course to mark as complete.';
    }

    get courseApiName(){
        return COURSE_OBJECT.objectApiName;
    }

    get disableEditButton(){
        return EXCLUDED_PR_RTs.includes(this.productRequestRecord.rtDevName) || this.productRequestRecord.status !== 'Design';
    }

    get courseRecordTypeId(){
        let _id;
        if(this.objectInfo.data && this.courseRecordTypeName){
            const rtis = this.objectInfo.data.recordTypeInfos;
            _id = Object.keys(rtis).find(rti => rtis[rti].name == this.courseRecordTypeName);
        }
        return _id;
    }

    get hasAccess(){
        return HAS_PERMISSION;
    }

    /**
     * calls apex method to get UI layout from metadata
     */
    getRecordLayout(){
        this.isLoading = true;
        getLayoutMapping({objApiName : this.courseApiName, rtLabel : this.productRequestRecord.rtName})
        .then(result => {
            this.layoutMapping = [...result];
            this.formatLayoutToDisplay();
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    /**
     * formats layout columns for UI rendering
     */
    formatLayoutToDisplay(){
        this.layoutToDisplay = this.layoutMapping.map(layout => {
            let layoutItem = {};
            layoutItem.sectionLabel = layout.MasterLabel;
            layoutItem.leftColumn = layout.Left_Column_Long__c ? JSON.parse(layout.Left_Column_Long__c) : null;
            layoutItem.rightColumn = layout.Right_Column_Long__c ? JSON.parse(layout.Right_Column_Long__c) : null;
            layoutItem.singleColumn = layout.Single_Column_Long__c ? JSON.parse(layout.Single_Column_Long__c) : null;
            return layoutItem;
        });
        this.activeSections = this.layoutToDisplay.map(layout => {return layout.sectionLabel});
    }

    /**
     * enables edit mode
     */
    handleEdit(){
        this.editMode = true;
    }

    /**
     * method for handling record edit form submission
     */
    handleSubmit(event){
        this.isLoading = true;
        if(!this.courseId){
            event.preventDefault();
            let fields = event.detail.fields;
            fields.ProductRequestID__c = this.recordId; 
            fields.RecordTypeId = this.courseRecordTypeId;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    } 

    /**
     * method for handling succesful save on record edit form
     */
    handleSuccess(event){     
        this.isLoading = false;
        this.editMode = false;
        this.generateToast('Success!','Record Updated.','success');
        if(!this.courseId){
            this.courseId = event.detail.id;
        }
        //getRecordNotifyChange([{recordId: this.courseId}]);
        this.resetPopover();
    }

    handleMarkAsComplete(){
        const fields = {};
        fields.Id = this.recordId;
        fields.Product_Request_Status__c = 'Release';
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
    }

    /**
     * method for handling record edit form errors
     */
    handleError(event){
        this.popoverFields = [];
        let fieldErrors = event.detail.output.fieldErrors;
        Object.keys(fieldErrors).forEach(fieldError => {
            this.popoverFields.unshift(fieldErrors[fieldError][0].fieldLabel);
        });
        this.isLoading = false;
        this.showPopoverIcon = true;
        this.showPopoverDialog = true;
    }
    
    /**
     * disables edit mode
     */
    handleCancel(){
        this.editMode = false;
        this.resetPopover();
    }

    /**
     * shows/hides popover dialog on errors
     */
    handlePopover(){
        this.showPopoverDialog = this.showPopoverDialog ? false : true;
    }

    /**
     * hides popover
     */
    resetPopover(){
        this.showPopoverIcon = false;
        this.showPopoverDialog = false;
        this.popoverFields = [];
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