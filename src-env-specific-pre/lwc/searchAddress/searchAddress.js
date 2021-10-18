/**
 * @description lwc that requests and gets loqate responses
 * @see loqateAddressInformationValidation
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | September 3, 2021     | DEP1-170,169,159,263 | Created file                 | 
      |                           |                       |                      |                              | 
 */
import { LightningElement, api} from 'lwc';
import searchAddress from '@salesforce/apex/AddressInformationValidationCtrl.searchAddress';
import getDetails from '@salesforce/apex/AddressInformationValidationCtrl.getDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const NO_ADDRESSES = 'No results found.'
const FIND_ADDRESS = 'Find Addresss'
const OPEN_DROPDOWN = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open'
const CLOSE_DROPDOWN = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click'
const ERROR_TITLE = 'Error'
const ERROR_VARIANT = 'error'
const ERROR_MSG =  'An error has been encounterd. Please contact your Administrator: '

export default class SearchAddress extends LightningElement {
    selectRecordId = '';
    selectRecordName;
    Label;
    searchRecords = [];
    required = false;
    LoadingText = false;
    txtclassname = CLOSE_DROPDOWN;
    messageFlag = false;
    iconFlag =  true;
    clearIconFlag = false;
    inputReadOnly = false;
    selectedCountry = 'AU';
    disableCombobox = false;
    hasCountry = false;
    selectedCountryLabel;
    noAddress = NO_ADDRESSES;
    findAddress = FIND_ADDRESS;
    @api 
    countries;
   
    //process inputs of user on the search field
    searchField(event) {
        let currentText = event.target.value;
        this.LoadingText = true;
        
        searchAddress({ searchValue: currentText  , country: this.selectedCountry})
        .then(result => {
            this.disableCombobox = true;
            this.searchRecords= result;
            this.LoadingText = false;
            this.txtclassname =  result.length > 0 ? OPEN_DROPDOWN : CLOSE_DROPDOWN;
            if(currentText.length > 0 && result.length === 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }
            if(this.selectRecordId !==  null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            this.showToast(ERROR_TITLE, ERROR_MSG + error,ERROR_VARIANT);
        });
        
    }
    
    //when user selects an address, stores id and the address name from loqate
    //sets the search field to read only
    //show the clear (x) icon
    //disables/closes the drop down
    setSelectedRecord(event) {
        this.txtclassname =  CLOSE_DROPDOWN;
        this.iconFlag = false;
        this.clearIconFlag = true;
        this.selectRecordId = event.currentTarget.dataset.id;
        this.selectRecordName = event.currentTarget.dataset.name;
        this.inputReadOnly = true;
        this.disableCombobox = true;
        this.getCompleteDetails(this.selectRecordId);

    }

    //gets the detailed info the address from loqate
    //and send the loqate details to the parent -> loqateAddressInformationValidation
    getCompleteDetails(targetUd){
        getDetails({ searchValue: targetUd , country: this.selectedCountry})
        .then(result => {
            let loqateAddress = {};
            loqateAddress['id'] = result.id;
            loqateAddress['fullAddress'] = result.fullAddress;
            loqateAddress['city'] = result.city?result.city:result.locality;
            loqateAddress['province'] = result.state?result.state:result.province;
            loqateAddress['street'] = result.buildingName + ' ' + result.subdwelling + ' ' + result.postal + ' ' + result.streetNumber + ' ' + result.street;
            loqateAddress['street2'] = result.street2;
            loqateAddress['postalCode'] = result.postcode;
            loqateAddress['country'] = 'Australia';
            this.sendToParent(loqateAddress);
        })
        .catch(error => {
            this.showToast(ERROR_TITLE, ERROR_MSG + error,ERROR_VARIANT);
        });
    }

    //when clear button is clicked (x)
    //enables the drop down
    //makes the search field editable again
    //shows the search icon
    resetData() {
        this.disableCombobox = false;
        this.selectRecordName = "";
        this.selectRecordId = "";
        this.inputReadOnly = false;
        this.iconFlag = true;
        this.clearIconFlag = false;
        this.sendToParent('');
    }

    //sends the address data from loqate to parent lwc
    sendToParent(addresstoParent){
        //send loqate address
        const foundAddress = new CustomEvent('found', { detail: {loqateAddress:addresstoParent} });
        // Dispatches the event.
        this.dispatchEvent(foundAddress);
    }

    //sets the selected country (not used in sprint 2)
    handleChange(event){
        //this.selectedCountry = event.detail.value;
        this.selectedCountryLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.hasCountry = true;
    }

    //shows success or error messages
    showToast(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    
}