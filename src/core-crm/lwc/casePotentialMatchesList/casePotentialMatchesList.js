import { LightningElement, api, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import getPossibleMatchEnquery from '@salesforce/apex/CasePotentialMatchesListCtrl.getPossibleMatchEnquery';
import linkToCase from '@salesforce/apex/CasePotentialMatchesListCtrl.linkToCase';

export default class CasePotentialMatchesList extends LightningElement {
    @api caseId;
    @api isTriggerViewAll = false;
    @track isLoaded = false;
    @track dataRecord = [];
    @track columns = [];
    @track totalRecord = 0;
    isDisabledBtn;
    toShowLimit = 5;

    viewAllColumns = [
        { label: 'Name', fieldName: 'name', type: 'text' },
        { label: 'Email', fieldName: 'email', type: 'text' },
        { label: 'Mobile', fieldName: 'mobile', type: 'text' },
        { label: 'Work Email', fieldName: 'workeMail', type: 'text' },
        { label: 'QUT Staff Email', fieldName: 'qutStaffEmail', type: 'text' },
        { label: 'QUT Learner', fieldName: 'qutLearner', type: 'text' },
        { label: 'Type', fieldName: 'type', type: 'text' },
    ];

    defaultViewColumns = [
        { label: 'Name', fieldName: 'name', type: 'text'},
        { label: 'Email', fieldName: 'email', type: 'text'},
        { label: 'Mobile', fieldName: 'mobile', type: 'text'}
    ];

    get getTitle() {
        let isDisabledBtn = true;

        if (this.template.querySelector("lightning-datatable")) {
            const selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();

            if (selectedRecords.length > 0) {
                isDisabledBtn = false;
            }

        }

        this.isDisabledBtn = isDisabledBtn;
        return `We Found (${this.totalRecord}) Possible Matches for Enquirer`
    }

    connectedCallback() {
        this.columns = this.isTriggerViewAll ? this.viewAllColumns : this.defaultViewColumns

        if (this.caseId) {
            this.possibleMatchEnquery(this.caseId);
        }

        window.addEventListener('casePotentialListener', this.handleCustomEvent.bind(this));
    }

    handleCustomEvent(event) {
        if (event.detail.isReload) {
            this.possibleMatchEnquery(this.caseId);
        }
    }

    disconnectedCallback() {
        window.removeEventListener('casePotentialListener', this.handleCustomEvent.bind(this));
    }

    possibleMatchEnquery(recordId) {
        this.dataRecord = [];
        getPossibleMatchEnquery({caseId: recordId})
            .then((response) => {
                const contacts = response.Contact;
                const leads = response.Lead;
                const contactLeadRecord = [];

                for(let i in contacts) {
                    const contactList = this.assignObj(contacts[i], 'Contact');
                    contactLeadRecord.push(contactList);
                }

                for(let i in leads) {
                    const leadList = this.assignObj(leads[i], 'Lead');
                    contactLeadRecord.push(leadList);
                }

                let arrRecordToShow = contactLeadRecord.slice(0, this.toShowLimit);

                if (this.isTriggerViewAll) {
                    arrRecordToShow = contactLeadRecord;
                }

                this.dataRecord = arrRecordToShow;
                this.totalRecord = contactLeadRecord.length;
                this.isLoaded = true;
            })
            .catch((error) => {
                console.log(error);
            })
    }

    handleLinkToCase() {
        this.isLoaded = false;
        const selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();

        if(selectedRecords.length > 0){
            const record = selectedRecords[0];

            if (record) {
                linkToCase({ caseId: this.caseId, contactLeadId: record.id, type: record.type })
                    .then(() => {
                        this.possibleMatchEnquery(this.caseId);
                        updateRecord({fields: { Id: this.caseId }});

                        const cEvent = new CustomEvent('casePotentialListener', {
                            detail: { isReload: true }
                        });

                        window.dispatchEvent(cEvent);
                    })
                    .catch((error) => {
                        console.log(error);
                        this.isLoaded = true;
                    })
            }
        }
    }

    assignObj(obj, type) {
        return {
            id: obj.Id,
            name: obj.Name,
            email: obj.Email,
            mobile: obj.Mobile_No_Locale__c,
            workeMail: obj.Work_Email__c,
            qutStaffEmail: obj.QUT_Staff_Email__c,
            qutLearner: obj.QUT_Learner_Email__c,
            type: type
        };
    }
}