/**
 * @description Lightning Web Component for add from existing list buttons.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | neil.s.h.lesidan          | January 22, 2024      | DEPP-7004            | Created file                 |
      | kenneth.f.alsay           | February 22, 2024     | DEPP-8040, DEPP-8099 | Fixed table column checking  |
      | neil.s.h.lesidan          | August 5, 2024        | DEPP-10232           | Fixed displayed Help Text    |
 */
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from "lightning/uiRecordApi";
import getSearchedLists from '@salesforce/apex/AddFromExistingListCtrl.getSearchedLists';
import getListMembers from '@salesforce/apex/CustomHeaderContainerCtrl.getListMembers';
import bulkSaveListMember from '@salesforce/apex/ListMemberImportModalCtrl.bulkSaveListMember';
import getUserHasListContributor from "@salesforce/apex/CustomHeaderContainerCtrl.getUserHasListContributor";
import getDefaultListContributor from '@salesforce/apex/ListMemberAddModalController.getDefaultListContributor';
import getListContributorByIds from '@salesforce/apex/ListMemberImportModalCtrl.getListContributorByIds';

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
import ID from "@salesforce/user/Id";

export default class AddFromExistingList extends LightningElement {
    @api listId;
    @api recordData;
    @api isShowModal;
    @api userInfo;

    @track columnNames;

