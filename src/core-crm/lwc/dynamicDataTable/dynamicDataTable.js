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
 *    | roy.nino.s.regala         | June 24, 2023         | DEPP-5411            | Added Visibility Check                       |
 */
import { LightningElement, api, track, wire } from "lwc";
import getTableDataWrapper from "@salesforce/apex/DynamicDataTableCtrl.getTableDataWrapper";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getCurrentUserNavigationType from "@salesforce/apex/UserInfoService.getCurrentUserNavigationType";
import { isValidUrl, transformObject } from "c/lwcUtility";
import Id from "@salesforce/user/Id";
import {
  subscribe,
  unsubscribe,
  onError,
  setDebugFlag,
  isEmpEnabled
} from "lightning/empApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class DynamicDataTable extends NavigationMixin(
  LightningElement
) {
  /* TARGET CONFIG START */
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
  @api defaultValues = "";
  @api showEditButton;
  @api editActionType;
  @api editScreenFlowApiName;
  @api dynamicDataTableInput = "";
  @api channelName = "/event/Dynamic_Datatable_Event__e";
  @api visibilityByParent = "";
  @api visibilityByUser = "";
  /* TARGET CONFIG END */

  /* DATATABLE VARIABLES START */
  @track finalSObjectDataList = [];
  @track finalColumns = [];
  @track objectInfo;
  @track sortBy;
  @track sortDirection;
  /* DATATABLE VARIABLES END */

  /*USER EXPERIENCE VARIABLES START */
  rowOffSet = 0;
  rowLimit = 10;
  recordCount = 0;
  dataTableIsLoading = false;
  subscription = {};
  visibilityCheckResult = false;
  userId = Id;
  isCustom = true;
  /*USER EXPERIENCE VARIABLES END */

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
    } else {
      return "";
    }
  }

  get isShowNewButton() {
    //if visiblity is controlled and show new button is checked
    return this.visibilityCheckResult && this.showNewButton;
  }

  /* GETTERS END */

  /*PLATFORM EVENT LOGIC START*/
  handleSubscribe() {
    subscribe(this.channelName, -1, this.refreshData).then((response) => {
      this.subscription = response;
    });
  }

  registerErrorListener() {
    onError((error) => {
      const logger = this.template.querySelector("c-logger");
      if (logger) {
        logger.error(JSON.stringify(error));
        logger.saveLog();
      }
    });
  }

  refreshData = (response) => {
    let obj = JSON.parse(JSON.stringify(response));
    let objData = obj.data.payload;
    if (
      objData.Parent_Id__c == this.recordId &&
      (objData.Dynamic_Datatable_Input__c == this.dynamicDataTableInput ||
        objData.Dynamic_Datatable_Input__c == this.recordTypeId) &&
      objData.CreatedById == this.userId
    ) {
      //only show custom toast when form is not standard
      if (this.isCustom) {
        this.showToast(objData.Message__c, "success", "dismissable");
      }
      //only refresh data if in console app/new tab
      //refresh the specific table by checking the dynamicdatatableinput and parentid
      this.handleRefreshData();
    }
  };

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription, (response) => {});
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  showToast(title, variant, mode) {
    const evt = new ShowToastEvent({
      title: title,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }

  /*PLATFORM EVENT LOGIC END*/

  /*SERVER CALLS START */
  connectedCallback() {
    this.loadData(this.setParameters());
    this.registerErrorListener();
    this.handleSubscribe();
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
    paramsMap["parentRecord"] = this.parentRecord;
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
    paramsMap["visibilityByUser"] = this.visibilityByUser;
    paramsMap["visibilityByParent"] = this.visibilityByParent;
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
        this.finalColumns =
          this.showEditButton && result.hasVisibility
            ? this.addActionsToColumn(
                result.dataTableColumns,
                result.recordCount
              )
            : result.dataTableColumns;
        this.recordCount = result.recordCount;
        this.visibilityCheckResult = result.hasVisibility;
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
    return [
      ...columns,
      {
        type: "action",
        typeAttributes: { rowActions: this.getRowActions },
        cellAttributes: { class: recordCount > 10 ? "slds-float_left" : "" }
      }
    ];
  }

  getRowActions = (row, doneCallback) => {
    let actions = [];
    if (row["UserRecordAccess.HasEditAccess"] == true) {
      actions.push({
        label: "Edit",
        name: "edit"
      });
    } else {
      actions.push({
        label: "No actions available",
        disabled: true
      });
    }
    doneCallback(actions);
  };
  /*DATATABLE CONFIGURATION END*/

  /* ACTION HANDLERS START */
  handleNewRecord() {
    this.isCustom = true;
    if (this.newActionType == "Screen Flow" && this.isConsoleApp) {
      this.handleNewRecordNavigateToNewTab();
    } else if (this.newActionType == "Screen Flow" && !this.isConsoleApp) {
      this.handleNewOnPageModal();
    } else if (this.newActionType == "LWC") {
      //add method that handles a lightning web component form
    } else {
      this.isCustom = false;
      this.handleNewRecordByDefault();
    }
  }

  handleRowAction(event) {
    const row = event.detail.row;
    if (this.editActionType == "Default") {
      this.isCustom = false;
      this.handleEditRecordByDefault(row.Id);
    } else if (this.editActionType == "Screen Flow") {
      this.isCustom = true;
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

    if (this.defaultValues) {
      encodeDefault = { ...encodeDefault, ...JSON.parse(this.defaultValues) };
    }

    let finalDefaultValues = encodeDefaultFieldValues(encodeDefault);

    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.relatedRecord,
        actionName: "new"
      },
      state: {
        defaultFieldValues: finalDefaultValues,
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
