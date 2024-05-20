import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ENGAGEMENT_LIST_CONFIGURATION_FIELD from "@salesforce/schema/Engagement_List_Configuration__c.Engagement_List_Configuration_Status__c";


const columns = [
  { label: 'Case Name', fieldName: 'name' },
  { label: 'Contact', fieldName: 'contact'},
  { label: 'Status', fieldName: 'status'  },
  { label: 'Case Owner', fieldName: 'amount'},
  { label: 'Created Date', fieldName: 'closeAt', type: 'date' },
];

const fields = [ENGAGEMENT_LIST_CONFIGURATION_FIELD];

export default class OutreachCaseImportController extends LightningElement {
  @api recordId;
  @track showModal = false;

  data = [];
  columns = columns;
  rowOffset = 0;

  @wire(getRecord, { recordId: "$recordId", fields })
  engagementListConfiguration;

  get getStatus() {
    return getFieldValue(this.engagementListConfiguration.data, ENGAGEMENT_LIST_CONFIGURATION_FIELD) === 'Deactivated' ? true : false;
  }

  connectedCallback() {
    for (let i = 0; i < 5; i++) {
      this.data.push({
          id: i,
          name: 'Case ' + i,
          contact: 'Contact ' + i,
          status: ['New', 'In Progress', 'Closed'][Math.floor(Math.random() * 3)], 
          amount: Math.floor(Math.random() * 10000),
          closeAt: new Date().toISOString()
      });
  }
}
  handleButtonOpenModal() {
    this.showModal = true;
  }

  handleCloseModal(event) {
    this.showModal = event.detail;
}
  
}