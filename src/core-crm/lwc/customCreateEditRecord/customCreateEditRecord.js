/**
 * @description A custom LWC modal pop-up for Creating or Editing records
 *
 * @see ../classes/CustomCreateEditRecordCtrl.cls
 * 
 * @author Accenture
 *
 * @usage 
 *      @parameters
 *      object-api-name (string, required) : object api name of record to be created/edited
 *      record-id (string, optional) : id of record to be edited
 *      record-type-name (string, optional) : record type label of records with specific record type
 *      parent-record-type-name (string, optional) : record type label of parent; for records with dependent record type selection
 *      allow-multi-create (optional, required) : boolean for determining if Save & New is allowed
 *      with-record-type-selection (boolean, optional) : boolean for determining if record has multiple record types
 *      pre-populated-fields (object, optional) : object containing pre-populated values e.g. {MyCustomField__c : 'My Custom Value'}
 *      @methods
 *      onclose - dispatches event containing false boolean when "X" or "Cancel" is selected
 *      onsave - dispatches event containing a draft (not yet committed to the database) of record created/edited
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | October 14, 2021      | DEPP-383     | Created file                                           | 
      | roy.nino.s.regala         | October 21, 2021      | DEPP-425     | Edited events and fixed bugs                           |
      | aljohn.motas              | December 21, 2021     | DEPP-214     | Added Edit temporary data parameter                    |      
*/
import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getLayoutMapping from '@salesforce/apex/CustomCreateEditRecordCtrl.getLayoutMapping';

export default class CustomCreateEditRecord extends LightningElement {

    @api objectApiName;
    @api recordId;
    @api recordTypeName;
    @api parentRecordTypeName;
    @api allowMultiCreate;
    @api editTempData;
    @api withRecordTypeSelection;
    @api prePopulatedFields = {};
    @api recordForOpe;
    @api isSaving = false;
    @api standardHeaderLabel;

    objectLabel = '';
    recordTypeId;
    selectedRecordType;
    isLoading;
    buttonName;
    showRecordTypeSelection = false;
    activeSections = [];
    recordTypeSelection = [];
    layoutMapping = [];
    layoutToDisplay = [];
    isDisabled = true;
    defaultRecordTypeId;

