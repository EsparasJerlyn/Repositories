/**
 * @description Lightning Web Component for custom parent container.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                         |
      |---------------------------|-----------------------|----------------------|----------------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                           |
      | jerlyn.esparas@qut.edu.au | January  10, 2024     | DEPP-6965            |                                        |
      | kenneth.f.alsay           | January 15, 2024      | DEPP-6964            | Added handleRefresh                    |
      | neil.s.h.lesidan          | January 24, 2024      | DEPP-7005            | Generate table structure               |
      |                           |                       |                      | Fetch List Member record from List     |
      |                           |                       |                      | Fetch List Member record from List     |
      |                           |                       |                      | CSV List Member record bulk save       |
      |                           |                       |                      |                                        |
      | eugene.andrew.abuan       | February 28, 2034     | DEPP-7992            | Added checking if userId == ownerId    |

 */
import { LightningElement, api, wire, track } from "lwc";
import { getRecord  } from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import USER_ID from "@salesforce/user/Id";
import USER_NAME from '@salesforce/schema/User.Name';

import LIST_MEMBER_STATUS from "@salesforce/schema/List_Member__c.List_Member_Status__c";
import LIST_STAGE from "@salesforce/schema/List__c.Stage__c";
import LIST_COLUMN_1 from "@salesforce/schema/List__c.Column_1__c";
import LIST_COLUMN_2 from "@salesforce/schema/List__c.Column_2__c";
import LIST_COLUMN_3 from "@salesforce/schema/List__c.Column_3__c";
import LIST_COLUMN_4 from "@salesforce/schema/List__c.Column_4__c";
import LIST_COLUMN_5 from "@salesforce/schema/List__c.Column_5__c";
import LIST_COLUMN_6 from "@salesforce/schema/List__c.Column_6__c";
import LIST_COLUMN_7 from "@salesforce/schema/List__c.Column_7__c";
import LIST_COLUMN_8 from "@salesforce/schema/List__c.Column_8__c";
import LIST_COLUMN_9 from "@salesforce/schema/List__c.Column_9__c";
import LIST_COLUMN_10 from "@salesforce/schema/List__c.Column_10__c";
import LIST_OWNER_ID from "@salesforce/schema/List__c.OwnerId";

import ENGAGEMENT_OPPORTUNITY_STAGE from "@salesforce/schema/Engagement_Opportunity__c.Stage__c";

import getListMembers from "@salesforce/apex/CustomHeaderContainerCtrl.getListMembers";
import getListIdEngOpp from "@salesforce/apex/CustomHeaderContainerCtrl.getListIdEngOpp";
import getUserHasListContributor from "@salesforce/apex/CustomHeaderContainerCtrl.getUserHasListContributor";
import updateListMemberStatus from "@salesforce/apex/CustomHeaderContainerCtrl.updateListMemberStatus";
import bulkSaveListMember from "@salesforce/apex/ListMemberImportModalCtrl.bulkSaveListMember";
import getListMembersForEngage from "@salesforce/apex/CustomHeaderContainerCtrl.getListMembersByListIdAndStatus"; 
import getAllListContributors from "@salesforce/apex/CustomHeaderContainerCtrl.getAllListContributors";

const ROW_WIDTH = 180;

