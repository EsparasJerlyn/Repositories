/**
 * @description LWC that renders a datatable for cadence sales cadence list view
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                                              |
 *    |---------------------------|-----------------------|----------------------|-----------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | July 14, 2023         | DEPP-5677            | Created file                                                                |
 */
import { LightningElement, api, track, wire } from "lwc";
import getTableDataWrapper from "@salesforce/apex/SalesCadenceListViewCtrl.getTableDataWrapper";
import removeTargetFromListView from "@salesforce/apex/SalesCadenceListViewCtrl.updateCalculatedCadence";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import assignToMe from "@salesforce/apex/SalesCadenceListViewCtrl.assignToMe";
import createCompletedTask from "@salesforce/apex/SalesCadenceListViewCtrl.createCompletedTask";

const ERROR_TOAST_VARIANT = "error";
const ERROR_TOAST_TITLE = "Error";
export default class DynamicDataTable extends LightningElement {
  /* TARGET CONFIG START */
  @api calculatedCadence;
  /* TARGET CONFIG END */

  /* DATATABLE VARIABLES START */
  @track finalDataList = [];
  @track dataList = [];
  @track sortBy = "leadScore";
  @track sortDirection = "DESC";
  @track finalColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      sortable: true
    },
    { label: "Gender", fieldName: "gender", type: "text", sortable: true },
    { label: "Email", fieldName: "email", type: "email", sortable: true },
    {
      label: "Country of Citizenship",
      fieldName: "countryOfCitizenship",
      type: "text",
      sortable: true
    },
    {
      label: "Country of Residency",
      fieldName: "countryOfResidency",
      type: "text",
      sortable: true
    },
    {
      label: "Lead Score",
      fieldName: "leadScore",
      type: "number",
      sortable: true,
      cellAttributes: {
        alignment: "left"
      }
    },
    {
      label: "Completed Cadence Status",
      fieldName: "completedCadenceStatus",
      type: "text",
      sortable: true
    }
  ];

  recordCount = 0;
  rowLimit = 10;
  selectedRows = [];
  selectedRowsData = [];
  userId = Id;
  /* DATATABLE VARIABLES END */

  /*USER EXPERIENCE VARIABLES START*/
  dataTableIsLoading = false;
  /*USER EXPERIENCE VARIABLES END */

  /* GETTERS START */
  get numberOfRowsDisplay() {
    if (this.recordCount > 10) {
      return " (10+)";
    } else if (this.recordCount == 0) {
      return "";
    } else {
      return " (" + this.finalDataList.length + ")";
    }
  }

  get hasNoRowSelected() {
    return this.selectedRowsData.length == 0;
  }

  get heightLimit() {
    return this.recordCount > 10
      ? "table-height-limit slds-border_top"
      : "slds-border_top";
  }

  get enableInfiniteLoading() {
    return this.recordCount > 10 &&
      this.recordCount != this.finalDataList.length
      ? true
      : false;
  }

  get hasRecords() {
    return this.finalDataList.length > 0 ? true : false;
  }

  /* GETTERS END */

  /*SERVER CALLS START */
  connectedCallback() {
    this.loadData(this.calculatedCadence);
  }

  //loads the datatable column,data, and recordcount
  loadData(calculatedCadence) {
    const logger = this.template.querySelector("c-logger");
    this.dataTableIsLoading = true;
    return getTableDataWrapper({ calculatedCadence: calculatedCadence })
      .then((result) => {
        this.dataList = result;
        this.recordCount = this.dataList.length;
        if (this.dataList.length > 0 && this.sortBy && this.sortDirection) {
          this.sortData(this.sortBy, this.sortDirection);
        } else {
          let splicedData = [...this.dataList].splice(0, this.rowLimit);
          this.finalDataList = splicedData;
        }
      })
      .catch((error) => {
        if (logger) {
          logger
            .error(
              "Exception caught in method loadData in LWC salesCadenceListView: "
            )
            .setError(error);
          logger.saveLog();
        }
      })
      .finally(() => {
        this.dataTableIsLoading = false;
      });
  }

  /*SERVER CALLS END */

  /*DATATABLE CONFIGURATION START*/

  loadMoreData(event) {
    event.preventDefault();
    const { target } = event;
    target.isLoading = true;
    let tempRowLimit = this.rowLimit + 10;
    this.processLoadMoreData(tempRowLimit, target);
  }

  processLoadMoreData(limit, target) {
    target.isLoading = false;
    this.rowLimit = limit;
    let splicedData = [...this.dataList].splice(0, limit);
    this.finalDataList = splicedData;
  }

  doSorting(event) {
    this.selectedRows = [];
    this.selectedRowsData = [];
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.dataList));

    //find the column to use its attributes using the fieldName
    let currentColumn = this.finalColumns.find(
      (key) => key.fieldName == fieldname
    );

    //if column type is url sort must be by label value and not the url value
    let keyValue = (a) => {
      return currentColumn.type == "url"
        ? a[currentColumn.typeAttributes.label.fieldName]
        : a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === "asc" ? 1 : -1;
    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ""; // handling null values
      y = keyValue(y) ? keyValue(y) : "";
      // sorting values based on direction
      if (x == "") {
        return 1;
      } else if (y == "") {
        return -1;
      } else {
        return isReverse * ((x > y) - (y > x));
      }
    });
    this.dataList = parseData;
    let splicedData = [...this.dataList].splice(0, this.rowLimit);
    this.finalDataList = splicedData;
  }

  getRowSelected(event) {
    this.selectedRowsData = event.detail.selectedRows;
  }

  /* ACTION HANDLERS START */
  handleRefreshData() {
    this.rowLimit = 10;
    this.selectedRows = [];
    this.selectedRowsData = [];
    this.loadData(this.calculatedCadence);
  }

  handleAssignToMe() {
    const logger = this.template.querySelector("c-logger");
    this.dataTableIsLoading = true;
    return assignToMe({
      targetsToEnroll: this.setTargetObject(this.calculatedCadence),
      targetsToChange: JSON.stringify(
        this.setTargetObject(this.calculatedCadence + " Edit")
      )
    })
      .then(() => {
        this.handleRefreshData();
      })
      .catch((error) => {
        this.generateToast(
          ERROR_TOAST_TITLE,
          LWC_Error_General,
          ERROR_TOAST_VARIANT
        );
        if (logger) {
          logger
            .error(
              "Exception caught in method handleAssignToMe in LWC salesCadenceListView: "
            )
            .setError(error);
          logger.saveLog();
        }
      })
      .finally(() => {
        this.dataTableIsLoading = false;
      });
  }

  handleRemoveTargetFromListView() {
    const logger = this.template.querySelector("c-logger");
    this.dataTableIsLoading = true;
    return removeTargetFromListView({
      targetToUpdate: JSON.stringify(this.setTargetObject(null))
    })
      .then(() => {
        return createCompletedTask({ taskRecords: this.setTaskObjects() });
      })
      .catch((error) => {
        this.generateToast(
          ERROR_TOAST_TITLE,
          LWC_Error_General,
          ERROR_TOAST_VARIANT
        );
        if (logger) {
          logger
            .error(
              "Exception caught in method handleRemoveTargetFromListView in LWC salesCadenceListView: "
            )
            .setError(error);
          logger.saveLog();
        }
      })
      .finally(() => {
        this.handleRefreshData();
        this.dataTableIsLoading = false;
      });
  }

  /* ACTION HANDLERS END */

  /* HELPER METHOD START */

  setTargetObject(calculatedCadence) {
    let targets = [];
    targets = [...this.selectedRowsData].map((key) => {
      let target = {};
      target.targetId = key.id;
      target.salesCadenceNameOrId = calculatedCadence;
      target.userId = this.userId;
      return target;
    });
    return targets;
  }

  setTaskObjects() {
    let tasks = [];
    tasks = [...this.selectedRowsData].map((key) => {
      let task = {};
      task.Subject = "Removed from Cadence";
      task.OwnerId = this.userId;
      task.Status = "Completed";
      task.Priority = "Normal";
      task.WhoId = key.id;
      task.Description = this.calculatedCadence;
      return task;
    });
    return tasks;
  }

  /**
   * creates toast notification
   */
  generateToast(_title, _message, _variant) {
    const evt = new ShowToastEvent({
      title: _title,
      message: _message,
      variant: _variant
    });
    this.dispatchEvent(evt);
  }

  /*HELPER METHODS END*/
}
