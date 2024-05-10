import { LightningElement,track } from 'lwc';

export default class OutReachCaseImportModal extends LightningElement {
  
  @track modalOpen = true;
  @track isCreateButtonDisabled = true;

  data = [];
  showTabset = false;
  rowCount;
  showModal = false;
  queryTerm;

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
    const files = event.detail.files;
    
    if (files.length > 0) {
      const file = files[0];
      
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
      
      console.log('sucess parse');
    } catch (e) {
      this.error = e;
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
    this.rowCount = lines.length - 2;
    
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
    this.data = data;
    console.log(this.data);
  }

  importList(){
    this.showModal = true;
  }

  handleClose(){
    this.showModal = !this.showModal;
  }

  

  handleKeyUp(evt) {
    const isEnterKey = evt.keyCode === 13;
    if (isEnterKey) {
      this.queryTerm = evt.target.value;
    }
  }
}