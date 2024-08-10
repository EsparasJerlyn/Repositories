/**
 * @description Lightning Web Component for custom parent container.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
     |---------------------------|-----------------------|----------------------|------------------------------|
    | carl.alvin.cabiles        | January 18, 2024      | DEPP-7003            | Created file                 |
    | nicole.genon              | February 1, 2024      | DEPP-7003            | Added methods                |
    |                           |                       |                      |                              |
*/
import { LightningElement, api, wire, track } from 'lwc';
import checkIfExistingContact from '@salesforce/apex/ListMemberAddModalController.checkIfExistingContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getDefaultListContributor from '@salesforce/apex/ListMemberAddModalController.getDefaultListContributor';
import getRelatedListContributor from '@salesforce/apex/ListMemberAddModalController.getRelatedListContributor';
import createListMember from '@salesforce/apex/ListMemberAddModalController.createListMember';
import getContacsWithMatchingEmailsPosition from '@salesforce/apex/ListMemberAddModalController.getContactsWithMatchingEmailsPosition';
import List_Member_OBJECT from '@salesforce/schema/List_Member__c';
import LIST_CONTRIBUTOR_FIELD from '@salesforce/schema/List_Member__c.List_Contributor__c';
import Id from "@salesforce/user/Id";

export default class ListMemberAddModal extends LightningElement {
    @api isShowModal;
    @api closeModal;
    @api recordId;
    @api objectApiName;

    @track listMemberId;

    contributorLists = [];
    listMemberContacts = [];
    _listId;
    selectedContributor = '';
    selectedListMember = '';
    defaultContributor = '';
    searchListContributorResult;
    prefields = [];
    standardHeaderLabel = 'New List Member';
    currentUser = Id;
    objectApiName = List_Member_OBJECT;
    searchContactInProgress = false;

    @api
    get tableColumns() {
        return true;
    }
    set tableColumns(value) {
        const columns = JSON.parse(JSON.stringify(value));
        const hasLookup = ['List_Member__c'];
        const removeFields = ['Name', 'List_Member_Status__c','List_Member__c', 'List_Contributor__c'];
        const prefields = [];
        columns.forEach((key, i) => {
            key.isDisabled = false;
            key.defaultValue = '';
            key.tableObjectType = 'List_Member__c';

            if(key.fieldName === "Email__c" || key.fieldName === "Mobile__c") {
                key.isDisabled = true;
            }

            if (hasLookup.indexOf(key.apiFieldName) > -1) {
                key.isGetRecord = true;
            }

            if (key.type !== 'Action' && removeFields.indexOf(key.apiFieldName) < 0) {
                prefields.push(key);
            }
        });

        this.prefields = prefields;
    };

    get isDisabledSaveButton() {
        if (this.selectedListMember) {
            return false;
        }

        return true;
    }

    @api
    get listId(){
    return this._listId;
    }

    set listId(value) {
        this._listId = value;
        if (value) {
            this.fetchContributorLists();
            this.fetchDefaultListContributor();
        }

    }

    fetchListMemberContacts(value){
        this.searchContactInProgress = true;
        getContacsWithMatchingEmailsPosition({ toSearch: value, recordLimit: 5 })
        .then((response) => {
            if(response){
                const requiredFieldMultipleLabels = ['Name','Email','hed__WorkEmail__c', 'hed__UniversityEmail__c', 'QUT_Staff_Email__c','Position__c'];
                const listMemberContacts = [];
                response.forEach((obj) => {
                    const multipleLabels = [];
                    requiredFieldMultipleLabels.forEach((i) => {
                        if(obj[i]){
                            multipleLabels.push(obj[i]);
                        }
                    })
                    listMemberContacts.push({
                        label: obj.Name,
                        value: obj.Id,
                        email: obj.Email,
                        mobilePhone: obj.MobilePhone,
                        multipleLabel: multipleLabels
                    });

                });

                this.listMemberContacts = listMemberContacts;
                this.searchContactInProgress = false;
            }
        })
    }

