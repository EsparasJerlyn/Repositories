/**
 * @description LWC component for creating of contact for CCE in Business Account
 ** 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                              |
      |---------------------------|-----------------------|--------------|-------------------------------------------------------------|
      | eccarius.munoz            | September 30, 2022    | DEPP-4480 &  | Created file                                                | 
      |                           |                       | DEPP-4489    |                                                             |  
      |                           |                       |              |                                                             |  
 */
import { api, LightningElement, wire } from 'lwc';

import { createRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import RT_Contact_Person from '@salesforce/label/c.RT_Contact_Person';
import CONTACT_OBJ from '@salesforce/schema/Contact';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import validateContactMatching from "@salesforce/apex/RegistrationMatchingHelper.validateContactMatching";
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const SUCCESS_TITLE = 'Success!';
const SUCCESS_VARIANT = 'success';
const SUCCESS_MSG = 'Record successfully saved!';

const fields = [ACCOUNT_NAME_FIELD];

export default class CreateCCEContact extends LightningElement {

    @api recordId;    

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJ})
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields })
    account;

    showSpinner = false;

    handleSubmit(event){    
        event.preventDefault();
        this.showSpinner = true;

        let contactList = [];
        let contact = {};
        contact.FirstName = event.detail.fields.FirstName;
        contact.LastName = event.detail.fields.LastName;
        contact.Birthdate = event.detail.fields.Birthdate;
        contact.Registered_Email__c = event.detail.fields.Work_Email__c;
        contactList.push(contact);

        validateContactMatching({ newContactList : JSON.stringify(contactList) }).then((res) => {
            let validationResult = res[0];
            if( validationResult.isPartialMatch == false && validationResult.isEmailMatch == false){                
                const recTypes = this.objectInfo.data.recordTypeInfos;
                let fields = {};  
                fields = {
                    FirstName : event.detail.fields.FirstName,
                    LastName : event.detail.fields.LastName,
                    Work_Email__c : event.detail.fields.Work_Email__c,
                    ContactMobile_Locale__c : event.detail.fields.ContactMobile_Locale__c,
                    MobilePhone : event.detail.fields.MobilePhone,
                    hed__Gender__c : event.detail.fields.hed__Gender__c,
                    Birthdate : event.detail.fields.Birthdate,
                    Position__c : event.detail.fields.Position__c,
                    Dietary_Requirement__c : event.detail.fields.Dietary_Requirement__c,
                    Accessibility_Requirement__c : event.detail.fields.Accessibility_Requirement__c,
                    hed__Primary_Organization__c : this.recordId,
                    RecordTypeId : Object.keys(recTypes).find(rti => recTypes[rti].name == RT_Contact_Person)
                }
                this.template.querySelector("lightning-record-edit-form").submit(fields);
            }else{
                this.showSpinner = false;
                this.generateToast('Warning', 'Duplicate contact cannot be created.', 'error');
            }
        }).catch(() => {
            this.showSpinner = false;
            this.generateToast('Error', LWC_Error_General, 'error');
        });
    }

    handleSuccess(){
        this.showSpinner = false;
        this.dispatchEvent(new CloseActionScreenEvent());
        this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);  
    }

    handleError(){
        this.showSpinner = false;
        this.generateToast('Error', LWC_Error_General, 'error');
    }

    closeModalAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    get accountName() {
        return getFieldValue(this.account.data, ACCOUNT_NAME_FIELD);
    }
}