import { LightningElement, api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import enablePortalUser from '@salesforce/apex/CCECorporateUserCtrl.enablePortalUser';
import enableCCECorporateUserForOPE from '@salesforce/apex/CCECorporateUserCtrl.enableCCECorporateUserForOPE';
import createExtManagedAcct from '@salesforce/apex/CCECorporateUserCtrl.createExtManagedAcct';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const SUCCESS_MSG = 'Successfully Enabled Portal User!';
const SUCCESS_TITLE = 'Success!';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';
const MODAL_HEADER = 'Enable Portal Access';
const OPE_OPTION_LBL = 'Product Catalogue';

export default class EnabledPortalAccessModal extends LightningElement {

    selectedOption = 'Corporate Portal';
    userDetails;
    errorMessage;
    isLoading = false;

    @api recordId;

    handleRadioChange(event){
        this.selectedOption = event.detail.value;
    }

    handleSave(){
        this.isLoading = true;
        enablePortalUser({ 'recordId': this.recordId, 'portalAccessType': this.selectedOption })
            .then(result => {
                if(!result.isSuccess){
                    this.errorMessage = result.errorMessage;
                    return false;
                }else{
                    this.userDetails = result;
                    let userId = result.userId;
                    if (result.hasOpeUser) {
                        if(!result.isNoUpdateNeeded){
                            return enableCCECorporateUserForOPE({
                                'recordId': result.contactId,
                                'contactFirstName': result.contactFirstName,
                                'contactLastName': result.contactLastName,
                                'email': result.email
                            });
                        }
                    } else {
                        if(!result.isNoUpdateNeeded){
                            return createExtManagedAcct({
                                'accountId': result.accountId,
                                'primaryBusinessAcctId': result.primaryBusinessAcctId,
                                'accountName': result.accountName,
                                'userId': userId
                            });
                        }
                    } 
                }
            }).then(() => {
                let fields = {
                    Id: this.userDetails.contactId,
                    Is_CCE_Enabled__c: this.selectedOption == OPE_OPTION_LBL ? false : true
                }
                const recordInput = { fields };
                return updateRecord(recordInput);
            }).then(() => {
                this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
                this.isLoading = false;
                this.closeModalAction();
            })
            .catch(() => {
                if(this.errorMessage){
                    this.generateToast('Warning', this.errorMessage, ERROR_VARIANT);
                    this.isLoading = false;
                this.closeModalAction();
                }else{
                    this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
                    this.isLoading = false;
                    this.closeModalAction();
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
    
    closeModalAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get options() {
        return [
            { label: 'Corporate Portal', value: 'Corporate Portal' },
            { label: 'Product Catalogue', value: 'Product Catalogue' }
        ];
    }

    get modalHeader(){
        return MODAL_HEADER;
    }

}