import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ENGAGEMENT_LIST_CONFIGURATION_FIELD from "@salesforce/schema/Engagement_List_Configuration__c.Engagement_List_Configuration_Status__c";
import listOfCases from "@salesforce/apex/OutreachCaseImportCtrl.listOfCases";
import { NavigationMixin } from 'lightning/navigation';


const columns = [
  { label: 'Case Name', fieldName: 'name' },
  { label: 'Contact', fieldName: 'contact'},
  { label: 'Status', fieldName: 'status'  },
  { label: 'Case Owner', fieldName: 'amount'},
  { label: 'Created Date', fieldName: 'closeAt', type: 'date' },
];

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
      type: "date-local",
      typeAttributes:{
        month: "2-digit",
        day: "2-digit"
      }
    }
  ];

  @api recordId;
  @api objectApiName;
  @track showModal = false;
  @track showTable = false;

  data = [];
  columns = columns;
  rowOffset = 0;
  caseTable = [];

  @wire(getRecord, { recordId: "$recordId", fields })
  engagementListConfiguration;

  getListofCase(){
    listOfCases({
        recordId: this.recordId
    }).then(result => {
      const caseData = result.map(item => {
        return {
          caseNumber: item.CaseNumber,
          caseUrl: `/lightning/r/Case/${item.Id}/view`,
          contactName: item.Contact.Name,
          contactUrl: `/lightning/r/Contact/${item.ContactId}/view`,
          status: item.Status,
          ownerName: item.Owner.Name,
          ownerUrl: `/lightning/r/User/${item.OwnerId}/view`,
          createdDate: item.CreatedDate
        }
      })
      this.data = caseData;
      this.showTable = this.data.length == 0 ? false : true;
    }).catch((error) =>{
      console.log('ERROR ::: ', error);

    })
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
    this.showTable = this.data.length == 0 ? false : true;
  }

  handleButtonOpenModal() {
    this.showModal = true;
  }

  handleCloseModal(event) {
    this.showModal = event.detail.close;
    setTimeout((e) => {
      this.getListofCase();
    },500,this);
    this.showTable = this.data.length == 0 ? false : true;
    
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
        }
    })
  }
}