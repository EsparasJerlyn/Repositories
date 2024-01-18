/**
 * @description Lightning Web Component for custom buttons.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                 | 
      | jerlyn.esparas            | January 10, 2024      | DEPP-6965            |                              | 
 */
import { LightningElement, wire, api } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import LIST_STAGE from "@salesforce/schema/List__c.Stage__c";

const CVS_DOWNLOAD_NAME = "lisData";

export default class CustomHeaderButtons extends LightningElement {
  @api recordId;
  @api selectedRows;
  statusSelected = 'Close';
  @api columnsName;
  @api columnsData;
  csvtemp;
  listMemberColumns = [LIST_STAGE];
  stageValue;

  // getter setter for isDisabledButton
  get isDisabledButton() {
     return this.stageValue === "Distribute" || this.stageValue === 'Closed' ? true : false;
}

  @wire(getRecord, { recordId: "$recordId", fields: "$listMemberColumns" })
     wiredList(responseData) {
          const { data, error } = responseData;

          if (data) {
               const fields = data.fields;
               this.stageValue = fields.Stage__c.value;
          }

     }

  // Method to download CSV
  handleDownloadCSV() {
    const columnsData = JSON.parse(JSON.stringify(this.columnsData));
    const columnsName = JSON.parse(JSON.stringify(this.columnsName));

    let headers = {};

    columnsName.forEach((obj) => {
      headers[obj.fieldName] = obj.label;
    });

    let csvData = [];

    columnsData.forEach((obj) => {
      let newObj = {};
      for (var key in obj) {
        console.log(key);
        for (var index in headers) {
          if (key === index) {
            newObj[key] = obj[key];
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
}