    /**
     * stores object record types and label
     */
    objectRecordTypeInfo;
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    handleObjectInfo({error,data}){
        if(data){
            this.objectRecordTypeInfo = data.recordTypeInfos;
            this.objectLabel = data.label;
            if(this.standardHeaderLabel){
                this.defaultRecordTypeId = data.defaultRecordTypeId;
            }
        }else if(error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * returns appropriate modal header depending on mode
     */
    get modalHeader(){
        let _modalHeader;

        if(this.standardHeaderLabel){
            if(this.objectRecordTypeInfo){
                let prefix = 'New';
                if(this.editTempData){
                    prefix = 'Edit';
                }
                _modalHeader = prefix + ' ' + this.objectLabel + ': '+this.objectRecordTypeInfo[this.defaultRecordTypeId].name;
            }else{
                _modalHeader = '';
            }
        }
        else{
            if(this.recordId || this.editTempData){
                _modalHeader = 'Edit ' + this.objectLabel;
            }else if(!this.recordId && this.showRecordTypeSelection){
                _modalHeader = this.objectLabel + ' Record Types';
            }else{
                _modalHeader = 'Create ' + this.objectLabel;
            }
        }

        return _modalHeader;
    }

    /**
     * returns boolean for disabling create button
     */
    get disableCreateButton(){
        return this.selectedRecordType && this.showRecordTypeSelection ? false : true;
    }

    /**
     * returns boolean for showing back button
     */
    get showBackButton(){
        return this.withRecordTypeSelection && !this.showRecordTypeSelection ? true : false;
    }

    /**
     * returns boolean for showing save and new button
     */
    get showSaveAndNewButton(){
        return this.allowMultiCreate && !this.recordId ? true : false;
    }

    /**
     * calls specified method on load
     */
    connectedCallback(){
        this.getRecordLayout();
    }

    /**
     * gets record layout from metadata
     * with record types (if applicable)
     */
     getRecordLayout(){
        this.isLoading = true;
        getLayoutMapping({objApiName : this.objectApiName, forOpe : this.recordForOpe})
        .then(result => {
            this.layoutMapping = [...result];
            
            if(this.withRecordTypeSelection){
                let recordTypes = this.layoutMapping.sort((a, b) => 
                    a.Record_Type_Setting__r.Order__c - b.Record_Type_Setting__r.Order__c
                );
                //for those with dependent record types
                if(this.parentRecordTypeName){
                    recordTypes = this.layoutMapping.filter(recType =>
                        recType.Record_Type_Setting__r.Parent_Record_Type__c == this.parentRecordTypeName
                    )
                }
                this.recordTypeSelection = recordTypes.map(recType => ({ 
                    label : recType.Record_Type_Setting__r.MasterLabel,
                    value : recType.Record_Type_Setting__r.MasterLabel,
                    checked : false
                }));
                this.showRecordTypeSelection = true;
            //for those without record type selection
            }else{
                this.selectedRecordType = this.recordTypeName;
                this.formatLayoutToDisplay();
            }
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
        let listToFormat = this.layoutMapping;
        //for records with specific record type
        if(this.selectedRecordType){
            this.recordTypeId = Object.keys(this.objectRecordTypeInfo).find(rti => 
                this.objectRecordTypeInfo[rti].name == this.selectedRecordType
            );
            listToFormat = this.layoutMapping.filter(layout =>
                layout.Record_Type_Setting__r.MasterLabel == this.selectedRecordType
            )
        }
        this.layoutToDisplay = listToFormat.map(layout => {
            let layoutItem = {};

            layoutItem.sectionLabel = layout.MasterLabel;
            layoutItem.leftColumn = layout.Left_Column_Long__c ? this.formatFieldProperties(JSON.parse(layout.Left_Column_Long__c)) : null;
            layoutItem.rightColumn = layout.Right_Column_Long__c ? this.formatFieldProperties(JSON.parse(layout.Right_Column_Long__c)) : null;
            layoutItem.singleColumn = layout.Single_Column_Long__c ? this.formatFieldProperties(JSON.parse(layout.Single_Column_Long__c)) : null;

            return layoutItem;

        });

        this.activeSections = this.layoutToDisplay.map(layout => {return layout.sectionLabel});
    }

    /**
     * pre-populates record type and specified fields if in create mode
     */
    formatFieldProperties(listToFormat){
        return listToFormat.length ? listToFormat.map(item => {
            let _field = {...item}; 

            //if in create mode
            if(!this.recordId){
                if(!this.recordTypeName && item.field == 'RecordTypeId'){
                    _field.value = this.recordTypeId;
                }else if( 'isPrePopulated' in item){
                    _field.value = this.prePopulatedFields[item.field];
                }
            }

            return _field;
        }) : [];
    }

    /**
     * fires an event with false boolean when "X" or Cancel is clicked
     */
    closeModal(){
        const closeModalEvent = new CustomEvent('close', {
            detail: false
        });
        this.dispatchEvent(closeModalEvent);
    }

    /**
     * shows record type selection
     * (if back button is applicable)
     */
    handleBack(){
        this.showRecordTypeSelection = true;
    }

    /**
     * checks if there are form changes
     */
    handleChange(){
        this.isDisabled = false;
    }

    /**
     * stores button name
     * (either saveAndNew or save)
     */
    storeButtonName(event){
        this.isSaving = true;
        this.buttonName = event.target.dataset.name;
    }

    /**
     * prevents default edit form submission
     * stores draft and fires an event to pass it
     */
    handleSubmit(event){
        event.preventDefault();
        let fields = event.detail.fields;
        if(this.recordId){
            fields.Id = this.recordId;
        }
        const saveRecordsEvent = new CustomEvent('save', {
            detail: fields
        });
        switch (this.buttonName){
            case 'saveAndNew':
                this.resetFields();
                break;
            case 'save':
                this.closeModal();
                break;
        }
        this.dispatchEvent(saveRecordsEvent);
        this.isSaving = false;
    }

    /**
     * resets edited fields that are not disabled
     */
    resetFields(){
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
            );
        
        if (inputFields) {
            inputFields.forEach(field => {
                if(!field.disabled){
                    field.reset();
                }
            });
        }
    }

    /**
     * hides record type selection and shows record layout
     */
    showPageLayout(){
        this.showRecordTypeSelection = false;
    }

    /**
     * (if with record type selection) gets the selected record type
     */
    getSelectedRecordType(event){
        this.selectedRecordType = event.target.value;
        this.recordTypeSelection.forEach(recType => {
            recType.checked = recType.value == this.selectedRecordType ? true : false;
        })
        this.formatLayoutToDisplay();
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

    /**
     * Show Validation Message
     */
    @api
    showValidationMessage(error){

        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );

        const fieldErrorsList = error.body.output.fieldErrors;

        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName in fieldErrorsList){
                    field.setErrors(error);
                }
                field.reportValidity();
            });
        }
    }

}