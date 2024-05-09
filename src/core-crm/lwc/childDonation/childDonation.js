/**
 * @description Lightning Web Component for Custom Donation Payment Tab.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                      | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Created file                                    |
      |                                |                       | DEPP-8570              |                                                 |
      |                                |                       | DEPP-8682              |                                                 |
*/
import { LightningElement, api, wire } from "lwc";
import { getRecord  } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { loadStyle } from "lightning/platformResourceLoader";
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';

import DONATION_TOTAL_AMOUNT from "@salesforce/schema/Donation__c.Total_Amount__c";
import DONATION_CONTACT from "@salesforce/schema/Donation__c.Contact__c";
import DONATION_ACCOUNT from "@salesforce/schema/Donation__c.Account__c";
import DONATION_FROM_DESIGNATION from "@salesforce/schema/Donation__c.From_Designation__c";
import DONATION_TO_DESIGNATION from "@salesforce/schema/Donation__c.To_Designation__c";
import DONATION_IS_ANONYMOUS from "@salesforce/schema/Donation__c.Is_Anonymous_Donation__c";
import DONATION_STAGE from "@salesforce/schema/Donation__c.Stage__c";

import getDonationsEndowmentInstalment from "@salesforce/apex/ChildDonationModalCtrl.getDonationsEndowmentInstalment";

export default class ChildDonation extends LightningElement {
    @api recordId;
    @api pageUniqueParam;

    isShowModal;
    tableLabel;
    data = [];
    isLoading = true;
    isDataEmpty = false;
    parentDonationDetail;

    donationFields = [DONATION_TOTAL_AMOUNT, DONATION_STAGE, DONATION_ACCOUNT, DONATION_FROM_DESIGNATION, DONATION_TO_DESIGNATION, DONATION_IS_ANONYMOUS, DONATION_CONTACT];

    donationEndownmentPaymentTab = [
        {
            label: 'Instalment Number',
            fieldName: 'instalmentNumber',
            type: 'text',
            editable: false,
            sortable: false,
            type: 'text',
        },
        {
            label: 'Donation Reference',
            fieldName: 'donationReference',
            editable: false,
            sortable: false,
            type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }
        },
        { label: 'Total Amount',
            fieldName: 'Total_Amount__c',
            editable: false,
            sortable: false,
            type: 'currency',
        },
        { label: 'Instalment Date',
            fieldName: 'Instalment_Date__c',
            editable: false,
            sortable: false,
            type: 'text',
        },
        { label: 'Stage',
            fieldName: 'Stage__c',
            editable: false,
            sortable: false,
            type: 'text',
        },
    ];

    get checkLoading() {
        return this.isLoading;
    }

    get showNewButton() {
        const parentDonationDetail = this.parentDonationDetail;
        if (parentDonationDetail && parentDonationDetail.Stage__c) {
            return !this.data.length && parentDonationDetail.Stage__c.value === 'Accepted' ? true : false;
        }

        return false;
    }

    get showEditButton() {
        const parentDonationDetail = this.parentDonationDetail;
        if (parentDonationDetail && parentDonationDetail.Stage__c) {
            const stageValue = parentDonationDetail.Stage__c.value;
            const stageNotEqualTo = ['Completed', 'Cancelled', 'Declined', 'Completed - Part Paid']
            return this.data.length && stageNotEqualTo.indexOf(stageValue) < 0 ? true : false;
        }

        return false;
    }

    @wire(getRecord, { recordId: '$recordId', fields: "$donationFields"})
    wireDonationDetail({error, data}) {
        if (data) {
            this.parentDonationDetail = data.fields;
        }
    }

    async connectedCallback() {
        Promise.all([
            loadStyle(this, customDataTableStyle)
            ]).then(() => {
        });

        if (this.pageUniqueParam === 'Donation Endowment Payment tab') {
            this.tableColumns = this.donationEndownmentPaymentTab;
            this.tableLabel = "Endowment Instalment";
            this.columns = this.donationEndownmentPaymentTab;

            this.fetchDonations();
        }
    }

    fetchDonations() {
        this.isLoading = true;
        getDonationsEndowmentInstalment({ parentDonation: this.recordId })
            .then((response) => {
                this.isLoading = false;

                response.forEach((obj, key) => {
                    obj.instalmentNumber = key + 1;
                    obj.donationReference = `/lightning/r/Donation__c/${obj.Id}/view`;
                });

                this.data = response;
                this.isDataEmpty = response.length ? false : true;
            })
    }

    handleShowModal() {
        this.isShowModal = true;
    }

    handleCloseModal() {
        this.isShowModal = false;
    }

    //Toast Message
    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });

        this.dispatchEvent(evt);
    }
}