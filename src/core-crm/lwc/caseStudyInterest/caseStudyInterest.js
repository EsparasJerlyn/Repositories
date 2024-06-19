import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getFieldDisplayValue, getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from "lightning/uiObjectInfoApi";

import CONTACT_CASE_CONTACTID from '@salesforce/schema/Case.ContactId';
import CONTACT_CITIZENSHIP_STATUS from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Citizenship_Status__c'; 
import CONTACT_COUNTRY_OF_CITIZENSHIP from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Country_Of_Citizenship__c'; 
import CONTACT_COUNTRY_OF_RESIDENCY from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Country_Of_Residency__c'; 
import CONTACT_PRIMARY_STUDY_LEVEL from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Primary_Study_Level__c'; 
import CONTACT_PRIMARY_BSA from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Primary_BSA__c'; 
import CONTACT_PRIMARY_NSA from '@salesforce/schema/Case.Contact.Marketing_Segmentation__r.My_Primary_NSA__c'; 

import LEAD_CITIZENSHIP_STATUS from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Citizenship_Status__c'; 
import LEAD_COUNTRY_OF_CITIZENSHIP from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Country_Of_Citizenship__c'; 
import LEAD_COUNTRY_OF_RESIDENCY from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Country_Of_Residency__c'; 
import LEAD_PRIMARY_STUDY_LEVEL from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Primary_Study_Level__c'; 
import LEAD_PRIMARY_BSA from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Primary_BSA__c'; 
import LEAD_PRIMARY_NSA from '@salesforce/schema/Case.Lead__r.Marketing_Segmentation__r.My_Primary_NSA__c'; 


const fields = [
  CONTACT_CASE_CONTACTID,
  CONTACT_CITIZENSHIP_STATUS,
  CONTACT_COUNTRY_OF_CITIZENSHIP,
  CONTACT_COUNTRY_OF_RESIDENCY,
  CONTACT_PRIMARY_STUDY_LEVEL,
  CONTACT_PRIMARY_BSA,
  CONTACT_PRIMARY_NSA, 
]

export default class CaseStudyInterest extends NavigationMixin(LightningElement) {

  @api recordId;
  @api parentRecord;

  caseRecord;
  hasStudyInterest

  connectedCallback() {
    if (this.parentRecord !== 'Contact') {
      fields.push(LEAD_CITIZENSHIP_STATUS,
      LEAD_COUNTRY_OF_CITIZENSHIP,
      LEAD_COUNTRY_OF_RESIDENCY,
      LEAD_PRIMARY_BSA,
      LEAD_PRIMARY_NSA,
      LEAD_PRIMARY_STUDY_LEVEL)
    }
  }


  @wire(getRecord, { recordId: '$recordId', fields })
    contact({ data, error }) {
      if (data) {
        this.hasStudyInterest= true;
        this.caseRecord = data;
      }else {
        console.log(error)
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
    this[NavigationMixin.Navigate]({
        type:'standard__objectPage',
        attributes: {
            objectApiName: 'Marketing_Segmentation__c',
            actionName: 'list'
        },
        state: {
            filterName: 'Recent'
        }
    })
  }

}