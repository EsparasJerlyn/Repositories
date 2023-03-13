/**
 * @description A LWC component to display registration and nominations usting in CCE portal
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | Tiffany.Zhang             | Aug 18, 2022          | DEPP-3486            | Created file                                 |
      | eccaiurs.munoz            | Sept. 05, 2022        | DEPP-3747            | Added validation on approval of nomination.  |
      | julie.jane.alegre         | Sept. 15, 2022        | DEPP-4311            | Added download button for Manage Registration|
      | marygrace.li              | Sept. 26, 2022        | DEPP-4422            | Modified catch, removed spinner height       |
      |                           |                       |                      |                                              |
 */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext, subscribe, unsubscribe } from 'lightning/messageService';

import getRegisAndNomis from '@salesforce/apex/ManageRegAndNomCtrl.getRegistrationsAndNominations';
import getNominationStatusValues from '@salesforce/apex/ManageRegAndNomCtrl.getNominationStatusValues';
import getRegistrationStatusValues from '@salesforce/apex/ManageRegistrationSectionCtrl.getRegistrationStatusValues';
import updateRegistrationOrNominationStatus from '@salesforce/apex/ManageRegAndNomCtrl.updateRegistrationOrNominationStatus';

import {loadStyle} from "lightning/platformResourceLoader";
import BasePath from "@salesforce/community/basePath";
import customCCECSS from "@salesforce/resourceUrl/QUTMainCSS";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import payloadAcctContainerLMS from '@salesforce/messageChannel/AccountId__c';
import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';

const COLUMN_HEADER = 'Course Name,First Name,Last Name,Email,Date of Birth,Mobile,Offering End Date,Offering Start Date,Status';
const STORED_ACCTID = "storedAccountId";
export default class ManageRegistrationAndNomination extends LightningElement {
    //Filter Field Params
    searchCourseName;
    searchFirstName;
    searchLastName;
    searchBirthday;
    searchEmail;
    searchMobile;
    searchStatus;

    //Filter Field Params in Nomination table
    searchNomiCourseName;
    searchNomiFirstName;
    searchNomiLastName;
    searchNomiBirthday;
    searchNomiEmail;
    searchNomiMobile;
    searchNomiStatus;
    
    //params
    statusOptions;
    selectedStudent;
    choosedStatus;
    defaultSortDirection = 'asc';
    sortRegistrationDirection = 'asc';
    sortedRegistrationBy;
    sortNominationDirection = 'asc';
    sortedNominationBy;
    _isLoading = false;
    searchRegistrationStatus;
    searchNominationStatus;

    subscription;
    accountId;

    registrationRecordSearchParameters = {
        isRegistrations: true,
        courseName: '',
        firstName: '',
        lastName: '',
        email: '',
        mobile: '',
        status: '',
        birthday: ''
    };

    nominationSearchParameters = {
        isRegistrations: false,
        courseName: '',
        firstName: '',
        lastName: '',
        email: '',
        mobile: '',
        status: '',
        birthday: '',
    };

    @track registrationList;
    @track nominationList;
    @track registrationStatus;
    @track nominationStatus;

    get isLoading() {
        return this._isLoading;
    }

