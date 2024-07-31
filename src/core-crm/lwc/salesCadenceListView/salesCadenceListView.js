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
 *    | roy.nino.s.regala         | Dec 11, 2023          | DEPP-7311            | Added assign to others logic                                                |
 */
import { LightningElement, api, track} from "lwc";
import getTableDataWrapper from "@salesforce/apex/SalesCadenceListViewCtrl.getTableDataWrapper";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import validateTargetsToAssign from "@salesforce/apex/SalesCadenceListViewCtrl.validateTargetsToAssign";
import assignToCadence from "@salesforce/apex/SalesCadenceListViewCtrl.assignToCadence";
import getSearchedUsers from "@salesforce/apex/SalesCadenceListViewCtrl.getSearchedUsers";
import getRecentlyViewed from "@salesforce/apex/SalesCadenceListViewCtrl.getRecentlyViewed";
import checkUserRole from "@salesforce/apex/SalesCadenceListViewCtrl.checkUserRole";

const ERROR_TOAST_VARIANT = "error";
const ERROR_TOAST_TITLE = "Error";
const MULTI_ASSIGN_ERROR_MSG = "Some of the contacts you selected have already been assigned to another user, those that weren't have now been assigned to you";
const SINGLE_ASSIGN_ERROR_MSG = "The contact you selected has already been assigned to another user";
export default class SalesCadenceListView extends LightningElement {
  /* TARGET CONFIG START */
  @api calculatedCadence;
  /* TARGET CONFIG END */

  /* DATATABLE VARIABLES START */
  @track finalDataList = [];
  @track dataList = [];
  @track sortDirection = "DESC";
  @track sortBy = '';

  domesticDeferredOfferOrEnrolment = [
    'Domestic Deferred Offer to Acceptance',
    'Domestic and International Enrolment to Census'
  ];

  domesticPreOrPostAcceptance = [
    'Domestic Accepted and Admitted',
    'Domestic First Offer to Acceptance',
    'Domestic Accepted not yet Enrolled',
    'Domestic Offer Lapsed'
  ];