    fetchContributorLists(){
        getRelatedListContributor({ listId: this._listId })
        .then((response) => {
            if(response){
                const contributorLists = [];
                response.forEach((obj) => {
                    contributorLists.push({
                        label: obj.List_Contributor__r.Name,
                        value: obj.Id,
                        multipleLabel: [obj.Name,obj.List_Contributor__r.Name]
                    });

                });

                this.contributorLists = contributorLists;
            }
        })
    }

    fetchDefaultListContributor(){
        getDefaultListContributor({ listId: this._listId, currentUser: this.currentUser })
        .then((response) => {
            if(response && response.length){
                this.selectedContributor = response[0].Id;
                this.defaultContributor = response[0].Id;
            }
        })
    }

    handleChangeListContributor(event) {
        this.selectedContributor = event.detail.value;
    }

    handleChangeListMember(event) {
        const value = event.detail.value;
        this.fetchListMemberContacts(value);
    }

    handleSelectedListMember(event) {
        const value = event.detail.value;
        this.selectedListMember = value;
        const prefields = JSON.parse(JSON.stringify(this.prefields));

        prefields.forEach((obj) => {
            this.listMemberContacts.forEach((contact) => {
                if (obj.fieldName === "Email__c") {
                    obj.value = contact.email;
                }

                if (obj.fieldName === "Mobile__c") {
                    obj.value = contact.mobilePhone;
                }
            });
        })

        this.prefields = prefields;

    }

    handleInputChange(event) {
        const fieldName = event.currentTarget.dataset.field;
        const value = event.target.value;

        const prefields = JSON.parse(JSON.stringify(this.prefields));
        prefields.forEach((obj) => {
            this.listMemberContacts.forEach((contact) => {
                if (obj.fieldName === fieldName) {
                    obj.value = value;
                }
            });
        })

        this.prefields = prefields;
    }

    handleCloseModal() {
        this.selectedContributor = '';
        this.selectedListMember = '';
        this.fetchDefaultListContributor();
        this.dispatchEvent(
            new CustomEvent('closemodal')
        );
    }

    async handleSubmit(event){
        event.preventDefault();
            const listMember = {
                List__c: this._listId
            };

            if (this.selectedContributor) {
                listMember.List_Contributor__c = this.selectedContributor;
            }

            if (this.selectedListMember) {
                listMember.List_Member__c = this.selectedListMember;
            }

            const prefields = JSON.parse(JSON.stringify(this.prefields));

            prefields.forEach((obj) => {
                if (obj.fieldName !== "Email__c" && obj.fieldName !== "Mobile__c") {
                    listMember[obj.fieldName] = obj.value;
                }
            })

            const contact = await checkIfExistingContact({listId: listMember.List__c, contactId: listMember.List_Member__c});
            if(contact && this.objectApiName == 'List__c'){
                this.showMessage('Error', 'This contact is already added to the List. Please select another contact.', 'error');
            }else if(contact && this.objectApiName == 'Engagement_Opportunity__c'){
                this.showMessage('Error', 'The contact already exist. Please select appropriate contact.', 'error');
            }else{
                createListMember({ records: [listMember]})
                .then((response) => {
                    this.showMessage('Success', 'List Member is successfully added.', 'success');
                    this.selectedContributor = '';
                    this.selectedListMember = '';
                    this.handleCloseModal();
                    this.reloadListMembersTable();
                })
                .catch((error) => {
                    console.log(error);
                })
            }
    }

    reloadListMembersTable() {
        this.dispatchEvent(new CustomEvent('reloadlistmemberstable', {
            detail: true
        }));
    }

    handleSuccess(event){
        const updatedRecord = event.detail.id;
        this.reloadListMembersTable();
        console.log('onsuccess: ', updatedRecord);
    }

    handleError(event) {
        console.log("handleError event");
        console.log(JSON.stringify(event.detail));
    }

    showMessage(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}