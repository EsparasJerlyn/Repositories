/**
 * @description Lightning Web Component for enabling of CCE Corporate User using quick action button
 *              located at the Account Record Page with Business Organization Record Type
 *
 * @see ../classes/CCECorporateUserCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
      |---------------------------|-----------------------|----------------------|-------------------------------------|
      | eccarius.munoz            | August 08, 2022       | DEPP-3488            | Created File                        |
      | eccarius.munoz            | September 13, 2022    | DEPP-4096            | Updated logic to handle enabling    |     
      |                           |                       |                      | user with existing ope user         | 
      | roy.nino.s.regala         | September 13, 2022    | DEPP-4225            | added work email requirement        | 
      | eccarius.munoz            | September 19, 2022    | DEPP-4366            | Added handling for business org     |     
      |                           |                       |                      | account validation.                 |
      |                           |                       |                      |                                     |
**/
import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import enableCCECorporateUser from '@salesforce/apex/CCECorporateUserCtrl.enableCCECorporateUser';
import enableCCECorporateUserForOPE from '@salesforce/apex/CCECorporateUserCtrl.enableCCECorporateUserForOPE';
import createExtManagedAcct from '@salesforce/apex/CCECorporateUserCtrl.createExtManagedAcct';

import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const SUCCESS_MSG = 'Successfully Enabled Corporate Partner User!';
const SUCCESS_TITLE = 'Success!';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';

export default class EnableCCECorporateUser extends LightningElement {

    userDetails;
    errorMessage;

    @api recordId;

    @api invoke() {
        enableCCECorporateUser({ 'recordId': this.recordId })
            .then(result => {
                if(!result.isSuccess){
                    this.errorMessage = result.errorMessage;
                    return false;
                }else{
                    this.userDetails = result;
                    let userId = result.userId;
                    if (result.hasOpeUser) {
                        return enableCCECorporateUserForOPE({
                            'recordId': result.contactId,
                            'contactFirstName': result.contactFirstName,
                            'contactLastName': result.contactLastName,
                            'email': result.email
                        });
                    } else {
                        return createExtManagedAcct({
                            'accountId': result.accountId,
                            'primaryBusinessAcctId': result.primaryBusinessAcctId,
                            'accountName': result.accountName,
                            'userId': userId
                        });
                    }
                }
            }).then(() => {
                let fields = {
                    Id: this.userDetails.contactId,
                    Is_CCE_Enabled__c: true
                }
                const recordInput = { fields };
                return updateRecord(recordInput);
            }).then(() => {
                this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
            })
            .catch(error => {
                console.error('ERROR: ' + JSON.stringify(error));
                if(this.errorMessage){
                    this.generateToast('Warning', this.errorMessage, ERROR_VARIANT);
                }else{
                    this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                }
            }
        );
    }

    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}