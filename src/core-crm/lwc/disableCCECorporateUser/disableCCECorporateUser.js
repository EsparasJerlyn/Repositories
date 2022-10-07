import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import disableCCECorporateUser from '@salesforce/apex/CCECorporateUserCtrl.disableCCECorporateUser';

const SUCCESS_MSG = 'Successfully Disabled Corporate Partner User!';
const SUCCESS_TITLE = 'Success!';
const SUCCESS_VARIANT = 'success';

export default class DisableCCECorporateUser extends LightningElement {

    @api recordId;

    @api invoke(){
        disableCCECorporateUser({'recordId' : this.recordId})
        .then(() => {
            let fields = {
                Id : this.recordId,
                Is_CCE_Enabled__c : false            
            }
            const recordInput = { fields };
            return updateRecord(recordInput);
        }).then(()=>{
            this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
        }).catch(error => {
            console.error('ERROR: ' + JSON.stringify(error));
        });
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