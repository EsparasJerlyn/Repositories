/**
 * @description Lightning Web Component for custom parent container.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                 |
      |                           |                       |                      |                              |
 */
import { LightningElement, api, track } from 'lwc';

export default class CustomHeaderContainer extends LightningElement {
     @api recordId;
     @track selectedRecords = [];

     handleSelectedRows(event){
          this.selectedRecords = event.detail;
     }
}