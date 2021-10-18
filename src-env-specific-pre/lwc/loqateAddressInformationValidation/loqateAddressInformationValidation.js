/**
 * @description lwc for address information validation
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | September 3, 2021     | DEP1-170,169,159,263 | Created file                 | 
      |                           |                       |                      |                              | 
 */
import { LightningElement, api, wire } from 'lwc';
import getLoqateMetaData from '@salesforce/apex/AddressInformationValidationCtrl.getLoqateMetaData';
import getHedAddress from '@salesforce/apex/AddressInformationValidationCtrl.getHedAddress'
import upsertAddress from '@salesforce/apex/AddressInformationValidationCtrl.upsertHedAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HED_ID from '@salesforce/schema/hed__Address__c.Id';
import HED_CITY from '@salesforce/schema/hed__Address__c.hed__MailingCity__c';
import HED_STREET from '@salesforce/schema/hed__Address__c.hed__MailingStreet__c';
import HED_STREET2 from '@salesforce/schema/hed__Address__c.hed__MailingStreet2__c';
import HED_STATE from '@salesforce/schema/hed__Address__c.hed__MailingState__c';
import HED_POSTALCODE from '@salesforce/schema/hed__Address__c.hed__MailingPostalCode__c';
import HED_COUNTRY from '@salesforce/schema/hed__Address__c.hed__MailingCountry__c';
import HED_TYPE from '@salesforce/schema/hed__Address__c.hed__Address_Type__c';
import HED_VALIDATE from '@salesforce/schema/hed__Address__c.Validated__c';
import HED_UNIQUE_ID from '@salesforce/schema/hed__Address__c.Unique_ID__c';
import HED_ADDRESS from '@salesforce/schema/hed__Address__c';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';


const BUTTON_UPDATE = 'Update'
const BUTTON_ADD = 'Add'
const VALID_STATUS = 'Valid'
const NOT_VALID_STATUS ='Not Valid'
const NONE_STATUS = 'None'
const ERROR_TITLE = 'Error'
const ERROR_VARIANT = 'error'
const SUCCESS_TITLE = 'Success'
const SUCCESS_VARIANT = 'success'
const SAVE_SUCCESS = 'Address saved.'
const ADDRESS_SUFFIX = ' Address'
const ERROR_MSG =  'An error has been encounterd. Please contact your Administrator: '

export default class LoqateAddressInformationValidation extends LightningElement {
    mapAddress = [];
    @api objectApiName;
    @api recordId;
    record;
    apiMap = [];
    fieldApiMapping;
    countrySelection;
    multpleAddressType = false;
    selectedAddressType;
    selectedAddressName;
    addressTypeOptions;
    unverified = false;
    validOptions;
    noAddress = true;
    isLoading = true;
    loqateResults = false;
    verifiedAddress = {};
    isUpdating = false;
    lookupField;
    buttonLabel = BUTTON_UPDATE;
    wiredAddresses;
    addressSuffix = ADDRESS_SUFFIX;
    hasUnverifiedAddress = false;

    //gets api mapping from custom metadata
    connectedCallback() {
        getLoqateMetaData({objectApiName : this.objectApiName})
        .then(result =>{
            this.fieldApiMapping = JSON.parse(result.fieldApiMapping);
            this.countrySelection = JSON.parse(result.countryMapping);
            this.lookupField = result.addressLookup;
            this.multpleAddressType = this.fieldApiMapping.length > 1?true:false;
        })
        .catch(error =>{
            this.showToast(ERROR_TITLE, ERROR_MSG + error,ERROR_VARIANT);
        });
    }

    //gets the hed__Address__c associated to the record on the record page
    @wire(getHedAddress,{recordId: '$recordId', lookUpApiName: '$lookupField'})
    wiredHedAddress(result){       
        this.wiredAddresses = result;
        if(result.data){
            const tempData = result.data.map(key =>{ 
                return { 
                    id:key.Id,
                    type:key.hed__Address_Type__c,
                    city:key.hed__MailingCity__c,
                    state:key.hed__MailingState__c,
                    street:key.hed__MailingStreet2__c?key.hed__MailingStreet2__c:'' + key.hed__MailingStreet__c?key.hed__MailingStreet__c:'',
                    postalCode:key.hed__MailingPostalCode__c,
                    country:key.hed__MailingCountry__c,
                    valid:key.Validated__c?key.Validated__c:NONE_STATUS
                }
            });
            this.mapAddress = tempData;
            this.setupOptions(this.fieldApiMapping);
            this.noAddress = this.mapAddress.length === 0 && this.multpleAddressType === false?true:false;
            this.isLoading = false;
        }
        else if(result.error){
            this.showToast(ERROR_TITLE, ERROR_MSG + result.error,ERROR_VARIANT);
        } 
    }

