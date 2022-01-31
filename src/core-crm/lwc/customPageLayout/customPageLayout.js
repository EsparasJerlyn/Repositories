/**
 * @description A custom LWC for showing different object page layouts on a parent record page
 *
 * @see ../classes/CustomPageLayoutCtrl.cls
 * 
 * @author Accenture
 * 
 * @usage 
 *      Please see the customPageLayout.js-meta.xml file to view available inputs
 *      (currently enabled for record pages)
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | December 21, 2021     | DEPP-838,1299       | Created file                                           |
      | eccarius.munoz            | January 21, 2022      | DEPP-1344,1303,1222 | Added handling for OPE Design Completion               |
      |                           |                       |                     |                                                        |
*/
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import COURSE from '@salesforce/schema/hed__Course__c';
import C_OPE_DESIGN_COMPLETE from '@salesforce/schema/hed__Course__c.OPE_Design_Complete__c';
import PRODUCT from '@salesforce/schema/Product2';
import P_ID from '@salesforce/schema/Product2.Id';
import PROGRAM_PLAN from '@salesforce/schema/hed__Program_Plan__c';
import PP_OPE_DESIGN_COMPLETE from '@salesforce/schema/hed__Program_Plan__c.OPE_Design_Complete__c';
import PRODUCT_REQUEST from '@salesforce/schema/Product_Request__c';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c'
import PR_RT_DEV_NAME from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import getLayoutMapping from '@salesforce/apex/CustomPageLayoutCtrl.getLayoutMapping';
import getChildRecordId from '@salesforce/apex/CustomPageLayoutCtrl.getChildRecordId';

//this contains flag fields for mark as complete button
const OPE_COMPLETE_FIELDS = {
    [COURSE.objectApiName] : C_OPE_DESIGN_COMPLETE,
    [PROGRAM_PLAN.objectApiName] : PP_OPE_DESIGN_COMPLETE,
    [PRODUCT.objectApiName] : P_ID
};

//this contains object labels for objects without record types
const OBJECT_LABELS = {
    [PRODUCT.objectApiName] : 'Products'
};
export default class CustomPageLayout extends LightningElement {
    @api childObjectApiName;
    @api parentObjectApiName;
    @api parentFieldApiName;
    @api grandParentFieldApiName;
    @api tab;
    @api forOpe;
    @api withRecordType;
    @api withMarkAsComplete;
    
    @api recordId;
    @api objectApiName;
    
    @track parentRecord = {};
    childRecordId;
    childRecordTypeDevName;
    activeSections = [];
    layoutMapping = [];
    layoutToDisplay = [];
    popoverFields = [];
    isLoading = false;
    editMode = false;
    showPopoverIcon = false;
    showPopoverDialog = false;
    opeDesignValue;

    //gets necessary parent fields
    //note: add conditions if another parent is to be added
    get parentFields(){
        let _fields = [];
        if(this.objectApiName == PRODUCT_REQUEST.objectApiName){
            _fields = [PR_STATUS,PR_RT_DEV_NAME];
        }
        return _fields;
    }

    //gets flag field for mark as complete
    get childCompleteField(){
        return [OPE_COMPLETE_FIELDS[this.childObjectApiName]];
    }

    //decides if layout is a grandchild (2-object relationship traversal)
    get isGrandChild(){
        return this.objectApiName !== this.parentObjectApiName;
    }

    //gets appropriate object api name
    get objectType(){
        return this.isGrandChild ? this.parentObjectApiName : this.childObjectApiName;
    }

    //gets field api name for filtering
    get parentCondition(){
        return this.isGrandChild ? this.grandParentFieldApiName : this.parentFieldApiName;
    }

    //gets grandchild information
    get grandChildData(){
        let _data = {};
        if(this.isGrandChild){
            _data.objectApiName = this.childObjectApiName;
            _data.conditionField = this.parentFieldApiName;
        }
        return _data;
    }

    //disables edit button if status does not match specified tab
    get disableEditButton(){
        return this.parentRecord.status !== this.tab;
    }

    //decides whether to enable/disable mark as complete button
    get opeDesignComplete() {
        if(this.disableEditButton){
            return true;
        }
        return this.opeDesignValue ? false : true;
    }

    //decides if text note should display
    get displayNote(){
        if(this.disableEditButton || this.opeDesignValue){
            return '';
        }
        return 'Note: Please input required fields for course to mark as complete.';
    }

    //decides if the layout has a mark as complete button
    get showMarkAsComplete(){
        return this.withMarkAsComplete && !this.editMode;
    }

    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    /**
     * gets parent record details
     */
    @wire(getRecord, { recordId: '$recordId', fields: '$parentFields' })
    handleParentRecord(result){
        if(result.data){
            this.parentRecord.status = getFieldValue(result.data,PR_STATUS);
            this.parentRecord.rtDevName = getFieldValue(result.data,PR_RT_DEV_NAME);
            if(this.withRecordType){
                this.childRecordTypeDevName = 
                    this.parentRecord.rtDevName.includes('_Request') && this.childObjectApiName == COURSE.objectApiName ? 
                    this.parentRecord.rtDevName.replace('_Request','') : this.parentRecord.rtDevName;
            }else{
                this.childRecordTypeDevName = 'All_OPE_' + OBJECT_LABELS[this.childObjectApiName];
            }
            this.getRecordLayout();
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * gets child record id
     */
    @wire(getChildRecordId, { 
        parentId : '$recordId', 
        parentField : '$parentCondition', 
        childObjectType : '$objectType', 
        grandChildInfo : '$grandChildData'
    })
    handleGetChildRecordId(result){
        if(result.data){
            this.childRecordId = result.data;
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * gets flag value for mark as complete button
     */
    @wire(getRecord, { recordId: '$childRecordId', fields: '$childCompleteField' })
    handleChildRecord(result){
        if(result.data){
            this.opeDesignValue = getFieldValue(result.data, OPE_COMPLETE_FIELDS[this.childObjectApiName]);
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }
     
    /**
     * calls apex method to get UI layout from metadata
     */
    getRecordLayout(){
        this.isLoading = true;
        getLayoutMapping({objApiName : this.childObjectApiName, rtDevName : this.childRecordTypeDevName, isOpe : this.forOpe})
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
     * updates the parent record's status
     */
    handleMarkAsComplete(){
        const fields = {};
        fields.Id = this.recordId;
        fields.Product_Request_Status__c = 'Release';
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.generateToast('Success!','Design marked as complete.','success');
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
    }

    /**
     * method for handling record edit form submission
     */
    handleSubmit(){
        this.isLoading = true;
    }

    /**
     * method for handling succesful save on record edit form
     */
    handleSuccess(){
        this.isLoading = false;
        this.editMode = false;
        this.generateToast('Success!','Record Updated.','success');
        this.resetPopover();
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