/**
 * @description Lightning Web Component for List Members in List container.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                           | Date                  | JIRA                 | Change Summary               |
      |-------------------------------------|-----------------------|----------------------|------------------------------|
      | neil.s.h.lesidan@accenture.com      | December 20, 2023     | DEPP-6963            | Created file                 |
      |                                     |                       |                      |                              |
 */
import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';
import { loadStyle } from "lightning/platformResourceLoader";

export default class CustomHeaderDatatable extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isLoading;
    @api columns;

    @track draftValues = [];
    @track dataListRecord;
    @track _recordData;
    @track recordDataCopy;

    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    selectedRows =[];

    @api
    get recordData() {
        return this._recordData;
    }
    set recordData(value) {
        this.recordDataCopy = value;
        this._recordData = value;
    }

    connectedCallback(){
        Promise.all([
            loadStyle(this, customDataTableStyle)
        ]).then(() => {
        });
    }

    handleSave(e) {
        this.dispatchEvent(new CustomEvent('tablesave'));
        refreshApex(this.dataListRecord);
        this.draftValues = [];
    }

    //cancels datatabel edits
    handleCancel(){
        this.recordDataCopy = this.recordDataCopy.map(data =>{
            return this.recordData.find(orig => orig.Id == data.Id);
        });

        this.draftValues = [];
    }

    //updates draft values if table cell is changed
    handleCellChange(event){
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    //updates draftValues list
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
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

        this.selectedRows = JSON.parse(JSON.stringify(selectedRows));
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
}