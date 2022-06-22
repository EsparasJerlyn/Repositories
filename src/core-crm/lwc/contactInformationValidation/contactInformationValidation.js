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
      | kathy.cornejo             | May 31, 2022          | DEPP-2729    | Pilot 1 Optimisations                                       | 
      
 */

import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import STATUSES_CHANNEL from '@salesforce/messageChannel/StatusesMessageChannel__c';
import LEAD_SCHEMA from '@salesforce/schema/Lead';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import getMapping from '@salesforce/apex/ContactInformationValidationCtrl.getMapping';
import validateFields from '@salesforce/apex/ContactInformationValidationCtrl.validateFields';

const STR_NONE = 'None';
const STR_NOT_VALID = 'Not Valid';
const STR_VALID = 'Valid';
const STR_DOT = '.';
const STR_AU = 'Australia (+61)';
const STR_NZ = 'New Zealand (+64)';
const FIELD_MAPPING_API_NAME = 'Field_Mapping__c';
const VALID_STATUSES = [STR_VALID.toUpperCase(),'Active','connected|Network confirmed connection'];
const LOCALE_MAP = {
    [STR_AU] : 'AU',
    [STR_NZ] : 'NZ'
};
    
export default class ContactInformationValidation extends LightningElement {
    @api recordId;
    @api objectApiName;
    fieldsMapping = [];
    fieldsToQuery = [];
    fieldsToValidate = [];
    isLoading;
    disableEditButton;
    
    /**
     * getter for UI properties
     */
     get disableValidateButton(){
        return this.fieldsToValidate.length == 0 ? true : false;
    }

    get invalidConvert(){
        return this.fieldsMapping.filter(field => field.label == 'Phone' && field.statusValue == STR_NONE ).length > 0 &&
            this.fieldsMapping.filter(field => field.label == 'Mobile' && field.statusValue == STR_NONE ).length > 0 &&
            this.objectApiName == LEAD_SCHEMA.objectApiName;
    }

    get fieldSize(){
        return this.disableEditButton ? '4' : '8';
    }

    get statusClass(){
        return this.disableEditButton ? 
            'slds-align-middle' : 
            'slds-align-bottom';
    }

    //for LMS
    @wire(MessageContext)
    messageContext;

    /**
     * calls Apex method 'getMapping' and stores all fields to be queried
     */
    @wire(getMapping, { objApiName: '$objectApiName', fieldsToQuery : FIELD_MAPPING_API_NAME })
    handleFieldMapping({error, data}){
        if(data){
            let result = JSON.parse(data);
            this.fieldsMapping = JSON.parse(result[FIELD_MAPPING_API_NAME]);
            this.fieldsToQuery = [...this.fieldsMapping.map(fieldMap => this.generateFieldName(fieldMap.apiNameNoLocale)),
                ...this.fieldsMapping.map(fieldMap => this.generateFieldName(fieldMap.statusValidationField)),
                ...this.fieldsMapping.map(fieldMap => this.generateFieldName(fieldMap.localeField))];
        }else if(error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * gets the actual field values and assigns them for the fields to display
     */
    @wire(getRecord, { recordId: '$recordId', fields: '$fieldsToQuery' })
    handleFieldValues({error, data}){
        if(data){
            //get all non-empty fields with 'None' validation status
            this.fieldsToValidate = this.fieldsMapping.filter(field => 
                getFieldValue(data, this.generateFieldName(field.statusValidationField)) == STR_NONE &&
                getFieldValue(data, this.generateFieldName(field.apiNameNoLocale)))
                .map(field => {
                    let _field = {};
                    
                    _field.apiName = field.apiName;
                    _field.loqateRequest = field.loqateRequest;
                    _field.loqateResponse = field.loqateResponse;
                    _field.statusValidationField = field.statusValidationField;
                    _field.locale = LOCALE_MAP[getFieldValue(data, this.generateFieldName(field.localeField))];
                    _field.value = getFieldValue(data, this.generateFieldName(field.apiNameNoLocale));
                    _field.localePicklistValue = getFieldValue(data, this.generateFieldName(field.localeField));
    
                    return _field;
            });
            
            this.publishMessage();
        }else if(error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    connectedCallback(){
        this.publishMessage();
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
     * publishes the LMS
     */
    publishMessage(){
        const payload = { invalidConvert: this.invalidConvert };
        publish(this.messageContext, STATUSES_CHANNEL, payload);
    }

    /**
     * triggers spinner to show when Save is clicked and updates record
     */
    handleSaveButton(event){
        this.isLoading = true;
        event.preventDefault();
        let fields = event.detail.fields
        fields.Id = this.recordId;

        this.fieldsMapping.forEach(field => {
            if(
                fields[field.apiNameNoLocale] &&
                fields[field.localeField] !== STR_AU &&
                fields[field.localeField] !== STR_NZ
            ){
                fields[field.apiName] = this.combineLocaleAndNumber(fields[field.localeField],fields[field.apiNameNoLocale]);
            }
        });

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    
    combineLocaleAndNumber(locale,number){
        if(locale){
            return locale.replace(/[^0-9\.]+/g,"") + parseInt(number);
        }            
        return parseInt(number).toString();
    }

    /**
     * hides spinner and shows toast when save is successful
     */
    handleSuccess(){
        this.isLoading = false;
        this.successfulSave();
    }

    successfulSave(){
        this.disableEditButton = false;
        this.generateToast('Success!','Record updated.','success');
    }

    /**
     * hides spinner and shows toast when record edit form fails
     */
    handleError(){
        this.isLoading = false;
        this.generateToast('Error.',LWC_Error_General,'error');
    }

    /**
     * resets input fields when cancelled
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
     * disables edit button
     */
    handleEditButton(){
        this.disableEditButton = true;
    }

    /**
     * calls Apex method 'validateFields' and assigns results
     */
    handleValidateButton(){
        this.isLoading = true;

        validateFields({
            validateRequestList : JSON.stringify(this.fieldsToValidate)
        })
        .then(result => {
            let payload = JSON.parse(result); //list of payloads
            let fieldsToUpdate  = {};

            this.fieldsToValidate.forEach(field => {
                let _statusValue;
                let payloadResponseForField = payload.find(payloadItem => 
                    payloadItem[field.loqateRequest] == field.value &&
                    payloadItem[field.locale] == field.country);

                _statusValue = payloadResponseForField[field.loqateResponse];
                if(VALID_STATUSES.includes(_statusValue)){
                    fieldsToUpdate[field.statusValidationField] = STR_VALID;
                    fieldsToUpdate[field.apiName] = this.combineLocaleAndNumber(field.localePicklistValue,field.value);
                }else{
                    fieldsToUpdate[field.statusValidationField] = STR_NOT_VALID;
                    fieldsToUpdate[field.apiName] = null;
                }
            });
            this.handleUpdateFields(fieldsToUpdate,true);
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
            this.isLoading = false;
        });
    }
    
    /**
     * updates fields
     */
    handleUpdateFields(fieldsToUpdate,forValidate){
        this.isLoading = true;

        const fields = {...fieldsToUpdate};
        fields.Id = this.recordId;
    
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            if(forValidate){
                this.generateToast('Success!',this.fieldsToValidate.length + ' field/s validated.','success');
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