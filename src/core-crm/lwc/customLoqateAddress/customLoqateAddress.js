import { LightningElement } from 'lwc';
import getLoqateMetaData from "@salesforce/apex/AddressInformationValidationCtrl.getLoqateMetaData";

const UNVERIFIED_ADDRESS_LBL = "Enter Unverified Address";
const ERROR_TITLE = "Error";
const ERROR_VARIANT = "error";
const ERROR_MSG = "An error has been encountered. Please contact your Administrator: ";

export default class CustomLoqateAddress extends LightningElement {
    selectedAddressName;
    unverified = false;
    verifiedAddress = {};
    countrySelection;
    fieldApiMapping;
    lookupField;
    addressTypeList = [];

    get unverifiedAddLabel() {
        return UNVERIFIED_ADDRESS_LBL;
    }

    //gets api mapping from custom metadata
    connectedCallback() {
        let objectApiName = 'Contact';

        if (objectApiName) {
        getLoqateMetaData({ objectApiName: objectApiName })
            .then((result) => {
            this.fieldApiMapping = JSON.parse(result.fieldApiMapping);
            this.countrySelection = JSON.parse(result.countryMapping);
            this.lookupField = result.addressLookup;
            // this.multpleAddressType =
            //     this.fieldApiMapping.length > 1 ? true : false;
            this.addressTypeList = this.fieldApiMapping.map(key =>{
                return key.type;
            });

            })
            .catch((error) => {
            this.showToast(ERROR_TITLE, ERROR_MSG + error, ERROR_VARIANT);
            });
        }
    }

    //gets selected loqate address from child
    getLoqateAddress(event) {
        this.verifiedAddress = event.detail.loqateAddress;
        this.selectedAddressName = event.detail.loqateAddress.fullAddress;
    }

    //sets a flag that indicates wants to enter an unverified address
    //resets selected address from loqate
    handleOnClick(event) {
        this.unverified = event.target.checked;
        this.selectedAddressName = "";
        this.hasUnverifiedAddress = false;
    }

    //sets a flag that indicates that the address form isn't empty
    handleChangeAddress(event) {
        this.hasUnverifiedAddress =
        event.target.city ||
        event.target.street ||
        event.target.province ||
        event.target.country ||
        event.target.postalCode
            ? true
            : false;
    }
}