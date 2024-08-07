import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ENGAGEMENT_LIST_CONFIGURATION_FIELD from "@salesforce/schema/Engagement_List_Configuration__c.Engagement_List_Configuration_Status__c";
import listOfCases from "@salesforce/apex/OutreachCaseImportCtrl.listOfCases";
import { NavigationMixin } from 'lightning/navigation';

const fields = [ENGAGEMENT_LIST_CONFIGURATION_FIELD];

export default class OutreachCaseImportController extends NavigationMixin(LightningElement) {
  tableColumns = [
    {
      label: 'Case Name',
      fieldName: 'caseUrl',
      editable: false,
      sortable: false,
      type: 'url',
      typeAttributes: { 
        label: { 
          fieldName: 'caseNumber' 
        }, 
        target: '_blank' 
      }
    },
    {
      label: 'Contact',
      fieldName: 'contactUrl',
      editable: false,
      sortable: false,
      type: 'url',
      typeAttributes: { 
        label: { 
          fieldName: 'contactName' 
        }, 
        target: '_blank' 
      }
    },
    {
      label: 'Status',
      fieldName: 'status',
      editable: false,
      sortable: false,
      type: 'text',
    },
    {
      label: 'Case Owner',
      fieldName: 'ownerUrl',
      editable: false,
      sortable: false,
      type: 'url',
      typeAttributes: { 
        label: { 
          fieldName: 'ownerName' 
        }, 
        target: '_blank' 
      }
    },
    {
      label: 'Created Date',
      fieldName: 'createdDate',
      editable: false,
      sortable: false,
      type: "text"
    }
  ];

  @api recordId;
  @api objectApiName;
  @track showModal = false;
  @track showTable = false;
  @track numberOfCases = 0;


  data = [];
  rowOffset = 0;
  caseTable = [];
  dataForViewAll = [];
  title = 'Cases';

  @wire(getRecord, { recordId: "$recordId", fields })
  engagementListConfiguration;

  getListofCase(){
    const logger = this.template.querySelector("c-logger");
    listOfCases({
        recordId: this.recordId
    }).then(result => {
      if (result.length > 0) {
        const caseData = result.map(item => {
          return {
            caseNumber: item.case.CaseNumber,
            caseUrl: `/lightning/r/Case/${item.case.Id}/view`,
            contactName: item.case.Contact.Name,
            contactUrl: `/lightning/r/Contact/${item.case.ContactId}/view`,
            status: item.case.Status,
            ownerName: item.case.Owner.Name,
            ownerUrl: `/lightning/r/User/${item.case.OwnerId}/view`,
            createdDate: item.caseCreatedDate
          }
        })
        
        const recordsToDisplay = [];
        if (caseData.length > 3) {
          for (let i = 0; i < 3; i++) {
            recordsToDisplay.push(caseData[i]);
          }
          this.data = recordsToDisplay;
        }else{
          this.data = caseData;
        }
        this.numberOfCases = caseData.length;
        this.dataForViewAll = caseData;
        this.showTable = recordsToDisplay.length > 3 ? false : true;
      }

    }).catch((error) =>{
      if (logger) {
        logger.error(
          "Exception caught in method loadData in LWC outreachCaseImportController: ",
          JSON.stringify(error)
        );
      }

    })
	}

  get caseTitle(){
    return this.title + ' (' + this.numberOfCases + ')';
  }

  get getStatus() {
    return getFieldValue(this.engagementListConfiguration.data, ENGAGEMENT_LIST_CONFIGURATION_FIELD) === 'Deactivated' ? true : false;
  }

  get isShowTable() {
    return this.showTable;
  }

  connectedCallback() {
    let caseColumns = ['Case Name', 'Contact', 'Status', 'Case Owner', 'Created Date'];
    const columns = this.tableColumns;
    const newCaseColumns = [];
    caseColumns.forEach((name) => {
      columns.forEach((obj) => {
        if (obj.label === name) {
          newCaseColumns.push(obj);
        }
      })
    });
    this.caseTable = newCaseColumns;
    this.getListofCase();
  }

  handleButtonOpenModal() {
    this.showModal = true;
  }

  handleCloseModal(event) {
    this.showModal = event.detail.close;
    setTimeout((e) => {
      this.getListofCase();
    },500,this);
  }

  async handleViewAll(methodName, methodArgs) {
    this[NavigationMixin.Navigate]({
        type: 'standard__component',
        attributes: {
            componentName: "c__outreachCaseRecord"
        },
        state: {
            c__objectId: this.recordId,
            c__objectName: this.objectApiName,
            c__data: this.dataForViewAll,
        }
    })
  }
}