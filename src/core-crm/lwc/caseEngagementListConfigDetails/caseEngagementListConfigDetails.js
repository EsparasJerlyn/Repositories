import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import CASE_ELCONF from '@salesforce/schema/Case.Engagement_List_Configuration__c';
import ELCONF from '@salesforce/schema/Engagement_List_Configuration__c';
import ELCONF_NAME from '@salesforce/schema/Engagement_List_Configuration__c.Name';
import ELCONF_DESCRIPTION from '@salesforce/schema/Engagement_List_Configuration__c.Description__c';
import ELCONF_PURPOSE from '@salesforce/schema/Engagement_List_Configuration__c.Purpose__c';
import ELCONF_MAXNUMBEROFCALLATTEMPTS from '@salesforce/schema/Engagement_List_Configuration__c.Max_Number_Of_Call_Attempts__c';
import ELCONF_BRIEFINGNOTES from '@salesforce/schema/Engagement_List_Configuration__c.Briefing_Notes__c';

const CARD_CLASS_HASCONFIG = "slds-card";
const CARD_CLASS_NOCONFIG = "slds-card card-with-bg";
const CARD_HEADER_CLASS_HASCONFIG = "slds-card__header slds-grid header-with-bg slds-border_bottom slds-p-bottom_x-small";
const CARD_HEADER_CLASS_NOCONFIG = "slds-card__header slds-grid";
export default class CaseEngagementListConfigDetails extends NavigationMixin(LightningElement) {
    cardClass = CARD_CLASS_NOCONFIG;
    cardHeaderClass = CARD_HEADER_CLASS_NOCONFIG;
    elconfObjectApiName = ELCONF;
    elconfRecordId;
    error;
    fields = [
        ELCONF_NAME,
        ELCONF_DESCRIPTION,
        ELCONF_PURPOSE,
        ELCONF_MAXNUMBEROFCALLATTEMPTS,
        ELCONF_BRIEFINGNOTES
    ];
    overviewFields = [
        ELCONF_NAME,
        ELCONF_MAXNUMBEROFCALLATTEMPTS
    ];
    descriptionFields = [
        ELCONF_DESCRIPTION
    ];
    purposeFields = [
        ELCONF_PURPOSE
    ];
    briefingNotesFields = [
        ELCONF_BRIEFINGNOTES
    ];
    hasConfig = false;

    @api recordId;
    
    @wire(getRecord, { recordId: '$recordId', fields: [ CASE_ELCONF ]})
    case({ data, error }) {
        if(data) {
            this.elconfRecordId = data.fields.Engagement_List_Configuration__c.value;
            this.hasConfig = this.elconfRecordId ? true : false;
            this.cardClass = this.hasConfig ? CARD_CLASS_HASCONFIG : CARD_CLASS_NOCONFIG
            this.cardHeaderClass = this.hasConfig ? CARD_HEADER_CLASS_HASCONFIG : CARD_HEADER_CLASS_NOCONFIG;
        } else if(error) {
            this.error = error.body.message;
            this.elconfRecordId = undefined;
        }
    }
}