import { LightningElement, track } from 'lwc';


const columns = [
  { label: 'Case Name', fieldName: 'name' },
  { label: 'Contact', fieldName: 'contact'},
  { label: 'Status', fieldName: 'status'  },
  { label: 'Case Owner', fieldName: 'amount'},
  { label: 'Created Date', fieldName: 'closeAt', type: 'date' },
];

export default class OutreachCaseImportController extends LightningElement {

  @track showModal = false;

  data = [];
  columns = columns;
  rowOffset = 0;

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

  handleCloseModal() {
    this.showModal = false;
}
  
}