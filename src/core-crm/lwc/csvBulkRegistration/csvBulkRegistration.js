/**
 * @description An LWC component for creating products and offerings
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                            | Change Summary                                            |
      |---------------------------|-----------------------|---------------------------------|-----------------------------------------------------------|
      | aljohn.motas              | Dec 18, 2021          | DEPP-214 DEPP-1051              | Created                                                   |
      | roy.nino.s.regala         | Dec 27, 2021          | DEPP-214 DEPP-1028              | modified to call and handle saveLearnerInfo LWC           |
 */


import { LightningElement,wire,api,track} from 'lwc';
import getResourceURL from '@salesforce/apex/CsvBulkRegistrationCtrl.GetCMSContentDataByName';
import COM_ID from '@salesforce/community/Id';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_SCHEMA from '@salesforce/schema/Contact';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSV from '@salesforce/apex/CsvBulkRegistrationCtrl.readCSVFile';
import { NavigationMixin } from 'lightning/navigation';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';

const CSV_NAME = 'Bulk Registration CSV Template';
const CONTENT_TYPE = 'cms_document';
const ERROR_FOR_TEMPLATE = 'Template does not exist, Please contact your admin';
const ERROR_MSG = 'An error has been encountered. Please contact your administrator.';
const LANG = 'en_US';
const actions = [
    { label: 'Delete', name: 'delete' },
    { label: 'Edit', name: 'edit' },
];
const COLUMNS = [
    { label: 'Salutation', fieldName: 'Salutation', type: 'text' }, 
    { label: 'First Name', fieldName: 'FirstName', type: 'text' },
    { label: 'Middle Name', fieldName: 'MiddleName', type: 'text'}, 
    { label: 'Last Name', fieldName: 'LastName', type: 'text'}, 
    { label: 'Suffix', fieldName: 'Suffix', type: 'text'}, 
    { label: 'Email', fieldName: 'Email', type: 'email'}, 
    { label: 'Mobile Phone', fieldName: 'MobilePhone', type: 'phone'}, 
    { label: 'Phone', fieldName: 'Phone', type: 'phone'}, 
    { label: 'Birthdate', fieldName: 'Birthdate',  type: 'date'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    } 
];

