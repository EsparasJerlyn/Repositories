/**
 * @description Lightning Web Component for List Members in List container.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                           | Date                  | JIRA                 | Change Summary                                                         |
      |-------------------------------------|-----------------------|----------------------|------------------------------------------------------------------------|
      | neil.s.h.lesidan                    | December 20, 2023     | DEPP-6963            | Created file                                                           |
      | jerlyn.esparas                      | January 10, 2024      | DEPP-6965            |                                                                        |
      | kenneth.f.alsay                     | January 15, 2024      | DEPP-6964            | Updated handleSave for saving status on datatable edit                 |
      | neil.s.h.lesidan                    | January 24, 2024      | DEPP-7005            | Dynamic Table structure                                                |
      | neil.s.h.lesidan                    | Feb 2, 2024           | DEPP-7004            | Save Validation in Contact and List Contributor for Import List        |
      |                                     |                       |                      |                                                                        |
 */
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from 'lightning/uiRecordApi';
import { loadStyle } from "lightning/platformResourceLoader";

import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';

export default class CustomHeaderDatatable extends LightningElement {
    @api recordId;
    @api columns;
    @api isLoading;
    @api objectApiName;
    @api isTableWithValidation;

    @track _draftValues = [];
    @track dataListRecord;
    @track _recordData;
    @track _recordDataToAdd;
    @track _recordDataToAddColumn;
    @track recordDataCopy;

    sortedBy;
    rowsValidationErrors;
    disableSaveListMember = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    selectedRows =[];

    actions = [
        { label: 'Delete', name: 'delete' }
    ];

    @api
    get recordData() {
        return this._recordData;
    }
    set recordData(value) {
        this.recordDataCopy = value;
        this._recordData = value;
    }

    @api
    get draftValues() {
        return this._draftValues;
    }
    set draftValues(value) {
        this._draftValues = value;
    }

    @api
    get recordDataToAdd() {
        return this._recordDataToAdd;
    }
    set recordDataToAdd(value) {
        let newColumns = [];
        this.columns.forEach((key, index)  => {
            newColumns.push(key);
        })

        newColumns.push({ type: "action", typeAttributes: { rowActions: this.actions } });
        const newRecord = [...this._recordData, ...value];

        this._recordDataToAddColumn = JSON.parse(JSON.stringify(newColumns));
        let recordDataToAdd = [];

        if (value && value.length) {
            recordDataToAdd = this.rowValidation(JSON.parse(JSON.stringify(newRecord)));
        }

        this._recordDataToAdd = recordDataToAdd;
    }

    connectedCallback(){
        Promise.all([
            loadStyle(this, customDataTableStyle)
        ]).then(() => {
        });
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent('handleupdatestatus', {
            detail: this._draftValues
        }));
    }

    handleCancel(){
        this.recordDataCopy = this.recordDataCopy.map(data =>{
            return this.recordData.find(orig => orig.Id == data.Id);
        });

        this._draftValues = [];
    }

    //updates draft values if table cell is changed
    handleCellChange(event){
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    //updates draftValues list
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this._draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this._draftValues = [...copyDraftValues];
        } else {
            this._draftValues = [...copyDraftValues, updateItem];
        }

    }

    //updates data and drafts to edited values
    //if custom picklist is changed
    handlePicklistSelect(event){
        this.handleCustomColumnEdit(
            event.detail.draftId,
            'List_Member_Status__c',
            event.detail.value,
            'customPicklistClass'
        );
    }

    // handle rows selected and stored in selectedRows
    handleSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        this.dispatchEvent(new CustomEvent('selectedrows', {
            detail: selectedRows
        }));
    }

    //updates data and drafts to edited values
    handleCustomColumnEdit(rowId, prop, value, classProp){
        const recordDataCopy = JSON.parse(JSON.stringify(this.recordDataCopy));
        this.recordDataCopy = recordDataCopy.map(data => {
            let updatedItem = {...data};
            if(data.Id == rowId){
                updatedItem[prop] = value;
                updatedItem[classProp] = 'slds-cell-edit slds-is-edited';
            }
            return updatedItem;
        });
        this.updateDraftValues({
            Id:rowId,
            [prop]:value
        });
    }

    //Sorts column for datatable
    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.recordDataCopy));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });

        this.recordDataCopy = parseData;
    }

    handleRowAction(event) {
        const recordId = event.detail.row.Id;

        if (event.detail.action.name == "delete") {
            const record = this._recordDataToAdd;
            let unableToDelete = false;
            const newRecord = record.filter(record=> {
                if (record.Id === recordId && record.toAddListRecord) {
                    return record.Id != recordId;
                } else if (record.Id === recordId && !record.toAddListRecord) {
                    unableToDelete = true;
                }

                return true;
            });

            if (unableToDelete) {
                this.generateToast('Warning', 'This record cannot be deleted as it is associated with the current record.', 'warning');
            }

            this._recordDataToAdd = this.rowValidation(newRecord);
        }
    }

    rowValidation(record) {
        let rowsValidation = {};
        let newData = [];
        let disableSaveListMember = false;
        let hasToAddListRecord = false;

        record.map(listMember => {
            let fieldNames = [];

            let messages = [];

            if (listMember.isExistingContact) {
                messages = ['Duplicate Contact ID', ...fieldNames];
            }

            if (fieldNames.length > 0 || messages.length > 0 ) {
                rowsValidation[listMember.Id] = {
                    title: 'We found an error/s.',
                    messages: ['Please enter valid value for the ff. fields', ...messages, ...fieldNames],
                    fieldNames : fieldNames
                };

                disableSaveListMember = true;
            }

            if (listMember.toAddListRecord) {
                hasToAddListRecord = true;
            }

            newData.push(listMember);
        });

        this.rowsValidationErrors = {
            rows: rowsValidation
        };

        this.disableSaveListMember = hasToAddListRecord ? disableSaveListMember : true;

        return newData;
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

    handleSaveExistingListMember() {
        this.dispatchEvent(new CustomEvent('handlesaveexistinglistmember', {
            detail: this._recordDataToAdd
        }));
    }

    handleCancelAddExistingListMember() {
        this.dispatchEvent(new CustomEvent('handlecanceladdexistinglistmember'));
    }
}