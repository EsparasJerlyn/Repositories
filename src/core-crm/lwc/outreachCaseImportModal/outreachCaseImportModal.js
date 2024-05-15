import { LightningElement,track } from 'lwc';

const exclusionsColumns = [
  { label: 'Student Id', fieldName: 'studentId' },
  { label: 'Error', fieldName: 'error'},
];

export default class OutReachCaseImportModal extends LightningElement {
  
  @track modalOpen = true;
  @track isCreateButtonDisabled = true;
  @track data = [];
  @track exclusionData = [];
  @track paramsMap = {};
  @track exclData = [];

  @track error = null;

  showTabset = false;
  @track rowCount;
  // @track exclRowCount = 0;
  showModal = false;
  queryTerm;
  fileName;
  exclusionsColumns = exclusionsColumns;
  tempData = [];

  closeModal() {
    const closeModalEvent = new CustomEvent('closemodal', {
      detail: false
    });
    this.dispatchEvent(closeModalEvent);
  }

  get modalClass() {
    return this.modalOpen ? 'slds-modal slds-fade-in-open' : 'slds-modal slds-fade-in-close';
  }

  get backdropClass() {
    return this.modalOpen ? 'slds-backdrop slds-backdrop_open' : 'slds-backdrop slds-backdrop_close';
  }

  handleFileChange(event) {
    if (event.target.files.length > 0) {
        this.isCreateButtonDisabled = false; 
    } else {
        this.isCreateButtonDisabled = true;
    }
  }

  handleFileUpload(event) {
    console.log('detail ::: ', event.detail);
    console.log('files ::: ', event.detail.files);
    console.log('file name ::: ', event.detail.files[0].name);
    const files = event.detail.files;
    
    if (files.length > 0) {
      const file = files[0];
      this.fileName = file.name;
      // Check if the file has a .csv extension
      if (!file.name.toLowerCase().endsWith('.csv')) {
        this.error = 'Invalid file format. Please ensure the file is a comma separated (.csv) file.';
        this.showTabset = false;
        console.log(this.error);
        return;
    }
      // start reading the uploaded csv file
      this.read(file);
      this.showTabset = true;
      console.log('sucess Read');
    }
  }
  async read(file) {
    try {
      const result = await this.load(file);
      console.log(result);
      
      // execute the logic for parsing the uploaded csv file
      this.parse(result);
      this.exclusionData = [];
      console.log('sucess parse');
    } catch (e) {
      this.error = e;
      const timestamp = new Date().toISOString();
      this.error = `System error. A system error occurred at ${timestamp}. Please contact the DEP support team to investigate the issue further.`;
      this.showTabset = false; 
      console.log(this.error);
    }
  }

  async load(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();

      reader.onload = () => {
          resolve(reader.result);
      };
      reader.onerror = () => {
          reject(reader.error);
      };
      reader.readAsText(file);
    });
  }

  parse(csv) {
    console.log('parse');
    // parse the csv file and treat each line as one item of an array
    const lines = csv.split(/\r\n|\n/);
    
    // parse the first line containing the csv column headers
    const headers = lines[0].split(',');
  
    // Check for incorrect columns
    if (headers.length !== 1 || headers[0].trim() !== 'StudentID') {
      this.error = "The file should only contain one column with the column header 'StudentID'.";
      console.log(this.error);
      this.showTabset = false;
      return;
   } 

    this.rowCount = lines.length - 2;

    if (this.rowCount === 0) {
      this.error = 'The file you have uploaded does not contain any data.';
      this.showTabset = false;
      console.log(this.error);
      return;
    }

    if (this.rowCount > 3000) {
      this.error = 'The CSV file contains too many rows. Please limit this to 3000 rows maximum.';
      console.log(this.error);
      this.showTabset = false;
      return;
  }
    
    // iterate through csv headers and transform them to column format supported by the datatable
    this.columns = headers.map((header) => {
      return { label: header, fieldName: header };
    });
    const data = [];
    
    // iterate through csv file rows and transform them to format supported by the datatable
    lines.forEach((line, i) => {
      if (i === 0) return;

      const obj = {};
      const currentline = line.split(',');
  
      for (let j = 0; j < headers.length; j++) {
          obj[headers[j]] = currentline[j];
      }
      
      if (i <= lines.length - 2) {
          data.push(obj)
      }

    });
    // assign the converted csv data for the lightning datatable
    this.data = data.sort((a, b) => a.QUT_Student_ID__c - b.QUT_Student_ID__c);
    console.log('DATA ::: ', JSON.stringify(this.data));
  }

  importList(){
    this.showModal = true;
  }

  handleClose(){
    this.showModal = !this.showModal;
  }

  handleDeleteAction(event){
    let selectedStudentId = event.target.dataset.id;

    const obj = {};
    obj[this.exclusionsColumns[0].fieldName] = selectedStudentId;
    obj[this.exclusionsColumns[1].fieldName] = 'Manually removed';
    this.exclData.push(obj);
    this.exclusionData = this.exclData;
    this.exclusionData.sort((a, b) => a.studentId - b.studentId);
    this.data.splice(this.data.findIndex(row => row.QUT_Student_ID__c == selectedStudentId), 1);
    this.rowCount--;
  }

  get exclRowCount() {
    return this.exclusionData.length === 0 ? 0 : this.exclusionData.length;
  }

  handleSearch(event) {
    const isEnterKey = event.keyCode === 13;
    this.queryTerm = event.target.value;
    let searchedData = [];
    this.tempData = this.data;
    if (isEnterKey) {
      if (this.queryTerm != null) {
        const found = this.data.find((element) =>
          element.QUT_Student_ID__c == this.queryTerm || element.Full_Name__c == this.queryTerm || element.QUT_Learner_Email__c == this.queryTerm || element.Mobile__c == this.queryTerm
        );
        searchedData.push(found);
        this.data = searchedData;
      } else {
        this.data = this.tempData;
      }
      
    }
  }
}