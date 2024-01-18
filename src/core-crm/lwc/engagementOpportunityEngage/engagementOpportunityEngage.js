import { LightningElement, api } from 'lwc';

export default class EngagementOpportunityEngage extends LightningElement {
    @api recordId;
    @api objectApiName;
    isEngageTab = true;
}