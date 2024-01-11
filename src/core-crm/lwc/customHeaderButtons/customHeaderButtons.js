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
import { LightningElement, api } from 'lwc';
import ListMemberStatusModal from 'c/listMemberStatusModal';

export default class CustomHeaderButtons extends LightningElement {
     result;
     showModal;
     showStatusPicklist;
     showSelectMembers;
     itemsSelected = [];
     //@api selectedRows;

     handleStatusClick(){
          console.log(this.itemsSelected);
          if(this.itemsSelected != null){
               this.showStatusPicklist = true;
               this.showSelectMembers = false;
          }
          else{
               this.showStatusPicklist = false;
               this.showSelectMembers = true;
          }
          ListMemberStatusModal
          .open({
               size: "small",
               modalTitle: "List Member Status"
          })
          .then((result) => {
               this.result = result;
          });    
     }
     handleStatusSave(){
          if(this.result != null){
               //save new status to selected members
          }
     }
     handleRowSelect(event) {
          //this.itemsSelected = selectedRows;
     }
     
}