    columns = [
        { label: 'Course Name', fieldName: 'courseName', type: 'text', sortable: true, wrapText: true},
        { label: 'First Name', fieldName: 'contactFirstName', type: 'text', sortable: true },
        { label: 'Last Name', fieldName: 'contactLastName', type: 'text', sortable: true },
        { label: 'Email', fieldName: 'contactEmail', type: 'text', sortable: true },
        { 
            label: 'Date of Birth', 
            fieldName: 'contactBirthdate', 
            type: 'date', 
            sortable: true, 
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric'
            }
        },
        { label: 'Mobile', fieldName: 'contactMobile', type: 'text', sortable: true },
        { 
            label: 'Offering End Date', 
            fieldName: 'offeringEndDate', 
            type: 'date', 
            sortable: true,
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric'
            }
        },
        { 
            label: 'Offering Start Date', 
            fieldName: 'offeringStartDate',             
            type: 'date',
            sortable: true, 
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric'
            }
        },
        { label: 'Status', fieldName: 'status', type: 'text',  sortable: true },
        {
            type: 'action',
            typeAttributes: { rowActions: [{label: 'Edit Status', name: 'editStatus'}] },
        },
    ];

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'editStatus':
                this.openModal(row);
                break;
            default:
        }
    }

    sortData(fieldname, direction, records) {       
        let parseData = JSON.parse(JSON.stringify(records));     
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return parseData;
    }   

    onHandleRegistrationSort(event) {
        const { fieldName, sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.registrationList];

        this.registrationList = this.sortData(fieldName, this.sortRegistrationDirection === 'asc' ? 'desc' : 'asc', cloneData);
        this.sortRegistrationDirection = this.sortRegistrationDirection === 'asc' ? 'desc' : 'asc';
        this.sortedRegistrationBy = sortedBy;
    }

    onHandleNominationSort(event) {
        const { fieldName, sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.nominationList];

        this.nominationList = this.sortData(fieldName, this.sortNominationDirection === 'asc' ? 'desc' : 'asc', cloneData);
        this.sortNominationDirection = this.sortNominationDirection === 'asc' ? 'desc' : 'asc';
        this.sortedNominationBy = sortedBy;
    }

    handleOnValueChange(event) {
        const name = event.target.name;
        const value = event.detail.value;
        this[name] = value;     
    }
    openModal(row) {
        this.selectedStudent = row;
        if(row.isRegistrations){
            this.statusOptions = this.registrationStatus;
        } else {
            this.statusOptions = this.nominationStatus;
        }
        this.choosedStatus = row.status;
    }

    updateStatus() {
        this._isLoading = true;
        let contactInformation = {
            First_Name__c: this.selectedStudent.contactFirstName,
            Last_Name__c: this.selectedStudent.contactLastName,
            Email__c: this.selectedStudent.contactEmail,
            Mobile__c : this.selectedStudent.contactMobile,
            Mobile_Locale__c: this.selectedStudent.contactMobileLocale? this.selectedStudent.contactMobileLocale : '',
            Birthdate__c: this.selectedStudent.contactBirthdate,
            //Birthdate__c: this.selectedStudent.contactBirthdate ? this.formatDate( this.parseDate(this.selectedStudent.contactBirthdate) ) : '' ,
            Accessibility_Requirement__c: this.selectedStudent.contactAccessibilityReq,
            Dietary_Requirement__c: this.selectedStudent.contactDietaryReq,
            Course_Offering__c : this.selectedStudent.courseOfferingId,
            Program_Offering__c : this.selectedStudent.programOfferingId,
            Pricebook_Entry_ID__c : this.selectedStudent.priceBookEntryId
        };
        let mobileNumber = '';
        if(!this.selectedStudent.isRegistrations){
            mobileNumber = this.combineLocaleAndNumber(this.selectedStudent.contactMobileLocale, this.selectedStudent.contactMobile);
        }
        updateRegistrationOrNominationStatus({
            id: this.selectedStudent.id,
            registrationStatus: this.choosedStatus,
            isRegistrations: this.selectedStudent.isRegistrations,
            contactInfo : contactInformation,
            mobileNumber : mobileNumber,
            businessOrgAccount : this.selectedStudent.businessAccount
        })
        .then(result =>{
            if(result){ 
                if(!this.selectedStudent.isRegistrations){
                   /*  this.nominationList = this.nominationList.map( item => {
                        if(item.id === this.selectedStudent.id){
                            return Object.assign({...item}, {'status': this.choosedStatus});
                        } else return {...item};
                    }); */
                    if(this.choosedStatus == 'Approved'){
                        if(!result.isSuccess){
                            this.generateToast('Warning.', result.errorMessage, 'warning');
                        }else{

                            this.registrationRecordSearchParameters = {
                                isRegistrations: true,
                                courseName: this.searchCourseName,
                                firstName: this.searchFirstName,
                                lastName: this.searchLastName,
                                email: this.searchEmail,
                                mobile: this.searchMobile,
                                status: this.searchStatus,
                                birthday: this.searchBirthday                                
                            };
                            
                            getRegisAndNomis({ recordSearchParams : this.registrationRecordSearchParameters, accountSelected : this.accountId })
                            .then( results => {
                                this.registrationList = results.map( item => {
                                    return {
                                        ...item,
                                        isRegistrations: true,
                                    }
                                });
                            }).catch(error=>{
                                console.error('Error: ' + JSON.stringify(error));
                            });
                        }
                    }
                } else {
                    this.registrationList = this.registrationList.map( item => {
                        if(item.id === this.selectedStudent.id){
                            return Object.assign({...item}, {'status': this.choosedStatus});
                        } else return {...item};
                    });
                }
            }
        }).catch(error=>{
            console.error('Error: ' + JSON.stringify(error));
        }).finally(()=>{
            this.selectedStudent = null;
            this._isLoading = false;
            refreshApex(this.nomisList); 
            refreshApex(this.regisList);
        });
    }

    handleSearchRegistration(){
        this._isLoading = true;
        this.registrationRecordSearchParameters = {
            isRegistrations: true,
            courseName: this.template.querySelector(".searchRegCourseName").value,
            firstName: this.template.querySelector(".searchRegFirstName").value,
            lastName: this.template.querySelector(".searchRegLastName").value,
            email: this.template.querySelector(".searchRegEmail").value,
            mobile: this.template.querySelector(".searchRegMobile").value,
            status: this.template.querySelector(`[data-name="searchStatus"]`).value,
            birthday: this.template.querySelector(".searchRegBirthday").value
        };
        getRegisAndNomis({ recordSearchParams : this.registrationRecordSearchParameters, accountSelected : this.accountId })
        .then(result =>{
            if(result){
                this.registrationList = result.map(item => {
                    return {
                        ...item,
                        isRegistrations: true,
                    }
                });
            }else{
                this.registrationList = [];
            }
            this._isLoading = false;
        }).catch(error=>{
            console.error('Error: ' + JSON.stringify(error));
        });
    }

    handleNomiSearch(){
        this._isLoading = true;

        this.nominationSearchParameters = {
            isRegistrations: false,
            courseName: this.template.querySelector(".searchNomCourseName").value,
            firstName: this.template.querySelector(".searchNomFirstName").value,
            lastName: this.template.querySelector(".searchNomLastName").value,
            email: this.template.querySelector(".searchNomEmail").value,
            mobile: this.template.querySelector(".searchNomMobile").value,
            status: this.template.querySelector(`[data-name="searchNomiStatus"]`).value,
            birthday: this.template.querySelector(".searchNomBday").value
        };

        getRegisAndNomis({ recordSearchParams : this.nominationSearchParameters, accountSelected : this.accountId})
        .then(result =>{
            if(result){
                this.nominationList = result.map(item => {
                    return {
                        ...item,
                        isRegistrations: false,
                    }
                });
            }else{
                this.nominationList = [];
            }
            this._isLoading = false;
        }).catch(error=>{
            console.error('Error: ' + JSON.stringify(error));
        });
    }

    closeModalAction(){
        this.selectedStudent = null;
        this.statusOptions = [];
    }

    
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.selectedStudent = null;
        this.statusOptions = [];
        this.isModalOpen = false;
    } 

    @wire(MessageContext)
    messageContext;

    regisList;
    @wire(getRegisAndNomis,{
        recordSearchParams : '$registrationRecordSearchParameters',
        accountSelected : '$accountId'
    })
    handleGetRegistrations(result){  
        this.regisList = result;
        if(result.data && result.data.length != 0){
            this.registrationList = result.data.map( item => {
                return {
                    ...item,
                    isRegistrations: true,
                }
            });  
            this._isLoading = false;   
        } else if(result.error){
            this._isLoading = false;
        }
    }

    nomisList;
    @wire(getRegisAndNomis,{
        recordSearchParams: '$nominationSearchParameters',
        accountSelected : '$accountId'
    })
    handleGetNominations(result){  
        this.nomisList = result;
        if(result.data && result.data.length != 0){
            this.nominationList = result.data.map( item => {
                return {
                    ...item,
                    isRegistrations: false,
                }
            }); 
            this._isLoading = false;
        } else if(result.error){
            this._isLoading = false;
        }
    }
    
    @wire(getRegistrationStatusValues)
    handleGetRegistrationStatusValues(result){  
        if(result.data){
            const options = result.data.map( v => {
                return {
                    label: v,
                    value: v
                }
            });
            this.registrationStatus = options;
            this.searchRegistrationStatus = [
                {
                    lable: '---Please Select---',
                    value: '',
                },
                ...options,
            ];
        }
    }

    @wire(getNominationStatusValues)
    handleGetNominationStatusValues(result){  
        if(result.data){
            const options = result.data.map( v => {
                return {
                    label: v,
                    value: v
                }
            });
            this.nominationStatus = options;
            
            this.searchNominationStatus = [
                {
                    lable: '---Please Select---',
                    value: '',
                },
                ...options,
            ];
        }
    }

    get isCCEPortal() {
        return BasePath.toLowerCase().includes("cce");
      }
    
      get isOPEPortal() {
        return BasePath.toLowerCase().includes("study");
    } 

    renderedCallback() {
        if (this.isCCEPortal == true){
            console.log('CCE=>', this.isCCEPortal);
            Promise.all([loadStyle(this, customCCECSS + "/QUTCCEComponent.css")]);
            this.publishLMS();
        }else{
        }
    
    }
    
    connectedCallback(){
        this.subscribeLMS();
        if(sessionStorage.getItem(STORED_ACCTID)){
            this.accountId =  sessionStorage.getItem(STORED_ACCTID);
          }
        this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
    }

    publishLMS() {
        let paramObj = {
            productId: 1,
            productName: 'Manage Registrations',
            clearOtherMenuItems: true
        }

        const payLoad = {
            parameterJson: JSON.stringify(paramObj)
        };

        publish(this.messageContext, payloadContainerLMS, payLoad);
    }

    subscribeLMS() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext, 
                payloadAcctContainerLMS, 
                (message) => this.validateValue(message));
        }
    }

    validateValue(val) {
        if (val && val.accountIdParameter) {
            let newValObj = JSON.parse(val.accountIdParameter);
            this.accountId = newValObj.accountId;
        }
    }

    disconnectedCallback() {
        this.unsubscribeLMS();
    }

	unsubscribeLMS(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    combineLocaleAndNumber(locale,number){
        let localeFormatted = locale.replace(/[^0-9\.]+/g,"");
        let num = number.replace(/\D/g, "");
        if(locale){
            let tempNum = num.slice(0, 2);
            if(localeFormatted == tempNum){
                num = num.slice(2);
        }            
            return localeFormatted + parseInt(num);
        }
        return parseInt(num).toString();
    }

    //Function to generate toastmessage
    generateToast(_title, _message, _variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    //handles the exporting of list of learners via csv file.
    handleExportLearnersList(){

        let rowEnd = '\n';
        let csvString = '';
        let arrangedKeys = ['courseName','contactFirstName','contactLastName','contactEmail','contactBirthdate','contactMobile','offeringEndDate','offeringStartDate','status'];

        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(arrangedKeys);

        csvString += COLUMN_HEADER;
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.registrationList.length; i++){
            let colValue = 0;
            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.registrationList[i][rowKey] === undefined ? '' : this.registrationList[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        // Creating anchor element to download
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = 'Exported Learners List.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();

    }
    formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    
        return [year, month, day].join('-');
    }
    parseDate(date){
        if(date.replace('\r','') === ''){
            return '';
        }else{
            return date?new Date(date.replace('\r','')).toLocaleDateString('en-AU'):'';
        }
        
    }
}