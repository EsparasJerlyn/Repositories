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
 *    | roy.nino.s.regala         | Sep 22, 2023          | DEPP-6365            | Added new field mapping and column logic                                    |
 *    | roy.nino.s.regala         | Oct 30, 2023          | DEPP-7024            | Added new field mapping and column logic                                    |
 */
import { LightningElement, api, track} from "lwc";
import getTableDataWrapper from "@salesforce/apex/SalesCadenceListViewCtrl.getTableDataWrapper";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import assignToMe from "@salesforce/apex/SalesCadenceListViewCtrl.assignToMe";

const ERROR_TOAST_VARIANT = "error";
const ERROR_TOAST_TITLE = "Error";
export default class SalesCadenceListView extends LightningElement {
  /* TARGET CONFIG START */
  @api calculatedCadence;
  /* TARGET CONFIG END */

  /* DATATABLE VARIABLES START */
  @track finalDataList = [];
  @track dataList = [];
  @track sortDirection = "DESC";
  @track sortBy = '';

  domesticPreAndPostOffer = [
    'Domestic First Offer to Acceptance',
    'Domestic Deferred Offer to Acceptance',
    'Domestic Accepted not yet Enrolled',
    'Domestic and International Enrolment to Census',
    'Domestic Offer Lapsed'
  ];

  domesticAcceptedAdmitted = [
    'Domestic Accepted and Admitted',
  ];

  //columns for domestic strong interest pre application cadence
  @track domesticPreApplicationColumns = [
    {
      label: "Name",
      fieldName: "name",
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
      label: "Primary Study Interest",
      fieldName: "primaryStudyInterest",
      type: "text",
      sortable: true
    },
    {
      label: "Status",
      fieldName: "completedCadenceStatus",
      type: "text",
      sortable: true
    },
    {
      label: "Entry Date",
      fieldName: "entryDate",
      type: "date",
      sortable: true,
      typeAttributes: { day: "numeric", month: "numeric", year: "numeric" }
    }
  ];

  //columns of all domestic cadences expect domestic strong interest pre application
  @track domesticColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      sortable: true
    },
    {
      label: "Offered Preference",
      fieldName: "offeredPreference",
      type: "text",
      sortable: true
    },
    {
      label: "Status",
      fieldName: "completedCadenceStatus",
      type: "text",
      sortable: true
    },
    {
      label: "Entry Date",
      fieldName: "entryDate",
      type: "date",
      sortable: true,
      typeAttributes: { day: "numeric", month: "numeric", year: "numeric" }
    }
  ];

  //columns for domestic with Offered Preference and Owning Faculty
  @track domesticPreAndPostOfferColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      sortable: true
    },
    {
      label: "Offered Program",
      fieldName: "offeredProgram",
      type: "text",
      sortable: true
    },
    {
      label: "Owning Faculty",
      fieldName: "offeredProgramOwningFaculty",
      type: "text",
      sortable: true
    },
    {
      label: "Status",
      fieldName: "completedCadenceStatus",
      type: "text",
      sortable: true
    },
    {
      label: "Entry Date",
      fieldName: "entryDate",
      type: "date",
      sortable: true,
      typeAttributes: { day: "numeric", month: "numeric", year: "numeric" }
    }
  ];

  //columns for domestic with Offered Program and Owning Faculty
  @track domesticAcceptedAdmittedColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      sortable: true
    },
    {
      label: "Offered Program",
      fieldName: "offeredProgram",
      type: "text",
      sortable: true
    },
    {
      label: "Owning Faculty",
      fieldName: "offeredProgramOwningFaculty",
      type: "text",
      sortable: true
    },
    {
      label: "QTAC Offer Round",
      fieldName: "qtacOfferRound",
      type: "number",
      sortable: true
    },
    {
      label: "Status",
      fieldName: "completedCadenceStatus",
      type: "text",
      sortable: true
    },
    {
      label: "Entry Date",
      fieldName: "entryDate",
      type: "date",
      sortable: true,
      typeAttributes: { day: "numeric", month: "numeric", year: "numeric" }
    }
  ];

  //columns for international strong interest pre application
  @track internationalPreApplicationColumns = [
    {
      label: "Name",
      fieldName: "name",
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
      label: "Citizenship Country",
      fieldName: "citizenshipCountry",
      type: "text",
      sortable: true,
      cellAttributes: {
        alignment: "left"
      }
    },
    {
      label: "Agent Assisted",
      fieldName: "agentAssisted",
      type: "boolean",
      sortable: true
    },
    {
      label: "Status",
      fieldName: "completedCadenceStatus",
      type: "text",
      sortable: true
    },
    {
      label: "Entry Date",
      fieldName: "entryDate",
      type: "date",
      sortable: true,
      typeAttributes: { day: "numeric", month: "numeric", year: "numeric" }
    }
  ];

  //columns of all international cadences expect international strong interest pre application
  @track internationalColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      sortable: true
    },
    {
      label: "Offered Preference",
      fieldName: "offeredPreference",
      type: "text",
      sortable: true
    },
    {
      label: "Citizenship Country",
      fieldName: "citizenshipCountry",
      type: "text",
      sortable: true,
      cellAttributes: {
        alignment: "left"
      }
    },
    {
      label: "Agent Assisted",
      fieldName: "agentAssisted",
      type: "boolean",
      sortable: true
    },
    {
      label: "Status",
      fieldName: "completedCadenceStatus",
      type: "text",
      sortable: true
    },
    {
      label: "Entry Date",
      fieldName: "entryDate",
      type: "date",
      sortable: true,
      typeAttributes: { day: "numeric", month: "numeric", year: "numeric" }
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

  get finalColumns() {
    if (this.calculatedCadence == "Domestic Strong Interest Pre-Application") {
      return this.domesticPreApplicationColumns;
    } else if (this.calculatedCadence.startsWith("Domestic")) {
        if (this.domesticAcceptedAdmitted.includes(this.calculatedCadence)) {
          return this.domesticAcceptedAdmittedColumns;
        } else if (this.domesticPreAndPostOffer.includes(this.calculatedCadence)) {
          return this.domesticPreAndPostOfferColumns;
        } else {
          return this.domesticColumns;
        }
    } else if (this.calculatedCadence == "International Strong Interest Pre-Application") {
      return this.internationalPreApplicationColumns;
    } else if (this.calculatedCadence.startsWith("International")) {
      return this.internationalColumns;
    }
    return this.internationalColumns;
  }

  get initialSortBy() {
    if (
      this.calculatedCadence == "Domestic Strong Interest Pre-Application" ||
      this.calculatedCadence == "International Strong Interest Pre-Application"
    ) {
      return "leadScore";
    }
    return "entryDate";
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
        this.sortBy = this.initialSortBy;
        this.sortDirection = 'DESC';
        if (this.dataList.length > 0) {
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
      if (x === "") {
        return 1;
      } else if (y === "") {
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
