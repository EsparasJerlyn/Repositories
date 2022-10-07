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
      | eccarius.munoz            | July 13, 2022         | DEPP-2035           | Added handling for CCE Design Completion               |
      | roy.nino.s.regala         | August 4, 2022        | DEPP-2498           | Added layout changes for SOA and Field Dependent layout|
      | eccarius.munoz            | August 16, 2022       | DEPP-2842           | Added handling to remove set-up group registration     |
      |                           |                       |                     | section from child of prescribed program.              |
*/
import { LightningElement, api, wire, track } from "lwc";
import { getRecordUi, getRecord, updateRecord, getRecordNotifyChange} from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import LWC_Error_NoAccess from '@salesforce/label/c.LWC_Error_NoAccess';
import LWC_Toast_DesignComplete from '@salesforce/label/c.LWC_Toast_DesignComplete';
import PL_ProductRequest_Release from '@salesforce/label/c.PL_ProductRequest_Release';
import PL_ProductRequest_Published from '@salesforce/label/c.PL_ProductRequest_Published';
import DesignToPublishObjects from '@salesforce/label/c.DesignToPublishObjects';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import getChildRecordId from '@salesforce/apex/CustomLayoutCtrl.getChildRecordId';
import getLayoutMapping from '@salesforce/apex/CustomLayoutCtrl.getLayoutMapping';
import getLayoutMappingWithField from '@salesforce/apex/CustomLayoutCtrl.getLayoutMappingWithField';
import PRODUCT_SCHEMA from '@salesforce/schema/Product2';
import COURSE_SCHEMA from '@salesforce/schema/hed__Course__c';
import PROGRAM_SCHEMA from '@salesforce/schema/hed__Program_Plan__c';
import BUYER_GROUP_SCHEMA from '@salesforce/schema/BuyerGroup';
import ASSET_SCHEMA from '@salesforce/schema/Asset';

//Product Request fields
const PR_FIELDS = [
    "Product_Request__c.Product_Specification__r.RecordTypeId",
    "Product_Request__c.Product_Request_Status__c",
    "Product_Request__c.Child_of_Prescribed_Program__c"
];

const BY_POSITION_LAYOUT = {
    Product2:
    [{
        recordType: 'OPE',
        isOPE: true,
        devName:'All_OPE_Products',
        top:[
            'Commerce Details'
        ],
        bottom:[
            'Set-up Group Registrations'
        ]
    },
    {
        recordType: 'CCE',
        isOPE: false,
        devName: 'All_Products',
        top:[
            'Product Details'
        ]
    }],
    hed__Course__c:
    [{
        recordType: 'CCE',
        isOPE: false,
        devName: 'Diagnostic_Tool',
        bottom:[
            'Design Complete',
            'System Information'
        ]
    }],
    hed__Program_Plan__c:
    [{
        recordType: 'CCE',
        isOPE: false,
        devName: 'Program_Without_Pathway',
        bottom:[
            'Design Complete',
            'System Information'
        ]
    }],
    BuyerGroup:
    [{
        recordType: 'CCE',
        isOPE: false,
        devName: 'All_Buyer_Groups',
        top:[
            'Standing Offer Arrangement',
            'Product Details',
            'Publishing',
            'Product Dates'
        ]
    }],
    Asset:
    [{
        recordType: 'CCE',
        isOPE: false,
        devName: 'All_Assets',
        top:[
            'Corporate Bundle Details',
            'Publishing',
            'Product Dates'
        ]
    }]
}

export default class CreateRecordUI extends LightningElement {
    @api objectApiName;
    @api recordId;

    @api childObjectApiName;
    @api parentObjectApiName;
    @api parentFieldApiName;
    @api grandParentFieldApiName;
    @api tab;
    @api isProgram;
    @api fieldDependencyLayout = {};
    @api recordType;

    @track parentRecord = {};
    activeSections = [];
    uiRecord;
    childRecordId;
    editMode = false;
    isLoading = true;
    isComplete;
    showPopoverIcon = false;
    showPopoverDialog = false;
    popoverErrorMessages = [];
    productSpecRecordType = '';
    layoutMapping = [];
    @track topLayoutList = [];
    @track bottomLayoutList = [];
    hasTopLayout = false;
    hasBottomLayout = false;
    isChildOfPresc;

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

