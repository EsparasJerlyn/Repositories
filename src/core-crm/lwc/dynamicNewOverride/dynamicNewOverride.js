
import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecordTypes } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';

import { NavigationMixin } from 'lightning/navigation';

export default class dynamicNewOverride extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api objectName;
    @api parentRecordId;
    selectedRecordTypeId;
    recordOptions = [];
    
    //Modal Data
    formData = {};
    failureType = null;
    saveStatus = {};
    saveInProcess = false;

    @wire(getObjectInfo, { objectApiName: '$objectName' })
    objectInfo({ error, data }) {
        if (data) {
            console.log('here');
            console.log(this.objectName);
            this.error = undefined;
            const recordTypes = data.recordTypeInfos;
            console.log(recordTypes);
            this.recordOptions = Object.keys(recordTypes).map(key => ({
                label: recordTypes[key].name,
                value: recordTypes[key].recordTypeId
            }));
            console.log(this.recordOptions);
        } else if (error) {
            this.error = error;
            this.showToast('Error', error.body.message, 'error');
        }
    }

    get hasRecordTypes(){
        return this.recordOptions?true:false;
    }

    navigateToNewRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            }
        });
    }
    
    handleRecordTypeChange(event) {
        this.selectedRecordTypeId = event.detail.value;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    handleCloseClick() {
        this.close('canceled');
    }

    closeModal() {
        // immediately exits, so no need to trigger
        // this.disableClose = false OR
        // this.saveInProcess = false;
        // modal is destroyed, and focus moves
        // back to originally clicked item that
        // generated the modal
        this.close('success');
      }
    
      mitigateSaveFailure() {
        // depending on how easily the failure can be resolved
        // you may need to immediately set disableClose = false
        if (this.failureType === 'recoverable') {
          // no need to call this.disableClose = false
          // or this.saveInProgress = false yet
          tryToFixFailure();
        } else {
          // can't resolve the error
          // need to allow users to exit modal
          this.disableClose = false;
          this.saveInProcess = false;
          // mock function to indicate modal state
          // while still allowing user to exit
          // preventing keyboard trap
          reportUnresolvableError();
        }
      }
    
      async saveData() {
        // switches disabled state on buttons
        this.saveInProcess = true;
        const saveStatus = await sendData(this.formData);
        return (saveStatus && saveStatus.success)
          ? closeModal()
          : mitigateSaveFailure();
      }
    
      async handleSaveClick() {
        if (isValid(this.formData)) {
          // begin saving data, temporarily disable
          // LightningModal's close button
          // Be sure to reenable the close button, by setting
          // this.disableClose = false, IF further interaction
          // is desired before the modal closes
          this.disableClose = true;
          await saveData();
        } else {
          // function that display form errors based on data
          showFormErrors(this.formData);
        }
      }

}