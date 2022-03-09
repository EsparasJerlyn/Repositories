/**
 * @description A custom LWC for showing single section layouts on a parent record page
 *              from metadata (with accordion section/toggle)
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
import { LightningElement, api, wire, track} from 'lwc';
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
    @track activeSections = [];
    layoutMapping = [];
    layoutItem = {};

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

    //decides whether to show accordion section
    get showAccordion(){
        return this.activeSections.length > 0 && this.parentSectionLabel;
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
        getLayoutMapping({objApiName : this.childObjectApiName, rtDevName : this.childRecordTypeDevName, isOpe : this.forOpe})
        .then(result => {
            this.layoutMapping = [...result];
            this.formatLayoutToDisplay();
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

    /**
     * formats layout columns for UI rendering
     */
    formatLayoutToDisplay(){
        this.layoutMapping = this.parentSectionLabel ? 
            this.layoutMapping.filter(layout => layout.MasterLabel == this.parentSectionLabel) : 
            this.layoutMapping.filter(layout => layout.Order__c);

        this.layoutItem.sectionLabel = this.layoutMapping[0].MasterLabel;
        this.layoutItem.leftColumn = 
            this.layoutMapping[0].Left_Column_Long__c ? 
            JSON.parse(this.layoutMapping[0].Left_Column_Long__c) : null;
        this.layoutItem.rightColumn = 
            this.layoutMapping[0].Right_Column_Long__c ? 
            JSON.parse(this.layoutMapping[0].Right_Column_Long__c) : null;
        this.layoutItem.singleColumn = 
            this.layoutMapping[0].Single_Column_Long__c ? 
            JSON.parse(this.layoutMapping[0].Single_Column_Long__c) : null;

        this.activeSections.push(this.layoutItem.sectionLabel);
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