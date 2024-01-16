/**
 * @description Lightning Web Component for custom buttons.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                            |
      |---------------------------|-----------------------|----------------------|-------------------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                              |
      | nicole.genon@qut.edu.au   | January 15, 2024      | DEPP-6966            | Added wiredList and isDisabledButton      | 
      | kenneth.f.alsay           | January 15, 2024      | DEPP-6964            | Added handleStatusClick, handlerShowModal |  
      |                           |                       |                      |                                           | 
 */
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord  } from 'lightning/uiRecordApi';
import LIST_STAGE from '@salesforce/schema/List__c.Stage__c';

export default class CustomHeaderButtons extends LightningElement {
     @api selectedRows;
     result;
     showModal;
     showStatusPicklist;
     showSelectMembers;
     itemsSelected;
     @track listMembers;
     @track listMemberStatus;
     isShowModal = false;
     @api isRefresh;
     error;
     @api recordId;
     statusSelected = 'Close';
     stageValue;

     listMemberColumns = [LIST_STAGE];

     @wire(getRecord, { recordId: "$recordId", fields: "$listMemberColumns" })
     wiredList(responseData) {
          const { data, error } = responseData;

          if (data) {
               const fields = data.fields;
               this.stageValue = fields.Stage__c.value;
          }

     }

     get isDisabledButton() {
          return this.stageValue === "Distribute" || this.stageValue === 'Closed' ? true : false;
     }

     handleStatusClick(){
          if((JSON.parse(this.selectedRows)).length === 0){
               this.dispatchEvent(new ShowToastEvent({
                   title: 'Toast Error',
                   message: 'Please select a List Member to change the status.',
                   variant: 'error',
                   mode: 'dismissable'
               })); 
          }else{
               this.itemsSelected = JSON.parse(this.selectedRows);
               this.isShowModal = true;
          }       
     }
     handleRefresh(){
          this.dispatchEvent(new CustomEvent('handlerefresh', { 
               detail: true                            
          }));
     }

     handlerShowModal(event){
          this.isShowModal = event.detail;
     }
}