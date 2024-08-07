import { LightningElement,track,api } from 'lwc';
import { subscribe, unsubscribe } from "lightning/empApi";
import listOfStudents from "@salesforce/apex/OutreachCaseImportCtrl.listOfStudents";
import listOfCasesByStudentIds from "@salesforce/apex/OutreachCaseImportCtrl.listOfCasesByStudentIds";
import listOfCasesById from "@salesforce/apex/OutreachCaseImportCtrl.listOfCasesById";
import Id from "@salesforce/user/Id";

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
      initialWidth: 150,
      typeAttributes:
      {
          iconName: 'utility:delete',
          name: 'delete'
      }
    }
  ];
  
  @api recordId;
  @api channelName = "/event/Outreach_Case__e";

  @track modalOpen = true;
  @track isCreateButtonDisabled = true;
  @track data = [];
  @track exclusionData = [];
  @track exclData = [];
  @track dataCopy = [];
  @track errors = [];
  @track studentsFound = 0;
  @track tempData = [];
  @track dataForCreateOutreach = [];
  @track loaded = false;
  @track title;
  @track description;
  @track showSpinner = true;

  showTabset = false;
  showModal = false;
  fileName;
  showCreateOutreach = true;
  showCaseCol = false;
  isCreateOutreach = false;
  exitModal = 'Cancel';
  studentTable = [];
  exclusionsTable = [];
  subscription = {};
  existingCasesCount;
  caseCreatedCount;
  caseTableView = false;
  fileUploadMessage = 'File upload in progress, this screen will update once the process has completed. Refreshing or closing this page will not affect the upload.';
  errorOccuredMessage = 'An error has occurred and some cases may have been created successfully. Please re-upload the file to create any remaining cases. Duplicates will not be created.';
  userId = Id;
  errorOccured = false;
  tableLoading = false;

  connectedCallback(){
    let stundentColumns = ['QUT Student ID', 'Full Name', 'QUT Learner Email', 'Mobile'];
    let exclusionsColumns = ['Student ID', 'Error'];
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
  
  get createButtonDisbaled() {
    return this.studentsFound == 0 ? true : false ;
  }

  get closeButtonDisabled() {
    return !this.showSpinner ? true : false ;
  }

  get column2Name() {
    return this.isCreateOutreach ? 'Case Created' : 'Rows';
  }

  get column3Name() {
    return this.isCreateOutreach ? 'Existing Cases' : 'Students Found';
  }

  get rowCount() { // Also used for Case Created Count
    return this.caseTableView ? this.caseCreatedCount : this.studentsFound + this.exclusionData.length;
  }

  get studentFound() { // Also used for Existing Cases Count
    return this.caseTableView ? this.existingCasesCount : this.studentsFound;
  }

  get exclRowCount() {
    return this.exclusionData.length <= 0 ? 0 : this.exclusionData.length;
  }

  get isLoading() {
    return !this.loaded;
  }

  get isErrorOccured(){
    return this.errorOccured;
  }

  handleFileUpload(event) {
    this.loaded = false;
    const files = event.detail.files;
    this.errors = [];

    if (files.length > 0) {
      const file = files[0];
      this.fileName = file.name;
      // Check if the file has a .csv extension
      if (!file.name.toLowerCase().endsWith('.csv')) {
        this.errors.push('The file you have uploaded is an incorrect format. Please ensure the file is a comma separated (.csv) file.');
        this.showTabset = false;
        return;
      }
      // start reading the uploaded csv file
      this.read(file);
    }
  }

  async read(file) {
    try {
      const result = await this.load(file);
      // execute the logic for parsing the uploaded csv file
      this.parse(result);
    } catch (e) {
      const timestamp = new Date().toISOString();
      this.errors.push(`A system error occurred at ${timestamp}. Please contact the DEP support team to investigate the issue further.`);
      this.showTabset = false; 
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
    // parse the csv file and treat each line as one item of an array
    const lines = csv.split(/\r\n|\n/);
    
    // parse the first line containing the csv column headers
    const headers = lines[0].split(',');
    const rowCount = lines.length - 2;

    this.validateCsvFile(headers, rowCount);
    if (this.errors.length > 0) {
      this.showTabset = false;
      return;
    }

    this.data = [];
    this.exclusionData = [];
    this.showCaseCol = false;
    this.showTabset = true;

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
    if (!headers.includes('StudentID') || headers.length > 1) {
      this.errors.push("The file should only contain one column with the column header 'StudentID'.");
    }

    if (rows === 0) {
      this.errors.push('The file you have uploaded does not contain any data.');
    }

    if (rows > 3000) {
      this.errors.push('The CSV file contains too many rows. Please limit this to 3000 rows maximum.');
    }
  }

  validateStudents(studentIds){
    const logger = this.template.querySelector("c-logger");

    listOfStudents({ studentIds: studentIds })
		.then(result => {
      let allStudentsData = result;
      const exclData = [];
      const data = this.data;
      for (let i = 0; i < allStudentsData.length; i++) {
        if(result[i].studentId != null){
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
        this.exclusionData = exclData.sort((a, b) => a.studentId - b.studentId);
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
          email : data.email ? data.email : '',
          mobilePhone : data.mobilePhone ? data.mobilePhone : '',
          contactId : data.id
        }
        if (data.id) {
          obj.contactUrl = `/lightning/r/Contact/${data.id}/view`;
        }
        return obj;
      });

      this.data = this.dataCopy;
      this.tempData = this.data; // for search
      this.dataForCreateOutreach = this.data; // For Create Outreach Case
      this.loaded = true; 
      this.showTabset = true;
		})
		.catch(error => {
			if (logger) {
        logger.error(
          "Exception caught in method validateStudents in LWC outreachCaseImportModal: ",
          JSON.stringify(error)
        );
      }
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
      const exclData = this.exclusionData;
      exclData.push(this.updateExclusiveData(detail.row.studentId, 'Manually Removed'));
      this.exclusionData = exclData.sort((a, b) => a.studentId - b.studentId);
      this.data = newdata;
      this.dataForCreateOutreach = newdata; // For Create Outreach Case
      this.tempData = newdata; // For Search
      this.studentsFound--;
    }
  }

  handleExclusionsTab(){
    const data = JSON.parse(JSON.stringify(this.exclusionData));
    this.exclusionData = data.sort((a, b) => a.studentId - b.studentId);
  }

  handleCreateOutreach() {
    this.showSpinner = false;
    this.title = this.title ? this.title : '';
    const allValid = [
      ...this.template.querySelectorAll('lightning-input'),
    ].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);

    if (allValid) {
      this.showSpinner = false;
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

      this.createOutreach(this.dataForCreateOutreach);
    }
  }

  handleTitle(event) {
    this.title = event.detail.value;
  }

  handleDescription(event) {
    this.description = event.detail.value;
  }

  updateExclusiveData(studentId, error){
    const obj = {
      studentId : studentId,
      error : error
    };

    return obj;
  }

  createOutreach(outreachData) {
    this.tableLoading = true;
    const logger = this.template.querySelector("c-logger");
    const data = JSON.parse(JSON.stringify(outreachData));
    const studentIds = [];
    data.forEach( (data, i) => {
      studentIds[i] = data.studentId.toString();
    });
    this.title = this.title ? this.title : '';
    this.description = this.description ? this.description : '';
    const criteria = this.title + ',' + this.description;
    listOfCasesByStudentIds({ 
      qutStudentIds : studentIds,
      criteria : criteria,
      configurationId : this.recordId
     })
		.then(() => {
      this.handleSubscribe();
    })
		.catch(error => {
      this.loaded = false;
      if (logger) {
        logger.error(
          "Exception caught in method createOutreach in LWC outreachCaseImportModal: "
        ).setError(error);
      }
      logger.saveLog();
		});
  }

  closeModal() {
    const data = this.data.map(
      (item) => {
        return {
          caseId : item.caseId,
          close : false
        };
      }
    )

    const closeModalEvent = new CustomEvent('closemodal', {
      detail: JSON.parse(JSON.stringify(data))
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
    this.searchKeyVal = searchKey;     	
    this.tableLoading = true;
  }

  handleCommitSearch(){
    let searchKey = this.searchKeyVal;
    let searchString = searchKey.toUpperCase();
    let allRecords = this.tempData;
    let new_search_result = [];
      
    for (let i = 0; i < allRecords.length; i++) {
      if ((allRecords[i].fullName) && searchString != '' && ( allRecords[i].studentId.toUpperCase().includes(searchString) || allRecords[i].fullName.toUpperCase().includes(searchString) || allRecords[i].email.toUpperCase().includes(searchString) || allRecords[i].mobilePhone.includes(searchString) || (allRecords[i].caseNumber && allRecords[i].caseNumber.includes(searchString)) )) {
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

    this.tableLoading = false;
  }

  handleSubscribe() {
    const messageCallback = (response) => {
      this.errorOccured = response.data.payload.Has_Error__c;
      if (response.data.payload.CreatedById != this.userId) {
        return;
      }
      const newOutreachCaseIds = response.data.payload.New_Outreach_Case_Ids__c;
      const existingOutreachCaseIds = response.data.payload.Existing_Outreach_Case_Ids__c;

      const newId = !newOutreachCaseIds ? '' : newOutreachCaseIds;
      const existingId = !existingOutreachCaseIds ? '' : existingOutreachCaseIds;
      const mergedCaseIds = newId +','+ existingId;

      const caseCreated = !newOutreachCaseIds ? 0 : newOutreachCaseIds.split(',');
      const existingCase = !existingOutreachCaseIds ? 0 : existingOutreachCaseIds.split(',');

      this.existingCasesCount = existingCase != 0 ? existingCase.length : existingCase;
      this.caseCreatedCount = caseCreated != 0 ? caseCreated.length : caseCreated;
      this.handleMessage(mergedCaseIds);
    };

    subscribe(this.channelName, -1, messageCallback).then((response) => {
      this.subscription = response;
    });
  }

  handleMessage(response) {

    let caseIdString = response;
    const splittedCaseIds = caseIdString.split(',');
    const caseIds = [];

    splittedCaseIds.forEach( (data, i) => {
      if (data.length > 0) {
        caseIds[i] = data;
      }
    });

    listOfCasesById({
      caseIds: caseIds
    }).then(result => {
      this.caseTableView = true;
      const caseData = result.map(data => {
        return {
          caseNumber: data.CaseNumber,
          caseUrl: `/lightning/r/Case/${data.Id}/view`,
          studentId: data.Contact.QUT_Student_ID__c,
          fullName: data.Contact.Name,
          contactUrl: `/lightning/r/Contact/${data.ContactId}/view`,
          email: data.Contact.QUT_Learner_Email__c ? data.Contact.QUT_Learner_Email__c : '',
          mobilePhone: data.Contact.MobilePhone ? data.Contact.MobilePhone : ''
        }
      })
      
      this.data = caseData;
      this.tempData = this.data; // For Search
    }).finally(() => {
      // Invoke unsubscribe method of empApi
      unsubscribe(this.subscription, () => {});
      this.loaded = true; 
      this.showSpinner = true;
      this.tableLoading = false;
    });
    
  }

}