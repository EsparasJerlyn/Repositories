/**
 * @description A LWC component for validating Contact Information using Loqate
 *
 * @see ../classes/ContactInformationValidationCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary               |
      |---------------------------|-----------------------|----------|------------------------------|
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156 | Created file                 | 
      |                           |                       |          |                              | 
 */

import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';

import ACCOUNT_SCHEMA from '@salesforce/schema/Account';
import ABN_SCHEMA from '@salesforce/schema/Account.ABN__c';
import ENTITY_NAME_SCHEMA from '@salesforce/schema/Account.Entity_Name__c';
import VALIDATION_SCHEMA from '@salesforce/schema/Account.AccountABNEntity_Validation__c';

import getFieldMapping from '@salesforce/apex/ContactInformationValidationCtrl.getFieldMapping';

const STR_NONE = 'None';
const STR_VALIDATE = 'Validate';
const STR_ALL = ' All';
const STR_DOT = '.';
const MSG_ERROR = 'An error has been encountered. Please contact your Administrator.';
const PADDING_LEFTXXSMALL_CLASS = 'slds-p-left_xx-small';
const MARGIN_TOPXLARGE_CLASS = ' slds-m-top_x-large';
const MARGIN_VSMALL_CLASS = 'slds-m-vertical_small';
const FIELD_CLASS = 'slds-border_bottom sf-blue-text';

export default class ContactInformationValidation extends LightningElement {
    @api recordId;
    @api objectApiName;

    fieldsToDisplay = []; 
    fieldsMapping = [];
    fieldsToQuery = [];
    fieldsToValidate = [];
    fieldsWithNullStatus = {};

    statusOptions = [];
    errorMessage;
    entityNameValue;

    /**
     * get picklist values for Loqate status fields
     */
    @wire(getObjectInfo, { objectApiName: ACCOUNT_SCHEMA })
    accountMetadata;

    
    @wire(getPicklistValues,
        {
            recordTypeId: '$accountMetadata.data.defaultRecordTypeId', 
            fieldApiName: VALIDATION_SCHEMA
        }
    )
    handleLoqateValidationPicklist({error, data}){
        if(data){
            this.statusOptions = data.values;
        }else if(error){
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
        }
    }
    
    /**
     * calls Apex method 'getFieldMapping' and stores all fields to be queried
     */
    @wire(getFieldMapping, { objApiName: '$objectApiName' })
    handleFieldMapping({error, data}){
        if(data){
            this.fieldsMapping = JSON.parse(data);
            this.fieldsToQuery = [...this.fieldsMapping.map(fieldMap => this.generateFieldName(fieldMap.apiName)),
                ...this.fieldsMapping.map(fieldMap => this.generateFieldName(fieldMap.statusValidationField))];
            
            if(this.isABNQueried()){
                this.fieldsToQuery.push(this.generateFieldName(ENTITY_NAME_SCHEMA.fieldApiName));
            }
        }else if(error){
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
        }
    }
        

    /**
     * gets the actual field values and assigns them for the fields to display
     */
    @wire(getRecord, { recordId: '$recordId', fields: '$fieldsToQuery' })
    handleFieldValues({error, data}){
        if(data){
            this.fieldsToDisplay = this.fieldsMapping.map(fieldMap => {
                let _field = {};

                _field.id = fieldMap.apiName;
                _field.label = fieldMap.label;
                _field.value = getFieldValue(data, this.generateFieldName(fieldMap.apiName));
                _field.statusValue = getFieldValue(data, this.generateFieldName(fieldMap.statusValidationField));
                _field.class = _field.value ? FIELD_CLASS : FIELD_CLASS + MARGIN_TOPXLARGE_CLASS;

                return _field;
            });

            let fieldsWithNullStatusList = this.fieldsMapping.filter(field => !getFieldValue(data, this.generateFieldName(field.statusValidationField)));
            fieldsWithNullStatusList.forEach(field =>{
                this.fieldsWithNullStatus[field.statusValidationField] = STR_NONE;
            });
            if(Object.keys(this.fieldsWithNullStatus).length > 0){
                this.handleUpdateFields(this.fieldsWithNullStatus);
            }

            if(this.isABNQueried()){
                this.entityNameValue = getFieldValue(data, this.generateFieldName(ENTITY_NAME_SCHEMA.fieldApiName));
            }

            //get all non-empty fields with 'None' validation status
            this.fieldsToValidate = this.fieldsMapping.filter(field => 
                getFieldValue(data, this.generateFieldName(field.statusValidationField)) == STR_NONE &&
                getFieldValue(data, this.generateFieldName(field.apiName)))
                .map(field => {
                    let _field = {};
    
                    _field.loqateRequest = field.loqateRequest;
                    _field.loqateResponse = field.loqateResponse;
                    _field.statusValidationField = field.statusValidationField;
                    _field.value = getFieldValue(data, this.generateFieldName(field.apiName));
    
                    return _field;
            });
           
        }else if(error){
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
        }
    }
    
    /**
     * getter for UI properties
     */
    get validateButtonLabel(){
        return this.fieldsToValidate.length <= 1 ? STR_VALIDATE : STR_VALIDATE + STR_ALL;
    }

    get disableValidateButton(){
        return true;
    }

    get showEntityName(){
        return this.isABNQueried();
    }

    get entityNameClass(){
        return this.entityNameValue ? PADDING_LEFTXXSMALL_CLASS : MARGIN_VSMALL_CLASS; 
    }

    /**
     * concatenates object and field api name
     */
    generateFieldName(field){
        return this.objectApiName + STR_DOT + field;
    }

    /**
     * concatenates error name and message
     */
    generateErrorMessage(err){
        let _errorMsg = ' (';

        _errorMsg += err.name && err.message ? err.name + ': ' + err.message : err.body.message;
        _errorMsg += ')';

        return _errorMsg;
    }

    /**
     * looks for the ABN field in the fields to be queried
     */
    isABNQueried(){
        return this.fieldsToQuery.includes(this.generateFieldName(ABN_SCHEMA.fieldApiName));
    }

    /**
     * updates status validation fields
     */
     handleUpdateFields(fieldsToUpdate){
        const fields = {...fieldsToUpdate};
        fields.Id = this.recordId;
    
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            if(Object.keys(this.fieldsWithNullStatus).length > 0){
                this.fieldsWithNullStatus = {};
            }
        })
        .catch(error => {
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
        });
    }
}