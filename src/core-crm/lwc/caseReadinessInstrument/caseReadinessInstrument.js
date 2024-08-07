import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

import CASE_QUALTRICS from '@salesforce/schema/Case.Qualtrics_Survey__c';
import CASE_QUALTRICS_NAME from '@salesforce/schema/Case.Qualtrics_Survey__r.Name';
import CASE_QUALTRICS_STATUS from '@salesforce/schema/Case.Qualtrics_Survey__r.Survey_Status__c';
import CASE_QUALTRICS_STAFFASSISTED from '@salesforce/schema/Case.Qualtrics_Survey__r.Staff_Assisted__c';
import CASE_QUALTRICS_INPROGRESSURL from '@salesforce/schema/Case.Qualtrics_Survey__r.In_Progress_Survey_URL__c';
import CASE_QUALTRICS_COMPLETEDURL from '@salesforce/schema/Case.Qualtrics_Survey__r.Completed_Survey_URL__c';

const fields = [
    CASE_QUALTRICS,
    CASE_QUALTRICS_NAME,
    CASE_QUALTRICS_STATUS,
    CASE_QUALTRICS_STAFFASSISTED,
    CASE_QUALTRICS_INPROGRESSURL,
    CASE_QUALTRICS_COMPLETEDURL
];

const CARD_CLASS_HASQUALTRICS = "slds-card";
const CARD_CLASS_NOQUALTRICS = "slds-card card-with-bg";
const CARD_HEADER_CLASS_HASQUALTRICS = "slds-card__header slds-grid header-with-bg slds-border_bottom slds-p-bottom_x-small";
const CARD_HEADER_CLASS_NOQUALTRICS = "slds-card__header slds-grid";

export default class CaseReadinessInstrument extends NavigationMixin(LightningElement) {
    cardClass = CARD_CLASS_NOQUALTRICS;
    cardHeaderClass = CARD_HEADER_CLASS_NOQUALTRICS;
    caseRecord;
    caseQualtricsUrl;
    caseQualtricsSurveyLink;
    error;
    hasQualtrics = false;
    isLoading;

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    case({ data, error }) {
        this.isLoading = true;
        if(data) {
            this.caseRecord = data;
            if(this.caseRecord.fields.Qualtrics_Survey__c.value != null) {
                this.hasQualtrics = true;
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.caseRecord.fields.Qualtrics_Survey__c.value,
                        actionName: 'view'
                    },
                }).then((url) => {
                    this.caseQualtricsUrl = url;
                });
            } else {
                this.hasQualtrics = false;
            }
            this.cardClass = this.hasQualtrics ? CARD_CLASS_HASQUALTRICS : CARD_CLASS_NOQUALTRICS
            this.cardHeaderClass = this.hasQualtrics ? CARD_HEADER_CLASS_HASQUALTRICS : CARD_HEADER_CLASS_NOQUALTRICS;
            let completedUrl = getFieldValue(this.caseRecord, CASE_QUALTRICS_COMPLETEDURL);
            let inProgressUrl = getFieldValue(this.caseRecord, CASE_QUALTRICS_INPROGRESSURL); 
            this.caseQualtricsSurveyLink = this.caseQualtricsStatus == 'Complete' ? completedUrl : inProgressUrl;
        } else if(error) {
            this.error = error;
            this.caseRecord = undefined;
        }

        this.isLoading = false;
    }

    get caseQualtricsName() {
        return getFieldValue(this.caseRecord, CASE_QUALTRICS_NAME);
    }

    get caseQualtricsStatus() {
        return getFieldValue(this.caseRecord, CASE_QUALTRICS_STATUS);
    }

    get caseQualtricsStaffAssisted() {
        return getFieldValue(this.caseRecord, CASE_QUALTRICS_STAFFASSISTED);
    }

    handleMenuSelect(event) {
        if(event.detail.value == 'view') {
            this.navigateToRecord();
        }
    }

    handleClickHeader() {
        this.navigateToRecord();
    }

    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseRecord.fields.Qualtrics_Survey__c.value,
                objectApiName: 'Qualtrics_Survey__c',
                actionName: 'view'
            },
        });
    }
}