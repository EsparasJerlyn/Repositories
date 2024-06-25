import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CONTACT_CASE_CONTACTID from '@salesforce/schema/Case.ContactId';
import CONTACT_MARKETING_SEGMENTATION_ID from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.Id';
import CONTACT_CITIZENSHIP_STATUS from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Citizenship_Status__c'; 
import CONTACT_COUNTRY_OF_CITIZENSHIP from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Country_Of_Citizenship__c'; 
import CONTACT_COUNTRY_OF_RESIDENCY from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Country_Of_Residency__c'; 
import CONTACT_PRIMARY_STUDY_LEVEL from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Primary_Study_Level__c'; 
import CONTACT_PRIMARY_BSA from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Primary_BSA__c'; 
import CONTACT_PRIMARY_NSA from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Primary_NSA__c'; 

import LEAD_MARKETING_SEGMENTATION_ID from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.Id';
import LEAD_CITIZENSHIP_STATUS from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Citizenship_Status__c'; 
import LEAD_COUNTRY_OF_CITIZENSHIP from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Country_Of_Citizenship__c'; 
import LEAD_COUNTRY_OF_RESIDENCY from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Country_Of_Residency__c'; 
import LEAD_PRIMARY_STUDY_LEVEL from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Primary_Study_Level__c'; 
import LEAD_PRIMARY_BSA from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Primary_BSA__c'; 
import LEAD_PRIMARY_NSA from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Primary_NSA__c'; 

import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const fields = [
  CONTACT_CASE_CONTACTID,
  CONTACT_CITIZENSHIP_STATUS,
  CONTACT_COUNTRY_OF_CITIZENSHIP,
  CONTACT_COUNTRY_OF_RESIDENCY,
  CONTACT_PRIMARY_STUDY_LEVEL,
  CONTACT_PRIMARY_BSA,
  CONTACT_PRIMARY_NSA, 
  CONTACT_MARKETING_SEGMENTATION_ID
];

const CARD_CLASS_HASSTUDYINTEREST = "slds-card";
const CARD_CLASS_NOSTUDYINTEREST = "slds-card card-with-bg";
const CARD_HEADER_CLASS_HASSTUDYINTEREST = "slds-card__header slds-grid header-with-bg slds-border_bottom slds-p-bottom_x-small";
const CARD_HEADER_CLASS_NOSTUDYINTEREST = "slds-card__header slds-grid";

export default class CaseStudyInterest extends NavigationMixin(LightningElement) {
  cardClass = CARD_CLASS_NOSTUDYINTEREST;
  cardHeader = CARD_HEADER_CLASS_NOSTUDYINTEREST;
  caseRecord;
  error;
  hasStudyInterest

  @api recordId;
  @api parentRecord;

  connectedCallback() {
    if (this.parentRecord !== 'Contact') {
      fields.push(LEAD_CITIZENSHIP_STATUS,
      LEAD_COUNTRY_OF_CITIZENSHIP,
      LEAD_COUNTRY_OF_RESIDENCY,
      LEAD_PRIMARY_BSA,
      LEAD_PRIMARY_NSA,
      LEAD_PRIMARY_STUDY_LEVEL,
      LEAD_MARKETING_SEGMENTATION_ID)
    }
  }


  @wire(getRecord, { recordId: '$recordId', fields })
    contact({ data, error }) {
      if (data) {
        this.hasStudyInterest= true;
        this.caseRecord = data;
        this.cardClass = this.hasStudyInterest ? CARD_CLASS_HASSTUDYINTEREST : CARD_CLASS_NOSTUDYINTEREST
        this.cardHeaderClass = this.hasStudyInterest ? CARD_HEADER_CLASS_HASSTUDYINTEREST : CARD_HEADER_CLASS_NOSTUDYINTEREST;
      }else {
        this.error = error;
        this.caseRecord = undefined;
      }
    }

  get caseContactCitizenshipStatus() {
    return this.parentRecord === 'Contact' 
    ? getFieldValue(this.caseRecord, CONTACT_CITIZENSHIP_STATUS) 
    : getFieldValue(this.caseRecord, LEAD_CITIZENSHIP_STATUS);
  }

  get caseContactCountryOfCitizenship() {
    return this.parentRecord === 'Contact' 
    ? getFieldValue(this.caseRecord, CONTACT_COUNTRY_OF_CITIZENSHIP)
    : getFieldValue(this.caseRecord, LEAD_COUNTRY_OF_CITIZENSHIP);
  }

  get caseContactCountryOfResidency() {
    return this.parentRecord === 'Contact' 
    ? getFieldValue(this.caseRecord, CONTACT_COUNTRY_OF_RESIDENCY)
    : getFieldValue(this.caseRecord, LEAD_COUNTRY_OF_RESIDENCY);
  }

  get caseContactPrimaryStudentLevel() {
    return this.parentRecord === 'Contact' 
    ? getFieldValue(this.caseRecord, CONTACT_PRIMARY_STUDY_LEVEL)
    : getFieldValue(this.caseRecord, LEAD_PRIMARY_STUDY_LEVEL);
  }

  get caseContactPrimaryBSA() {
    return this.parentRecord === 'Contact' 
    ? getFieldValue(this.caseRecord, CONTACT_PRIMARY_BSA)
    : getFieldValue(this.caseRecord, LEAD_PRIMARY_BSA);
  }

  get caseContactPrimaryNSA() {
    return this.parentRecord === 'Contact' 
    ? getFieldValue(this.caseRecord, CONTACT_PRIMARY_NSA)
    : getFieldValue(this.caseRecord, LEAD_PRIMARY_NSA);
  }

  handleInterestClick() {
    this.navigateToRecord();
  }

  handleMenuSelect(event) {
    if(event.detail.value == 'view') {
        this.navigateToRecord();
    }
  }

  navigateToRecord() {
    const logger = this.template.querySelector("c-logger");
    let mktgSegId;
    if (this.parentRecord === 'Contact') {
        mktgSegId = getFieldValue(this.caseRecord, CONTACT_MARKETING_SEGMENTATION_ID);
    } else {
        mktgSegId = getFieldValue(this.caseRecord, LEAD_MARKETING_SEGMENTATION_ID);
    }

    if (!mktgSegId) {
        logger.error('Unable to retrieve Marketing Segmentation ID');
        logger.saveLog();
        this.generateToast('Error.', LWC_Error_General, 'error');
        return;
    }

    this[NavigationMixin.Navigate]({
        type:'standard__recordPage',
        attributes: {
            recordId: mktgSegId,
            objectApiName: 'Marketing_Segmentation__c',
            actionName: 'view'
        }
    });     
  }

  generateToast(_title,_message,_variant){
    const evt = new ShowToastEvent({
        title: _title,
        message: _message,
        variant: _variant,
    });
    this.dispatchEvent(evt);
}

}