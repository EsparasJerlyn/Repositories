/**
 * @description Lightning Web Component for Custom Donation Payment Tab.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                      | Date                  | JIRA                   | Change Summary                                                                |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Created file                                                                  |
      |                                |                       | DEPP-8570              |                                                                               |
      |                                |                       | DEPP-8682              |                                                                               |
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8595              | Add functionality that can view, create and edit                              |
      |                                |                       | DEPP-8632              | Pledge Designation Split and Pledge Instalment                                |
      |                                |                       | DEPP-8720              |                                                                               |
      |                                |                       | DEPP-8596              |                                                                               |
      |                                |                       | DEPP-8621              |                                                                               |
      |                                |                       | DEPP-8721              |                                                                               |
      |                                |                       |                        |                                                                               |
*/
import { LightningElement, api, wire } from "lwc";
import { getRecord  } from "lightning/uiRecordApi";

import { loadStyle } from "lightning/platformResourceLoader";
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';

import DONATION_TOTAL_AMOUNT from "@salesforce/schema/Donation__c.Total_Amount__c";
import DONATION_CONTACT from "@salesforce/schema/Donation__c.Contact__c";
import DONATION_ACCOUNT from "@salesforce/schema/Donation__c.Account__c";
import DONATION_FROM_DESIGNATION from "@salesforce/schema/Donation__c.From_Designation__c";
import DONATION_TO_DESIGNATION from "@salesforce/schema/Donation__c.To_Designation__c";
import DONATION_IS_ANONYMOUS from "@salesforce/schema/Donation__c.Is_Anonymous_Donation__c";
import DONATION_STAGE from "@salesforce/schema/Donation__c.Stage__c";
import DONATION_PAYMENT_TYPE from "@salesforce/schema/Donation__c.Payment_Type__c";
import DONATION_HAS_DESIGNATION_SPLIT from "@salesforce/schema/Donation__c.Has_Designation_Split__c";
import DONATION_COMMENT from "@salesforce/schema/Donation__c.Donation_Comment__c";

import getDonationsByRecordTypeParentId from "@salesforce/apex/ChildDonationModalCtrl.getDonationsByRecordTypeParentId";
export default class ChildDonation extends LightningElement {
    @api recordId;

    @api
    get pageUniqueParam() {
        return this._pageUniqueParam;
    }
    set pageUniqueParam(value) {
        if (value === 'Donation Endowment Payment tab') {
            this.isDonationEndowmentPaymentTab = true;
        }

        if (value === 'Donation Pledge Payment tab') {
            this.isDonationPledgePaymentTab = true;
        }

        this._pageUniqueParam = value;
    }

    isShowModal;
    _pageUniqueParam;
    tableLabel;
    data = [];
    isDonationEndowmentPaymentTab = false;
    isDonationPledgePaymentTab = false;
    isLoading = true;
    isDataEmpty = false;
    parentDonationDetail;

    donationFields = [
        DONATION_TOTAL_AMOUNT,
        DONATION_STAGE,
        DONATION_ACCOUNT,
        DONATION_FROM_DESIGNATION,
        DONATION_TO_DESIGNATION,
        DONATION_IS_ANONYMOUS,
        DONATION_CONTACT,
        DONATION_PAYMENT_TYPE,
        DONATION_HAS_DESIGNATION_SPLIT,
        DONATION_COMMENT,
    ];

    donationColumns = [
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
        {
            label: 'Total Amount',
            fieldName: 'Total_Amount__c',
            editable: false,
            sortable: false,
            type: 'currency',
        },
        {
            label: 'Instalment Date',
            fieldName: 'Instalment_Date__c',
            editable: false,
            sortable: false,
            type: 'text',
        },
        {
            label: 'Stage',
            fieldName: 'Stage__c',
            editable: false,
            sortable: false,
            type: 'text',
        },
        {
            label: 'To Designation',
            fieldName: 'toDesignationReference',
            editable: false,
            sortable: false,
            type: 'url',
            typeAttributes: { label: { fieldName: 'toDesignationReferenceName' }, target: '_self' }
        },
    ];

    get checkLoading() {
        return this.isLoading;
    }

    get showNewButton() {
        const parentDonationDetail = this.parentDonationDetail;
        if (parentDonationDetail && parentDonationDetail.Stage__c) {

            if (
                this.isDonationEndowmentPaymentTab &&
                !this.data.length &&
                parentDonationDetail.Stage__c.value === 'Accepted'
            ) {
                return true;
            } else if (
                this.isDonationPledgePaymentTab &&
                (
                    !this.data.length &&
                    parentDonationDetail &&
                    (parentDonationDetail.Stage__c && parentDonationDetail.Stage__c.value === 'Accepted') &&
                    (parentDonationDetail.Payment_Type__c && parentDonationDetail.Payment_Type__c.value === 'One-Off Payment') &&
                    (parentDonationDetail.Has_Designation_Split__c && parentDonationDetail.Has_Designation_Split__c.value === true)
                )
            ) {
                return true;
            } else if (
                this.isDonationPledgePaymentTab &&
                (
                    !this.data.length &&
                    parentDonationDetail &&
                    (parentDonationDetail.Stage__c && parentDonationDetail.Stage__c.value === 'Accepted') &&
                    (parentDonationDetail.Payment_Type__c && parentDonationDetail.Payment_Type__c.value === 'Payment Plan')
                )
            ) {
                return true;
            }
        }

        return false;
    }

