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
      | kenneth.f.alsay           | January 15, 2024      | DEPP-6964            | Added handleRefresh          |  
      |                           |                       |                      |                              |
 */
import { LightningElement, api, track } from "lwc";
export default class CustomHeaderContainer extends LightningElement {
  @api recordId;
  @track selectedRecords = [];
  isRefresh = false;
  @track columnsName;
  @track columnsData;

  handleSelectedRows(event) {
    this.selectedRecords = event.detail;
  }

  handleRefresh(e) {
    this.isRefresh = e.detail;
  }

  // sets the list member column data
  listDataHandler(event) {
    this.columnsData = event.detail;
  }

  // sets the list header
  newColumnsList(event) {
    this.columnsName = event.detail;
  }
}
