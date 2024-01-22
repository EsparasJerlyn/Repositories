/**
 * @description Lightning Web Component for List Members in List container.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                           | Date                  | JIRA                 | Change Summary               |
      |-------------------------------------|-----------------------|----------------------|------------------------------|
      | neil.s.h.lesidan@accenture.com      | December 20, 2023     | DEPP-6963            | Created file                 |
      | jerlyn.esparas                      | January 10, 2024      | DEPP-6965            |                              |
      | nicole.genon                        | January 18, 2024      | DEPP-6953            | Added wiredEngageList
 */
import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord  } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
      
import LIST_MEMBER from '@salesforce/schema/List_Member__c';
import LIST_MEMBER_STATUS from '@salesforce/schema/List_Member__c.List_Member_Status__c';
import LIST_MEMBER_CONTACT from '@salesforce/schema/List_Member__c.List_Member__c';
import LIST_MEMBER_ACTIVITY_NAME from '@salesforce/schema/List_Member__c.Activity_Name__c';
import LIST_MEMBER_ACTIVITY_START_DATE from '@salesforce/schema/List_Member__c.Activity_Start_Date__c';
import LIST_MEMBER_ACTIVITY_END_DATE from '@salesforce/schema/List_Member__c.Activity_End_Date__c';
import LIST_MEMBER_ACTIVITY_STATUS from '@salesforce/schema/List_Member__c.Activity_Status__c';
import LIST_STAGE from '@salesforce/schema/List__c.Stage__c';
import LIST_COLUMN_1 from '@salesforce/schema/List__c.Column_1__c';
import LIST_COLUMN_2 from '@salesforce/schema/List__c.Column_2__c';
import LIST_COLUMN_3 from '@salesforce/schema/List__c.Column_3__c';
import LIST_COLUMN_4 from '@salesforce/schema/List__c.Column_4__c';
import LIST_COLUMN_5 from '@salesforce/schema/List__c.Column_5__c';
import LIST_COLUMN_6 from '@salesforce/schema/List__c.Column_6__c';
import LIST_COLUMN_7 from '@salesforce/schema/List__c.Column_7__c';
import LIST_COLUMN_8 from '@salesforce/schema/List__c.Column_8__c';
import LIST_COLUMN_9 from '@salesforce/schema/List__c.Column_9__c';
import LIST_COLUMN_10 from '@salesforce/schema/List__c.Column_10__c';
import ENGAGE_STAGE from '@salesforce/schema/Engagement_Opportunity__c.Stage__c';
      
import getListMembers from '@salesforce/apex/CustomHeaderDatatableCtrl.getListMembers';
import getEngagementOpportunityListId from '@salesforce/apex/CustomHeaderDatatableCtrl.getEngagementOpportunityListId';
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';
import { loadStyle } from "lightning/platformResourceLoader";
      
const ROW_WIDTH = 180;
      
export default class CustomHeaderDatatable extends LightningElement {
  @api recordId;
  @api objectApiName;
  @track dataListRecord;
  @track dataRecord;
  @track dataRecordCopy;
  @track columnsCopy = [];
  @track qualifiedEngageRecords = [];
  @track columns = [
      { label: 'List Member Reference', fieldName: 'Name', type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH },
      { label: 'List Contributor', fieldName: 'List_Contributor__c', type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH },
      { label: 'List Member Status', fieldName: 'List_Member_Status__c', type: 'customPicklistColumn',
          wrapText: true,
          sortable: true,
          typeAttributes: {
          tableObjectType: 'List_Member__c',
            rowDraftId: { fieldName: 'Id' },
            picklistValue: { fieldName: 'List_Member_Status__c' },
            picklistFieldName: 'List_Member_Status__c',
            editable: true
          },
            cellAttributes: {
                class: { fieldName: 'customPicklistClass' }
            }, "initialWidth": ROW_WIDTH
        }
    ];
    @track engagementOpportunityColumns = [
        { label: 'Activity Name', fieldName: 'Activity_Name__c', type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH },
        { label: 'Activity Start Date', fieldName: 'Activity_Start_Date__c', type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH },
        { label: 'Activity End Date', fieldName: 'Activity_End_Date__c', type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH },
        { label: 'Activity Status', fieldName: 'Activity_Status__c', type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH }
    ];


  @track draftValues = [];
  @track engagementOpportunityListId = this.recordId;

  isLoading = true;
  sortedBy;
  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  selectedRows =[];

  listMemberColumns = [LIST_STAGE,LIST_COLUMN_1, LIST_COLUMN_2, LIST_COLUMN_3, LIST_COLUMN_4, LIST_COLUMN_5, LIST_COLUMN_6,
      LIST_COLUMN_7, LIST_COLUMN_8, LIST_COLUMN_9, LIST_COLUMN_10];
  engageOppfields = [ENGAGE_STAGE];
      
