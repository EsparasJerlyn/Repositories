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
 *      for-ope (string, optional) : Set to true if layout is for an OPE feature
 *      parent-section-label (string, optional) : For individual sections use-case and not entire layout 
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | December 21, 2021     | DEPP-838,1299       | Created file                                           |
      | eccarius.munoz            | January 21, 2022      | DEPP-1344,1303,1222 | Added handling for OPE Design Completion               |
      |                           |                       |                     |                                                        |
*/
import { LightningElement, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getLayoutMapping from '@salesforce/apex/CustomLayoutCtrl.getLayoutMapping';
import getChildRecordId from '@salesforce/apex/CustomLayoutCtrl.getChildRecordId';

export default class CustomSectionLayout extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api childObjectApiName;
    @api parentObjectApiName;
    @api parentFieldApiName;
    @api grandParentFieldApiName;
    @api forOpe;
    @api parentSectionLabel;
    
    childRecordId;
    childRecordTypeDevName;
    activeSections = [];
    layoutMapping = [];
    layoutToDisplay = [];
    isLoading = false;
    editMode = false;

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

    
    /**
     * gets info of child object
     */
    @wire(getObjectInfo, { objectApiName: '$childObjectApiName'})
    handleChildObjectInfo(result){
        if(result.data){
            //condition for layouts with no record types
            //metadata is named as All_OPE_<Object_Label>
            this.childRecordTypeDevName = 'All_OPE_' + result.data.labelPlural.replace(' ','_');
            this.getRecordLayout();
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
        this.layoutMapping = this.parentSectionLabel ? 
            this.layoutMapping.filter(layout => layout.MasterLabel == this.parentSectionLabel) : 
            this.layoutMapping.filter(layout => layout.Order__c);
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
    handleSubmit(){
        this.isLoading = true;
    }

    /**
     * method for handling succesful save on record edit form
     */
    handleSuccess(){
        this.isLoading = false;
        this.editMode = false;
    }
    
    /**
     * method for handling record edit form errors
     */
    handleError(){
        this.isLoading = false;
    }
    
    /**
     * disables edit mode
     */
    handleCancel(){
        this.editMode = false;
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