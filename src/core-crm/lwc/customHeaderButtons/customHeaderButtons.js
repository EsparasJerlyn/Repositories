/**
 * @description Lightning Web Component for custom buttons.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                            |
      |---------------------------|-----------------------|----------------------|-------------------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                              | 
      | kenneth.f.alsay           | January 15, 2024      | DEPP-6964            | Added handleStatusClick, handlerShowModal |  
      |                           |                       |                      |                                           | 
 */
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ListMemberStatusModal from 'c/listMemberStatusModal';
import updateListMembers from '@salesforce/apex/CustomHeaderButtonsCtrl.updateListMemberStatus';

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