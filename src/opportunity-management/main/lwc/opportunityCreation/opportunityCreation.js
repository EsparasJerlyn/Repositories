/**
 * @description A LWC component for creating manual Opportunity
 *
 * @see ../classes/ContactLookupCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary                                                            |
      |--------------------------------|-----------------------|----------------------|---------------------------------------------------------------------------|
      | marygrace.li@qut.edu.au        | September 18, 2021    | DEP1-158             | Created file                                                              | 
      |--------------------------------|-----------------------|----------------------|---------------------------------------------------------------------------|  
      | marygrace.li@qut.edu.au        | September 23, 2021    | DEP1-615             | modified handleSelectionChange disabled value                             |     
      |--------------------------------|-----------------------|----------------------|---------------------------------------------------------------------------|  
      | marygrace.li@qut.edu.au        | September 27, 2021    | DEP1-618             | add getAccountName and set to opportunity name                            |   
      |--------------------------------|-----------------------|----------------------|---------------------------------------------------------------------------|  
      | marygrace.li@qut.edu.au        | September 30, 2021    | DEPP-280             | modified createNewOpportunity then set disabled state for next btn        |                 
 */


import { LightningElement, track, wire, api } from "lwc";  
import getContactRecords from "@salesforce/apex/ContactLookupCtrl.getContactRecords";
import {getObjectInfo} from "lightning/uiObjectInfoApi";
import Opportunity from '@salesforce/schema/Opportunity';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';

 export default class OpportunityCreation extends NavigationMixin(LightningElement) {
  @api selectedValue;  
  @track isModalOpen = false;
  @api recordId;
  
  @track errors = [];
  initialSelection = [];
  @api displayContactId;
  @api displayContactName;
  @api defaultlabel;
  @api defaultvalue;
  @track isMultiEntry = false;
  @track contacts;
  @track selectedRecordTypeValue = '';
  @track options = [];
  @track showRecordType = false;
  @track disableButton = true;
  @track accountObjectInfo;
  @api contactId;

   connectedCallback(){
      this.getContactRecords();
   } 
   
   //retrieve contact records
    getContactRecords() {
      this.contacts = [];
      getContactRecords().then(res => {
              this.contactList = JSON.stringify(res);
              res.map(contact => {
                  let obj = {
                      'label': contact.Name,
                      'value': contact.Id
                  };
                  this.contacts.push(obj);
                  return null;
              })
          })
          .catch((error) => {
              this.error = error.body.message;
              this.showToast('Something went wrong', this.error, 'error');
          })
    } 

  //retrieve opportunity record types
  @wire(getObjectInfo, { objectApiName: Opportunity })
    opportunityObjectInfo({data, error}) {
        if(data) {
            let optionsValues = [];
            // map of record type Info
            const rtInfos = data.recordTypeInfos;

            // getting map values
            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }
            this.options = optionsValues;
        }
        else if(error) {
            this.error = error.body.message;
            this.showToast('Something went wrong', this.error, 'error');
        }
  }
     
  // Handling on change value for record types
  handleRecordTypeChange(event) {
      this.selectedRecordTypeValue = event.detail.value;
      this.disableButton = false;
  }


  //handle search lookup text
  handleSearch(event) {
      let contactList = [];
      let searchText = JSON.parse(JSON.stringify(event.detail));

      contactList = this.contacts.filter(mapValues => mapValues.label.toLocaleLowerCase().indexOf(searchText.searchTerm) >= 0);
        this.template
            .querySelector('c-custom-lookup')
            .setSearchResults(contactList);
  }

  //handle lookup selection change
  handleSelectionChange() {
      this.errors = [];
      this.disableButton = !this.template
                        .querySelector('c-custom-lookup')
                        .hasSelection();
  }

  //set contact id in the lookup
  updateContactId(event) {
    this.displayContactId = event.detail;
    this.selectedValue = event.detail;
    this.contactId = event.detail;
  }

   //set contact name in the lookup
  updateContactName(event) {
      this.displayContactName = event.detail;
  }

  //show toast message for error message
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
  }

//call when New Opportunity button is clicked
  createNewOpportunity(){
    //disable the new Oppotunity button when user does not select a Contact
    this.disableButton = !this.template
                              .querySelector('c-custom-lookup')
                              .hasSelection();

    if(!this.disableButton){
      this.showRecordType = true;

      //set Next button as disabled when record type is equal to empty string
      this.disableButton = this.selectedRecordTypeValue ==='';

    }else{
      this.showRecordType = false;
    }
  }

  //call when Next button is clicked
  newOpportunity(){
      
    //set the contact selected from the lookup
    const contact = this.contactId;
    const valueChangeEvent = new CustomEvent("valuechange", {
      detail: {contact}
    });
    // Fire the custom event
    this.dispatchEvent(valueChangeEvent);

    this.navigateToNewOpportunity();

  }

  //call the method in aura component to create new opportunity
  navigateToNewOpportunity(){
    const createOppEvent = new CustomEvent('create');
    this.dispatchEvent(createOppEvent);
  }

 //call the method in aura component to close the opportunity modal
  closeFocusedTab(){
    const closeEvent = new CustomEvent('close');
    this.dispatchEvent(closeEvent);
  }
  
}