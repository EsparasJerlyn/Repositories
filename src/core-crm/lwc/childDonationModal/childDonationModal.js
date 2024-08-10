/**
 * @description Lightning Web Component for Custom Donation Payment Tab Upsert Record.
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
import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import DESIGNATION_NAME from '@salesforce/schema/Designation__c.Name';

import upsertDonationChild from "@salesforce/apex/ChildDonationModalCtrl.upsertDonationChild";


export default class ChildDonationModal extends LightningElement {
    @api recordId;
    @api pageUniqueParam;
    @api existingData;
    @api title;
    @api isDonationEndowmentPaymentTab;
    @api isDonationPledgePaymentTab;

    errors;
    modalHeader = "New Donation";
    isErrorMessage = false;
    isEdit = false;
    title = '';

    @track data = [];
    @track toUpsert = {
        totalAmount: '',
        numberInstalments: ''
    };
    @track draftValues = [];
    @track columns = [];

    donationColumns = [
        {
            label: 'Instalment Number',
            fieldName: 'instalmentNumber',
            apiFieldName:'instalmentNumber',
            editable: false,
            sortable: true,
            type: 'text',
        },
        {
            label: 'Total Amount',
            fieldName: 'Total_Amount__c',
            apiFieldName:'Total_Amount__c',
            editable: true,
            sortable: false,
            type: 'currency',
        },
        {
            label: 'Instalment Date',
            fieldName: 'Instalment_Date__c',
            apiFieldName:'Instalment_Date__c',
            editable: true,
            sortable: false,
            type: "date-local",
            typeAttributes:{
                month: "2-digit",
                day: "2-digit"
            }
        },
        {
            label: 'Stage',
            fieldName: 'Stage__c',
            apiFieldName:'Stage__c',
            wrapText: false,
            sortable: false,
            type: 'text',
        },
        {
            label: 'To Designation',
            type: 'customLookupColumn',
            editable: true,
            typeAttributes: {
                tableObjectType: 'Donation__c',
                rowDraftId: { fieldName: 'rowId' },
                rowRecordId: { fieldName: 'Id' },
                lookupValue: { fieldName: 'To_Designation__c' },
                lookupValueFieldName: [DESIGNATION_NAME],
                lookupFieldName: 'To_Designation__c',
                editable: { fieldName: 'editable' }
            },
            cellAttributes: {
                class: { fieldName: 'toDesignationClass' }
            }
        },
        {
            type: 'button-icon',
            initialWidth: 100,
            typeAttributes:
            {
                iconName: 'utility:delete',
                name: 'delete',
                disabled: { fieldName: 'deleteDisabled' }
            }
        }
    ];

    @api
    get parentDonationDetail() {
        return this._parentDonationDetail;
    }
    set parentDonationDetail(value) {
        if (value.Total_Amount__c.value) {
            this.toUpsert.totalAmount = value.Total_Amount__c.value;
        }

        this._parentDonationDetail = value;
    }

    get isPledgeInstalment() {
        const parentDonationDetail = this._parentDonationDetail;
        if (this.isDonationPledgePaymentTab && parentDonationDetail.Payment_Type__c.value === 'Payment Plan') {
            return true;
        }
        return false;
    }

    get isPledgeDesignationSplit() {
        const parentDonationDetail = this._parentDonationDetail;
        if (this.isDonationPledgePaymentTab && parentDonationDetail.Payment_Type__c.value === 'One-Off Payment') {
            return true;
        }
        return false;
    }

    get saveBtnDisabled() {
        return this.saveButtonDisabled || !this.data.length ? true : false;
    }

    get isNew() {
        return this.existingData.length ? false : true;
    }

    connectedCallback() {
        const existingData = JSON.parse(JSON.stringify(this.existingData));
        const parentDonationDetail = this._parentDonationDetail;
        const newColumn = [];

        let donationColumns = this.donationColumns;
        let toDisplayTableColumns = [];
        let toAddAction = false;

        if (this.isDonationEndowmentPaymentTab) {
            toDisplayTableColumns = ['Instalment Number', 'Total Amount', 'Instalment Date', 'Stage'];
            toAddAction = true;

        } else if (this.isDonationPledgePaymentTab) {
            if (parentDonationDetail.Payment_Type__c.value === 'One-Off Payment') {
                toDisplayTableColumns = ['Total Amount', 'To Designation', 'Stage'];
            }

            if (parentDonationDetail.Payment_Type__c.value === 'Payment Plan') {
                toDisplayTableColumns = ['Instalment Number', 'Total Amount', 'Instalment Date', 'To Designation', 'Stage'];

                if (!parentDonationDetail.Has_Designation_Split__c.value) {
                    let newArr = [];
                    donationColumns.forEach((obj) => {
                        if (obj.label != 'To Designation') {
                            newArr.push(obj);
                        }
                    });

                    donationColumns = newArr;
                }
            }

            toAddAction = true;
        }


        toDisplayTableColumns.forEach((name) => {
            donationColumns.forEach((obj) => {
                if (obj.label === name) {
                    newColumn.push(obj);
                }
            })
        });

        if (toAddAction) {
            newColumn.push(donationColumns[donationColumns.length - 1]);
        }

        this.columns = newColumn;

        if (existingData && existingData.length) {
            this.isEdit = true;
            const newData = [];

            existingData.forEach((obj, key) => {
                const data = {
                    rowId: `row-${key}`,
                    fieldId: obj.Id,
                    instalmentNumber: key + 1,
                    Stage__c: obj.Stage__c || '',
                    Total_Amount__c: obj.Total_Amount__c || '',
                    Instalment_Date__c: obj.Instalment_Date__c || '',
                    parentId: obj.Donation_Parent__c || '',
                    To_Designation__c: obj.To_Designation__c || '',
                    Donation_Comment__c: obj.Donation_Comment__c || '',
                    Payment_Type__c: obj.Payment_Type__c || '',
                    deleteDisabled: true,
                    editable: true,
                }

                newData.push(data);
            })

            this.modalHeader = "Edit Donation";

            this.data = newData;
        }
    }

    handleChange(e) {
        const name = e.target.dataset.name;
        this.toUpsert[name] = e.target.value;
    }

    handleGenerateRow() {
        const toUpsert = this.toUpsert;

        if (toUpsert.numberInstalments && toUpsert.totalAmount) {
            const totalAmount = parseInt(toUpsert.totalAmount);
            const numberInstalments = parseInt(toUpsert.numberInstalments);
            const eachRowTotalAmount = parseFloat((totalAmount / numberInstalments).toFixed(2));

            let countGenerateRow = 0;
            let data = JSON.parse(JSON.stringify(this.data));

            let lastRowTotalAmount = totalAmount - (eachRowTotalAmount * (numberInstalments - 1));

            if (data.length) {
                data.forEach((obj, key) => {
                    let rowAmount = eachRowTotalAmount;

                    if (key === (numberInstalments - 1)) {
                        rowAmount = lastRowTotalAmount;
                    }

                    obj.Total_Amount__c =  rowAmount;
                })
            }

            if (data.length < numberInstalments) {
                countGenerateRow = (numberInstalments - data.length);
            } else if (data.length > numberInstalments) {
                data = data.slice(0, numberInstalments);
            }

            this.data = data;
            this.draftValues = [];

            if (countGenerateRow) {
                const data = JSON.parse(JSON.stringify(this.data));
                const newRow = [];

                for (let x = 0; x < countGenerateRow; x ++) {
                    let rowAmount = eachRowTotalAmount;

                    if ((x + 1) === countGenerateRow) {
                        rowAmount = lastRowTotalAmount;
                    }

                    const row = this.generateNewRow(rowAmount, data.length + x);
                    newRow.push(row);
                }

                this.data = [...data, ...newRow];
            }
        }
    }

    handleAddRow() {
        const data = JSON.parse(JSON.stringify(this.data));
        const newRow = this.generateNewRow();

        let newData = [...data, ...[newRow]];
        newData.forEach((obj, key) => {
            obj.rowId =  `row-${key}`;
            obj.instalmentNumber =  key + 1;
        });

        this.data = newData;
        this.draftValues = [];
    }

    generateNewRow(eachRowTotalAmount = '', rowCount = 0) {
        return {
            rowId: `row-${rowCount}`,
            instalmentNumber: rowCount + 1,
            Total_Amount__c: eachRowTotalAmount,
            Instalment_Date__c: '',
            To_Designation__c: '',
            Stage__c: 'Accepted',
            deleteDisabled: false,
            parentId: this.recordId,
            editable: true,
        };
    }

    handleRowAction(event) {
        const detail = event.detail;

        if (detail.action.name === 'delete') {
            const data = JSON.parse(JSON.stringify(this.data));

            const newdata = [];

            for (let field in data) {
                if (String(data[field].rowId) !== String(detail.row.rowId)) {
                    newdata.push(data[field]);
                }
            }

            newdata.forEach((obj, key) => {
                obj.rowId =  `row-${key}`;
                obj.instalmentNumber =  key + 1;
            });

            this.data = newdata;
        }

    }

    //updates draft values if table cell is changed
    handleCellChange(event){
        this.updateDraftToDataValues(event.detail.draftValues[0]);
    }

    //updates look up if table cell is changed
    handleLookupSelect(event){
        let eventValue = event.detail.value;
        let draftId = event.detail.draftId;

        this.updateDraftToDataValues({
            Id: draftId,
            To_Designation__c: eventValue || ''
        });
    }

    //updates draftValues
    updateDraftToDataValues(updateItem) {
        let data = JSON.parse(JSON.stringify(this.data));

        const rowNumber = updateItem.Id.replace('row-','');
        data.forEach((item, key) => {
            if (key === parseInt(rowNumber)) {
                for (let field in updateItem) {
                    if (field !== 'Id') {
                        item[field] = updateItem[field];
                    }
                }
            }
        });

        this.data = data;
        this.draftValues = [];
    }

    //updates data and drafts to edited values
    //if custom picklist is changed
    handlePicklistSelect(e){
        this.handleCustomColumnEdit(
            e.detail.draftId,
            'Stage__c',
            e.detail.value,
            'customPicklistClass'
        );
    }

    //updates data and drafts to edited values
    handleCustomColumnEdit(rowId, prop, value, classProp){
        const data = JSON.parse(JSON.stringify(this.data));
        this.data = data.map(data => {
            let updatedItem = {...data};
            if(data.Id == rowId){
                updatedItem[prop] = value;
                updatedItem[classProp] = 'slds-cell-edit slds-is-edited';
            }
            return updatedItem;
        });

        this.updateDraftToDataValues({
            Id: rowId,
            [prop]:value
        });
    }

    handleCloseModal() {
        this.dispatchEvent(
            new CustomEvent('closemodal')
        );
    }

    handleSave() {
        setTimeout((e) => {
            const logger = this.template.querySelector("c-logger");

            this.saveButtonDisabled = true;
            this.isErrorMessage = false;

            const hasError = this.rowvalidation();
            const data = JSON.parse(JSON.stringify(this.data));
            const parentDonationDetail = this._parentDonationDetail;
            const toUpsertList = [];

            let totalRowAmount = 0;

            data.forEach((obj) => {
                const toUpsertRecord = {
                    Total_Amount__c: obj.Total_Amount__c,
                    Stage__c: obj.Stage__c,
                    Donation_Parent__c: obj.parentId,
                    Contact__c: parentDonationDetail.Contact__c ? parentDonationDetail.Contact__c.value : "",
                    Account__c: parentDonationDetail.Account__c ? parentDonationDetail.Account__c.value : "",
                    From_Designation__c: parentDonationDetail.From_Designation__c ? parentDonationDetail.From_Designation__c.value : "",
                    Is_Anonymous_Donation__c: parentDonationDetail.Is_Anonymous_Donation__c ? parentDonationDetail.Is_Anonymous_Donation__c.value : "",
                };

                if (this.isDonationEndowmentPaymentTab) {
                    toUpsertRecord.Instalment_Date__c = obj.Instalment_Date__c;
                    toUpsertRecord.To_Designation__c = parentDonationDetail.To_Designation__c ? parentDonationDetail.To_Designation__c.value : "";
                } else if (this.isDonationPledgePaymentTab) {
                    let addToDesignation = true;
                    if (parentDonationDetail.Payment_Type__c.value === 'Payment Plan') {
                        toUpsertRecord.Instalment_Date__c = obj.Instalment_Date__c;

                        if (!parentDonationDetail.Has_Designation_Split__c.value) {
                            addToDesignation = false;
                        }
                    }

                    if (addToDesignation) {
                        toUpsertRecord.To_Designation__c = obj.To_Designation__c;
                    }

                    toUpsertRecord.Donation_Comment__c = parentDonationDetail.Donation_Comment__c.value;
                    toUpsertRecord.Payment_Type__c = parentDonationDetail.Payment_Type__c.value;
                }

                totalRowAmount = parseFloat(obj.Total_Amount__c) + totalRowAmount;

                if (obj.fieldId) {
                    toUpsertRecord.Id = obj.fieldId;
                }

                toUpsertList.push(toUpsertRecord);
            });

            if (this.toUpsert.totalAmount && totalRowAmount >= parseFloat(this.toUpsert.totalAmount)) {
                if (!hasError && toUpsertList.length) {
                    let recordType = '';

                    if (this.isDonationEndowmentPaymentTab) {
                        recordType = 'Endowment Instalment';
                    } else if (this.isDonationPledgePaymentTab) {
                        if (parentDonationDetail.Payment_Type__c.value === 'One-Off Payment') {
                            recordType = 'Pledge Designation Split';
                        }

                        if (parentDonationDetail.Payment_Type__c.value === 'Payment Plan') {
                            recordType = 'Pledge Instalment';
                        }
                    }

                    upsertDonationChild({donationsList: toUpsertList, recordType: recordType})
                        .then((response) => {
                            if (this.isNew) {
                                this.generateToast('Success.', 'Record successfully created!','success');
                            } else {
                                this.generateToast('Success.', 'Record successfully updated!','success');
                            }
                            this.dispatchEvent(
                                new CustomEvent('reloadmaintable')
                            );

                            this.handleCloseModal();
                        })
                        .catch((e) => {
                            if (logger) {
                                logger.error(
                                    "Exception caught in apex method upsertDonationChild in LWC childDonationModal: ",
                                    JSON.stringify(error)
                                );
                            }

                            this.saveButtonDisabled = false;
                        })
                } else {
                    this.saveButtonDisabled = false;
                }

                this.draftValues = [];
            } else {
                this.isErrorMessage = true;
                this.saveButtonDisabled = false;
            }
        }, 500, this);
    }

    rowvalidation() {
        const data = JSON.parse(JSON.stringify(this.data));
        const parentDonationDetail = this._parentDonationDetail;
        let rowsValidation = {};
        let hasError = false;

        data.map(obj => {
            let fieldNames = [];
            let messages = [];
            let validateColumns = [];

            if (this.isDonationEndowmentPaymentTab) {
                validateColumns = ['Total_Amount__c', 'Instalment_Date__c'];
            } else if (this.isDonationPledgePaymentTab) {
                if (parentDonationDetail.Payment_Type__c.value === 'One-Off Payment') {
                    validateColumns = ['Total_Amount__c', 'To_Designation__c'];
                }

                if (parentDonationDetail.Payment_Type__c.value === 'Payment Plan') {
                    validateColumns = ['Total_Amount__c', 'Instalment_Date__c', 'To_Designation__c'];

                    if (!parentDonationDetail.Has_Designation_Split__c.value) {
                        validateColumns = ['Total_Amount__c', 'Instalment_Date__c'];
                    }
                }
            }

            if (!obj.Total_Amount__c && validateColumns.indexOf('Total_Amount__c') >= 0) {
                messages.push('Total Amount is a mandatory field');
            }

            if (!obj.Instalment_Date__c && validateColumns.indexOf('Instalment_Date__c') >= 0) {
                messages.push('Instalment Date is a mandatory field');
            }

            if (!obj.To_Designation__c && validateColumns.indexOf('To_Designation__c') >= 0) {
                messages.push('To Designation is a mandatory field');
            }

            if (messages.length > 0 ) {
                rowsValidation[obj.rowId] = {
                    title: 'We found an error/s.',
                    messages: ['Please enter valid value for the ff. fields', ...messages, ...fieldNames],
                    fieldNames : fieldNames
                };

                hasError = true;
            }
        });

        this.errors = {
            rows: rowsValidation
        };

        this.disabledSave = Object.keys(rowsValidation).length > 0 ? true : false;

        return hasError;
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