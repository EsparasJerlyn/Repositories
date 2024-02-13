/**
 * @description Lightning Web Component for custom parent container.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | neil.s.h.lesidan          | January 24, 2024      | DEPP-7005            | Created file                 |
      |                           |                       |                      |                              |
 */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LIST_MEMBER_SCHEMA from '@salesforce/schema/List_Member__c';

import getContactById from '@salesforce/apex/ListMemberImportModalCtrl.getContactById';
import getListContributorByIds from '@salesforce/apex/ListMemberImportModalCtrl.getListContributorByIds';
import bulkSaveListMember from '@salesforce/apex/ListMemberImportModalCtrl.bulkSaveListMember';

const ROW_WIDTH = 180;

export default class ListMemberImportModal extends LightningElement {
    @api isShowModal;
    @api recordData;
    @api objectApiName;
    @api listId;
    standardHeaderLabel = 'Edit List Member';

    @track columns;
    @track data = [];
    @track csvdata = [];

    rowId;
    errors;
    hasRowError = true;;
    isNotEqualColumns = false;
    disabledSave = true;
    isEditRecord = false;
    prefields = [];
    excludeCTableolumns = ['List Member Reference'];
    excludeCSVColumns = ['List Member Reference', 'Email', 'Mobile'];
    actions = [
        { label: 'Delete', name: 'delete' },
        { label: 'Edit', name: 'edit' },
    ];

    @api
    get tableColumns() {
        return this.columns;
    }
    set tableColumns(value) {
        let newColumns = [];
        value.forEach((key, index)  => {
            if (this.excludeCTableolumns.indexOf(key.label) < 0) {
                newColumns.push(key);
            }
        })

        newColumns.push({ type: "action", typeAttributes: { rowActions: this.actions } });
        this.columns = newColumns;
    }

    get acceptedFormats() {
        return ['.csv'];
    }

    get columnWidth() {
        return ROW_WIDTH;
    }

    get tableWidth() {
        return `table-layout: fixed; width: ${ROW_WIDTH * this.columns.length}px;`;
    }

    toShowListMemberImportModal(value) {
        this.dispatchEvent(
            new CustomEvent('changeshowimportmodal', {
                detail: value
            })
        );
    }

    handleCloseModal() {
        this.toShowListMemberImportModal(false);
        this.data = [];
    }

    handleUploadCSV(event) {
        const file = event.target.files[0]
        const reader = new FileReader()
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            const csvContent = atob(base64);
            const csvtoArray = this.csvToArray(csvContent);
            const csvHeader = csvtoArray[0];
            const csvRecord = csvtoArray.slice(1)
            csvRecord.pop();

            const columns = JSON.parse(JSON.stringify(this.columns));

            const data = [];
            let isNotEqualColumns = false;

            csvRecord.forEach((key, index) => {
                let obj = {};
                let isFound = false;

                key.forEach((kValue, i) => {
                    const value = kValue.replace(/(\r\n|\n|\r)/gm, "");

                    let headerName = csvHeader[i].replace(/(\r\n|\n|\r)/gm, "");

                    let fieldName = headerName.replace(/\s/g, '').toLowerCase();

                    if (fieldName === 'contactid') {
                        headerName = 'Contact ID';
                    }

                    csvHeader[i] = headerName;

                    columns.forEach((v, ii) => {
                        if (v.label === headerName) {
                            isFound = true;
                            obj[v.apiFieldName] = value;
                        }
                    })
                })

                if (isFound) {
                    data.push(obj);
                }
            })

            const columnsNames = [];

            columns.forEach((obj) => {
                if (this.excludeCSVColumns.indexOf(obj.label) < 0 && obj.type.toLowerCase() != 'action') {
                    columnsNames.push(obj.label);
                }
            });

            if (JSON.stringify(csvHeader) !== JSON.stringify(columnsNames)) {
                isNotEqualColumns = true;
            }

            if (!isNotEqualColumns) {
                this.data = data.map((key, index)=> {
                    let id = index + 1 + "";
                        return {
                            ...key,
                            id
                        }
                });

                this.rowvalidation();
                this.generateToast('Success', ' List Member are created based on CSV file.', 'success');
            } else {
                this.data = [];
                this.disabledSave = true;
                this.generateToast('Reminder', 'Uploaded file CSV column Header must match the List Column Headers.', 'error');
            }
        }

