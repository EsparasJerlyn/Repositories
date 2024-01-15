/**
 * @description Lightning Web Component for custom buttons.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                 | 
      |                           |                       |                      |                              | 
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
     @api itemsSelected;
     @track listMembers;
     @track listMemberStatus;
     error;

     handleStatusClick(){
          ListMemberStatusModal
          .open({
               size: "small",
               modalTitle: "List Member Status"
          })
          .then((result) => {
               this.result = result;
               this.handleStatusSave(this.result);
          });         
     }
     handleStatusSave(result){
          const value = JSON.parse(result);
          if(this.selectedRows.size === 0){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Toast Error',
                    message: 'Please select a List Member to change the status.',
                    variant: 'error',
                    mode: 'dismissable'
                }));   
          }else if(value.action === 'Save' && value.data){
               updateListMembers({listMembers: JSON.parse(this.selectedRows), status: value.data})
               .then((result) => {
                    console.log(result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'Success',
                            message : `Records saved succesfully!`,
                            variant : 'success',
                        }),
                    )
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    console.log("Error in Save call back:", this.error);
                });
          }
     }    
}