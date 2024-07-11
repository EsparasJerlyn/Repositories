import { LightningElement, track, api } from 'lwc';

export default class CaseCreateLead extends LightningElement {
  @track isVisible = true;
  @api recordId;


get inputVariables() {
  return [
    {
      name: 'recordId',
      type: 'String',
      value: this.recordId
    },
  ]
}

 
}