    error;
    result;
    errorMessage;
    selectedList;
    selectedListId;
    defaultContributor;
    excludeCTableolumns = ['Name', 'List_Contributor__c', 'List_Member_Status__c'];
    content = 'The modal content';
    header = 'The modal header';
    size = 'slds-modal_medium';
    fieldsToColumns = 'List__c';
    searchListInProgress = false;
    listSearchItems = [];
    selectListColumns = [];
    selectColumnLabels = [];
    columnLabel = [];
    listFields = [
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

    @api
    get tableColumns() {
        return this.columns;
    }
    set tableColumns(value) {
        const columns = [];
        const columnLabel = [];
        value.forEach(key => {
            if (this.excludeCTableolumns.indexOf(key.fieldName) < 0) {
                columns.push(key.fieldName);
                columnLabel.push(key.label);
            }
        });

        this.columnLabel = columnLabel;
        this.columnNames = columns;
    }

    connectedCallback(){
        if(this.listId){
            this.fetchDefaultListContributor();
        }
    }

    @wire(getRecord, { recordId: "$selectedListId", fields: "$listFields" })
    wiredList(responseData) {
        const { data, error } = responseData;

        this.dataListRecord = responseData;
        if (data) {
            const fields = data.fields;

            this.checkColumns(fields);
        }
    }

    checkColumns(fields) {
        const listColumns = [
            {column: 'Column_1__c', fieldName: 'ContactUrl', type: 'url', typeAttributes: { label: { fieldName: 'ListMemberName' }, target: '_self' }},
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

        const selectListColumns = [];
        const selectColumnLabels = [];
        listColumns.forEach((key, index) => {
            let toShowColumn = false;

            if (fields[key.column] && fields[key.column].value) {
                toShowColumn = true;
            }

            if (toShowColumn) {
                selectListColumns.push(key.fieldName);
                selectColumnLabels.push(fields[key.column].value);
            }
        });

        this.selectListColumns = selectListColumns;
        this.selectColumnLabels = selectColumnLabels;
    }

    // sets header change
    handleHeaderChange(event) {
        this.header = event.target.value;
    }

    // sets for content change
    handleContentChange(event) {
        this.content = event.target.value;
    }

    // modal size
    handleModalSizeChange(event) {
        this.size = event.target.value;
    }

    // closing the modal
    handleCloseModal() {
        this.handleListRemove();
        this.dispatchEvent(new CustomEvent('handleshowmodalexistinglist', {detail:false}));
    }

    // sets the list selection
    handleListSelection(event){
        this.selectedList = event.target.value;
    }

    //returns list of list based on input
    handleSearchList(event){
        this.searchListInProgress = true;

        getSearchedLists({
            recordId: this.listId,
            filterString: event.detail.filterString,
        })
        .then(result =>{
            const newResult = [];
            result.forEach(obj => {
                newResult.push({
                    id: obj.Id,
                    label: obj.Name+'-'+obj.List_Name__c,
                    meta: '',
                });
            });

            this.listSearchItems = newResult;
        })
        .finally(()=>{
            this.searchListInProgress = false;
        })
        .catch(error =>{
            this.generateToast('Error', 'Error retrieving list records.', 'error');
        });
    }

    //sets selected list id
    handleListSelect(event){
        this.selectedListId = event.detail.value;
    }

    //removes selected list
    handleListRemove(){
        this.errorMessage = '';
        this.selectedListId = undefined;
        this.listSearchItems = [];
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

    // sets save existing list
    async handleSaveExistingList() {
        let columnLabels = JSON.parse(JSON.stringify(this.columnLabel));
        const listMembers = await this.fetchListMembers(this.selectedListId);
        const recordData = JSON.parse(JSON.stringify(this.recordData));
        const selectColumnLabels = JSON.parse(JSON.stringify(this.selectColumnLabels));
        
        const excludeFields = ["List Member Reference", "List Contributor", "List Member Status"];

        if (listMembers && listMembers.length) {
            columnLabels = columnLabels.filter((val) => {
                if (excludeFields.indexOf(val) >= 0) {
                    return false;
                }

                return true;
            });

            let isEqualColumns =  JSON.stringify(selectColumnLabels) ===  JSON.stringify(columnLabels);
            let hasExistingListMemberContact = false;

            const newListMember = [];
            const userInfo = JSON.parse(JSON.stringify(this.userInfo));

            listMembers.forEach(async (obj) => {
                obj.isExistingContact = false;
                obj.toAddListRecord = true;
                obj.List_Contributor__c = this.defaultContributor;
                obj.List_Member_Status__c = null;
                recordData.forEach((o) => {
                    if (obj.List_Member__c === o.List_Member__c) {
                        hasExistingListMemberContact = true;
                        obj.isExistingContact = true;
                    }
                })

                newListMember.push(obj);
            })

            if (isEqualColumns) {
                if (!listMembers || !listMembers.length) {
                    this.errorMessage = "Selected List doesn't have List Member or its List Member Status is not equal to Qualified.";
                } else if (hasExistingListMemberContact) {
                    const listContributorRecord = await getUserHasListContributor({ listId: this.listId, userId: userInfo.Id });
                    
                    let listContributors = await getListContributorByIds({ listId: this.listId, contributorIds: listContributorRecord[0] });

                    listMembers.forEach((obj) => {
                        obj.List_Contributor__c = this.defaultContributor;
                        obj.List_Contributor__r = JSON.parse(JSON.stringify(userInfo));

                        if (listContributors && listContributors.length) {
                            obj.ListContributorName = listContributors[0].List_Contributor__r.Name;
                            obj.ListContributorUrl = `/lightning/r/List_Contributor__c/${listContributors[0].Id}/view`;
                        }
                    })

                    this.handleCloseModal();
                    this.dispatchEvent(new CustomEvent('recordlistmemberhaserror', { detail: newListMember }));
                } else {
                    const toDeleteFields = ["Id", "ListMemberName", "Name", "Email__c", "Mobile__c", "List_Member__r", "List_Contributor__r",
                        "ListMemberUrl", "ListContributorUrl", "ListContributorName", "ContactUrl", "isExistingContact", "toAddListRecord"];

                    listMembers.forEach((obj) => {
                        obj.List__c = this.listId;

                        toDeleteFields.forEach((o) => {
                            if (o in obj) {
                                delete obj[o];
                            }
                        })
                    });

                    try {
                        await bulkSaveListMember({record: listMembers });

                        this.reloadListMembersTable();
                        this.generateToast("Success", "Successfully Created List Member.", "success");
                        this.handleCloseModal();
                    } catch (error) {
                        this.errorMessage = "Error Creating List Member.";
                    }
                }
            } else {
                this.errorMessage = "The list headers do not match. Please choose appropriate list.";
            }
        } else {
            this.errorMessage = "The selected list does not contain any list members.";
        }
    }

    //gets List Contributor ID of current user and assign it to var defaultContributor
    fetchDefaultListContributor(){
        getDefaultListContributor({ listId: this.listId, currentUser: ID })
        .then((response) => {
            if(response && response.length){
                this.defaultContributor = response[0].Id;
            }
        })
    }

    async fetchListMembers(listId) {
        const response = await getListMembers({ recordId: listId });
        const requiredListMember = ['Qualified'];
        const listmembers = [];

        if (response && response.length) {
            response.forEach(obj => {
                if (obj.List_Member__r && obj.List_Member_Status__c && requiredListMember.indexOf(obj.List_Member_Status__c) >= 0) {

                    obj.List_Member__c = obj.List_Member__r.Id;
                    obj.ListMemberName = obj.List_Member__r.Name;

                    obj.ContactUrl = `/lightning/r/Contact/${obj.List_Member__r.Id}/view`;

                    if (obj.List_Contributor__r) {
                        obj.List_Contributor__c = obj.List_Contributor__r.Id;
                        obj.ListContributorName = obj.List_Contributor__r.Name;

                        obj.ListContributorUrl = `/lightning/r/List_Contributor__c/${obj.List_Contributor__r.Id}/view`;
                    }

                    listmembers.push(obj);
                }
            });

            return listmembers;
        }

        return false;
    }

    reloadListMembersTable() {
        this.dispatchEvent(new CustomEvent('reloadlistmemberstable', {
            detail: true
        }));
    }
}