     //hides pagelayout and use custom metadata to show sections and fields
    get isFullyCustom(){
        return this.fieldDependencyLayout.fullyCustom ||
        (this.recordType == 'Standing_Offer_Arrangement' && this.tab && this.tab.split(',').includes('Release')) ||
        (this.recordType == 'Corporate_Bundle' && this.tab && this.tab.split(',').includes('Release'));
    }

    //disables edit button if status does not match specified tab
    get disableEditButton(){
        return this.tab && !this.tab.split(',').includes(this.parentRecord.status);
    }

    get childRecordTypeDevName(){
        if(this.childObjectApiName == PRODUCT_SCHEMA.objectApiName && this.productSpecRecordType == 'OPE'){
            return 'All_OPE_Products';
        }else if(this.childObjectApiName == PRODUCT_SCHEMA.objectApiName && this.productSpecRecordType == 'CCE'){
            return 'All_Products';
        }else if(this.childObjectApiName == COURSE_SCHEMA.objectApiName || this.childObjectApiName == PROGRAM_SCHEMA.objectApiName ){
            return this.recordType;
        }else if(this.childObjectApiName == BUYER_GROUP_SCHEMA.objectApiName && this.tab && this.tab.split(',').includes('Release')){
            return 'All_Buyer_Groups';
        }else if(this.childObjectApiName === ASSET_SCHEMA.objectApiName && this.tab && this.tab.split(',').includes('Release')){
            return 'All_Assets';
        }else{
            return '';
        }
    }

