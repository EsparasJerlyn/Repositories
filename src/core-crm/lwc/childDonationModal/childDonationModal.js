/**
 * @description Lightning Web Component for Custom Donation Payment Tab Upsert Record.
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
import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import upsertDonationChildEndownmentInstalment from "@salesforce/apex/ChildDonationModalCtrl.upsertDonationChildEndownmentInstalment";

export default class ChildDonationModal extends LightningElement {
    @api recordId;
    @api pageUniqueParam;
    @api existingData;
    @api title;

    errors;
    modalHeader = "New Donation";
    isErrorMessage = false;
    title = '';

    @track data = [];
    @track toUpsert = {
        totalAmount: '',
        numberInstalments: ''
    };
    @track draftValues = [];
    @track columns = [
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
            sortable: true,
            type: 'currency',
        },
        {
            label: 'Instalment Date',
            fieldName: 'Instalment_Date__c',
            apiFieldName:'Instalment_Date__c',
            editable: true,
            sortable: true,
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

    get saveBtnDisabled() {
        return this.saveButtonDisabled || !this.data.length ? true : false;
    }

    get isNew() {
        return this.existingData.length ? false : true;
    }

    async connectedCallback() {
        const existingData = JSON.parse(JSON.stringify(this.existingData));

        if (existingData && existingData.length) {
            const newData = [];

            if (this.pageUniqueParam === 'Donation Endowment Payment tab') {
                existingData.forEach((obj, key) => {
                    const data = {
                        rowId: `row-${key}`,
                        fieldId: obj.Id,
                        instalmentNumber: key + 1,
                        Stage__c: obj.Stage__c,
                        Total_Amount__c: obj.Total_Amount__c,
                        Instalment_Date__c: obj.Instalment_Date__c,
                        parentId: obj.Donation_Parent__c,
                        deleteDisabled: true,
                    }

                    newData.push(data);
                })

                this.modalHeader = "Edit Donation";
            }

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
            instalmentNumber: rowCount,
            Total_Amount__c: eachRowTotalAmount,
            Instalment_Date__c: '',
            Stage__c: 'Accepted',
            deleteDisabled: false,
            parentId: this.recordId,
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
                    Instalment_Date__c: obj.Instalment_Date__c,
                    Stage__c: obj.Stage__c,
                    Donation_Parent__c: obj.parentId,
                    Contact__c: parentDonationDetail.Contact__c ? parentDonationDetail.Contact__c.value : "",
                    Account__c: parentDonationDetail.Account__c ? parentDonationDetail.Account__c.value : "",
                    From_Designation__c: parentDonationDetail.From_Designation__c ? parentDonationDetail.From_Designation__c.value : "",
                    To_Designation__c: parentDonationDetail.To_Designation__c ? parentDonationDetail.To_Designation__c.value : "",
                    Is_Anonymous_Donation__c: parentDonationDetail.Is_Anonymous_Donation__c ? parentDonationDetail.Is_Anonymous_Donation__c.value : "",
                };

                totalRowAmount = parseFloat(obj.Total_Amount__c) + totalRowAmount;

                if (obj.fieldId) {
                    toUpsertRecord.Id = obj.fieldId;
                }

                toUpsertList.push(toUpsertRecord);
            });

            if (this.toUpsert.totalAmount && totalRowAmount >= parseFloat(this.toUpsert.totalAmount)) {
                if (!hasError && toUpsertList.length) {
                    upsertDonationChildEndownmentInstalment({donationsList: toUpsertList})
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
                                    "Exception caught in apex method upsertDonationChildEndownmentInstalment in LWC childDonationModal: ",
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

        let rowsValidation = {};
        let hasError = false;

        data.map(obj => {
            let fieldNames = [];
            let messages = [];
            if (!obj.Total_Amount__c) {
                messages.push('Participating Group is a mandatory field');
            }

            if (!obj.Instalment_Date__c) {
                messages.push('Instalment Date is a mandatory field');
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