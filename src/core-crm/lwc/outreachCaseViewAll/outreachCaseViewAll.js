import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';


export default class OutreachCaseViewAll extends LightningElement {
   tableColumns = [
      {
        label: 'Case Name',
        fieldName: 'caseUrl',
        editable: false,
        sortable: false,
        type: 'url',
        typeAttributes: { 
          label: { 
            fieldName: 'caseNumber' 
          }, 
          target: '_blank' 
        }
      },
      {
        label: 'Contact',
        fieldName: 'contactUrl',
        editable: false,
        sortable: false,
        type: 'url',
        typeAttributes: { 
          label: { 
            fieldName: 'contactName' 
          }, 
          target: '_blank' 
        }
      },
      {
        label: 'Status',
        fieldName: 'status',
        editable: false,
        sortable: false,
        type: 'text',
      },
      {
        label: 'Case Owner',
        fieldName: 'ownerUrl',
        editable: false,
        sortable: false,
        type: 'url',
        typeAttributes: { 
          label: { 
            fieldName: 'ownerName' 
          }, 
          target: '_blank' 
        }
      },
      {
        label: 'Created Date',
        fieldName: 'createdDate',
        editable: false,
        sortable: false,
        type: "text"
      }
   ];
  
    @api recordId;
    @api objectApiName;

    @track objectId;
    @track objectName;

   data = [];
   rowOffset = 0;
   caseTable = [];

   connectedCallback() {
      let caseColumns = ['Case Name', 'Contact', 'Status', 'Case Owner', 'Created Date'];
      const columns = this.tableColumns;
      const newCaseColumns = [];
      caseColumns.forEach((name) => {
         columns.forEach((obj) => {
            if (obj.label === name) {
            newCaseColumns.push(obj);
            }
         })
      });
      this.caseTable = newCaseColumns;
   }

   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
      
      if (currentPageReference && !this.objectId) {
         const { c__objectId, c__objectName, c__data } = currentPageReference.state;
         if (c__objectId) {
               this.objectId = c__objectId;
         }

         if (c__objectId) {
               this.objectName = c__objectName;
         }
         
         if (c__data) {
            this.data = c__data;
         }
      }
   }
}