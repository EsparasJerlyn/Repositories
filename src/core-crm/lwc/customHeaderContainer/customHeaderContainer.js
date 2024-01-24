/**
 * @description Lightning Web Component for custom parent container.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                 |
      | neil.s.h.lesidan          | January 24, 2024      | DEPP-7005            |                              |
      |                           |                       |                      |                              |
 */
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord  } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import LIST_MEMBER_STATUS from '@salesforce/schema/List_Member__c.List_Member_Status__c';
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

import getListMembers from '@salesforce/apex/CustomHeaderContainerCtrl.getListMembers';

const ROW_WIDTH = 180;

export default class CustomHeaderContainer extends LightningElement {
     @api recordId;
     @api objectApiName;

     @track columnsName;
     @track columnsData;
     @track listId;
     @track selectedRows;
     @track recordData = [];
     @track tableColumnsCopy = [];
     @track tableColumns = [];
     @track listColumns = [
          { label: 'List Member Reference', fieldName: 'Name', apiFieldName:'Name', type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH },
          { label: 'List Contributor', fieldName: 'List_Contributor__c', apiFieldName:'List_Contributor__c', type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH },
          { label: 'List Member Status', fieldName: 'List_Member_Status__c', apiFieldName:'List_Member_Status__c', type: 'customPicklistColumn',
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

     listFields = [LIST_STAGE,LIST_COLUMN_1, LIST_COLUMN_2, LIST_COLUMN_3, LIST_COLUMN_4, LIST_COLUMN_5, LIST_COLUMN_6,
          LIST_COLUMN_7, LIST_COLUMN_8, LIST_COLUMN_9, LIST_COLUMN_10];

     engagementOpportunityFields = [LIST_STAGE,LIST_COLUMN_1, LIST_COLUMN_2, LIST_COLUMN_3, LIST_COLUMN_4, LIST_COLUMN_5, LIST_COLUMN_6,
          LIST_COLUMN_7, LIST_COLUMN_8, LIST_COLUMN_9, LIST_COLUMN_10];

     fieldsToColumns = [];
     isTableLoading = true;
     listStageValue;

     @wire(getRecord, { recordId: "$recordId", fields: "$fieldsToColumns" })
     wiredList(responseData) {
          const { data, error } = responseData;

          this.dataListRecord = responseData;
          if (data) {
               if (this.objectApiName === 'List__c') {
                    const fields = data.fields;
                    this.listStageValue = fields.Stage__c.value;

                    const listColumns = [
                         {column: 'Column_1__c', fieldName: 'ListMemberName'},
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

                         if (fields[key.column] && fields[key.column].value) {
                              let fieldName = fields[key.column].value;

                              if (fieldName) {
                                   fieldName = fieldName.replace(/\s/g, '').toLowerCase();

                                   if (fieldName === 'contactid') {
                                        key.fieldName = 'List_Member__c';
                                   }
                              }

                              toShowColumn = true;
                         }

                         if (toShowColumn) {
                              toAddColumns.push(
                                   { label: fields[key.column].value, fieldName: key.fieldName, apiFieldName: key.column, type: 'text', editable: false, sortable: true, "initialWidth": ROW_WIDTH }
                              );
                         }
                    });

                    let columns = JSON.parse(JSON.stringify(this.tableColumnsCopy));

                    if (!columns.length) {
                         columns = JSON.parse(JSON.stringify(this.tableColumns));
                         this.tableColumnsCopy = this.tableColumns;
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

                    this.tableColumns = newColumns;
               } else if (this.objectApiName === 'Engagement_Opportunity__c') {

               }

               this.fetchListMembers();
          }
     }

     connectedCallback() {
          if (this.objectApiName === 'List__c') {
               this.fieldsToColumns = this.listFields;
               this.tableColumns = this.listColumns;
               this.listId = this.recordId;
          } else if (this.objectApiName === 'Engagement_Opportunity__c') {
               this.fieldsToColumns = this.engagementOpportunityFields;
          }

     }

     reloadListMembersTable(event) {
          if (event.detail) {
               this.fetchListMembers();
          }
     }

     fetchListMembers() {
          getListMembers({ listId: this.recordId })
          .then((response) => {
               response.forEach(obj => {
                    if (obj.List_Member__r) {
                         obj.List_Member__c = obj.List_Member__r.Id;
                         obj.ListMemberName = obj.List_Member__r.Name;
                    }
               });

               this.recordData = response;
               this.isTableLoading = false;
          })
     }

     selectedRowsHandler(event) {
          this.selectedRows = event.detail;
     }

     // sets the list member column data
     listDataHandler(event){
          this.columnsData = event.detail;
          this.columnsName = event.detail;
     }

     // sets the list header
     newColumnsList(event){
     }
}