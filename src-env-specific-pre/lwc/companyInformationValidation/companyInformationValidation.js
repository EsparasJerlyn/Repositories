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
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import STATUSES_CHANNEL from '@salesforce/messageChannel/StatusesMessageChannel__c';
import getCompanyMapping from '@salesforce/apex/CompanyInformationValidationCtrl.getCompanyMapping';
import validateCompany from '@salesforce/apex/CompanyInformationValidationCtrl.validateCompany';

const STR_DOT = '.';
const STR_NONE = 'None';
const STR_VALID = 'Valid';
const STR_NOT_VALID = 'Not '+ STR_VALID;
const STR_API_NAME = 'apiName';
const STR_STATUS_VAL_FIELD = 'statusValidationField';
const STR_STATUS_VALUE = 'statusValue';
const STR_VALUE = 'value';
const ABN_CLASS = 'slds-border_bottom sf-blue-text';
const MARGIN_TOPXLARGE_CLASS = ' slds-m-top_x-large';
const MSG_ERROR = 'An error has been encountered. Please contact your Administrator.';
const MSG_CONVERT_ERROR = 'You can\'t convert this lead if below contact information has not attempted validation.';

export default class CompanyInformationValidation extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track abn = {};
    abnToValidate = {};
    fieldsToQuery = [];
    entityNameValue;
    errorMessage;
    disableEditButton;
    invalidConvert = false;
    isLoading = false;
   
    /**
     * calls Apex method 'getCompanyMapping' and stores all fields to be queried
     */
     @wire(getCompanyMapping, { objApiName: '$objectApiName', fieldToQuery : 'Company_Mapping__c' })
     handleCompanyMapping({error, data}){
         if(data){
             this.abn = {...JSON.parse(data)};
             this.fieldsToQuery = [
                this.generateFieldName(this.abn[STR_API_NAME]),
                this.generateFieldName(this.abn[STR_STATUS_VAL_FIELD]),
                this.generateFieldName(ENTITY_NAME_SCHEMA.fieldApiName)
            ];
  
         }else if(error){
             this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
         }
     }

     /**
     * gets the actual field values
     */
    @wire(getRecord, { recordId: '$recordId', fields: '$fieldsToQuery' })
    handleFieldValues({error, data}){
        if(data){
            this.disableEditButton = false;

            let _statusValue = getFieldValue(data, this.generateFieldName(this.abn[STR_STATUS_VAL_FIELD]));
            if(_statusValue){
                this.abn[STR_STATUS_VALUE] = _statusValue;
            }else{
                let _statusToUpdate = {};
                _statusToUpdate[this.abn[STR_STATUS_VAL_FIELD]] = STR_NONE;
                this.handleUpdateFields(_statusToUpdate,false);
            }

            this.abn[STR_VALUE] = getFieldValue(data, this.generateFieldName(this.abn[STR_API_NAME]));
            this.entityNameValue = getFieldValue(data, this.generateFieldName(ENTITY_NAME_SCHEMA.fieldApiName));
         
            this.abnToValidate['loqateRequest'] = this.abn['loqateRequest'];
            this.abnToValidate['loqateResponse'] = this.abn['loqateResponse'];
            this.abnToValidate['locale'] = null;
            this.abnToValidate[STR_STATUS_VAL_FIELD] = this.abn[STR_STATUS_VAL_FIELD];
            this.abnToValidate[STR_VALUE] = this.abn[STR_VALUE];
           
            this.subscribeToMessageChannel();
        }else if(error){
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
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
        return MSG_CONVERT_ERROR;
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
        this.invalidConvert = (this.abn[STR_STATUS_VALUE] == STR_NONE || message.invalidConvert) &&
            this.objectApiName == LEAD_SCHEMA.objectApiName
            ? true : false;
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
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
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
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
            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }
}