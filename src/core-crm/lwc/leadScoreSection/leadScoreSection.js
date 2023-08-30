import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import CONTACT_LEAD_SCORE from '@salesforce/schema/Contact.Lead_Score__c';
import CONTACT_TOTAL_LEAD_SCORE from '@salesforce/schema/Contact.Lead_Score_Detail__r.Total_Lead_Score__c';
import CONTACT_NAME from '@salesforce/schema/Contact.Name';
import LEAD_NAME from '@salesforce/schema/Lead.Name';
import LEAD_LEAD_SCORE from '@salesforce/schema/Lead.Lead_Score__c';
import LEAD_TOTAL_LEAD_SCORE from '@salesforce/schema/Lead.Lead_Score_Detail__r.Total_Lead_Score__c';

export default class LeadScoreSection extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track fieldApiNames = [];
    progress = '';
    totalLeadScore = 0;
    totalScore = 0;
    wiredAccountList;
    cx = 0;
    cy = 0;

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldApiNames'})
    wiredRecord(result) {
        const { error, data } = result;

        if (data) {
            let leadScore = 0
            let totalLeadScore = 0;
            if (this.objectApiName === 'Lead') {
                leadScore = getFieldValue(data, LEAD_LEAD_SCORE);
                totalLeadScore = getFieldValue(data, LEAD_TOTAL_LEAD_SCORE);
            }

            if (this.objectApiName === 'Contact') {
                leadScore = getFieldValue(data, CONTACT_LEAD_SCORE);
                totalLeadScore = getFieldValue(data, CONTACT_TOTAL_LEAD_SCORE);
            }

            this.totalLeadScore = totalLeadScore;
            this.totalScore = leadScore;

            this.progress = this.getRingProgress(leadScore, totalLeadScore);

            const width = 0.7;
            const height = 0.7;
            const anglePercentage = (leadScore / totalLeadScore) * 100;;  // Percentage of the circumference

            const coordinates = this.calculateNodeCoordinates(width, height, anglePercentage);

            this.cx = coordinates.x;
            this.cy = coordinates.y;
        }
    }

    get getTotalLeadScore() {
        return this.totalLeadScore;
    }

    get getLeadScore() {
        return this.totalScore;
    }

    connectedCallback() {
        if (this.objectApiName === 'Lead') {
            this.fieldApiNames = [
                LEAD_LEAD_SCORE,
                LEAD_TOTAL_LEAD_SCORE,
            ];
        }

        if (this.objectApiName === 'Contact') {
            this.fieldApiNames = [
                CONTACT_LEAD_SCORE,
                CONTACT_TOTAL_LEAD_SCORE,
            ];
        }
    }

    getRingProgress(leadScore, totalLeadScore) {
        let quotient = 0
        if (leadScore / totalLeadScore >= 0.5) {
            quotient = 1;
        }

        let negativePercentage = 1 - (leadScore / totalLeadScore);

        const x = Math.cos(2 * Math.PI * negativePercentage).toFixed(2);
        const y = Math.sin(2 * Math.PI * negativePercentage).toFixed(2);

        return `M 1 0 A 1 1 0 ${quotient} 0 ${x} ${y} L 0 0`;
    }

    calculateNodeCoordinates(width, height, anglePercentage) {
        // Convert percentage to angle in degrees (clockwise)
        const angleDegrees = (1 - anglePercentage / 100) * 360; // Clockwise mapping

        // Convert angle to radians
        const angleRadians = (angleDegrees * Math.PI) / 180;

        // Calculate the coordinates
        const x = (width * Math.cos(angleRadians)).toFixed(2);
        const y = (height * Math.sin(angleRadians)).toFixed(2);

        return { x, y };
    }
}