import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getFieldDisplayValue, getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from "lightning/uiObjectInfoApi";

import CASE_CONTACTID from '@salesforce/schema/Case.ContactId';
import CASE_CONTACT_NAME from '@salesforce/schema/Case.Contact.Name';
import CASE_CONTACT_BIRTHDATE from '@salesforce/schema/Case.Contact.Birthdate';
import CASE_CONTACT_QUT_STUDENT_ID from '@salesforce/schema/Case.Contact.QUT_Student_ID__c';
import CASE_CONTACT_PRIMARY_EMAIL from '@salesforce/schema/Case.Contact.Email';
import CASE_CONTACT_QUT_LEARNER_EMAIL from '@salesforce/schema/Case.Contact.QUT_Learner_Email__c';
import CASE_CONTACT_MOBILEPHONE from '@salesforce/schema/Case.Contact.MobilePhone';
import CASE_CONTACT_STUDENT_SUCCESS_DO_NOT_CALL from '@salesforce/schema/Case.Contact.Student_Success_Do_Not_Call__c';
import CASE_CONTACT_CITIZENSHIP_STATUS from '@salesforce/schema/Case.Contact.hed__Citizenship_Status__c';
import CASE_CONTACT_CITIZENSHIP_COUNTRY from '@salesforce/schema/Case.Contact.Citizenship_Country__c';
import CASE_CONTACT_COUNTRY_OF_RESIDENCY from '@salesforce/schema/Case.Contact.Country_of_Residency__c';
import CASE_CONTACT_APPLICANT_ONSHORE from '@salesforce/schema/Case.Contact.Applicant_Onshore__c';
import CASE_CONTACT_OTHER_STREET from '@salesforce/schema/Case.Contact.OtherStreet';
import CASE_CONTACT_OTHER_CITY from '@salesforce/schema/Case.Contact.OtherCity';
import CASE_CONTACT_OTHER_STATE from '@salesforce/schema/Case.Contact.OtherState';
import CASE_CONTACT_OTHER_COUNTRY from '@salesforce/schema/Case.Contact.OtherCountry';
import CASE_CONTACT_OTHER_POSTAL from '@salesforce/schema/Case.Contact.OtherPostalCode';
import CASE_CONTACT_ATSI_CODE from '@salesforce/schema/Case.Contact.ATSI_Code__c';
import CASE_CONTACT_LOW_SOCIO_ECONOMIC_STATUS from '@salesforce/schema/Case.Contact.Low_Socio_Economic_Status__c';
import CASE_CONTACT_REGIONAL_REMOTE from '@salesforce/schema/Case.Contact.Regional_Remote__c';
import CASE_CONTACT_QUT_APPROVED_DISABILITY from '@salesforce/schema/Case.Contact.QUT_Approved_Disability__c';
import CASE_CONTACT_FIRST_IN_FAMILY from '@salesforce/schema/Case.Contact.First_in_Family__c';
import CASE_CONTACT_LEAD_SCORE from '@salesforce/schema/Case.Contact.Lead_Score__c';
import CASE_CONTACT_LEAD_SOURCE_CATEGORY from '@salesforce/schema/Case.Contact.Lead_Source_Category__c';
import CASE_CONTACT_LEADSOURCE from '@salesforce/schema/Case.Contact.LeadSource';
import CASE_RECORDTYPE_DEVELOPERNAME from '@salesforce/schema/Case.RecordType.DeveloperName';

const fields = [
    CASE_CONTACTID,
    CASE_CONTACT_NAME,
    CASE_CONTACT_BIRTHDATE,
    CASE_CONTACT_QUT_STUDENT_ID,
    CASE_CONTACT_PRIMARY_EMAIL,
    CASE_CONTACT_QUT_LEARNER_EMAIL,
    CASE_CONTACT_MOBILEPHONE,    
    CASE_CONTACT_CITIZENSHIP_STATUS,
    CASE_CONTACT_CITIZENSHIP_COUNTRY,
    CASE_CONTACT_COUNTRY_OF_RESIDENCY,
    CASE_CONTACT_APPLICANT_ONSHORE,
    CASE_CONTACT_OTHER_STREET,
    CASE_CONTACT_OTHER_CITY,
    CASE_CONTACT_OTHER_STATE,
    CASE_CONTACT_OTHER_COUNTRY,
    CASE_CONTACT_OTHER_POSTAL,
    CASE_CONTACT_ATSI_CODE,
    CASE_CONTACT_LEAD_SCORE,
    CASE_CONTACT_LEAD_SOURCE_CATEGORY,
    CASE_CONTACT_LEADSOURCE,
    CASE_RECORDTYPE_DEVELOPERNAME
];

const CARD_CLASS_HASCONTACT = "slds-card";
const CARD_CLASS_NOCONTACT = "slds-card card-with-bg";
const CARD_HEADER_CLASS_HASCONTACT = "slds-card__header slds-grid header-with-bg slds-border_bottom slds-p-bottom_x-small";
const CARD_HEADER_CLASS_NOCONTACT = "slds-card__header slds-grid";

export default class CaseContactDetails extends NavigationMixin(LightningElement) {
    @api recordId;

    cardClass = CARD_CLASS_NOCONTACT;
    cardHeaderClass = CARD_HEADER_CLASS_NOCONTACT;
    caseRecord;
    caseContactUrl;
    error;
    hasContact;
    isInbound;
    isLoading;
    isOutreach;

