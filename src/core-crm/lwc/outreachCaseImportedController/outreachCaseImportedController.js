import { LightningElement } from 'lwc';

const columns = [
  { label: 'Engagement List Criteria', fieldName: '' },
  { label: 'Engagement List Title', fieldName: '' },
  { label: 'Cases Created', fieldName: '', type: 'number' },
  { label: 'Created Date', fieldName: '', type: 'date' },
];


export default class OutreachCaseImportedController extends LightningElement {

  data = [];
  rowOffset = 0;
  columns = columns;

    connectedCallback() {
      const amountOfRecords = 5;
      this.data = this.generateMockData(amountOfRecords);
    }

    generateMockData(amountOfRecords) {
      return [...Array(amountOfRecords)].map((_, index) => {
          return {
              engagementCriteria: `Criteria ${index}`,
              engagementTitle: `Title ${index}`,
              casesCreated: Math.floor(Math.random() * 100), // Random number of cases created
              createdDate: new Date(
                  Date.now() + 86400000 * Math.ceil(Math.random() * 20)
              ).toISOString(), // Random date within next 20 days
          };
      });
  }

}