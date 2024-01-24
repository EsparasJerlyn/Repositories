import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LIST_MEMBER_SCHEMA from '@salesforce/schema/List_Member__c';

import getContactById from '@salesforce/apex/ListMemberImportModalCtrl.getContactById';
import bulkSaveListMember from '@salesforce/apex/ListMemberImportModalCtrl.bulkSaveListMember';

// import readCSV from '@salesforce/apex/CsvBulkRegistrationCtrl.readCSVFile';

const ROW_WIDTH = 180;

export default class ListMemberImportModal extends LightningElement {
    @api isShowModal;
    @api recordData;
    @api objectApiName;
    @api listId;

    @track columns;
    @track data = [];
    @track csvdata = [];

    actions = [
        { label: 'Delete', name: 'delete' },
        { label: 'Edit', name: 'edit' },
    ];
    excludeCTableolumns = ['List Member Reference'];
    excludeCSVColumns = ['List Member Reference', 'Email', 'Mobile'];
    prefields = [];
    isNotEqualColumns = false;
    disabledSave = true;
    isEditRecord = false;
    errors;
    rowId;

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
        console.log(JSON.parse(JSON.stringify(newColumns)));
        this.columns = newColumns;
    }

    get standardHeaderLabel(){ return true;}

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

            const csvdata = [];
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
                            obj[v.fieldName] = value;
                        }
                    })
                })

                if (isFound) {
                    csvdata.push(obj);
                }
            })

            for (let i = 0; i < columns.length - 1 ; i++) {
                if (this.excludeCSVColumns.indexOf(columns[i].label) < 0 && csvHeader.indexOf(columns[i].label) < 0) {
                    isNotEqualColumns = true;
                }
            }

            if (!isNotEqualColumns) {
                this.csvdata = csvdata.map((key, index)=> {
                    let id = index + 1 + "";
                        return {
                            ...key,
                            id
                        }
                });

                this.rowvalidation();
            }

            if (csvdata.length === 0) {
                this.generateToast('Reminder', 'Uploaded file CSV column Header must match the List Column Headers.', 'error');
            } else {
                this.generateToast('Success', ' List Member are created based on CSV file.', 'success');
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
        const csvdata = JSON.parse(JSON.stringify(this.csvdata));
        let idArr = [];
        csvdata.forEach(obj => {
            if (obj.List_Member__c) {
                idArr.push(obj.List_Member__c);
            }
        });

        const ids = idArr.toString();
        let contacts = await getContactById({ ids: ids });
        let newData = [];

        this.csvdata.map(listMember => {
            let fieldNames = [];
            let isDuplicate = false;
            this.recordData.forEach(obj => {
                if (listMember.List_Member__c === obj.List_Member__c) {
                    isDuplicate = true;
                }
            });

            let isFoundContact = false;

            let email = '';
            let mobilePhone = '';
            contacts.forEach(obj => {
                if (listMember.List_Member__c === obj.Id) {
                    email = 'Email' in obj ? obj.Email : '';
                    mobilePhone = 'MobilePhone' in obj ? obj.MobilePhone : '';
                    isFoundContact = true;
                }
            });

            listMember.Email__c = email;
            listMember.Mobile__c = mobilePhone;

            let messages = [];

            if (!listMember.List_Member__c) {
                fieldNames.push("Contact ID");
            }

            if (!isFoundContact) {
                messages = ['Contact ID not found', ...fieldNames];
            }

            if (isDuplicate) {
                messages = ['Duplicate Contact ID', ...fieldNames];
            }

            if (fieldNames.length > 0 || messages.length > 0 ) {
                rowsValidation[listMember.id] = {
                    title: 'We found an error/s.',
                    messages: ['Please enter valid value for the ff. fields', ...messages, ...fieldNames],
                    fieldNames : fieldNames
                };
            }

            newData.push(listMember);
        });

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
            let selectedContact = this.csvdata.filter(record => record.id == recordId)[0];
            selectedContact = JSON.parse(JSON.stringify(selectedContact));
            this.rowId = selectedContact.id

            const prefields = JSON.parse(JSON.stringify(this.columns));
            const hasLookup = ['List_Member__c', 'List_Contributor__c', 'List_Member_Status__c'];

            prefields.forEach((key, i) => {
                key.value = selectedContact[key.fieldName];
                key.isDisabled = false;
                key.tableObjectType = 'List_Member__c';

                if(key.fieldName === "Email__c" || key.fieldName === "Mobile__c") {
                    key.isDisabled = true;
                }

                if (hasLookup.indexOf(key.fieldName) > -1) {
                    key.isGetRecord = true;
                }
            });

            prefields.pop();

            this.prefields = prefields;

            this.isEditRecord = true;
        }

        if(event.detail.action.name == "delete"){
            const csvdata = this.csvdata;
            const newcsvdata = csvdata.filter(record=> {
                return record.id != recordId;
            });

            newcsvdata.forEach((element, index) => {
                element.id = index + 1;
            });

            this.csvdata = newcsvdata;
        }

        this.rowvalidation();
    }

    handleCloseEditModal() {
        this.isEditRecord = false;
    }

    handleEdit(event){
        let tempHolder= this.contacts;
        let details = JSON.parse(JSON.stringify(event.detail));

        const data = this.data;
        data.forEach((row) => {
            if(row.id === details.id) {
                for (const i in row) {
                    details.data.forEach((o) => {
                        if (o.fieldName === i) {
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
        });

        try {
            await bulkSaveListMember({listId: this.listId, record: JSON.stringify(params) });

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