/**
 * @description A custom LWC for showing different section layouts on a parent record page
 *
 * @see ../classes/CustomLayoutCtrl.cls
 * 
 * @author Accenture
 * 
 * @usage 
 *      @parameters
 *      record-id (string, required) : ID of the record page the layout is in
 *      object-api-name (string, required) : API name of the object the layout is in
 *      child-object-api-name (string, required) : API name of the object the layout is for
 *      parent-object-api-name (string, required) : API name of the parent object the layout is for
 *      parent-field-api-name (string, required) : API name of the parent field in the child object
 *      grand-parent-field-api-name (string, optional) : API name of the grandparent field in the child object (This is for a parent-child-grandchild layout traversal)
 *      tab (string, optional) : Tab where the layout is placed
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | December 21, 2021     | DEPP-838,1299       | Created file                                           |
      | eccarius.munoz            | January 21, 2022      | DEPP-1344,1303,1222 | Added handling for OPE Design Completion               |
      | mary.grace.j.li           | February 23, 2022     | DEPP-1908           | Updated to use getRecordUI instead of custom mdt       |
*/
import { LightningElement, api, wire, track } from "lwc";
import { getRecordUi, getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import LWC_Error_NoAccess from '@salesforce/label/c.LWC_Error_NoAccess';
import LWC_Toast_DesignComplete from '@salesforce/label/c.LWC_Toast_DesignComplete';
import PL_ProductRequest_Release from '@salesforce/label/c.PL_ProductRequest_Release';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import PROGRAM_PLAN from '@salesforce/schema/hed__Program_Plan__c';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import getChildRecordId from '@salesforce/apex/CustomLayoutCtrl.getChildRecordId';

export default class CreateRecordUI extends LightningElement {
    @api objectApiName;
    @api recordId;

    @api childObjectApiName;
    @api parentObjectApiName;
    @api parentFieldApiName;
    @api grandParentFieldApiName;
    @api tab;
    @api isProgram;
    
    @track parentRecord = {};
    programTypeFields = {};
    activeSections = [];
    uiRecord;
    childRecordId;
    editMode = false;
    isLoading = true;
    isComplete;

    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    //gets no access message
    get noAccessMessage(){
        return LWC_Error_NoAccess;
    }

    //decides if layout is to be shown
    get showLayout(){
        return this.hasAccess && this.uiRecord;
    }
    
    //decides if layout is a grandchild (2-object relationship traversal)
    get isGrandChild(){
        return this.objectApiName !== this.parentObjectApiName;
    }

    //gets field api name for filtering
    get parentCondition(){
        return this.isGrandChild ? this.grandParentFieldApiName : this.parentFieldApiName;
    }

    //gets appropriate object api name
    get objectType(){
        return this.isGrandChild ? this.parentObjectApiName : this.childObjectApiName;
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
        return this.tab && this.parentRecord.status !== this.tab;
    }

    //gets product request status
    @wire(getRecord, { recordId: '$recordId', fields: [PR_STATUS] })
    handleParentRecord(result){
        if(result.data){
            this.parentRecord.status = getFieldValue(result.data,PR_STATUS);
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    //gets child record id
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

    //gets ui layout properties of record
    @wire(getRecordUi, {
            recordIds: '$childRecordId',
            layoutTypes: "Full",
            modes: "Edit",
    })
    wiredRecordView({ error, data }) {
        if(data){
            for (let layout of Object.values(data.layouts[this.childObjectApiName])) {
                this.uiRecord = {...layout.Full.Edit};
                this.uiRecord.sections = this.uiRecord.sections.map(section => {
                    return {
                        ...section,
                        fieldSize: 12/section.columns
                    }
                });
                this.activeSections = this.uiRecord.sections.map(section => {return section.id});
                break;
            }
            this.isLoading = false;
        }
        else{
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    //enables edit mode
    handleEdit(){
        this.editMode = true;
    }

    //enables spinner on save
    handleSubmit(event){
        let eventFields = event.detail.fields;
        this.isLoading = true;
        this.isComplete = eventFields.Mark_Design_Stage_as_Complete__c;
        //for Program record type (real-time product request tab update)
        if(this.childObjectApiName == PROGRAM_PLAN.objectApiName){
            this.programTypeFields.Id = this.recordId;
            this.programTypeFields.OPE_Program_Plan_Type__c = eventFields.Program_Type__c;
        }
    }

    //disables spinner and edit mode on success
    handleSuccess(){
        this.editMode = false;
        this.isLoading = false;
        
        //checks if design stage is marked as complete
        if(this.isComplete){
            this.handleMarkAsComplete();
        }

        //for Program record type (real-time product request tab update)
        if(this.childObjectApiName == PROGRAM_PLAN.objectApiName){
            this.handleUpdateRecord(this.programTypeFields,false);
        }
    }

    //disables spinner on error
    handleError(){
        this.isLoading = false;
    }

    //cancels edit mode
    handleCancel(){
        this.editMode = false;
    }

    //updates product request status to release
    handleMarkAsComplete(){
        const fields = {};
        fields.Id = this.recordId;
        fields.Product_Request_Status__c = PL_ProductRequest_Release;
        this.handleUpdateRecord(fields,true);
    }

    //updates given record
    handleUpdateRecord(fieldsToUpdate,markAsComplete){
        const fields = {...fieldsToUpdate};
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            if(markAsComplete){
                this.generateToast('Success!',LWC_Toast_DesignComplete,'success');
            }
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

     //creates toast notification
     generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}