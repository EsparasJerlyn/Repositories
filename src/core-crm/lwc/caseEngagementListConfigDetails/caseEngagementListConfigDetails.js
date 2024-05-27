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

export default class CaseEngagementListConfigDetails extends NavigationMixin(LightningElement) {
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

    @api recordId;
    
    @wire(getRecord, { recordId: '$recordId', fields: [ CASE_ELCONF ]})
    case({ data, error }) {
        console.log(this.elconfObjectApiName);
        if(data) {
            this.elconfRecordId = data.fields.Engagement_List_Configuration__c.value;
            console.log('Wire:getRecord - Obtained elconfRecordId');
            console.log(this.elconfRecordId);
        } else if(error) {
            this.error;
            this.elconfRecordId = undefined;
            console.log('Wire:getRecord - Failed to get elconfRecordId with error');
            console.log(this.error);
        }
    }

    handleClickHeader() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.elconfRecordId,
                objectApiName: 'Engagement_List_Configuration__c',
                actionName: 'view'
            },
        });
    }
}