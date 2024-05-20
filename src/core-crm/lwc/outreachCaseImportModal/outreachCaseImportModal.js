import { LightningElement,track,api,wire } from 'lwc';
import listOfStudents from'@salesforce/apex/OutreachCaseImportCtrl.listOfStudents';
import listOfCasesbyStudentIds from'@salesforce/apex/OutreachCaseImportCtrl.listOfCasesbyStudentIds';

export default class OutReachCaseImportModal extends LightningElement {
  tableColumns = [
    {
      label: 'Case',
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
      label: 'QUT Student ID',
      fieldName: 'studentId',
      editable: false,
      sortable: false,
      type: 'text',
    },
    {
      label: 'Full Name',
      fieldName: 'contactUrl',
      editable: false,
      sortable: false,
      type: 'url',
      typeAttributes: { 
        label: { 
          fieldName: 'fullName' 
        }, 
        target: '_blank' 
      }
    },
    {
      label: 'QUT Learner Email',
      fieldName: 'email',
      editable: false,
      sortable: false,
      type: 'text',
    },
    {
      label: 'Mobile',
      fieldName: 'mobilePhone',
      editable: false,
      sortable: false,
      type: 'text',
    },
    {
      label: 'Student ID',
      fieldName: 'studentId',
      editable: false,
      sortable: false,
      type: 'text',
    },
    ,
    {
      label: 'Error',
      fieldName: 'error',
      editable: false,
      sortable: false,
      type: 'text',
    },
    { 
      type: 'button-icon',
      typeAttributes:
      {
          iconName: 'utility:delete',
          name: 'delete'
      }
    }
  ];
  
  @api recordId;

  @track modalOpen = true;
  @track isCreateButtonDisabled = true;
  @track data = [];
  @track exclusionData = [];
  @track exclData = [];
  @track dataCopy = [];
  @track errors = [];
  @track studentsFound = 0;
  @track tempData = [];
  @track tempDataCopy = [];

  showTabset = false;
  showModal = false;
  fileName;
  loaded = false;
  showCreateOutreach = true;
  showCaseCol = false;
  isCreateOutreach = false;
  exitModal = 'Cancel';
  draftValues = [];
  studentTable = [];
  exclusionsTable = [];
  @track title;
  @track description;


  connectedCallback(){
    let stundentColumns = ['QUT Student ID', 'Full Name', 'QUT Learner Email', 'Mobile'];
    let exclusionsColumns = ['Student ID', 'Error'];
    let toAddAction = false;
    const columns = this.tableColumns;
    const newStudentColumns = [];
    const newExclusionsColumns = [];
    stundentColumns.forEach((name) => {
      columns.forEach((obj) => {
        if (obj.label === name) {
          newStudentColumns.push(obj);
        }
      })
    });
    newStudentColumns.push(columns[columns.length-1]);
    exclusionsColumns.forEach((name) => {
      columns.forEach((obj) => {
          if (obj.label === name) {
            newExclusionsColumns.push(obj);
          }
      })
    });

    this.studentTable = newStudentColumns;
    this.exclusionsTable = newExclusionsColumns;

  }

  get modalClass() {
    return this.modalOpen ? 'slds-modal slds-fade-in-open slds-modal_small' : 'slds-modal slds-fade-in-close';
  }

  get backdropClass() {
    return this.modalOpen ? 'slds-backdrop slds-backdrop_open' : 'slds-backdrop slds-backdrop_close';
  }
  
  get createButtonDisbaled(){
    return this.studentsFound == 0 ? true : false ;
  }

  get column2Name(){
    return this.isCreateOutreach ? 'Case Created' : 'Rows';
  }

  get column3Name(){
    return this.isCreateOutreach ? 'Existing Cases' : 'Students Found';
  }

  get exclRowCount() {
    return this.exclusionData.length <= 0 ? 0 : this.exclusionData.length;
  }

