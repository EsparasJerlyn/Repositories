import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, getObjectInfo } from 'lightning/uiRecordApi';


import getScoreByCitizenshipStudyLvl from '@salesforce/apex/LeadScoreSectionCtrl.getScoreByCitizenshipStudyLvl';
import getScoreDomesticStrongInterestPreApplication from '@salesforce/apex/LeadScoreSectionCtrl.getScoreDomesticStrongInterestPreApplication';

import CONTACT_LEAD_SCORE from '@salesforce/schema/Contact.Lead_Score__c';
import CONTACT_CITIZENSHIP_STATUS from '@salesforce/schema/Contact.hed__Citizenship_Status__c';
import CONTACT_PRIMARY_STUDY_LEVEL from '@salesforce/schema/Contact.Marketing_Segmentation__r.My_Primary_Study_Level__c';

import LEAD_LEAD_SCORE from '@salesforce/schema/Lead.Lead_Score__c';
import LEAD_CITIZENSHIP_STATUS from '@salesforce/schema/Lead.Marketing_Segmentation__r.My_Citizenship_Status__c';
import LEAD_PRIMARY_STUDY_LEVEL from '@salesforce/schema/Lead.Marketing_Segmentation__r.My_Primary_Study_Level__c';

export default class LeadScoreSection extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track fieldApiNames = [];
    progress = '';
    totalLeadScore = 0;
    leadScore = 0;
    nurtureTrack;
    cx = 0;
    cy = 0;

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldApiNames'})
    wiredRecord(result) {
        const { error, data } = result;

        if (data) {
            let leadScore = 0;
            let primaryStudyLevel = '';
            let citizenshipStatus = '';

            if (this.objectApiName === 'Lead') {
                leadScore = getFieldValue(data, LEAD_LEAD_SCORE);
                this.leadScore = leadScore;
                citizenshipStatus = getFieldValue(data, LEAD_CITIZENSHIP_STATUS);
                citizenshipStatus = citizenshipStatus == 'International Student' ? 'International' : 'Domestic';
                primaryStudyLevel = getFieldValue(data, LEAD_PRIMARY_STUDY_LEVEL);
            }

            if (this.objectApiName === 'Contact') {
                leadScore = getFieldValue(data, CONTACT_LEAD_SCORE);
                this.leadScore = leadScore;
                citizenshipStatus = getFieldValue(data, CONTACT_CITIZENSHIP_STATUS);
                primaryStudyLevel = getFieldValue(data, CONTACT_PRIMARY_STUDY_LEVEL);
            }

            if (citizenshipStatus === 'Domestic' || citizenshipStatus === 'International') {
                getScoreByCitizenshipStudyLvl({citizenshipStatus, primaryStudyLevel})
                    .then(async(response) => {
                        if (response.length) {
                            try {
                                const nurtureTrack = await getScoreDomesticStrongInterestPreApplication({citizenshipStatus});

                                if (nurtureTrack.length) {
                                    this.nurtureTrack = nurtureTrack[0].Lead_Score_Threshold__c;
                                    this.generateProgressRing(leadScore, response[0].Max_Score__c);
                                }
                            } catch (error) {
                                console.error(error);
                            }
                        }
                    });
            }
        }
    }

    get getColorRingProgress() {
        let css = 'slds-progress-ring slds-progress-ring_large slds-float_left  ';

        if (this.nurtureTrack && this.leadScore < this.nurtureTrack) {
            css += 'slds-progress-ring_warning';
        }

        return css;
    }

    get getHasMaxScore() {
        return this.cx != 0 && this.cy != 0 ? true : false;
    }

    get getTotalLeadScore() {
        return this.totalLeadScore;
    }

    get getLeadScore() {
        return this.leadScore;
    }

    connectedCallback() {
        if (this.objectApiName === 'Lead') {
            this.fieldApiNames = [
                LEAD_LEAD_SCORE,
                LEAD_CITIZENSHIP_STATUS,
                LEAD_PRIMARY_STUDY_LEVEL
            ];
        }

        if (this.objectApiName === 'Contact') {
            this.fieldApiNames = [
                CONTACT_LEAD_SCORE,
                CONTACT_CITIZENSHIP_STATUS,
                CONTACT_PRIMARY_STUDY_LEVEL
            ];
        }
    }

    generateProgressRing(leadScore, totalLeadScore) {
        if (totalLeadScore) {
            this.totalLeadScore = totalLeadScore;
            console.log('generateProgressRing', leadScore, totalLeadScore);
            this.progress = this.getRingProgress(leadScore, totalLeadScore);

            const width = 0.75;
            const height = 0.75;
            const anglePercentage = (leadScore / totalLeadScore) * 100;  // Percentage of the circumference

            const coordinates = this.calculateNodeCoordinates(width, height, anglePercentage);

            this.cx = coordinates.x;
            this.cy = coordinates.y;
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

        if (this.nurtureTrack === undefined) {
            return;
        }

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