/**
 * @description A LWC component for validating Company Information using Loqate
 *
 * @see ../classes/CompanyInformationValidationCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary    |
      |---------------------------|-----------------------|--------------|-------------------|
      | angelika.j.s.galang       | September 17, 2021    | DEP1-518     | Created file      | 
      |                           |                       |              |                   | 
 */

import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LEAD_SCHEMA from '@salesforce/schema/Lead';
import ENTITY_NAME_SCHEMA from '@salesforce/schema/Account.Entity_Name__c';
import PHONE_SCHEMA from '@salesforce/schema/Account.Phone';
import CAN_BE_CONVERTED from '@salesforce/schema/Lead.Can_Be_Converted__c';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import STATUSES_CHANNEL from '@salesforce/messageChannel/StatusesMessageChannel__c';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getMapping from '@salesforce/apex/CompanyInformationValidationCtrl.getMapping';
import validateCompany from '@salesforce/apex/CompanyInformationValidationCtrl.validateCompany';

const STR_DOT = '.';
const STR_COMMA = ',';
const STR_NONE = 'None';
const STR_VALID = 'Valid';
const STR_NOT_VALID = 'Not '+ STR_VALID;
const STR_API_NAME = 'apiName';
const STR_STATUS_VAL_FIELD = 'statusValidationField';
const STR_STATUS_VALUE = 'statusValue';
const STR_VALUE = 'value';
const COMPANY_MAPPING_API_NAME = 'Company_Mapping__c';
const VAL_RULE_API_NAME = 'Validation_Rule_Fields__c';
const ABN_CLASS = 'slds-border_bottom sf-blue-text';
const MARGIN_TOPXLARGE_CLASS = ' slds-m-top_x-large';
const MSG_CONVERT_ERROR = 'You can\'t convert this lead if below contact information has not attempted validation.';
const MSG_VAL_ERROR = ' The following fields need to be populated: ';
const PHONE_OR_MOBILE = ['Phone_No_Locale__c','Mobile_No_Locale__c'];
const ADDRESS_FIELDS = ['Street','City','State','PostalCode','Country'];

