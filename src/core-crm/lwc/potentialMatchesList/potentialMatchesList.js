import { LightningElement, api, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import getPossibleMatchEnquery from '@salesforce/apex/PotentialMatchesListCtrl.getPossibleMatchEnquery';
import linkToObject from '@salesforce/apex/PotentialMatchesListCtrl.linkToObject';

export default class PotentialMatchesList extends LightningElement {
    @api objectId;
    @api objectName;
    @api isTriggerViewAll = false;
    @track isLoaded = false;
    @track dataRecord = [];
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

    viewAllColumnsWithDOB = [
        { label: 'Name', fieldName: 'name', type: 'text' },
        { label: 'Email', fieldName: 'email', type: 'text' },
        { label: 'Mobile', fieldName: 'mobile', type: 'text' },
        { label: 'Birthdate', fieldName: 'birthdate', type: 'text' },
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
    get linkBtnlabelName() {
        let labelName = '';
        if (this.objectName == 'Case') {
            labelName = 'Link to Case';
        } else if (this.objectName == 'ServiceAppointment') {
            labelName = 'Link to Service Appointment';
        }

        return labelName;
    }

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

    get tableColumns() {
        let columns = this.defaultViewColumns;

        if (this.isTriggerViewAll && this.objectName == 'Case') {
            columns = this.viewAllColumns;
        } else if (this.isTriggerViewAll && this.objectName == 'ServiceAppointment') {
            columns = this.viewAllColumnsWithDOB;
        }

        return columns;
    }

    connectedCallback() {
        if (this.objectId) {
            this.possibleMatchEnquery(this.objectId);
        }

        window.addEventListener('casePotentialListener', this.handleCustomEvent.bind(this));
    }

    handleCustomEvent(event) {
        if (event.detail.isReload) {
            this.possibleMatchEnquery(this.objectId);
        }
    }

    disconnectedCallback() {
        window.removeEventListener('casePotentialListener', this.handleCustomEvent.bind(this));
    }

    possibleMatchEnquery(recordId) {
        this.dataRecord = [];
        getPossibleMatchEnquery({objectId: recordId, objectName: this.objectName})
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

    handlelinkToObject() {
        this.isLoaded = false;
        const selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();

        if(selectedRecords.length > 0){
            const record = selectedRecords[0];

            if (record) {
                linkToObject({ objectId: this.objectId, contactLeadId: record.id, type: record.type, objectName: this.objectName })
                    .then(() => {
                        this.possibleMatchEnquery(this.objectId);
                        updateRecord({fields: { Id: this.objectId }});

                        const cEvent = new CustomEvent('casePotentialListener', {
                            detail: { isReload: true }
                        });

                        window.dispatchEvent(cEvent);

                        if (this.isTriggerViewAll) {
                            const closeTab = new CustomEvent('closetab');
                            this.dispatchEvent(closeTab);
                        }
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
            mobile: obj.MobilePhone,
            birthdate: obj.Birthdate,
            workeMail: obj.Work_Email__c,
            qutStaffEmail: obj.QUT_Staff_Email__c,
            qutLearner: obj.QUT_Learner_Email__c,
            type: type
        };
    }
}