        reader.readAsDataURL(file)
    }

    csvToArray(csv) {
        const rows = csv.split('\n');
        const result = [];

        for (const row of rows) {
            const values = row.split(',');
            result.push(values);
        }

        return result;
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

    async rowvalidation() {
        let rowsValidation = {};
        const data = JSON.parse(JSON.stringify(this.data));
        let idContactArr = [];
        let idListContributorArr = [];
        data.forEach(obj => {
            if (obj.List_Member__c) {
                idContactArr.push(obj.List_Member__c);
            }

            if (obj.List_Contributor__c) {
                idListContributorArr.push(obj.List_Contributor__c);
            }
        });

        const contactids = idContactArr.toString();
        const listContributorids = idListContributorArr.toString();
        let contacts = [];
        if (contactids) {
            contacts = await getContactById({ ids: contactids });
        }

        let listContributors = [];
        if (listContributorids) {
            listContributors = await getListContributorByIds({ listId: this.listId, contributorIds: listContributorids });
        }

        let newData = [];
        let hasError = false;

        this.data.map(listMember => {
            let fieldNames = [];
            let isDuplicate = false;

            listMember.ListContributorName = '';
            listMember.ListContributorUrl = '';
            listMember.ListMemberName = '';
            listMember.ContactUrl = '';

            this.recordData.forEach(obj => {
                if (listMember.List_Member__c === obj.List_Member__c) {
                    isDuplicate = true;
                }
            });

            let isFoundContact = false;
            let isFoundListContributor = false;

            let email = '';
            let mobilePhone = '';
            contacts.forEach(obj => {
                if (listMember.List_Member__c === obj.Id) {
                    email = 'Email' in obj ? obj.Email : '';
                    mobilePhone = 'MobilePhone' in obj ? obj.MobilePhone : '';
                    isFoundContact = true;

                    listMember.ListMemberName = obj.Name;
                    listMember.ContactUrl = `/lightning/r/Contact/${obj.Id}/view`;
                }
            });

            listMember.Email__c = email;
            listMember.Mobile__c = mobilePhone;

            if (listMember.List_Contributor__c) {
                listMember.ListContributorName = listMember.List_Contributor__c;
                listMember.ListContributorUrl = `/lightning/r/List_Contributor__c/${listMember.List_Contributor__c}/view`;
            }

            listContributors.forEach(obj => {
                if (listMember.List_Contributor__c === obj.Id) {
                    isFoundListContributor = true;

                    listMember.ListContributorName = obj.Name;
                    listMember.ListContributorUrl = `/lightning/r/List_Contributor__c/${obj.Id}/view`;
                }
            });

            let messages = [];

            if (!listMember.List_Member__c) {
                fieldNames.push("Contact ID");
            }

            if (!isFoundContact) {
                messages.push('Contact ID not found');

                if (listMember.List_Member__c) {
                    listMember.ListMemberName = listMember.List_Member__c;
                    listMember.ContactUrl = `/lightning/r/Contact/${listMember.List_Member__c}/view`;
                }
            }

            listMember.isFoundContact = isFoundContact;
            listMember.isFoundListContributor = isFoundContact;

            if (isDuplicate) {
                messages.push('Duplicate Contact ID');
            }

            if (!isFoundListContributor && listMember.List_Contributor__c) {
                messages.push('List Contributor is not linked to this List, or the record does not exist.');
            }

            if (fieldNames.length > 0 || messages.length > 0 ) {
                rowsValidation[listMember.id] = {
                    title: 'We found an error/s.',
                    messages: ['Please enter valid value for the ff. fields', ...messages, ...fieldNames],
                    fieldNames : fieldNames
                };

                hasError = true;
            }

            newData.push(listMember);
        });

        this.hasRowError = hasError;
        this.disabledSave = hasError;

        this.data = newData;

        this.errors = {
            rows: rowsValidation
        };

        this.disabledSave = false;

        if (Object.keys(rowsValidation).length > 0) {
            this.disabledSave = true;
        }
    }

    handleRowAction(event) {
        const recordId = event.detail.row.id;

        if(event.detail.action.name == "edit"){
            let selectedContact = this.data.filter(record => record.id == recordId)[0];
            selectedContact = JSON.parse(JSON.stringify(selectedContact));
            this.rowId = selectedContact.id

            const prefields = JSON.parse(JSON.stringify(this.columns));
            const hasLookup = ['List_Member__c', 'List_Contributor__c', 'List_Member_Status__c'];

            prefields.forEach((key, i) => {
                key.value = '';

                if (
                    (key.apiFieldName === 'List_Member__c' && selectedContact.isFoundListContributor) ||
                    (key.apiFieldName === 'List_Contributor__c' && selectedContact.isFoundContact))
                {
                    key.value = selectedContact[key.apiFieldName];
                }

                key.isDisabled = false;
                key.tableObjectType = 'List_Member__c';

                if(key.apiFieldName === "Email__c" || key.apiFieldName === "Mobile__c") {
                    key.isDisabled = true;
                }

                if (hasLookup.indexOf(key.apiFieldName) > -1) {
                    key.isGetRecord = true;
                }
            });

            prefields.pop();

            this.prefields = prefields;

            this.isEditRecord = true;
        }

        if(event.detail.action.name == "delete"){
            const data = this.data;
            const newdata = data.filter(record=> {
                return record.id != recordId;
            });

            newdata.forEach((element, index) => {
                element.id = index + 1;
            });

            this.data = newdata;
        }

        this.rowvalidation();
    }

    handleCloseEditModal() {
        this.isEditRecord = false;
    }

    handleEdit(event){
        const details = JSON.parse(JSON.stringify(event.detail));

        const data = this.data;
        data.forEach((row) => {
            if(row.id === details.id) {
                for (const i in row) {
                    details.data.forEach((o) => {
                        if (o.apiFieldName === i) {
                            row[i] = o.value;
                        }
                    })
                }
            }
        });

        this.data = JSON.parse(JSON.stringify(data));
        this.rowvalidation();
    }

    async handleSave() {
        this.disabledSave = true;
        let params = JSON.parse(JSON.stringify(this.data));

        params.forEach((obj) => {
            obj.Activity_Status__c = 'Accepted';
            obj.List__c = this.listId;
            delete obj.id;
            delete obj.Email__c;
            delete obj.Mobile__c;
            delete obj.ListMemberName;
            delete obj.ContactUrl;
            delete obj.ListContributorName;
            delete obj.ListContributorUrl;
            delete obj.isFoundContact;
            delete obj.isFoundListContributor;
        });

        try {
            await bulkSaveListMember({record: params });

            this.reloadListMembersTable();
            this.generateToast('Success', 'Successfully Created List Member based on CSV file.', 'success');
            this.handleCloseModal();
        } catch (error) {
            this.generateToast('Error', 'Error Creating List Member ', 'error');
        }
    }

    reloadListMembersTable() {
        this.dispatchEvent(new CustomEvent('reloadlistmemberstable', {
            detail: true
        }));
    }
}