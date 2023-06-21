/**
 * @description LWC that renders a dynamic datatable that similar to dynamic related list
 * @see ../classes/DynamicDataTableCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | roy.nino.s.regala         | June 14, 2023         | DEPP-5391            | Created file                                 |
 */
import { LightningElement, api, track, wire } from "lwc";
import getTableDataWrapper from "@salesforce/apex/DynamicDataTableCtrl.getTableDataWrapper";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getCurrentUserNavigationType from "@salesforce/apex/UserInfoService.getCurrentUserNavigationType";
import { isValidUrl, transformObject } from "c/lwcUtility";
export default class DynamicDataTable extends NavigationMixin(
  LightningElement
) {
  @api icon;
  @api relatedListLabel;
  @api parentRecord;
  @api relatedRecord;
  @api relatedField;
  @api relatedListFields;
  @api relatedListFilters;
  @api sortOrder;
  @api sortField;
  @api recordId;
  @api recordTypeName;
  @api showNewButton = false;
  @api newActionType;
  @api newScreenFlowApiName;
  @api showEditButton;
  @api editActionType;
  @api editScreenFlowApiName;
  @api dynamicDataTableInput = "";

  @track finalSObjectDataList = [];
  @track finalColumns = [];
  @track objectInfo;
  @track sortBy;
  @track sortDirection;

  rowOffSet = 0;
  rowLimit = 10;
  recordCount = 0;
  dataTableIsLoading = false;

  /* GETTERS START */
  get enableInfiniteLoading() {
    return this.recordCount > 10 &&
      this.recordCount != this.finalSObjectDataList.length
      ? true
      : false;
  }

  get numberOfRowsDisplay() {
    if (this.recordCount > 10) {
      return " (10+)";
    } else if (this.recordCount == 0) {
      return "";
    } else {
      return " (" + this.finalSObjectDataList.length + ")";
    }
  }

  get hasRecords() {
    return this.finalSObjectDataList.length > 0 ? true : false;
  }

  get heightLimit() {
    return this.recordCount > 10
      ? "table-height-limit slds-border_top"
      : "slds-border_top";
  }

  get isConsoleApp() {
    return this.navigationType == "Console" ? true : false;
  }

  get recordTypeId() {
    // Returns a map of record type Ids
    if (
      this.objectInfo &&
      this.objectInfo.data &&
      this.objectInfo.data.recordTypeInfos
    ) {
      const rtis = this.objectInfo.data.recordTypeInfos;
      return Object.keys(rtis).find(
        (rti) => rtis[rti].name === this.recordTypeName
      );
    } else {
      return "";
    }
  }

  get relatedObjectLabel() {
    // Returns a map of record type Ids
    if (this.objectInfo && this.objectInfo.data) {
      return this.objectInfo.data.label;
    }
  }
  /* GETTERS END */

  /*SERVER CALLS START */
  connectedCallback() {
    this.loadData(this.setParameters());
  }

  navigationType;
  @wire(getCurrentUserNavigationType)
  handleGetNavType(result) {
    const logger = this.template.querySelector("c-logger");
    if (result.data) {
      this.navigationType = result.data;
    } else if (result.error) {
      if (logger) {
        logger.error(JSON.stringify(error));
        logger.saveLog();
      }
    }
  }

  @wire(getObjectInfo, { objectApiName: "$relatedRecord" })
  objectInfo;

  setParameters() {
    this.dataTableIsLoading = this.rowOffSet == 0 ? true : false;
    let paramsMap = {};
    paramsMap["recordId"] = this.recordId;
    paramsMap["relatedRecord"] = this.relatedRecord;
    paramsMap["relatedField"] = this.relatedField;
    paramsMap["relatedListFields"] = this.relatedListFields;
    paramsMap["relatedListFilters"] = this.relatedListFilters
      ? "AND " + this.relatedListFilters
      : "";
    paramsMap["rowOffSet"] = this.rowOffSet;
    paramsMap["rowLimit"] = this.rowLimit;
    paramsMap["sortOrder"] = this.sortOrder;
    paramsMap["sortField"] = this.sortField;
    return paramsMap;
  }

  //loads the datatable column,data, and recordcount
  loadData(tableWrapperParams) {
    const logger = this.template.querySelector("c-logger");
    return getTableDataWrapper({
      tableWrapperParams: tableWrapperParams
    })
      .then((result) => {
        let sObjectRelatedFieldListValues = [];

        //traverse through the datatabledata records
        for (let row of result.dataTableData) {
          const finalSobjectRow = {};
          let rowIndexes = Object.keys(row);
          rowIndexes.forEach((rowIndex) => {
            const relatedFieldValue = row[rowIndex];
            //flatten the inner object of the records
            if (relatedFieldValue.constructor === Object) {
              transformObject(relatedFieldValue, finalSobjectRow, rowIndex);
            } else if (isValidUrl(relatedFieldValue)) {
              finalSobjectRow[rowIndex] = relatedFieldValue;
              finalSobjectRow[rowIndex + "Url"] = relatedFieldValue;
            } else if (rowIndex == "Id") {
              finalSobjectRow[rowIndex] = relatedFieldValue;
              finalSobjectRow[rowIndex + "Url"] = "/" + relatedFieldValue;
            } else {
              finalSobjectRow[rowIndex] = relatedFieldValue;
            }
          });
          sObjectRelatedFieldListValues.push(finalSobjectRow);
        }

        let tempSObjectDataList =
          this.rowOffSet == 0
            ? sObjectRelatedFieldListValues
            : [...this.finalSObjectDataList, ...sObjectRelatedFieldListValues];

        this.finalSObjectDataList = tempSObjectDataList;

        //if show edit button is checked, add edit action to the datatable
        this.finalColumns = this.showEditButton
          ? this.addActionsToColumn(result.dataTableColumns, result.recordCount)
          : result.dataTableColumns;
        this.recordCount = result.recordCount;
      })
      .catch((error) => {
        if (logger) {
          logger.error(JSON.stringify(error));
          logger.saveLog();
        }
      })
      .finally(() => {
        this.dataTableIsLoading = false;
      });
  }

  loadMoreData(event) {
    event.preventDefault();
    const { target } = event;
    target.isLoading = true;
    this.rowOffSet = this.rowOffSet + this.rowLimit;
    this.loadData(this.setParameters()).then(() => {
      target.isLoading = false;
    });
  }

  handleRefreshData() {
    this.rowOffSet = 0;
    this.loadData(this.setParameters());
  }
  /*SERVER CALLS END */

  /*DATATABLE CONFIGURATION START*/

  doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.finalSObjectDataList));

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
      return isReverse * ((x > y) - (y > x));
    });
    this.finalSObjectDataList = parseData;
  }

  addActionsToColumn(columns, recordCount) {
    let customActions = [{ label: "Edit", name: "edit" }];
    return [
      ...columns,
      {
        type: "action",
        typeAttributes: { rowActions: customActions },
        cellAttributes: { class: recordCount > 10 ? "slds-float_left" : "" }
      }
    ];
  }
  /*DATATABLE CONFIGURATION END*/

  /* ACTION HANDLERS START */
  handleNewRecord() {
    if (this.newActionType == "Screen Flow" && this.isConsoleApp) {
      this.handleNewRecordNavigateToNewTab();
    } else if (this.newActionType == "Screen Flow" && !this.isConsoleApp) {
      this.handleNewOnPageModal();
    } else if (this.newActionType == "LWC") {
      //add method that handles a lightning web component form
    } else {
      this.handleNewRecordByDefault();
    }
  }

  handleRowAction(event) {
    const row = event.detail.row;
    if (this.editActionType == "Default") {
      this.handleEditRecordByDefault(row.Id);
    } else if (this.editActionType == "Screen Flow") {
      this.handeEditRecordByScreenFlow(row);
    }
  }

  handleNewOnPageModal() {
    const popupModal = this.template.querySelector("c-dynamic-data-table-form");
    popupModal.recordId = "";
    popupModal.recordName = "";
    popupModal.sobjectApiName = this.relatedRecord;
    popupModal.sobjectLabel = this.relatedObjectLabel;
    popupModal.parentId = this.recordId;
    popupModal.relatedListLabel = this.relatedListLabel;
    popupModal.parentObjectApiName = this.parentRecord;
    popupModal.actionType = this.newActionType;
    popupModal.screenFlowApiName = this.newScreenFlowApiName;
    popupModal.recordTypeId = this.recordTypeId;
    popupModal.dynamicDataTableInput = this.dynamicDataTableInput;
    popupModal.showCloseButton = true;
    popupModal.show();
  }

  handeEditRecordByScreenFlow(row) {
    const popupModal = this.template.querySelector("c-dynamic-data-table-form");
    popupModal.recordId = row.Id;
    popupModal.recordName = row.Name;
    popupModal.sobjectApiName = this.relatedRecord;
    popupModal.sobjectLabel = this.relatedObjectLabel;
    popupModal.parentId = this.recordId;
    popupModal.relatedListLabel = this.relatedListLabel;
    popupModal.parentObjectApiName = this.parentRecord;
    popupModal.actionType = this.editActionType;
    popupModal.screenFlowApiName = this.editScreenFlowApiName;
    popupModal.recordTypeId = this.recordTypeId;
    popupModal.dynamicDataTableInput = this.dynamicDataTableInput;
    popupModal.showCloseButton = true;
    popupModal.show();
  }

  handleNewRecordByDefault() {
    let encodeDefault = {};
    encodeDefault[this.relatedField] = this.recordId;
    let defaultValues = encodeDefaultFieldValues(encodeDefault);

    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.relatedRecord,
        actionName: "new"
      },
      state: {
        defaultFieldValues: defaultValues,
        recordTypeId: this.recordTypeId,
        useRecordTypeCheck: this.recordTypeId ? "false" : "true"
      }
    });
  }

  handleEditRecordByDefault(recordId) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        actionName: "edit"
      }
    });
  }

  handleNewRecordNavigateToNewTab() {
    var compDefinition = {
      componentDef: "c:flowContainer",
      attributes: {
        inputVariables: [
          {
            name: "ParentId",
            type: "String",
            value: this.recordId
          },
          {
            name: "DynamicDataTableInput",
            type: "String",
            value: this.dynamicDataTableInput ? this.dynamicDataTableInput : ""
          },
          {
            name: "ParentObjectApiName",
            type: "String",
            value: this.parentRecord
          },
          {
            name: "RecordTypeId",
            type: "String",
            value: this.recordTypeId ? this.recordTypeId : ""
          }
        ],
        modalTitle: "New " + this.relatedObjectLabel,
        flowApiName: this.newScreenFlowApiName
      }
    };
    // Base64 encode the compDefinition JS object
    var encodedCompDef = btoa(JSON.stringify(compDefinition));
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/one/one.app#" + encodedCompDef
      }
    });
  }

  handleNavigateToListView() {
    // Navigate to the object's Recent list view.
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.relatedRecord,
        actionName: "list"
      },
      state: {
        filterName: "Recent"
      }
    });
  }

  /* ACTION HANDLERS END */
}