    mailingAddressArray = [];

    @wire(getObjectInfo, { objectApiName: 'Case' })
    caseObjectInfo({ data, error }) {
        if(data) {
            for (let key in data.recordTypeInfos) {
                if (data.recordTypeInfos.hasOwnProperty(key)) {
                    let recordTypeInfo = data.recordTypeInfos[key];
                    if (recordTypeInfo.name === "Outreach" && recordTypeInfo.available === true) {
                        fields.push(CASE_CONTACT_LOW_SOCIO_ECONOMIC_STATUS)
                        fields.push(CASE_CONTACT_STUDENT_SUCCESS_DO_NOT_CALL)
                        fields.push(CASE_CONTACT_REGIONAL_REMOTE)
                        fields.push(CASE_CONTACT_QUT_APPROVED_DISABILITY)
                        fields.push(CASE_CONTACT_FIRST_IN_FAMILY)
                    }
                }
            }
        }
    }


    @wire(getRecord, { recordId: '$recordId', fields })
    case({ data, error }) {
        this.isLoading = true;
        if(data) {
            //store the case in another var
            this.caseRecord = data;
            if(this.caseRecord.fields.ContactId.value != null) {
                // flag to signify contact exists
                this.hasContact = true;
                // generate case contact url
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.caseRecord.fields.ContactId.value,
                        actionName: 'view'
                    },
                }).then((url) => {
                    this.caseContactUrl = url;
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
                this.hasContact = false;
                this.caseContactUrl = '#';
            }
            this.cardClass = this.hasContact ? CARD_CLASS_HASCONTACT : CARD_CLASS_NOCONTACT
            this.cardHeaderClass = this.hasContact ? CARD_HEADER_CLASS_HASCONTACT : CARD_HEADER_CLASS_NOCONTACT;
        }
        else if(error) {
            this.error = error;
            this.caseRecord = undefined;
        }
        this.isLoading = false;
    }

    get caseContactName() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_NAME);
    }

    get caseContactBirthdate() {
        return getFieldDisplayValue(this.caseRecord, CASE_CONTACT_BIRTHDATE);
    }
    
    get caseContactQUTStudentId() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_QUT_STUDENT_ID);
    }
    
    get caseContactPrimaryEmail() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_PRIMARY_EMAIL);
    }
    
    get caseContactQUTLearnerEmail() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_QUT_LEARNER_EMAIL);
    }
    
    get caseContactMobile() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_MOBILEPHONE);
    }
    
    get caseContactStudentSuccessDoNotCall() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_STUDENT_SUCCESS_DO_NOT_CALL);
    }

    get caseContactCitizenshipStatus() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_CITIZENSHIP_STATUS);
    }

    get caseContactCitizenshipCountry() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_CITIZENSHIP_COUNTRY);
    }

    get caseContactCountryOfResidency() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_COUNTRY_OF_RESIDENCY);
    }

    get caseContactApplicantOnshore() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_APPLICANT_ONSHORE);
    }

    get caseContactMailingAddress() {
        let street = getFieldValue(this.caseRecord, CASE_CONTACT_OTHER_STREET);
        let city = getFieldValue(this.caseRecord, CASE_CONTACT_OTHER_CITY);
        let state = getFieldValue(this.caseRecord, CASE_CONTACT_OTHER_STATE);
        let country = getFieldValue(this.caseRecord, CASE_CONTACT_OTHER_COUNTRY);
        let postal = getFieldValue(this.caseRecord, CASE_CONTACT_OTHER_POSTAL);
        this.mailingAddressArray = [];
        if(street != null) this.mailingAddressArray.push(street);
        if(city != null) this.mailingAddressArray.push(city);
        if(state != null) this.mailingAddressArray.push(state);
        if(country != null) this.mailingAddressArray.push(country);
        if(postal != null) this.mailingAddressArray.push(postal);
        return this.mailingAddressArray.join(', ');
    }

    get caseContactATSICode() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_ATSI_CODE);
    }

    get caseContactLowSocioEconomicStatus() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_LOW_SOCIO_ECONOMIC_STATUS);
    }

    get caseContactRegionalRemote() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_REGIONAL_REMOTE);
    }

    get caseContactQUTApprovedDisability() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_QUT_APPROVED_DISABILITY);
    }

    get caseContactFirstInFamily() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_FIRST_IN_FAMILY);
    }

    get caseContactLeadScore() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_LEAD_SCORE);
    }

    get caseContactLeadSourceCategory() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_LEAD_SOURCE_CATEGORY);
    }

    get caseContactLeadSource() {
        return getFieldValue(this.caseRecord, CASE_CONTACT_LEADSOURCE);
    }

    get caseRecordTypeIsOutreach() {
        let rtDevName = getFieldValue(this.caseRecord, CASE_RECORDTYPE_DEVELOPERNAME);
        if(rtDevName == 'Outreach') {
            this.isInbound = false;
            this.isOutreach = true;
        }
        return this.isOutreach;
    }

    get caseRecordTypeIsInbound() {
        let rtDevName = getFieldValue(this.caseRecord, CASE_RECORDTYPE_DEVELOPERNAME);
        if(rtDevName == 'Inbound_Enquiry') {
            this.isInbound = true;
            this.isOutreach = false;
        }
        return this.isOutreach;
    }

    handleClickHeader() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseRecord.fields.ContactId.value,
                objectApiName: 'Contact',
                actionName: 'view'
            },
        });
    }
}