export default class CompanyInformationValidation extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track abn = {};
    abnToValidate = {};
    allFieldsToQuery = [];
    validationRuleFields = [];
    requiredFieldsToDisplay = [];
    entityNameValue;
    disableEditButton;
    invalidConvertContact = false;
    isLoading = false;
    showEditField = true;

    /**
     * calls Apex method 'getMapping' and stores all fields to be queried
     */
    @wire(getMapping, { objApiName: '$objectApiName', fieldsToQuery : '$mdtFieldsToQuery' })
    handleMapping({error, data}){
        if(data){
            let result = JSON.parse(data);
            let addLeadFields = [];
            if(this.objectApiName == LEAD_SCHEMA.objectApiName){
                this.validationRuleFields = JSON.parse(result[VAL_RULE_API_NAME]);
                addLeadFields = [
                    this.generateFieldName(CAN_BE_CONVERTED.fieldApiName),
                    ...this.validationRuleFields.map(field => {return this.generateFieldName(field.apiName)})
                ];
            }
            this.abn = JSON.parse(result[COMPANY_MAPPING_API_NAME]);
            this.allFieldsToQuery = [
                this.generateFieldName(this.abn[STR_API_NAME]),
                this.generateFieldName(this.abn[STR_STATUS_VAL_FIELD]),
                this.generateFieldName(ENTITY_NAME_SCHEMA.fieldApiName),
                ...addLeadFields
            ];
        }else if(error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

     /**
     * gets the actual field values
     */
    @wire(getRecord, { recordId: '$recordId', fields: '$allFieldsToQuery' })
    handleFieldValues({error, data}){
        if(data){
            this.disableEditButton = false;
            this.requiredFieldsToDisplay = [];
            
            //for preupdating fields
            let _statusToUpdate = {};
            let _statusValue = getFieldValue(data, this.generateFieldName(this.abn[STR_STATUS_VAL_FIELD]));
            if(_statusValue){
                this.abn[STR_STATUS_VALUE] = _statusValue;
            }else{
                _statusToUpdate[this.abn[STR_STATUS_VAL_FIELD]] = STR_NONE;
                this.handleUpdateFields(_statusToUpdate,false);
            }
            
            //for lead validation rule error message
            if(this.objectApiName == LEAD_SCHEMA.objectApiName){
                let phoneOrMobile = 0;
                let address = 0;
                this.validationRuleFields.forEach(field => {
                    if(!getFieldValue(data,this.generateFieldName(field.apiName))){
                        if(PHONE_OR_MOBILE.includes(field.apiName)){
                            phoneOrMobile++;
                        }else if(ADDRESS_FIELDS.includes(field.apiName)){
                            address++;
                        }else{
                            this.requiredFieldsToDisplay.push(field.label);
                        }
                    }
                });
                if(phoneOrMobile > 1){
                    this.requiredFieldsToDisplay.push('Phone or Mobile');
                }
                if(address == 5){
                    this.requiredFieldsToDisplay.push('Address');
                }
            }
            
            this.abn[STR_VALUE] = getFieldValue(data, this.generateFieldName(this.abn[STR_API_NAME]));
            this.entityNameValue = getFieldValue(data, this.generateFieldName(ENTITY_NAME_SCHEMA.fieldApiName));
            
            //for loqate response
            this.abnToValidate['loqateRequest'] = this.abn['loqateRequest'];
            this.abnToValidate['loqateResponse'] = this.abn['loqateResponse'];
            this.abnToValidate['locale'] = null;
            this.abnToValidate[STR_STATUS_VAL_FIELD] = this.abn[STR_STATUS_VAL_FIELD];
            this.abnToValidate[STR_VALUE] = this.abn[STR_VALUE] ? this.abn[STR_VALUE].replace(/\s/g, '') : '';

            this.subscribeToMessageChannel();
        }else if(error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * getter for UI properties
     */
    get disableValidateButton(){
        return this.abn[STR_STATUS_VALUE] == STR_NONE && this.abn[STR_VALUE] ? false : true;
    }

    get abnValueClass(){
        return this.abn[STR_VALUE] ? ABN_CLASS : ABN_CLASS + MARGIN_TOPXLARGE_CLASS;
    }

    get errorConvertMessage(){
        let _errorMsg;

        if(this.invalidStatusConvert && this.requiredFieldsToDisplay.length > 0){
            _errorMsg = MSG_CONVERT_ERROR + MSG_VAL_ERROR + this.requiredFieldsToDisplay.join(', ') + STR_DOT;
        }else if(this.invalidStatusConvert && this.requiredFieldsToDisplay.length == 0){
            _errorMsg = MSG_CONVERT_ERROR;
        }else if(!this.invalidStatusConvert && this.requiredFieldsToDisplay.length > 0){
            _errorMsg = MSG_VAL_ERROR + this.requiredFieldsToDisplay.join(', ') + STR_DOT;
        }

        return _errorMsg;
    }

    get mdtFieldsToQuery(){
        return this.objectApiName == LEAD_SCHEMA.objectApiName ? 
            COMPANY_MAPPING_API_NAME + STR_COMMA + VAL_RULE_API_NAME : COMPANY_MAPPING_API_NAME;
    }

    get invalidStatusConvert(){
        return this.invalidConvertContact ? true : false;
    }

    get showErrorMessage(){
        return (this.invalidStatusConvert || this.requiredFieldsToDisplay.length > 0) &&
            this.objectApiName == LEAD_SCHEMA.objectApiName
            ? true : false;
    }

   
    //for LMS
    @wire(MessageContext)
    messageContext;

    /**
     * encapsulates logic for LMS subscribe and unsubsubscribe
     */ 
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                STATUSES_CHANNEL,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        this.invalidConvertContact = message.invalidConvert && this.objectApiName == LEAD_SCHEMA.objectApiName ? true : false;
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    /**
     * concatenates object and field api name
     */
    generateFieldName(field){
        return this.objectApiName + STR_DOT + field;
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
     * disables edit button
     */
    handleEditButton(){
        this.disableEditButton = true;
        this.showEditField = !this.showEditField;
    }

    /**
     * disables edit button for phone field
     */
    handleEdit() {
        this.showEditField = !this.showEditField;
      }

    /**
     * calls apex method 'validateCompany' and assigns results
     */
    handleValidateButton(){
        this.isLoading = true;

        validateCompany({
            validateRequestList : JSON.stringify([this.abnToValidate])
        })
        .then(result => {
            let payload = JSON.parse(result); //list of payloads
            let _statusToUpdate = {};

            if(payload.length > 0){
                this.entityNameValue = payload[0].name;
                this.abn[STR_STATUS_VALUE] = STR_VALID;
                _statusToUpdate[ENTITY_NAME_SCHEMA.fieldApiName] = payload[0].name;
                _statusToUpdate[this.abn[STR_STATUS_VAL_FIELD]] = STR_VALID;
            }else{
                _statusToUpdate[this.abn[STR_STATUS_VAL_FIELD]] = STR_NOT_VALID;
            }

            this.handleUpdateFields(_statusToUpdate,true);
            
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
            this.isLoading = false;
        });
    }

    /**
     * trigger spinner when Save is clicked
     */
    handleSaveButton(){
        this.isLoading = true;
    }

    /**
     * off spinner and show toast if update successful
     */
    handleSuccess(){
        this.isLoading = false;
        this.disableEditButton = false;
        this.generateToast('Success!','Record updated.','success');
    }

    /**
     * resets the input field when cancelled
     */
    handleCancelButton(){
        this.disableEditButton = false;

        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if(inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    /**
     * updates given fields
     */
    handleUpdateFields(fieldsToUpdate,forValidate){
        this.isLoading = true;
        
        const fields = {...fieldsToUpdate};
        fields.Id = this.recordId;
    
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            if(forValidate){
                this.generateToast('Success!',this.abn['label'] + ' field validated.','success')
            }
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }
}