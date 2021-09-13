/**
 * @description A LWC component for validating Contact Information using Loqate
 *
 * @see ../classes/ContactInformationValidationCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                              |
      |---------------------------|-----------------------|--------------|-------------------------------------------------------------|
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156     | Created file                                                | 
      | angelika.j.s.galang       | September 8, 2021     | DEP1-157,172 | Added error message for conversion and validation handler   | 
 */

import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ACCOUNT_SCHEMA from '@salesforce/schema/Account';
import LEAD_SCHEMA from '@salesforce/schema/Lead';
import ABN_SCHEMA from '@salesforce/schema/Account.ABN__c';
import ENTITY_NAME_SCHEMA from '@salesforce/schema/Account.Entity_Name__c';
import VALIDATION_SCHEMA from '@salesforce/schema/Account.AccountABNEntity_Validation__c';

import getFieldMapping from '@salesforce/apex/ContactInformationValidationCtrl.getFieldMapping';
import validateFields from '@salesforce/apex/ContactInformationValidationCtrl.validateFields';

const STR_NONE = 'None';
const STR_NOT_VALID = 'Not Valid';
const STR_VALID = 'Valid';
const STR_INV = 'INV';
const STR_VALIDATE = 'Validate';
const STR_NAME = 'name';
const STR_ABN = 'abn';
const STR_DOT = '.';
const STR_COMMA = ',';
const MSG_ERROR = 'An error has been encountered. Please contact your Administrator.';
const MSG_CONVERT_ERROR = 'You can\'t convert this Lead if below contact information are not valid.';
const PADDING_LEFTXXSMALL_CLASS = 'slds-p-left_xx-small';
const MARGIN_TOPXLARGE_CLASS = ' slds-m-top_x-large';
const MARGIN_VSMALL_CLASS = 'slds-m-vertical_small';
const FIELD_CLASS = 'slds-border_bottom sf-blue-text';
const VALID_STATUSES = [STR_VALID.toUpperCase(),'Active','connected|Network confirmed connection'];

export default class ContactInformationValidation extends LightningElement {
    @api recordId;
    @api objectApiName;

    fieldsToDisplay = []; 
    fieldsMapping = [];
    fieldsToQuery = [];
    fieldsToValidate = [];
    fieldsToUpdate = {};
    fieldsWithNullStatus = {};
    
    statusOptions = [];
    errorMessage;
    entityNameValue;
    isLoading;

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

            //update existing records with null validation statuses
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
        return STR_VALIDATE;
    }

    get disableValidateButton(){
        return this.fieldsToValidate.length == 0 ? true : false;
    }

    get showEntityName(){
        return this.isABNQueried();
    }

    get invalidConvert(){
        return this.fieldsToDisplay.filter(field => field.statusValue == STR_NOT_VALID).length > 0 && this.objectApiName == LEAD_SCHEMA.objectApiName;
    }

    get errorConvertMessage(){
        return MSG_CONVERT_ERROR;
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
     * looks for the ABN field in the fields to be queried
     */
    isABNQueried(){
        return this.fieldsToQuery.includes(this.generateFieldName(ABN_SCHEMA.fieldApiName));
    }

    /**
     * calls Apex method 'validateFields' and assigns results
     */
    handleValidate(){
        this.isLoading = true;

        validateFields({
            validateRequestList : JSON.stringify(this.fieldsToValidate)
        })
        .then(result => {
            let payload = JSON.parse(result); //list of payloads

            this.fieldsToValidate.forEach(field => {
                //for abn value, request payload property is 'name' but response property is 'abn'
                //entity name value in response property is 'name'
                let _loqateRequest = field.loqateRequest == STR_NAME ? STR_ABN : field.loqateRequest;
                let _statusValue;

                if(payload.find(payloadItem => payloadItem[_loqateRequest] == field.value)){
                    let payloadResponseForField = payload.find(payloadItem => payloadItem[_loqateRequest] == field.value);

                    //assign entity name if abn response returned
                    if(_loqateRequest == STR_ABN){
                        this.entityNameValue = payloadResponseForField[field.loqateRequest];
                        this.fieldsToUpdate[ENTITY_NAME_SCHEMA.fieldApiName] = this.entityNameValue;
                    }

                    //this condition is for email response properties
                    //7 JSON properties have to be checked for it to be considered Valid
                    if(field.loqateResponse.includes(STR_COMMA)){
                        let _properties = field.loqateResponse.split(STR_COMMA);
                        let _propertyValuesStr = [];
                        let _propertyValuesBool = [];

                        _properties.forEach(_property => {
                            let _propertyValue;
                            //this condition is for properties with sub-properties
                            if(_property.includes(STR_DOT)){
                                let _subproperties = _property.split(STR_DOT);

                                //if response attributes returned values
                                if(payloadResponseForField[_subproperties[0]]){
                                    _propertyValue = payloadResponseForField[_subproperties[0]][_subproperties[1]];
                                }
                            }else{
                                _propertyValue = payloadResponseForField[_property];
                            }

                            if(typeof _propertyValue === 'string'){
                                _propertyValuesStr.push(_propertyValue);
                            }else if(typeof _propertyValue === 'boolean'){
                                _propertyValuesBool.push(_propertyValue);
                            }
                            
                        });
                        _propertyValuesStr = _propertyValuesStr.filter(_prop => _prop !== STR_VALID.toUpperCase());
                        _propertyValuesBool = _propertyValuesBool.filter(_prop => _prop == false);
                        _statusValue = _propertyValuesStr.length > 0 || _propertyValuesBool.length > 0 ? STR_INV : STR_VALID.toUpperCase();
                    }else{
                        _statusValue = payloadResponseForField[field.loqateResponse];
                    } 
                }else if(field.loqateRequest == STR_NAME){
                    //this condition is to set ABN status field to invalid if value not found in payload
                    //loqate API does not return anything if ABN is invalid/DNE
                    _statusValue = STR_INV;
                }

                this.fieldsToUpdate[field.statusValidationField] = VALID_STATUSES.includes(_statusValue) ? STR_VALID : STR_NOT_VALID;
            });

            this.handleUpdateFields(this.fieldsToUpdate);
            
        })
        .catch(error => {
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
            this.isLoading = false;
        })
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
            if(Object.keys(this.fieldsToUpdate).length > 0){
                this.fieldsToUpdate = {};
            }
            if(this.fieldsToValidate.length > 0){
                this.generateToast('Success!',this.fieldsToValidate.length + ' field/s validated.','success');
            }
        })
        .catch(error => {
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }
}