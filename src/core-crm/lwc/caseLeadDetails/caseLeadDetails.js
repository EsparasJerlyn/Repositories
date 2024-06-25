import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getFieldDisplayValue, getFieldValue, getRecord } from "lightning/uiRecordApi";

import CASE_LEAD_NAME from "@salesforce/schema/Case.Lead__r.Name";
import CASE_LEAD_PRIMARY_EMAIL from "@salesforce/schema/Case.Lead__r.Email";
import CASE_LEAD_WORK_EMAIL from "@salesforce/schema/Case.Lead__r.Work_Email__c";
import CASE_LEAD_MOBILE from "@salesforce/schema/Case.Lead__r.MobilePhone";
import CASE_LEAD_PHONE from "@salesforce/schema/Case.Lead__r.Phone";
import CASE_LEAD_PREFERRED_CONTACT from "@salesforce/schema/Case.Lead__r.Preferred_Contact_Method__c";
import CASE_LEAD_LEADSCORE from "@salesforce/schema/Case.Lead__r.Lead_Score__c";
import CASE_LEAD_LEADSOURCE from "@salesforce/schema/Case.Lead__r.LeadSource";
import CASE_LEAD_LEADSOURCECATEGORY from "@salesforce/schema/Case.Lead__r.Lead_Source_Category__c";
import CASE_RECORDTYPE_DEVELOPERNAME from '@salesforce/schema/Case.RecordType.DeveloperName';

const fields = [
  CASE_LEAD_NAME,
  CASE_LEAD_PRIMARY_EMAIL,
  CASE_LEAD_WORK_EMAIL,
  CASE_LEAD_MOBILE,
  CASE_LEAD_PHONE,
  CASE_LEAD_PREFERRED_CONTACT,
  CASE_LEAD_LEADSCORE,
  CASE_LEAD_LEADSOURCE,
  CASE_LEAD_LEADSOURCECATEGORY,
  CASE_RECORDTYPE_DEVELOPERNAME
];

const CARD_CLASS_HASLEAD = "slds-card";
const CARD_CLASS_NOLEAD = "slds-card card-with-bg";
const CARD_HEADER_CLASS_HASLEAD = "slds-card__header slds-grid header-with-bg slds-border_bottom slds-p-bottom_x-small";
const CARD_HEADER_CLASS_NOLEAD = "slds-card__header slds-grid";

export default class CaseLeadDetails extends NavigationMixin(LightningElement) {
  cardClass = CARD_CLASS_NOLEAD;
  cardHeaderClass = CARD_HEADER_CLASS_NOLEAD;
  caseRecord;
  error;
  isLoading;
  isInbound;
  isOutreach
  hasLead;
  caseLeadUrl;

  @api recordId;

  @wire(getRecord, {recordId: '$recordId', fields})
  case({data, error}){
    if (data) {
      this.caseRecord = data;
      console.log(this.caseRecord.fields.Lead__r.value.fields.id)
      if(this.caseRecord.fields.Lead__r.value != null) {
        // flag to signify contact exists
        this.hasLead = true;
        // generate case contact url
        NavigationMixin.gebe
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseRecord.fields.Lead__r.value.id,
                actionName: 'view'
            },
        }).then((url) => {
            this.caseLeadUrl = url;
        });
        let rtDevName = getFieldValue(this.caseRecord, CASE_RECORDTYPE_DEVELOPERNAME);
        if(rtDevName == 'Outreach') {
            this.isOutreach = true;
            this.isInbound = false;
        } else if(rtDevName == 'Inbound_Enquiry') {
            this.isOutreach = false;
            this.isInbound = true;
        }
    } else {
        this.hasLead = false;
        this.caseLeadUrl = '#';
    }
    this.cardClass = this.hasLead ? CARD_CLASS_HASLEAD : CARD_CLASS_NOLEAD
    this.cardHeaderClass = this.hasLead ? CARD_HEADER_CLASS_HASLEAD : CARD_HEADER_CLASS_NOLEAD;
    } else {
      this.error = error;
      this.caseRecord = undefined;
    }
  }

  get caseLeadName() {
    return getFieldValue(this.caseRecord, CASE_LEAD_NAME)
  }

  get caseLeadPrimaryEmail() {
    return getFieldValue(this.caseRecord, CASE_LEAD_PRIMARY_EMAIL)
  }

  get caseLeadWorkEmail(){
    return getFieldValue(this.caseRecord, CASE_LEAD_WORK_EMAIL)
  }

  get caseLeadMobile() {
    return getFieldValue(this.caseRecord, CASE_LEAD_MOBILE)
  }

  get caseLeadPhone() {
    return getFieldValue(this.caseRecord, CASE_LEAD_PHONE)
  }

  get caseLeadPreferredContact() {
    return getFieldValue(this.caseRecord, CASE_LEAD_PREFERRED_CONTACT)
  }

  get caseLeadScore() {
    return getFieldValue(this.caseRecord, CASE_LEAD_LEADSCORE)
  }

  get caseLeadSource() {
    return getFieldValue(this.caseRecord, CASE_LEAD_LEADSOURCE)
  }

  get caseLeadSourceCategory() {
    return getFieldValue(this.caseRecord,CASE_LEAD_LEADSOURCECATEGORY)
  }

  handleClickHeader() {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.caseRecord.fields.Lead__r.value.id,
            objectApiName: 'Lead',
            actionName: 'view'
        },
    });
  }

  handleLeadClick() {
    this[NavigationMixin.Navigate]({
        type:'standard__objectPage',
        attributes: {
            objectApiName: 'Lead',
            actionName: 'list'
        },
        state: {
            filterName: 'Recent'
        }
    })
}

}