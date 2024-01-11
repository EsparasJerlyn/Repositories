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
import { LightningElement, api, wire} from 'lwc';
import ListMemberStatusModal from 'c/listMemberStatusModal';
import {
     subscribe,
     unsubscribe,
     MessageContext
   } from "lightning/messageService";

import LIST_MEMBER_CHANNEL from "@salesforce/messageChannel/ListMember__c";

export default class CustomHeaderButtons extends LightningElement {
     result;
     showModal;
     showStatusPicklist;
     showSelectMembers;
     itemsSelected;
     @wire(MessageContext)
     messageContext;
   
     receivedMessage;
     subscription = null;

     handleStatusClick(){
          console.log("in handle subscribe");
          if (this.subscription) {
               return;
          }

          //4. Subscribing to the message channel
          this.subscription = subscribe(
               this.messageContext,
               LIST_MEMBER_CHANNEL,
               (message) => {
               this.handleMessage(message);
               }
          );
          console.log('Subscription > ' + this.subscription);
          
          ListMemberStatusModal
          .open({
               size: "small",
               modalTitle: "List Member Status"
          })
          .then((result) => {
               this.result = result;
          });    
     }
     handleMessage(message) {
          console.log('in handle message');
          this.itemsSelected = message
            ? message
            : "no message";

          console.log(message
               ? message
               : "no message");
     }
     handleUnsubscribe() {
          console.log("in handle unsubscribe");
      
          unsubscribe(this.subscription);
          this.subscription = null;
          this.receivedMessage = null;
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