  internationalPreOrPostAcceptance = [
    'International Application to Offer',
    'International Offer to Acceptance - Direct',
    'International Acceptance Deposit not Paid'
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
  @track domesticDeferredOfferOrEnrolmentColumns = [
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
  @track domesticPreOrPostAcceptanceColumns = [
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

  @track internationalPartnerSourcedColumns = [
    {
      label: "Name",
      fieldName: "name",
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

  @track internationalStrongApplicationColumns = [
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

  @track internationalApplicationColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      sortable: true
    },
    {
      label: "Current Preference",
      fieldName: "currentPreference",
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

  
  @track internationalPreOrPostAcceptanceColumns = [
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
      label: "Residence Country",
      fieldName: "residenceCountry",
      type: "text",
      sortable: true,
      cellAttributes: {
        alignment: "left"
      }
    },
    {
      label: "Partner Sourced",
      fieldName: "partnerSourced",
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
  showModal = false;
  header = 'Add to ';
  objectLabelName ='User';
  searchInProgress = false;
  searchedId = '';
  userSearchItems = [];
  recentlyViewed = [];
  filterString = '';
  isTeamLeader = false;
  hasAssignmentError = false;
  assignmentErrorMessage = '';
  filterArray = [];
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

  get hasNoUserSelected(){
    return !this.searchedId;
  }

  get finalSearchItems(){
    if(this.userSearchItems.length != 0){
      return this.userSearchItems;
    }else if(this.filterString.length == 0 || this.filterString.trim() == 0){
      return this.recentlyViewed;
    }
    return [];
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

  get showNoRecordsFound() {
    return this.recordCount == 0 && this.filterArray.length > 0;
  }

  get hasRecords() {
    return this.finalDataList.length > 0 ? true : false;
  }

  get finalColumns() {
    if (this.calculatedCadence == "Domestic Strong Interest Pre-Application") {
      return this.domesticPreApplicationColumns;
    } else if (this.calculatedCadence.startsWith("Domestic")) {
        if (this.domesticPreOrPostAcceptance.includes(this.calculatedCadence)) {
          return this.domesticPreOrPostAcceptanceColumns;
        } else if (this.domesticDeferredOfferOrEnrolment.includes(this.calculatedCadence)) {
          return this.domesticDeferredOfferOrEnrolmentColumns;
        } else {
          return this.domesticColumns;
        }
    } else if (this.calculatedCadence == "International Strong Interest Pre-Application") {
      return this.internationalStrongApplicationColumns;
    } else if (this.calculatedCadence == "International Pre-Application - Partner Sourced"){
      return this.internationalPartnerSourcedColumns;
    } else if (this.internationalPreOrPostAcceptance.includes(this.calculatedCadence)){
      return this.internationalPreOrPostAcceptanceColumns;
    } else if (this.calculatedCadence == "International Application Submission - Direct Applicant"){
      return this.internationalApplicationColumns;
    }
    return this.internationalColumns;
  }

  get columnFieldNames(){
    return this.finalColumns.map((col) => {
      return col['fieldName'];
    });
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
    this.checkIfTeamLeader();
  }

  checkIfTeamLeader(){
    return checkUserRole({})
    .then((result)=>{
      this.isTeamLeader = result;
    })
  }

  //loads the datatable column,data, and recordcount
  loadData(calculatedCadence) {
    const logger = this.template.querySelector("c-logger");
    this.dataTableIsLoading = true;
    this.dataList = [];
    return getTableDataWrapper({ calculatedCadence: calculatedCadence })
      .then((result) => {
        this.sortBy = this.sortBy ? this.sortBy : this.initialSortBy;
        this.sortDirection = this.sortDirection ? this.sortDirection : "DESC";

        if (this.filterArray.length > 0 && result.length > 0) {
          let filterDataList = result;
          //loop through the filter string separated by ';' as delimmiter
          for (let searchString of this.filterArray) {
            let tempfilterDataList = [];
            //loop through the column field names
            for (let fieldName of this.columnFieldNames) {
              tempfilterDataList = [
                ...tempfilterDataList,
                ...this.filteredRecords(filterDataList, fieldName, searchString)
              ];
            }
            filterDataList = tempfilterDataList;
          }

          //collect the ids
          const ids = filterDataList.map(({ id }) => id);

          //remove duplicates
          this.dataList = filterDataList.filter(
            ({ id }, index) => !ids.includes(id, index + 1)
          );
        } else {
          this.dataList = result;
        }
      })
      .then(() => {
        this.recordCount = this.dataList.length;
        this.sortData(this.sortBy, this.sortDirection);
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

  handleSearchUser(event){
    this.searchInProgress = true;
    this.filterString = event.detail.filterString.trim();
    const logger = this.template.querySelector("c-logger");
    getSearchedUsers({
        filterString: this.filterString,
        citizenship: this.calculatedCadence.split(' ')[0]
    })
    .then(result =>{
        if(result){
            this.userSearchItems = result;
        }else{
            this.userSearchItems = [];
        }
    })
    .finally(()=>{
        this.searchInProgress = false;
    })
    .catch(error =>{
        if (logger) {
          logger
            .error(
              "Exception caught in method handleSearchUser in LWC salesCadenceListView: "
            )
            .setError(error);
          logger.saveLog();
        }
        this.generateToast('Error.',LWC_Error_General,'error');
    });
  }
  handleLookupSelect(event){
    this.searchedId = event.detail.value;
  }
  handleLookupRemove(){
    this.searchedId = '';
    this.userSearchItems = [];
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
    this.handleValidateTargetsToAssign(this.userId);
  }

  handleAssignToOther() {
    this.handleValidateTargetsToAssign(this.searchedId);
    this.closeModal();
  }

  handleValidateTargetsToAssign(userId){
    const logger = this.template.querySelector("c-logger");
    this.dataTableIsLoading = true;
    return validateTargetsToAssign({
      targetIds: this.getTargetIds(),
      calculatedCadence: this.calculatedCadence
    })
    .then((returnedTargetIds)=>{
      if(returnedTargetIds.length != this.selectedRowsData.length){
        this.assignmentErrorMessage = this.selectedRowsData.length > 1?MULTI_ASSIGN_ERROR_MSG:SINGLE_ASSIGN_ERROR_MSG;
        this.hasAssignmentError = true;
      }
      return assignToCadence({
        targetsToEnroll: this.setTargetObject(this.calculatedCadence, returnedTargetIds,userId),
        targetsToChange: JSON.stringify(
          this.setTargetObject(this.calculatedCadence + " Edit", returnedTargetIds,userId)
        )
      })
    })
    .then(()=>{
      this.handleRefreshData();
      if(this.hasAssignmentError){
        
        this.generateToast(
          ERROR_TOAST_TITLE,
          this.assignmentErrorMessage,
          ERROR_TOAST_VARIANT
        );
      }
    })
    .catch((error)=> {
      if(error.message && error.message.includes('UNABLE_TO_LOCK_ROW')){
        this.assignmentErrorMessage = this.selectedRowsData.length > 1?MULTI_ASSIGN_ERROR_MSG:SINGLE_ASSIGN_ERROR_MSG;
        this.generateToast(
          ERROR_TOAST_TITLE,
          this.assignmentErrorMessage,
          ERROR_TOAST_VARIANT
        );
      }else{
        this.generateToast(
          ERROR_TOAST_TITLE,
          LWC_Error_General,
          ERROR_TOAST_VARIANT
        );
      }
      if (logger) {
        logger
          .error(
            "Exception caught in method handleValidateTargetsToAssign in LWC salesCadenceListView: "
          )
          .setError(error);
        logger.saveLog();
      }
    })
    .finally(() => {
      this.dataTableIsLoading = false;
      this.hasAssignmentError = false;
    });
  }

  handleFilter(event) {
    const searchKey = event.target.value.toLowerCase();
    const searchArray =
      searchKey.trim().length === 0 ? [] : searchKey.trim().split(";").map(key => key.trim());
    this.filterArray = searchArray;
  }

  handleCommit() {
    this.handleRefreshData();
  }

  closeModal(){
    this.showModal = false;
    this.searchedId = '';
    this.userSearchItems = [];
  }

  handleAssignToOtherSearch(){
    this.showModal = true;
    return getRecentlyViewed({
        citizenship: this.calculatedCadence.split(' ')[0]
    }).then((result)=>{
      if(result){
        this.recentlyViewed = result;
      }else{
        this.recentlyViewed = [];
      }
    })
  }

  /* ACTION HANDLERS END */

  /* HELPER METHOD START */

  setTargetObject(calculatedCadence,targetIds,userId) {
    let targets = [];
    targets = [...targetIds].map((key) => {
      let target = {};
      target.targetId = key;
      target.salesCadenceNameOrId = calculatedCadence;
      target.userId = userId;
      return target;
    });
    return targets;
  }

  getTargetIds(){
    let targets = [];
    targets = [...this.selectedRowsData].map((key) => {
      return key.id;
    });
    return targets;
  }

  //filter out the records where field name value includes the filter string
  //e.g QTAC Offer Round column value includes 250
  filteredRecords(filteredList, fieldName, filterString) {
    return filteredList.filter(
      (record) =>
        //only proceed if value is type of boolean or value is valid
        (typeof record[fieldName] == "boolean" || record[fieldName]) &&
        //compare to a date string for date filters.
        (this.convertDate(record[fieldName].toString().slice(0, 10)).includes(
            filterString
          ) ||
          record[fieldName].toString().toLowerCase().includes(filterString))
    );
  }

  //converts YYYY-mm-dd to dd/mm/YYYY
  convertDate(dateString) {
    let p = dateString.split(/\D/g);
    return [p[2], p[1], p[0]].join("/");
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
