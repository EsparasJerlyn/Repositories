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
 */
import { LightningElement, api, track } from 'lwc';

export default class CustomHeaderContainer extends LightningElement {
     @api recordId;

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