  @wire(getRecord, { recordId: "$recordId", fields: "$engageOppfields" })
  wiredEngageList(responseData) {
      const { data, error } = responseData;

      this.dataListRecord = responseData;
      if (data) {
        if(this.objectApiName == 'Engagement_Opportunity__c'){
            const engageFields = data.fields;
            const engageListColumns = [
                {column: 'Contact', fieldName: 'ContactName'}
            ];

            const toAddEngageColumns = [];
            engageListColumns.forEach((key, index) => {
                toAddEngageColumns.push(
                    { label: key.column, fieldName: key.fieldName, type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH }
                );
            });

            let columns = JSON.parse(JSON.stringify(this.columnsCopy));

            if (!columns.length) {
                columns = JSON.parse(JSON.stringify(this.engagementOpportunityColumns));
                this.columnsCopy = this.engagementOpportunityColumns;
            }

            const newEngageColumns = [
                ...toAddEngageColumns,
                ...columns.slice(0)
            ];

            this.columns = newEngageColumns;

            getEngagementOpportunityListId({ engagementOpportunityId: this.recordId })
            .then((response) => {
                
                this.engagementOpportunityListId = response;
                this.isLoading = false;

                getListMembers({ listId: response })
                .then((response) => {
                    response.forEach(obj => {
                        if (obj.List_Member__r && obj.List_Member__r.Name && obj.List_Member_Status__c == 'Qualified') {
                            this.qualifiedEngageRecords.push(obj);
                            obj.ContactName = obj.List_Member__r.Name;
                        }
                    });

                    this.dataRecord = this.qualifiedEngageRecords;
                    this.dataRecordCopy = this.qualifiedEngageRecords;
    
                    this.isLoading = false;
                })
            })

        }
      }

    }
      
  @wire(getRecord, { recordId: "$recordId", fields: "$listMemberColumns" })
  wiredList(responseData) {
      const { data, error } = responseData;

      this.dataListRecord = responseData;
      if (data) {
        if(this.objectApiName == 'List__c'){
            const fields = data.fields;
            const listColumns = [
                {column: 'Column_1__c', fieldName: 'listMemberName'},
                {column: 'Column_2__c', fieldName: 'Email__c'},
                {column: 'Column_3__c', fieldName: 'Mobile__c'},
                {column: 'Column_4__c', fieldName: 'Column_1_Value__c'},
                {column: 'Column_5__c', fieldName: 'Column_2_Value__c'},
                {column: 'Column_6__c', fieldName: 'Column_3_Value__c'},
                {column: 'Column_7__c', fieldName: 'Column_4_Value__c'},
                {column: 'Column_8__c', fieldName: 'Column_5_Value__c'},
                {column: 'Column_9__c', fieldName: 'Column_6_Value__c'},
                {column: 'Column_10__c', fieldName: 'Column_7_Value__c'}
            ];

            const toAddColumns = [];
            listColumns.forEach((key, index) => {
                let toShowColumn = false;

                if (index > 2 && fields[key.column] && fields[key.column].value) {
                    toShowColumn = true;
                } else {
                    toShowColumn = true;
                }

                if (toShowColumn) {
                    toAddColumns.push(
                        { label: fields[key.column].value, fieldName: key.fieldName, type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH }
                    );
                }
            });

            let columns = JSON.parse(JSON.stringify(this.columnsCopy));

            if (!columns.length) {
                columns = JSON.parse(JSON.stringify(this.columns));
                this.columnsCopy = this.columns;
            }

            const newColumns = [
                ...columns.slice(0, 1),
                ...toAddColumns,
                ...columns.slice(1)
            ];

            newColumns.forEach((key, index) => {
                if (key.fieldName === 'List_Member_Status__c' &&
                    fields.Stage__c &&
                    fields.Stage__c.value &&
                    fields.Stage__c.value === 'Closed')
                {
                    key.type = 'text';
                }
            });

            this.columns = newColumns;

            getListMembers({ listId: this.recordId })
                .then((response) => {
                    response.forEach(obj => {
                        if (obj.List_Member__r && obj.List_Member__r.Name) {
                            obj.listMemberName = obj.List_Member__r.Name;
                        }
                    });

                    this.dataRecord = response;
                    this.dataRecordCopy = response;

                    const eventlistdatahandler = new CustomEvent("listdatahandler", {
                        detail: response
                    });
                    this.dispatchEvent(eventlistdatahandler);

                    
                    const columnsList = new CustomEvent("listdatacolumns", {
                        detail: newColumns
                    });
                    this.dispatchEvent(columnsList);

                    this.isLoading = false;
                })
        }
      }
  }
      
  connectedCallback(){
      Promise.all([
          loadStyle(this, customDataTableStyle)
      ]).then(() => {
      });
      // if(this.objectApiName == 'List__c'){
        //     this.listMemberColumns = this.listColumns;
        // }else if(this.objectApiName == 'Engagement_Opportunity__c'){
        //     this.listMemberColumns = this.engagementOpportunityColumns;
        // }
  }

  handleSave(e) {
      this.dispatchEvent(new CustomEvent('tablesave'));
      refreshApex(this.dataListRecord);
      this.draftValues = [];
  }

  //cancels datatabel edits
  handleCancel(){
      this.dataRecordCopy = this.dataRecordCopy.map(data =>{
          return this.dataRecord.find(orig => orig.Id == data.Id);
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
      const dataRecordCopy = JSON.parse(JSON.stringify(this.dataRecordCopy));
      this.dataRecordCopy = dataRecordCopy.map(data => {
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
      let parseData = JSON.parse(JSON.stringify(this.dataRecordCopy));

      let keyValue = (a) => {
          return a[fieldname];
      };

      let isReverse = direction === 'asc' ? 1: -1;

      parseData.sort((x, y) => {
          x = keyValue(x) ? keyValue(x) : '';
          y = keyValue(y) ? keyValue(y) : '';
          return isReverse * ((x > y) - (y > x));
      });

      this.dataRecordCopy = parseData;
  }
}