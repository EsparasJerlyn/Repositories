/**
 * @description Lightning Web Component for custom parent container.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                 |
      | kenneth.f.alsay           | January 15, 2024      | DEPP-6964            | Added handleRefresh          |  
      |                           |                       |                      |                              |
 */
import { LightningElement, api, track } from 'lwc';

export default class CustomHeaderContainer extends LightningElement {
     @api recordId;
     @track selectedRecords = [];
     isRefresh = false;

     handleSelectedRows(event){
          this.selectedRecords = event.detail;
     }

     handleRefresh(){
          this.isRefresh = true;
     }
}