    @wire(getObjectInfo, { objectApiName: HED_ADDRESS })
    objectInfo;

    //gets the picklist values of a field across its recordtype
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: HED_VALIDATE })
    pickListValues({error,data}){
        if(data){
            this.validOptions = data.values;
        }else if(error){
            this.showToast(ERROR_TITLE, ERROR_MSG + error,ERROR_VARIANT);
        }
    }

    //disables the update button if user didnt input an address
    get buttonDisable(){
        return this.selectedAddressName || this.hasUnverifiedAddress? false : true;
    }

    //shows and store the user's address selection
    //changes the button's label to Add/Update 
    handleChange(event){
        this.selectedAddressType = event.detail.value;
        this.buttonLabel = this.mapAddress.find(key => key.type === this.selectedAddressType)?BUTTON_UPDATE:BUTTON_ADD;
    }

    //setup address type selection options
    //and defaults the first seletion
    setupOptions(optionMap){
        this.addressTypeOptions = optionMap.map(key =>{
            return{
                label:key.type + ADDRESS_SUFFIX,
                value:key.type
            }
        });
        if(this.addressTypeOptions.length > 0){
            this.selectedAddressType = this.addressTypeOptions.slice(0,1).shift().value;
            this.buttonLabel = this.mapAddress.find(key => key.type === this.selectedAddressType)?BUTTON_UPDATE:BUTTON_ADD;
        }
    }

    //sets a flag that indicates wants to enter an unverified address
    //resets selected address from loqate
    handleOnClick(event){
        this.unverified = event.target.checked;
        this.selectedAddressName = '';
        this.hasUnverifiedAddress = false;
    }

    //sets a flag that indicates that the address form isn't empty
    handleChangeAddress(event){
        this.hasUnverifiedAddress = event.target.city||event.target.street||event.target.province||event.target.country||event.target.postalCode?true:false;
    }

    //when add/update button is pressed, calls a function that creates a hed__Address__c object
    handleUpsert(){   
        //check if address to update is unverified address
        if(this.unverified === true){
            //get data from unverified address form
            const unverifiedAddress =  this.template.querySelector('lightning-input-address');
            this.createUpdateObject(unverifiedAddress,this.selectedAddressType,NOT_VALID_STATUS);
        }else{ 
            if(this.selectedAddressName){
                this.createUpdateObject(this.verifiedAddress,this.selectedAddressType,VALID_STATUS);
            }
        }
    }
    
    //creates a hed__address__c object and upsert
    createUpdateObject(newAddress,adType,validity){
        //creates an object where key = apiname and value = value of new address
        const addressObject = {}
        addressObject[HED_ID.fieldApiName] = this.mapAddress.find(key => key.type === adType)?this.mapAddress.find(key => key.type === adType).id:null;
        addressObject[this.lookupField] = this.recordId;
        addressObject[HED_CITY.fieldApiName] = newAddress.city?newAddress.city:null; 
        addressObject[HED_STREET.fieldApiName] = newAddress.street?newAddress.street:null; 
        addressObject[HED_STREET2.fieldApiName] = newAddress.street2?newAddress.street2:null;
        addressObject[HED_STATE.fieldApiName] = newAddress.province?newAddress.province:null;
        addressObject[HED_POSTALCODE.fieldApiName] = newAddress.postalCode?newAddress.postalCode:null;
        addressObject[HED_COUNTRY.fieldApiName] = newAddress.country?newAddress.country:null;
        addressObject[HED_TYPE.fieldApiName] = adType;
        addressObject[HED_VALIDATE.fieldApiName] = validity;
        addressObject[HED_UNIQUE_ID.fieldApiName] = newAddress.id?newAddress.id:null;

        this.isUpdating = true;
        upsertAddress({addressToUpsert:addressObject})
        .then(result =>{
            this.showToast(SUCCESS_TITLE,SAVE_SUCCESS, SUCCESS_VARIANT);
            this.isUpdating = false;
            refreshApex(this.wiredAddresses);
        }).finally(() => {
            getRecordNotifyChange([{recordId: this.recordId}]);
        })
        .catch(error =>{
            this.showToast(ERROR_TITLE, ERROR_MSG + error,ERROR_VARIANT);
        });
    }

    //gets selected loqate address from child
    getLoqateAddress(event){
        this.verifiedAddress = event.detail.loqateAddress;
        this.selectedAddressName = event.detail.loqateAddress.fullAddress;
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