export default class CustomHeaderContainer extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api tableColumnType;

    @track ownerId;
    @track columnsName;
    @track columnsData;
    @track listId;
    @track selectedRows;
    @track draftValues = [];
    @track recordData = [];
    @track recordDataToAdd = [];
    @track tableColumnsCopy = [];
    @track tableColumns = [];
    @track listColumns = [
        {
            label: 'List Member Reference',
            fieldName: 'ListMemberUrl',
            apiFieldName:'Name',
            type: 'text',
            editable: false,
            sortable: true,
            "initialWidth": ROW_WIDTH,
            type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }
        },
        { label: 'List Contributor',
            fieldName: 'ListContributorUrl',
            apiFieldName:'List_Contributor__c',
            editable: false,
            sortable: true,
            "initialWidth": ROW_WIDTH,
            type: 'url',
            typeAttributes: { label: { fieldName: 'ListContributorName' }, target: '_self' }
        },
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

    @track engageColumns = [
        {
            label: 'Contact',
            fieldName: 'ContactUrl',
            apiFieldName:'List_Member__c',
            type: 'text',
            editable: false,
            sortable: true,
            "initialWidth": ROW_WIDTH,
            type: 'url',
            typeAttributes: { label: { fieldName: 'ListMemberName' }, target: '_self' }
        },        
        {
            label: 'Activity Name',
            fieldName: 'Activity_Name__c',
            apiFieldName:'Activity_Name__c',
            type: 'text',
            editable: false,
            sortable: true,
            "initialWidth": ROW_WIDTH,
            type: 'text'
        },
        {
            label: 'Activity Start Date',
            fieldName: 'Activity_Start_Date__c',
            apiFieldName:'Activity_Start_Date__c',
            type: 'text',
            editable: false,
            sortable: true,
            "initialWidth": ROW_WIDTH,
            type: 'text'
        },
        {
            label: 'Activity End Date',
            fieldName: 'Activity_End_Date__c',
            apiFieldName:'Activity_End_Date__c',
            type: 'text',
            editable: false,
            sortable: true,
            "initialWidth": ROW_WIDTH,
            type: 'text'
        },
        {
            label: 'Activity Status',
            fieldName: 'Activity_Status__c',
            apiFieldName:'Activity_Status__c',
            type: 'text',
            editable: false,
            sortable: true,
            "initialWidth": ROW_WIDTH,
            type: 'text'
        }
    ]

    listFields = [
        LIST_STAGE,
        LIST_OWNER_ID,
        LIST_COLUMN_1,
        LIST_COLUMN_2,
        LIST_COLUMN_3,
        LIST_COLUMN_4,
        LIST_COLUMN_5,
        LIST_COLUMN_6,
        LIST_COLUMN_7,
        LIST_COLUMN_8,
        LIST_COLUMN_9,
        LIST_COLUMN_10
    ];

    engagementOpportunityDetail;
    fieldsToColumns = [];
    isTableLoading = true;
    isTableWithValidation = false;
    isContributorLinkToList = false;
    userId = USER_ID;
    userInfo;
    receivedListData;
    receivedListMemberData;
    receivedRecordId;
    listStageValue;
    isEngageTab = false;
    isOwner = false;

    get isEnableTableWithValidation() {
        return this.recordDataToAdd.length ? true : false;
    }

    // sets the list member column data
    listDataHandler(event){
        this.columnsData = event.detail;
    }
    // sets the list header
    newColumnsList(event) {
        this.columnsName = event.detail;
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USER_NAME]})
    wireCurrentUserInfo({error, data}) {
        if (data) {
            const fields = data.fields;
            this.userInfo = {
                Id: this.userId,
                Name: fields.Name.value
            };
        }
    }

    @wire(getRecord, { recordId: "$listId", fields: "$fieldsToColumns" })
    async wiredList(responseData) {
        const { data, error } = responseData;

        this.dataListRecord = responseData;
        if (data && this.tableColumnType === 'Dynamic') {
            const fields = data.fields;

            // Check the UserId is matched with OwnerId
            this.ownerId = fields.OwnerId.value;
            this.isOwner = (this.userId === this.ownerId) ? true: false;

            await this.createColumn(fields);
            this.fetchListMembers();
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ENGAGEMENT_OPPORTUNITY_STAGE]})
    wireEngagementOpportunity({error, data}) {
        if (this.objectApiName === 'Engagement_Opportunity__c') {
            if (data) {
                this.engagementOpportunityDetail= data;
            }
        }
    }

    async connectedCallback() {
        if (this.tableColumnType === 'Dynamic') {
            this.tableColumns = this.listColumns;
            this.fieldsToColumns = this.listFields;

            if (this.objectApiName === 'List__c') {
                this.listId = this.recordId;
            } else if (this.objectApiName === 'Engagement_Opportunity__c') {
                await this.fetchList();
            }

            this.fetchListContributors();
        } else if (this.tableColumnType === 'Engage' && this.objectApiName === 'Engagement_Opportunity__c') {
            this.tableColumns = this.engageColumns;
            await this.fetchList();
            await this.fetchUserHasListContributor();
            this.fetchListMembersForEngage();
            this.isEngageTab = true;
        } 
    }

    reloadListMembersTable(event) {
        if (event.detail) {
            this.fetchListMembers();
        }
    }

    async fetchUserHasListContributor() {
        const response = await getUserHasListContributor({ listId: this.listId, userId: this.userId });

        if (response && response.length) {
            this.isContributorLinkToList = true;
        }
    }

    fetchListMembers() {
        setTimeout(() => {
            getListMembers({ recordId: this.listId })
            .then((response) => {
                response.forEach(obj => {
                    obj.ListMemberUrl = `/lightning/r/List_Member__c/${obj.Id}/view`;

                    if (obj.List_Member__r) {
                        obj.List_Member__c = obj.List_Member__r.Id;
                        obj.ListMemberName = obj.List_Member__r.Name;

                        obj.ContactUrl = `/lightning/r/Contact/${obj.List_Member__r.Id}/view`;
                    }

                    if (obj.List_Contributor__r) {
                        obj.List_Contributor__c = obj.List_Contributor__r.Id;
                        this.allListContributors.forEach(contributor =>{
                            if(contributor.Id === obj.List_Contributor__r.Id){
                                obj.ListContributorName = contributor.List_Contributor__r.Name;
                            }
                        });
                        obj.ListContributorUrl = `/lightning/r/List_Contributor__c/${obj.List_Contributor__r.Id}/view`;
                    }
                });

                this.recordData = response;
                this.isTableLoading = false;
            })
        }, 1000);
    }

    fetchListMembersForEngage() {
        setTimeout(() => {
            getListMembersForEngage({ listId: this.listId, status: 'Qualified'})
            .then((response) => {
                response.forEach(obj => {
                    if (obj.List_Member__r) {
                        obj.List_Member__c = obj.List_Member__r.Id;
                        obj.ListMemberName = obj.List_Member__r.Name;

                        obj.ContactUrl = `/lightning/r/Contact/${obj.List_Member__r.Id}/view`;
                    }
                });

                this.recordData = response;
                this.isTableLoading = false;
            })
        }, 1000);
    }

    fetchListContributors() {
        getAllListContributors({ listId: this.listId})
        .then((response) => {
            if(response){
                this.allListContributors = response;
            }
        })
    }

    async fetchList() {
        const response = await getListIdEngOpp({ recordId: this.recordId });
        if (response && response.length) {
            this.listId = response[0].Id;
        }
    }

    async createColumn(fields) {
        await this.fetchUserHasListContributor();
        this.listStageValue = fields.Stage__c.value;

        const listColumns = [
            {column: 'Column_1__c', fieldName: 'ContactUrl', type: 'url', typeAttributes: { label: { fieldName: 'ListMemberName' }, target: '_self' }},
            {column: 'Column_2__c', fieldName: 'Email__c', type: 'text'},
            {column: 'Column_3__c', fieldName: 'Mobile__c', type: 'text'},
            {column: 'Column_4__c', fieldName: 'Column_1_Value__c', type: 'text'},
            {column: 'Column_5__c', fieldName: 'Column_2_Value__c', type: 'text'},
            {column: 'Column_6__c', fieldName: 'Column_3_Value__c', type: 'text'},
            {column: 'Column_7__c', fieldName: 'Column_4_Value__c', type: 'text'},
            {column: 'Column_8__c', fieldName: 'Column_5_Value__c', type: 'text'},
            {column: 'Column_9__c', fieldName: 'Column_6_Value__c', type: 'text'},
            {column: 'Column_10__c', fieldName: 'Column_7_Value__c', type: 'text'}
        ];

        const toAddColumns = [];
        listColumns.forEach((key, index) => {
            let toShowColumn = false;

            if (fields[key.column] && fields[key.column].value) {
                toShowColumn = true;
            }

            if (toShowColumn) {
                let apiFieldName = key.column;
                if (index === 0) {
                    apiFieldName = 'List_Member__c';
                }

                let objColumn = { label: fields[key.column].value, fieldName: key.fieldName, apiFieldName: apiFieldName, type: key.type, editable: false, sortable: true, "initialWidth": ROW_WIDTH };

                if (key.typeAttributes) {
                    objColumn.typeAttributes = key.typeAttributes;
                }

                toAddColumns.push(objColumn);
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
            if (
                (key.fieldName === 'List_Member_Status__c' &&
                fields.Stage__c &&
                fields.Stage__c.value &&
                (fields.Stage__c.value === 'Closed' || fields.Stage__c.value === 'Distribute'))
                || (key.fieldName === 'List_Member_Status__c' && !this.isOwner)
            ){
                key.type = 'text';
            }
        });

        this.tableColumns = newColumns;
    }

    handleSelectedRows(event) {
        this.selectedRows = event.detail;
    }

    handleRecordListMemberHasError (event) {
        this.recordDataToAdd = event.detail;
        this.isTableWithValidation = true;
    }

    async handleSaveExistingListMember(event) {
        const record = JSON.parse(JSON.stringify(event.detail));

        const toDeleteFields = ["Id", "ListMemberName", "ContactUrl", "Name", "Email__c", "Mobile__c", "List_Member__r", "ListMemberUrl",
            "List_Contributor__r", "ListContributorName", "ListContributorUrl", "isExistingContact", "toAddListRecord"];

        const toSaveRecord = [];

        record.forEach((obj) => {
            obj.List__c = this.listId;

            if (obj.toAddListRecord) {
                toDeleteFields.forEach((o) => {
                    if (o in obj) {
                        delete obj[o];
                    }
                })

                toSaveRecord.push(obj)
            }
        });

        try {
            await bulkSaveListMember({record: toSaveRecord });
            this.fetchListMembers();
            this.handleCancelAddExistingListMember();
            this.generateToast('Success', 'Successfully Created List Member.', 'success');
        } catch(e) {
            console.log(e);
            this.generateToast('Error', 'Error Creating List Member', 'error');
        }
    }

    handleCancelAddExistingListMember() {
        this.recordDataToAdd = [];
        this.isTableWithValidation = false;
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

    handleUpdateStatus(event) {
        const record = event.detail;
        updateListMemberStatus({listMembers: JSON.parse(JSON.stringify(record))})
        .then((result) => {
            this.generateToast('Success', 'List Members updated succesfully!', 'success');
            this.draftValues = [];
            this.fetchListMembers();
        })
        .catch(error => {
            console.log("Error in Save call back:", this.error);
        });
    }
}