    get showEditButton() {
        const parentDonationDetail = this.parentDonationDetail;
        if (parentDonationDetail && parentDonationDetail.Stage__c) {
            const stageValue = parentDonationDetail.Stage__c.value;

            if (
                this.isDonationEndowmentPaymentTab &&
                this.data.length &&
                parentDonationDetail.Stage__c.value === 'Accepted'
            ) {
                return true;
            } else if (
                this.isDonationPledgePaymentTab &&
                (
                    this.data.length &&
                    parentDonationDetail &&
                    (parentDonationDetail.Stage__c && stageValue === 'Accepted') &&
                    (parentDonationDetail.Payment_Type__c && parentDonationDetail.Payment_Type__c.value === 'One-Off Payment') &&
                    (parentDonationDetail.Has_Designation_Split__c && parentDonationDetail.Has_Designation_Split__c.value === true)
                )
            ) {
                return true;
            } else if (this.isDonationPledgePaymentTab &&
                (
                    this.data.length &&
                    parentDonationDetail &&
                    (parentDonationDetail.Payment_Type__c && parentDonationDetail.Payment_Type__c.value === 'Payment Plan')
                )
            ) {
                const notInStage = ['Completed', 'Cancelled', 'Completed - Part Paid'];
                if (notInStage.indexOf(stageValue) < 0) {
                    return true;
                }
            }
        }

        return false;
    }

    get isDisplayPaymentDonation() {
        const parentDonationDetail = this.parentDonationDetail;

        if (parentDonationDetail && parentDonationDetail.Stage__c) {
            if (this.isDonationEndowmentPaymentTab) {
                return true;
            } else if (
                this.isDonationPledgePaymentTab &&
                (
                    parentDonationDetail &&
                    (parentDonationDetail.Payment_Type__c && parentDonationDetail.Payment_Type__c.value === 'One-Off Payment') &&
                    (parentDonationDetail.Has_Designation_Split__c && parentDonationDetail.Has_Designation_Split__c.value === true)
                )
            ) {
                return true;
            } else if (
                this.isDonationPledgePaymentTab &&
                (
                    parentDonationDetail &&
                    (parentDonationDetail.Payment_Type__c && parentDonationDetail.Payment_Type__c.value === 'Payment Plan')
                )
            ) {
                return true;
            }
        }

        return false;
    }

    @wire(getRecord, { recordId: '$recordId', fields: "$donationFields"})
    wireDonationDetail({error, data}) {
        if (data) {
            this.parentDonationDetail = data.fields;
            this.fetchDonations();
        }
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, customDataTableStyle)
            ]).then(() => {
        });
    }

    fetchDonations() {
        const parentDonationDetail = this.parentDonationDetail;
        const donationColumns = this.donationColumns;
        let toFetchrecordType = '';
        const newColumn = [];
        let toDisplayTableColumns = [];

        if (this.isDonationEndowmentPaymentTab) {
            toDisplayTableColumns = ['Instalment Number', 'Donation Reference', 'Total Amount', 'Instalment Date', 'Stage'];
            this.tableLabel = "Endowment Instalment";

            toFetchrecordType = 'Endowment Instalment';
        } else if (this.isDonationPledgePaymentTab && parentDonationDetail.Payment_Type__c.value === 'One-Off Payment') {
            toDisplayTableColumns = ['Donation Reference', 'Total Amount', 'To Designation', 'Stage'];
            this.tableLabel = "Pledge Designation Split";

            toFetchrecordType = 'Pledge Designation Split';
        } else if (this.isDonationPledgePaymentTab && parentDonationDetail.Payment_Type__c.value === 'Payment Plan') {
            toDisplayTableColumns = ['Instalment Number', 'Donation Reference', 'Total Amount', 'Instalment Date', 'Stage'];
            this.tableLabel = "Pledge Instalment";

            toFetchrecordType = 'Pledge Instalment';
        }

        toDisplayTableColumns.forEach((name) => {
            donationColumns.forEach((obj) => {
                if (obj.label === name) {
                    newColumn.push(obj);
                }
            })
        });

        this.columns = newColumn;

        if (toFetchrecordType) {
            this.fetchDonationByRecordType(toFetchrecordType);
        }
    }

    fetchDonationByRecordType(toFetchrecordType) {
        this.isLoading = true;
        getDonationsByRecordTypeParentId({ parentDonation: this.recordId, recordType: toFetchrecordType })
            .then((response) => {
                this.isLoading = false;

                response.forEach((obj, key) => {
                    obj.instalmentNumber = key + 1;
                    obj.donationReference = `/lightning/r/Donation__c/${obj.Id}/view`;

                    if (obj.To_Designation__c) {
                        obj.toDesignationReference = `/lightning/r/Designation__c/${obj.To_Designation__c}/view`;
                        obj.toDesignationReferenceName = obj.To_Designation__r.Name;
                    }
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
}