    //gets product request fields
    //assign custom layout from metadata
    @wire(getRecord, { recordId: '$recordId', fields: PR_FIELDS })
    handleParentRecord(result){

        if(result.data){
            this.topLayoutList = [];
            this.bottomLayoutList = [];
            this.activeSections = [];
            this.parentRecord.status = result.data.fields.Product_Request_Status__c.value;
            this.productSpecRecordType = result.data.fields.Product_Specification__r.value.recordTypeInfo.name;
            this.isChildOfPresc = result.data.fields.Child_of_Prescribed_Program__c.value;
            if( BY_POSITION_LAYOUT[this.childObjectApiName] &&
                BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType) &&
                BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType).devName == this.childRecordTypeDevName){

                this.getRecordLayout(BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType).isOPE);


            }
            if( this.fieldDependencyLayout &&
                this.fieldDependencyLayout.childObject === this.childObjectApiName){

                this.getRecordLayoutWithField();
            }
        }else if(result.error){
            console.log(result.error);
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
                    this.activeSections.push(section.id);
                    return {
                        ...section,
                        layoutRows: section.layoutRows.map(row => {
                            return {
                                ...row,
                                layoutItems: row.layoutItems.map(item => {
                                    return {
                                        ...item,
                                        isSysInfoData: item.label == 'Created By' || item.label == 'Last Modified By',
                                        isDisabled: !item.editableForUpdate //Not editable on page layout
                                    }
                                })
                            }
                        }),
                        fieldSize: 12/section.columns
                    }
                });
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

        this.isComplete = eventFields.Mark_Design_Stage_as_Complete__c || eventFields.Mark_Design_as_Complete__c?true:false;
    }

    //disables spinner and edit mode on success
    handleSuccess(){
        this.editMode = false;
        this.isLoading = false;
        
        //checks if design stage is marked as complete
        if(this.isComplete){
            this.handleMarkAsComplete();
        }else{
            getRecordNotifyChange([{recordId: this.recordId}]);

            //fix for buyer group publishing fields not refreshing
            getRecordNotifyChange([{recordId: this.childRecordId}]);
        }
    }

    //disables spinner on error
    handleError(event){
        this.popoverErrorMessages = [];
        if( event.detail && event.detail.output &&
            event.detail.output.errors[0] &&
            event.detail.output.errors[0].errorCode == 'FIELD_CUSTOM_VALIDATION_EXCEPTION'){
            this.popoverErrorMessages.unshift(event.detail.output.errors[0].message);
        }
        if( event.detail && event.detail.output &&
            event.detail.output.errors[0] && 
            event.detail.output.errors[0] && 
            event.detail.output.errors[0].errorCode == 'DUPLICATES_DETECTED'){
            this.popoverErrorMessages.unshift(event.detail.output.errors[0].message);
        }
        //for error messages not visible on shown fields
        if(this.popoverErrorMessages.length > 0){  
            this.showPopoverIcon = true;
            this.showPopoverDialog = true;
        }
        this.isLoading = false;
    }

    //cancels edit mode
    handleCancel(){
        this.resetPopover();
        this.editMode = false;
    }

    /**
     * calls apex method to get UI layout from metadata
     */
     getRecordLayout(isOPE){
        getLayoutMapping({objApiName : this.childObjectApiName, rtDevName : this.childRecordTypeDevName, isOpe : isOPE})
        .then(result => {

            this.layoutMapping = [...result];
            if( BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType) &&
                BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType).top){

                BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType).top.map(row => {
                    this.topLayoutList.push(this.formatLayoutToDisplay(row));
                })

                this.hasTopLayout = true;
            }

            if( BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType) &&
                BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType).bottom){

                let setupGrpRegSectionLabel = 'Set-up Group Registrations';
                let productObjName = 'Product2';

                BY_POSITION_LAYOUT[this.childObjectApiName].find(row => row.recordType === this.productSpecRecordType).bottom.map(row => {
                    if(!(this.isChildOfPresc && row == setupGrpRegSectionLabel && this.childObjectApiName == productObjName)){
                        this.bottomLayoutList.push(this.formatLayoutToDisplay(row));
                    }
                })

                this.hasBottomLayout = true;
            }

        })
        .catch(error =>{
            console.log(error);
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

    /**
     * calls apex method to get UI layout from metadata with dependency field
     */
    getRecordLayoutWithField(){
        getLayoutMappingWithField({objectInfo : this.fieldDependencyLayout, recordId:this.recordId})
        .then((result) =>{
            this.layoutMapping = [...result];
            this.layoutMapping.map(row => {
                this.topLayoutList.push(this.formatLayoutToDisplay(row.MasterLabel));
            });
            this.hasTopLayout = true;
        })
    }


     /**
     * formats layout columns for UI rendering
     */
      formatLayoutToDisplay(parentSectionLabel){

        let tempLayoutMapping = parentSectionLabel ?
        this.layoutMapping.filter(layout => layout.MasterLabel == parentSectionLabel) :
        this.layoutMapping.filter(layout => layout.Order__c);

        let tempLayoutItem = {};

        tempLayoutItem.sectionLabel = tempLayoutMapping[0].Section_Label__c?
        tempLayoutMapping[0].Section_Label__c: tempLayoutMapping[0].MasterLabel;

        tempLayoutItem.leftRightColumn =
        tempLayoutMapping[0].Left_Right_Column_Long__c ?
            JSON.parse(tempLayoutMapping[0].Left_Right_Column_Long__c) : null;

        tempLayoutItem.leftColumn =
        tempLayoutMapping[0].Left_Column_Long__c ?
            JSON.parse(tempLayoutMapping[0].Left_Column_Long__c) : null;

        tempLayoutItem.rightColumn =
        tempLayoutMapping[0].Right_Column_Long__c ?
            JSON.parse(tempLayoutMapping[0].Right_Column_Long__c) : null;

        tempLayoutItem.singleColumn =
        tempLayoutMapping[0].Single_Column_Long__c ?
            JSON.parse(tempLayoutMapping[0].Single_Column_Long__c) : null;

        this.activeSections.push(tempLayoutItem.sectionLabel);

        return tempLayoutItem;
    }

    //updates product request status to release
    handleMarkAsComplete(){
        const objs = DesignToPublishObjects;
        const fields = {};
        fields.Id = this.recordId;
        if(objs.includes(this.childObjectApiName)){
            fields.Product_Request_Status__c = PL_ProductRequest_Published;
        }else{
            fields.Product_Request_Status__c = PL_ProductRequest_Release;
        }
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
            console.log(error);
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

     //creates toast notification
     generateToast(_title,_message,_variant){
        this.resetPopover();
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    /**
     * shows/hides the popover error dialog
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
        this.popoverErrorMessages = [];
    }
}