  handleFileUpload(event) {
    this.loaded = false;
    const files = event.detail.files;
    
    if (files.length > 0) {
      const file = files[0];
      this.fileName = file.name;
      // Check if the file has a .csv extension
      if (!file.name.toLowerCase().endsWith('.csv')) {
        this.errors.push('Invalid file format. Please ensure the file is a comma separated (.csv) file.');
        this.showTabset = false;
        console.log(this.error);
        return;
      }
      // start reading the uploaded csv file
      this.read(file);
      this.showTabset = true;
    }
  }

  async read(file) {
    try {
      const result = await this.load(file);
      
      // execute the logic for parsing the uploaded csv file
      this.parse(result);
      this.exclusionData = [];
    } catch (e) {
      this.error = e;
      const timestamp = new Date().toISOString();
      this.errors.push(`System error. A system error occurred at ${timestamp}. Please contact the DEP support team to investigate the issue further.`);
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
    this.data = [];
    this.exclusionData = [];
    this.exclData = [];
    this.showCaseCol = false;
    // parse the csv file and treat each line as one item of an array
    const lines = csv.split(/\r\n|\n/);
    
    // parse the first line containing the csv column headers
    const headers = lines[0].split(',');
    const rowCount = lines.length - 2;

    this.validateCsvFile(headers, rowCount);

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

    const studentIds = [];
    data.forEach( (data, i) => {
      studentIds[i] = data.StudentID.toString();
    });
    this.validateStudents(studentIds);
  }

  validateCsvFile(headers, rows){
    // Check if the header does not contain 'StudentID'
    if (!headers.includes('StudentID')) {
      this.errors.push("The file should contain a column with the header 'StudentID'.");
      this.showTabset = false;
      console.log(this.error);
    }

    if (rows === 0) {
      this.errors.push('The file you have uploaded does not contain any data.');
      this.showTabset = false;
      console.log(this.error);
    }

    if (rows > 3000) {
      this.errors.push('The CSV file contains too many rows. Please limit this to 3000 rows maximum.');
      console.log(this.error);
      this.showTabset = false;
    }
  }

  validateStudents(studentIds){
    listOfStudents({ studentIds: studentIds })
		.then(result => {
      let allStudentsData = result;
      const exclData = this.exclData;
      const data = this.data;
      for (let i = 0; i < allStudentsData.length; i++) {
        if (result[i].resultCode == 'VALID') {
          data.push(allStudentsData[i]);
        } 
        if (result[i].resultCode == 'MULTIPLE_MATCH') {
          exclData.push(this.updateExclusiveData(result[i].studentId, 'Multiple students found with the same Student ID in DEP'));
        } 
        if (result[i].resultCode == 'INVALID') {
          exclData.push(this.updateExclusiveData(result[i].studentId, 'Student ID was not found'));
        } 
      }
      const duplicates = [];
      studentIds.forEach((item, index) => {
        if (studentIds.indexOf(item) != index && duplicates.indexOf(item) < 0) {
          duplicates.push(item);
        }
      });

      duplicates.forEach(i => {
        exclData.push(this.updateExclusiveData(i, 'Duplicate student ID found in list, duplicates will be ignored'));
      });

      if (exclData.length > 0) {
        this.exclData = exclData.sort((a, b) => a.studentId - b.studentId);
        this.exclusionData = this.exclData;
      }

      if (data.length > 0) {
        this.isCreateButtonDisabled = false;
        this.data = data.sort((a, b) => a.studentId - b.studentId);
        this.studentsFound = this.data.length;
      }
      
      this.dataCopy = this.data.map((data, index) => {
        const obj = {
          rowId : `row-${index}`,
          studentId : data.studentId,
          fullName : data.fullName,
          email : data.email,
          mobilePhone : data.mobilePhone,
          contactId : data.id
        }
        if (data.id) {
          obj.contactUrl = `/lightning/r/Contact/${data.id}/view`;
        }
        return obj;
      });

      this.data = this.dataCopy;
      this.tempData = this.data; // for search
      this.loaded = true; 
		})
		.catch(error => {
			console.log('error ::: ', error);
		});
  }

  //deletes row selected
  handleActionRow(event){
    const detail = event.detail;
    if (detail.action.name === 'delete') {
      const data = JSON.parse(JSON.stringify(this.data));
      const newdata = [];

      for (let field in data) {
        if (String(data[field].rowId) !== String(detail.row.rowId)) {
          newdata.push(data[field]);
        }
      }

      newdata.forEach((obj, key) => {
          obj.rowId =  `row-${key}`;
      });
      const exclData = this.exclData;
      exclData.push(this.updateExclusiveData(detail.row.studentId, 'Manually Removed'));
      this.exclusionData = exclData.sort((a, b) => a.studentId - b.studentId);
      this.data = newdata;
      this.studentsFound--;
    }
  }

  handleCreateOutreach() {
    this.loaded = false;
    this.isCreateOutreach = true;
    let stundentColumns = ['Case', 'QUT Student ID', 'Full Name', 'QUT Learner Email', 'Mobile'];
    const columns = this.tableColumns;
    const newStudentColumns = [];
    this.exitModal = 'Close';
    this.showCreateOutreach = false;
    this.showCaseCol = true;
    
    stundentColumns.forEach((name) => {
      columns.forEach((obj) => {
        if (obj.label === name) {
          newStudentColumns.push(obj);
        }
      })
    });
    this.studentTable = newStudentColumns;

    this.createOutreach(this.data)
    this.loaded = true;
  }

  handleTitle(event) {
    this.showCaseCol = this.showCaseCol;
    this.showTabset = this.showTabset;
    this.title = event.detail.value;
  }

  handleDescription(event) {
    this.showCaseCol = this.showCaseCol;
    this.showTabset = this.showTabset;
    this.description = event.detail.value;
  }

  updateExclusiveData(studentId, error){
    let excludedData = this.exclusionData;
    const obj = {
      studentId : studentId,
      error : error
    };

    return obj;
  }

  createOutreach(outreachData) {
    const data = JSON.parse(JSON.stringify(outreachData));
    const studentIds = [];
    data.forEach( (data, i) => {
      studentIds[i] = data.contactId.toString();
    });

    listOfCasesbyStudentIds({ 
      contactIds : studentIds,
      criteriaTitle : this.title,
      criteriaDescription : this.description,
      configurationId : this.recordId
     })
		.then(result => {
      const caseData = JSON.parse(JSON.stringify(result));
      const studentData = JSON.parse(JSON.stringify(data));
      const merged = studentData.map(t1 => {
        const matchData = caseData.find((t2) => t2.ContactId === t1.contactId);
        return !!matchData ? {
          ...t1, 
          caseId : matchData.Id, 
          caseNumber : matchData.CaseNumber, 
          caseUrl : `/lightning/r/Case/${matchData.Id}/view`} : null
      }).filter(Boolean);
      this.data = merged;
      this.tempData = this.data;
      this.loaded = true; 
		})
		.catch(error => {
			console.log('error ::: ', error);
		});
  }

  closeModal() {
    const closeModalEvent = new CustomEvent('closemodal', {
      detail: false
    });
    this.dispatchEvent(closeModalEvent);
  }

  importList(){
    this.showModal = true;
  }

  handleClose(){
    this.showModal = !this.showModal;
  }

  handleSearch(event) {
    let searchKey = event.target.value;
    let searchString = searchKey.toUpperCase();
    let allRecords = this.tempData;
    let new_search_result = [];
      
    for (let i = 0; i < allRecords.length; i++) {
      if ((allRecords[i].fullName) && searchString != '' && (allRecords[i].studentId.toUpperCase().includes(searchString) || allRecords[i].fullName.toUpperCase().includes(searchString) || allRecords[i].email.toUpperCase().includes(searchString) || allRecords[i].mobilePhone.toUpperCase().includes(searchString))) {
        new_search_result.push(allRecords[i]);
      }
    }

    if(new_search_result.length !=0){
      this.data = new_search_result;
    }else if((new_search_result.length ==0 && searchString != '')){
      this.data = [];
    }else{
      this.data = this.tempData;
    }       	
  }
}