/**
 * @description Lightning Web Component for custom parent container.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | December 19, 2023     | DEPP-7489            | Created file                 |
      | jerlyn.esparas@qut.edu.au | January  10, 2024     | DEPP-6965            |                              |
      | nicole.genon@qut.edu.au   | January  18, 2024     | DEPP-6953            |                              |
 */
import { LightningElement, api, track } from 'lwc';

export default class CustomHeaderContainer extends LightningElement {
     @api recordId;
     @api objectApiName;
     @api isEngageTab = false;

     @track columnsName;
     @track columnsData;

     // sets the list member column data
     listDataHandler(event){
          this.columnsData = event.detail;
     }

     // sets the list header 
     newColumnsList(event){
          this.columnsName = event.detail;
     }

}