/**
 * @description A LWC clone component for organisation validating Company Information
 *
 * @see ../classes/CompanyInformationValidationCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary    |
      |---------------------------|-----------------------|--------------|-------------------|
      | richard.a.santos          | August 25, 2024       | DEPP-9137    | Created file      | 
      |                           |                       |              |                   | 
 */

import { LightningElement, api, wire, track } from 'lwc';
import validateCompany from '@salesforce/apex/CompanyInformationValidationCtrl.validateCompany';

export default class CustomCompanyInformationValidation extends LightningElement {
    @track accountName = '';
    @track abn = '';
    @track entityName = '';
    @track requiredInputClass = { title: 'slds-input' }; // Add your required CSS class here

    handleAccountNameChange(event) {
        this.accountName = event.target.value;
    }

    handleABNChange(event) {
        this.abn = event.target.value;
    }

    handleEntityNameChange(event) {
        this.entityName = event.target.value;
    }

    handleValidateABN() {
        // Add your ABN validation logic here

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

        console.log('ABN validation clicked');
    }
}