export default class ProductBulkRegistration extends NavigationMixin(
    LightningElement
) {
    csvUrl;
    errors;
    recordId;
    @track columns = COLUMNS;
    contacts;
    prefields;
    isCreateRecord = false;
    isEditRecord = false;
    multiCreate;
    errorForTemplate= ERROR_FOR_TEMPLATE;
    processing = false;
    pickList;
    @api courseOffering = {}; //the course offering selected on the product details page


    get acceptedFormats() {
        return ['.csv'];
    }

    get disableProceedButton(){
        if(this.errors){
            return  Object.keys(this.errors.rows).length > 0 ||  
                    Object.keys(this.contacts).length === 0 
                    ||  this.processing? true: false;
        }else{
            return true;
        }
    }

    handleProcessing(event){
        this.processing = event.detail;
    }

    closeModal(){
        this.isCreateRecord = false;
        this.isEditRecord = false;
    }

    closeRegistrationModal(){
        let event = new CustomEvent('closecsvmodal');
        this.dispatchEvent(event);
    }

    handleRowAction( event ) {
    this.recordId=event.detail.row.id
    this.objApiName = CONTACT_SCHEMA.objectApiName;
        if(event.detail.action.name == "edit"){
            this.prefields = this.contacts.filter(contact => contact.id==this.recordId)[0];
            this.isEditRecord =true;
            this.isCreateRecord = false;
        }else if(event.detail.action.name == "delete"){
                let tempHolder = this.contacts;
                this.contacts = tempHolder.filter(contact=> {
                    return contact.id != this.recordId;
                });
        }else{
            alert("action not available");
        }
        this.rowvalidation();
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_SCHEMA })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SALUTATION_FIELD})
    saluationPickListValues({data,error}){
        if(data){
            this.pickList=data.values.map(option => {
                let optionHolder = [];
                optionHolder.push(option.label);
                optionHolder.push(option.value);
                return optionHolder;
            }).flat();
        }else if(error){
            console.log(error);
        }
    };

    addNewRow(event){
        this.objApiName = CONTACT_SCHEMA.objectApiName;
        this.prefields={
            Salutation:"",
            FirstName:"",
            MiddleName:"",
            LastName:"",
            Suffix:"",
            Email:"",
            MobilePhone:"",
            Phone:"",
            Birthdate:""
        }
        this.isEditRecord =false;
        this.isCreateRecord = true;
    }


    saveEdit(event){
        let tempHolder= this.contacts;
        let details = event.detail;
        this.contacts = tempHolder.map((contact,index)=>{
            let id=index+"";
            if(this.recordId == id){
                return {
                    Salutation:details.Salutation,
                    FirstName:details.FirstName,
                    MiddleName:details.MiddleName,
                    LastName:details.LastName,
                    Suffix:details.Suffix,
                    Email:details.Email,
                    MobilePhone:details.MobilePhone,
                    Phone:details.Phone,
                    Birthdate:details.Birthdate,
                    id
                }
            }else{
                return {
                    ...contact,
                    id
                    }
            }
        });
        this.rowvalidation();
    }

    saveNew(event){
        let tempHolder= this.contacts
        let details = event.detail;
        let maxId = (this.contacts.length!=0)?Math.max.apply(Math, this.contacts.map(function(contact) { return contact.id;})):0;
        let id = (maxId+1)+"";
        this.contacts = [...tempHolder,
            {
                Salutation:details.Salutation,
                FirstName:details.FirstName,
                MiddleName:details.MiddleName,
                LastName:details.LastName,
                Suffix:details.Suffix,
                Email:details.Email,
                MobilePhone:details.MobilePhone,
                Phone:details.Phone,
                Birthdate:details.Birthdate,
                id
            }
        ];
        this.rowvalidation();
    }

    validateEmail(email){
        const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return email.match(emailRegex)?true:false;
    }
    validatePhone(phone){
        const phoneRegex=/^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/im;
        return phone.match(phoneRegex)?true:false;
    }
    validateSalutation(Salutation){
        return this.pickList.includes(Salutation)?true:false;
    }
    parseDate(date){
        return date?new Date(date.replace('\r','')).toLocaleDateString('en-US'):''
    }
    rowvalidation(){
        let rowsValidation={};

        this.contacts.map(contact=>{
            let fieldNames = [];
            if(!this.validateEmail(contact.Email))fieldNames.push('Email');
            if(!this.validatePhone(contact.MobilePhone))fieldNames.push('MobilePhone');
            if(!this.validatePhone(contact.Phone))fieldNames.push('Phone');
            if(!this.validateSalutation(contact.Salutation))fieldNames.push('Salutation');
            if(fieldNames.length>0){
                rowsValidation[contact.id]={
                    title: 'We found an error/s.',
                    messages: [
                        'Please enter valid value for the ff. fields',
                        ...fieldNames
                    ],
                    fieldNames
                };
            }
        });
        this.errors = {
            rows:rowsValidation
        };
        
    }

    handleUploadFinished(event) {
        this.processing = true;
        const uploadedFiles = event.detail.files;
        readCSV({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            this.contacts = result.map((contact,index)=>{
                let id=index+"";
                    return {
                    ...contact,
                    Birthdate:this.parseDate(contact.Birthdate),
                    id
                    }
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message: 'Contacts are created based CSV file.',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );     
        })
        .finally(() => {
            this.processing = false;
            this.rowvalidation();
        });
    }

    @wire(getResourceURL, {contentNames : CSV_NAME,communityId : COM_ID, contentType : CONTENT_TYPE, language : LANG})
    handleGetCourses({data,error}){
        if(data){
            this.csvUrl = "/cce/sfsites/c/cms/delivery/media/"+data.contentKey;
            console.log(this.csvUrl,"url");
        }else if(error){
            this.generateToast('Error.',ERROR_MSG,'error');
        }
    }

}