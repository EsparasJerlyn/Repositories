/**
 * @description LWC that renders a dynamic datatable that similar to dynamic related list
 * @see ../classes/DynamicDataTableCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                                              |
 *    |---------------------------|-----------------------|----------------------|-----------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | June 14, 2023         | DEPP-5391            | Created file                                                                |
 *    | roy.nino.s.regala         | June 24, 2023         | DEPP-5411            | Added Visibility Check                                                      |
 *    | roy.nino.s.regala         | July 11, 2023         | DEPP-5459            | removed isvalidurl and only subscribe to event channel on new and edit      |
 *    | eugene.andrew.abuan       | August 14, 2023       | DEPP-6331            | Added newActionTypeLabel property                                           |
 *    | roy.nino.s.regala         | August 25, 2023       | DEPP-6348            | flatten inner fields,added user access checker, and dynamic link access     |
 *    | roy.nino.s.regala         | Feb 28, 2023          | DEPP-8155            | enable locking of edit button of related list by parent field               |
 *    | roy.nino.s.regala         | March 19, 2024        | DEPP-7885            | refresh table on parent updates                                             |
 *
 */
import { LightningElement, api, track, wire } from "lwc";
import getTableDataWrapper from "@salesforce/apex/DynamicDataTableCtrl.getTableDataWrapper";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord } from 'lightning/uiRecordApi';
import getCurrentUserNavigationType from "@salesforce/apex/UserInfoService.getCurrentUserNavigationType";
import { isValidUrl } from "c/lwcUtility";
import Id from "@salesforce/user/Id";
import { subscribe, unsubscribe, onError } from "lightning/empApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import customDataTableStyle from "@salesforce/resourceUrl/CustomDynamicDataTable";
import { loadStyle } from "lightning/platformResourceLoader";
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
  @api newActionTypeLabel;
  @api newScreenFlowApiName;
  @api defaultValues = "";
  @api showEditButton;
  @api editActionType;
  @api editScreenFlowApiName;
  @api dynamicDataTableInput = "";
  @api channelName = "/event/Dynamic_Datatable_Event__e";
  @api visibilityByParent = "";
  @api visibilityByUser = "";
  @api numberOfRows;
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
  userId = Id;
  isCustom = true;
  userAccessInfo = [];
  visibilityCheckResultByUser = false;
  visibilityCheckResultByParent = false;
  showViewLess = false;
  enableViewLessButton = false;
  /*USER EXPERIENCE VARIABLES END */

  /* GETTERS START */
  get enableInfiniteLoading() {
    return this.recordCount > 10 &&
      this.recordCount != this.finalSObjectDataList.length
      && this.enableViewLessButton
      ? true
      : false;
  }

  get enableViewAllButton(){
    return (this.recordCount > 10 || this.recordCount > this.numberOfRows) && !this.enableViewLessButton;
  }

  get reactiveRecordId() {
    return this.recordId;
  }

  get reactiveParentId(){
    return this.parentRecord + '.Id';
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
    return this.recordCount > 10 && this.enableViewLessButton
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
    return this.visibilityCheckResultByUser && this.visibilityCheckResultByParent  && this.showNewButton;
  }

  get newActionLabel() {
    // Returns a button label for exsiting flexipages
    if (
      this.newActionTypeLabel == undefined ||
      this.newActionTypeLabel != "Link"
    ) {
      this.newActionTypeLabel = "New";
    }
    return this.newActionTypeLabel;
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
        logger.error(
          "Exception caught in method registerErrorListener in LWC dynamicDataTable: ",
          JSON.stringify(error)
        );
      }
    });
  }

  refreshData = (response) => {
    let obj = JSON.parse(JSON.stringify(response));
    let objData = obj.data.payload;
    if (
      objData.Parent_Id__c == this.recordId &&
      objData.Message__c.includes(this.relatedObjectLabel) &&
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
    Promise.all([loadStyle(this, customDataTableStyle)]).then(() => {
      this.loadData(this.setParameters());
      this.registerErrorListener();
    });
  }

  navigationType;
  @wire(getCurrentUserNavigationType)
  handleGetNavType(result) {
    if (result.data) {
      this.navigationType = result.data;
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
    paramsMap["rowLimit"] = this.numberOfRows < 10 && !this.enableViewLessButton ? this.numberOfRows : 10;
    paramsMap["sortOrder"] = this.sortOrder;
    paramsMap["sortField"] = this.sortField;
    paramsMap["visibilityByUser"] = this.visibilityByUser;
    paramsMap["visibilityByParent"] = this.visibilityByParent;
    return paramsMap;
  }
  
  @wire(getRecord, { recordId: '$reactiveRecordId', fields: ['$reactiveParentId'] })
  wiredRecord(result) {
    this.record = result;
    if (result.data) {
        this.handleRefreshData()
    }
  }

  //loads the datatable column,data, and recordcount
  loadData(tableWrapperParams) {
    const logger = this.template.querySelector("c-logger");
    return getTableDataWrapper({
      tableWrapperParams: tableWrapperParams
    })
      .then((result) => {
        this.userAccessInfo = result.userAccessTable;
        let sObjectRelatedFieldListValues = [];
        //traverse through the datatabledata records
        for (let row of result.dataTableData) {
          const finalSobjectRow = {};
          let rowIndexes = Object.keys(row);
          rowIndexes.forEach((rowIndex) => {
            const relatedFieldValue = row[rowIndex];
            //flatten the inner object of the records
            if (relatedFieldValue.constructor === Object) {
              this.transformObject(
                relatedFieldValue,
                finalSobjectRow,
                rowIndex,
                result.userAccessTable
              );
            } else if (rowIndex == "Id") {
              finalSobjectRow[rowIndex] = relatedFieldValue;
              finalSobjectRow[rowIndex + "Url"] = "/" + relatedFieldValue;
              if (
                result.userAccessTable &&
                result.userAccessTable.find(
                  (row) => row.RecordId == relatedFieldValue
                ) &&
                result.userAccessTable.find(
                  (row) => row.RecordId == relatedFieldValue
                ).HasReadAccess == false
              ) {
                finalSobjectRow["linkStyle"] = "datatable-unlink";
              }
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
        this.finalColumns = this.customizeColumn(
          result.dataTableColumns.map((x) => ({ ...x })),
          result.recordCount
        );
        this.recordCount = result.recordCount;
        this.visibilityCheckResultByUser = result.hasAcessByUser;
        this.visibilityCheckResultByParent = result.hasAccessByParent;
      })
      .catch((error) => {
        if (logger) {
          logger.error(
            "Exception caught in method loadData in LWC dynamicDataTable: ",
            JSON.stringify(error)
          );
        }
      })
      .finally(() => {
        this.unsubscribeToMessageChannel();
        this.dataTableIsLoading = false;
      });
  }

  loadMoreData(event) {
    event.preventDefault();
    const { target } = event;
    target.isLoading = true;
    this.rowOffSet = this.rowOffSet + 10;
    this.loadData(this.setParameters()).then(() => {
      target.isLoading = false;
    });
  }

  handleRefreshData() {
    this.finalSObjectDataList = [];
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
      if (x == "") {
        return 1;
      } else if (y == "") {
        return -1;
      } else {
        return isReverse * ((x > y) - (y > x));
      }
    });
    this.finalSObjectDataList = parseData;
  }

  customizeColumn(columns, recordCount) {
    columns.forEach((element) => {
      if (
        element.type == "url" &&
        ((element.fieldName.includes(".IdUrl") &&
        !element.fieldName
          .substring(0, element.fieldName.indexOf(".IdUrl"))
          .includes(".")) ||
          element.fieldName == "IdUrl")
      ) {
        element.cellAttributes = {
          alignment: "left",
          class: {
            fieldName:
              element.fieldName.substring(
                0,
                element.fieldName.indexOf("IdUrl")
              ) + "linkStyle"
          }
        };
      } else {
        element.cellAttributes = {
          alignment: "left"
        };
      }
    });

    return this.showEditButton
      ? this.addActionsToColumn(columns, recordCount)
      : columns;
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
    if (
      this.userAccessInfo &&
      this.userAccessInfo.find((key) => key.RecordId == row.Id).HasEditAccess &&
      this.visibilityCheckResultByParent
    ) {
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

  //added this recursive method here
  //because dynamic link style is unique to this component
  transformObject = (
    fieldValue,
    finalSobjectRow,
    fieldName,
    userAccessData
  ) => {
    let rowIndexes = Object.keys(fieldValue);
    rowIndexes.forEach((key) => {
      let finalKey = fieldName + "." + key;

      if (
        userAccessData &&
        userAccessData.find((row) => row.RecordId == fieldValue[key]) &&
        userAccessData.find((row) => row.RecordId == fieldValue[key])
          .HasReadAccess == false
      ) {
        finalSobjectRow[fieldName + ".linkStyle"] = "datatable-unlink";
      }

      finalSobjectRow[finalKey] = fieldValue[key];
      if (key == "Id") {
        finalSobjectRow[finalKey + "Url"] = "/" + fieldValue[key];
      } else if (isValidUrl(fieldValue[key])) {
        finalSobjectRow[finalKey + "Url"] = fieldValue[key];
      }

      if (fieldValue[key].constructor === Object) {
        //added recursive method to cater more levels of look up fields
        this.transformObject(
          fieldValue[key],
          finalSobjectRow,
          finalKey,
          userAccessData
        );
      }
    });
  };

  /*DATATABLE CONFIGURATION END*/

  /* ACTION HANDLERS START */
  handleNewRecord() {
    this.isCustom = true;
    this.handleSubscribe();
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
    this.handleSubscribe();
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

  handleViewAll(){
    this.enableViewLessButton = true;
    this.handleRefreshData();
  }

  handleViewLess() {
    this.enableViewLessButton = false;
    this.handleRefreshData();
  }
  /* ACTION HANDLERS END */
}
