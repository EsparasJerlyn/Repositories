/**
 * @description Lightning Web Component for custom buttons.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                                                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------------------------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                                                                               |
      | jerlyn.esparas            | January 10, 2024      | DEPP-6965            |                                                                                            |
      | nicole.genon@qut.edu.au   | January 15, 2024      | DEPP-6966            | Added wiredList and isDisabledButton                                                       |
      | kenneth.f.alsay           | January 15, 2024      | DEPP-6964            | Added handleStatusClick, handlerShowModal                                                  |
      |                           |                       |                      | Added isDownloadCSVDisabled                                                                |
      | neil.s.h.lesidan          | January 24, 2024      | DEPP-7005            | Display Import CSV modal add method handleImporCSV                                         |
      | carl.alvin.cabiles        | February 13,2024      | DEPP-8039            | Add Contact Name column in csv                                                             |
 */
import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import LIST_STAGE from "@salesforce/schema/List__c.Stage__c";

const CVS_DOWNLOAD_NAME = "lisData";

export default class CustomHeaderButtons extends LightningElement {
    @api recordId;
    @api userInfo;
    @api selectedRows;
    statusSelected = "Close";
    @api columnsName;
    @api columnsData;
    @api isEnableTableWithValidation;
    @api isContributorLinkToList;

    @api listStageValue;
    @api tableColumns;
    @api recordData;

    _listId;
    csvtemp;
    listMemberColumns = [LIST_STAGE];
    stageValue;
    result;
    showModal;
    showStatusPicklist;
    showSelectMembers;
    itemsSelectedListMemberStatus;
    @track listMembers;
    @track listMemberStatus;
    isShowModalListMemberStatus = false;
    error;

    isShowImportCSVModal = false;
    receivedRecordId;
    isAddFromExistingListModal = false;

    @api
    get listId() {
        return this._listId;
    }
    set listId(value) {
        this._listId = value;
    }

    get isDisabledButton() {
        let isDisabled = true;
        if (this.isContributorLinkToList) {
            isDisabled =  this.stageValue === "Distribute" || this.stageValue === "Closed" || this.isEnableTableWithValidation ? true : false;
        }

        return isDisabled;
    }

    get isDisabledAddFromExistingListButton() {
        let isDisabled = true;
        if (this.isContributorLinkToList) {
            isDisabled = this.stageValue === "Distribute" || this.stageValue === "Closed" ? true : false;
        }

        return isDisabled;
    }

    get isDownloadCSVDisabled() {
        return this.stageValue === "Distribute" ? false : true;
    }

    @wire(getRecord, { recordId: "$recordId", fields: "$listMemberColumns" })
        wiredList(responseData) {
        const { data, error } = responseData;

        if (data) {
            const fields = data.fields;
            this.stageValue = fields.Stage__c.value;
        }
    }

    handleStatusClick(){
        if(this.selectedRows && this.selectedRows.length === 0){
            this.generateToast('Error', 'Please select a List Member to change the status.', 'error');
        }else{
            this.itemsSelectedListMemberStatus = this.selectedRows;
            this.isShowModalListMemberStatus = true;
        }
    }

    handlerShowModalListMemberStatus(event){
        this.isShowModalListMemberStatus = event.detail;
    }

    // Method to download CSV
    handleDownloadCSV() {
        const columnsData = JSON.parse(JSON.stringify(this.recordData));
        const columnsName = JSON.parse(JSON.stringify(this.tableColumns));

        let headers = {};

        columnsName.forEach((obj) => {
            headers[obj.apiFieldName] = obj.label;
            if(obj.label == 'Contact ID'){
                headers['List_Member__r'] = 'Contact Name'
            }
        });

        let csvData = [];
        const fieldObj = {
            Email__c: "Column_2__c",
            Mobile__c: "Column_3__c",
            Column_1_Value__c: "Column_4__c",
            Column_2_Value__c: "Column_5__c",
            Column_3_Value__c: "Column_6__c",
            Column_4_Value__c: "Column_7__c",
            Column_5_Value__c: "Column_8__c",
            Column_6_Value__c: "Column_9__c",
            Column_7_Value__c: "Column_10__c"
        }

        columnsData.forEach((obj) => {
            let newObj = {};
            for (var key in obj) {
                for (var index in headers) {
                    
                    if (fieldObj[key] && fieldObj[key] === index) {
                        newObj[fieldObj[key]] = obj[key];
                    } else {

                        if (key === index && key == 'List_Member__r') {   
                            newObj[key] = obj['List_Member__r']['Name'];    
                        }else if(key === index){
                            newObj[key] = obj[key];  
                        }
                    }
                }
            }
            csvData.push(newObj);
        });


        csvData.forEach((obj) => {
            for (var index in headers) {
                if (!obj[index]) {
                        obj[index] = "";
                }
            }
        });

        this.exportCSVFile(headers, csvData, CVS_DOWNLOAD_NAME);
    }

    // Method to Convert file to CSV
    convertToCSV(objArray, headers) {
        const columnDelimiter = ",";
        const lineDelimiter = "\r\n";
        const actualHeaderKey = Object.keys(headers);
        const headerToShow = Object.values(headers);
        let str = "";
        str += headerToShow.join(columnDelimiter);
        str += lineDelimiter;
        const data = typeof objArray !== "object" ? JSON.parse(objArray) : objArray;

        data.forEach((obj) => {
            let line = "";
            actualHeaderKey.forEach((key) => {
                if (line != "") {
                        line += columnDelimiter;
                }

                let strItem = obj[key] + "";
                line += strItem ? strItem.replace(/,/g, "") : strItem;
            });
            str += line + lineDelimiter;
        });

        return str;
    }

    // Method to Export CSV File
    exportCSVFile(headers, totalData, fileTitle) {
        if (!totalData || !totalData.length) {
            return null;
        }

        const jsonObject = JSON.stringify(totalData);
        const result = this.convertToCSV(jsonObject, headers);

        if (result === null) return;

        const blob = new Blob([result]);
        const exportedFilename = fileTitle ? fileTitle + ".csv" : "export.csv";

        if (navigator.msSaveBlob) {
            navigator.msSaveBlob(blob, exportedFilename);
        } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
            const link = window.document.createElement("a");
            link.href = "data:text/csv;charset=utf-8," + encodeURI(result);
            link.target = "_blank";
            link.download = exportedFilename;
            link.click();
        } else {
            const link = document.createElement("a");
            if (link.download !== undefined) {
                const url = URL.createObjectURL(blob);
                link.setAttribute("href", url);
                link.setAttribute("download", exportedFilename);
                link.style.visibility = "hidden";
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        }
    }

    handleImporCSV() {
        this.changeShowImportCSVModal(true);
    }

    changeShowImportCSVModal(e) {
        let isShowModal = false;
        if (typeof e.detail !== "undefined") {
            isShowModal = e.detail === true ? true : false;
        } else {
            isShowModal = e;
        }

        this.isShowImportCSVModal = isShowModal;
    }

    reloadListMembersTable() {
        this.dispatchEvent(new CustomEvent("reloadlistmemberstable", {
            detail: true
        }));
    }

    handleAddFromExistingListModal() {
        this.isAddFromExistingListModal = true;
    }

    handleShowModalExistingList(event){
        this.isAddFromExistingListModal = event.detail;
    }

    handleRecordListMemberHasError (event) {
        this.dispatchEvent(new CustomEvent("recordlistmemberhaserror", { detail: event.detail }));
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