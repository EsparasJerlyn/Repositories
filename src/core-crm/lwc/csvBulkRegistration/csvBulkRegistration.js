/**
 * @description An LWC component for creating products and offerings
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                            | Change Summary                                            |
      |---------------------------|-----------------------|---------------------------------|-----------------------------------------------------------|
      | aljohn.motas              | Dec 18, 2021          | DEPP-214 DEPP-1051              | Created                                                   |
      | roy.nino.s.regala         | Dec 27, 2021          | DEPP-214 DEPP-1028              | modified to call and handle saveLearnerInfo LWC           |
      | jessel.bajao              | August 11, 2022       | DEPP-3483                       | Changed table rows, added validations and functions for   |
      |                           |                       |                                 | csv bulk registration                                     |
      | jessel.bajao              | September 12, 2022    | DEPP-4248                       | Fix Mobile Locale issues                                  |
      | john.m.tambasen			  | September 12, 2022    | DEPP-3743                       | validate duplicate contacts		    			    	|
      | eugene.andrew.abuan   	  | September 20, 2022    | DEPP-4341                       | validate invalid date of birth		    			  	|
      | jessel.bajao              | September 29, 2022    | DEPP-4314                       | Changed code for browsers compatibility of Date of Birth  |
      | eugene.andrew.abuan   	  | October 03, 2022      | DEPP-4494                       | Added leading zeroes in convertDate function		    	|
      | eugene.andrew.abuan   	  | October 04, 2022      | DEPP-4503                       | Added validation for firstname and lastname               |
      | julie.jane.alegre         | October 08, 2022      | DEPP-4551                       | Update pass parameter to the sessionStorage  |

      */


import { LightningElement,wire,api,track} from 'lwc';
import getResourceURL from '@salesforce/apex/CsvBulkRegistrationCtrl.GetCMSContentDataByName';
import getMobileLocaleOptions from "@salesforce/apex/RegistrationFormCtrl.getMobileLocaleOptions";
import COM_ID from '@salesforce/community/Id';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_SCHEMA from '@salesforce/schema/Contact';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSV from '@salesforce/apex/CsvBulkRegistrationCtrl.readCSVFile';
import { NavigationMixin } from 'lightning/navigation';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';

import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import {loadStyle} from "lightning/platformResourceLoader";
import BasePath from "@salesforce/community/basePath";
import customCCECSS from "@salesforce/resourceUrl/QUTMainCSS";

const CURRENTPRODUCTCATEGORY = "product_category";
const CSV_NAME = 'BulkRegistrationCSVTemplate';
const CONTENT_TYPE = 'cms_document';
const ERROR_FOR_TEMPLATE = 'Template does not exist, Please contact your admin';
const ERROR_MSG = 'An error has been encountered. Please contact your administrator.';
const Tailored_Executive_Education = 'Tailored Executive Education';
const Corporate_Bundle = 'Corporate Bundle';
const LANG = 'en_US';
const actions = [
    { label: 'Delete', name: 'delete' },
    { label: 'Edit', name: 'edit' },
];
const COLUMNS = [
    { label: 'First Name', fieldName: 'FirstName', type: 'text' },
    { label: 'Last Name', fieldName: 'LastName', type: 'text' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: "Mobile Locale", fieldName: "MobileLocale", type: "text" },
    { label: "Mobile", fieldName: "MobilePhone", type: "phone" },
    { label:'Date of Birth', fieldName: 'Birthdate', type: 'date' },
    {
        label: "Dietary Requirement",
        fieldName: "DietaryRequirement",
        type: "text"
    },
    {
        label: "Accessibility Requirement",
        fieldName: "AccessibilityRequirement",
        type: "text"
    },
    {
        type: "action",
        typeAttributes: { rowActions: actions }
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
    productCategoryCheck;
    @api courseOffering = {}; //the course offering selected on the product details page
    @api productDetails; //the product details data on the product details page
    @api isPrescribed; //the isPrescribed data on the product details page
    @api creditAvailable; //this is the available remaining credit
    @track totalAmount;
    mobileLocaleList = [];
    filteredFieldNames = [];
    filteredMobileLocale = [];
    
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
    connectedCallback(){
        if(this.isCCEPortal){
            //get current product category
            let currentProductCategory = JSON.parse(
             sessionStorage.getItem(CURRENTPRODUCTCATEGORY)
            );
            if(currentProductCategory && currentProductCategory.fromCategoryName == Corporate_Bundle){ 
                this.productCategoryCheck = true;
            }
       }
        this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";

        //fetch mobile locales
        getMobileLocaleOptions()
        .then((result) => {
            this.mobileLocaleList = result;
        })
        .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "warning");
        });
    }

    closeRegistrationModal(){
        let event = new CustomEvent('closecsvmodal');
        this.dispatchEvent(event);
    }



    handleRowAction( event ) {
    this.recordId=event.detail.row.id
    this.objApiName = CONTACT_SCHEMA.objectApiName;
        if(event.detail.action.name == "edit"){
            //filter contact
            let selectedContact = this.contacts.filter(
                (contact) => contact.id == this.recordId
            )[0];
              //format date
              let bdayFormat = selectedContact.Birthdate;
          
              //setup edit form prefields
            this.prefields = {
                FirstName: selectedContact.FirstName,
                LastName: selectedContact.LastName,
                Email: selectedContact.Email,
                ContactMobile_Locale__c: selectedContact.MobileLocale,
                MobilePhone: selectedContact.MobilePhone,
                Birthdate:bdayFormat,
                Accessibility_Requirement__c:
                    selectedContact.AccessibilityRequirement,
                Dietary_Requirement__c: selectedContact.DietaryRequirement,
                id: selectedContact.id
            };        
           
            this.isEditRecord = true;
            this.isCreateRecord = false;
        }else if(event.detail.action.name == "delete"){
                let tempHolder = this.contacts;
                this.contacts = tempHolder.filter(contact=> {
                    return contact.id != this.recordId;
                });

                //after deletion, reset the id to it's index
                this.contacts.forEach((element, index) => {
                    element.id = index + 1;
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
        if (this.contacts.length === this.courseOffering.availableSeats) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Reminder",
                    message:
                        "There are not enough seats available to complete this transaction.",
                    variant: "warning"
                })
            );
        } 
        else 
        if(this.contacts.length < this.courseOffering.availableSeats){
            this.objApiName = CONTACT_SCHEMA.objectApiName;
            this.prefields = {
                FirstName: "",
                LastName: "",
                Email: "",
                MobileLocale: "",
                MobilePhone: "",
                Birthdate: "",
                DietaryRequirement: "",
                AccessibilityRequirement: ""
            };
            this.isEditRecord = false;
            this.isCreateRecord = true;
        }
    }


    saveEdit(event){
        let tempHolder= this.contacts;
        let details = event.detail;
        this.contacts = tempHolder.map((contact,index)=>{
            let id = index + 1;
            if (this.recordId == contact.id) {
                return {
                    FirstName: details.FirstName,
                    LastName: details.LastName,
                    Email: details.Email,
                    MobileLocale: details.ContactMobile_Locale__c,
                    MobilePhone: details.MobilePhone,
                    Birthdate: details.Birthdate,
                    DietaryRequirement: details.Dietary_Requirement__c,
                    AccessibilityRequirement: details.Accessibility_Requirement__c,
                    id
                };
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
                FirstName: details.FirstName,
                LastName: details.LastName,
                Email: details.Email,
                MobileLocale: details.ContactMobile_Locale__c,
                MobilePhone: details.MobilePhone,
                Birthdate: details.Birthdate,
                AccessibilityRequirement: details.Accessibility_Requirement__c,
                DietaryRequirement: details.Dietary_Requirement__c,
                id
            }
        ];
        this.rowvalidation();
    }

    validateEmail(email){
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return email.match(emailRegex) ? true : false;
    }
    validatePhone(phone){
        const phoneRegex=/^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/im;
        const mobileNumber= phone.replace(/[^0-9\.]/g, '');
        return mobileNumber.match(phoneRegex) ? true : false;
    }

     
    validateDate(Birthdate){
        return Birthdate === '' ? false : true;
    }
    parseDate(date){
        if(date.replace('\r','') === ''){
            return '';
        }else{
            return date?new Date(date.replace('\r','')).toLocaleDateString('en-AU'):'';
        }
        
    }
    rowvalidation(){
        let rowsValidation={};

       this.contacts =  this.contacts.map(contact=>{
        let fieldNames = [];
		let mobileLocaleExists = [];					
		mobileLocaleExists = this.mobileLocaleList.filter(lcl =>  //filters if contact mobile locale exist in mobile locale list
		   lcl.value == contact.MobileLocale        
		);
          let contactLocale;
            if(contact.Email) {
                if (!this.validateEmail(contact.Email))
                    fieldNames.push("Email");
            }                 
            if (contact.MobileLocale.length == 0){
                fieldNames.push("Mobile Locale");
            }
			else if(mobileLocaleExists.length > 0){
				contactLocale = contact.MobileLocale
				  fieldNames = fieldNames.filter(field => field != 'Mobile Locale')
			  } 
			 else if(isNaN(contact.MobileLocale)){
                fieldNames.push("Mobile Locale"); 
                contactLocale = contact.MobileLocale;  
            }else{
                this.filteredMobileLocale = this.mobileLocaleList.filter(lcl => 
                
                    lcl.countryCode == contact.MobileLocale        
                 );
                 if(this.filteredMobileLocale.length == 0 || this.filteredMobileLocale === undefined){
                    this.filteredFieldNames = fieldNames.filter(fld => fld == 'Mobile Locale')
                    if(this.filteredFieldNames.length == 0 || this.filteredFieldNames === undefined){
                        fieldNames.push('Mobile Locale');                   
                    }
                    contactLocale  = contact.MobileLocale;           
                 }else{
                          contactLocale = this.filteredMobileLocale[0].value;
						  fieldNames = fieldNames.filter(field => field != 'Mobile Locale')
                 }           
            }    
            if(contact.MobilePhone.length == 0) {
                fieldNames.push("MobilePhone");                     
            }else if(isNaN(contact.MobilePhone)){
                fieldNames.push("MobilePhone");     
            }
            else{
                if (
                    !this.validatePhone(
                        contact.MobileLocale +
                            contact.MobilePhone
                    )
                ) {
                    fieldNames.push("MobilePhone");
                }
            }

            if(contact.Birthdate) {
                if (!this.validateDate(contact.Birthdate)){
                    fieldNames.push("Date of Birth");
                }
            } else{
                fieldNames.push("Date of Birth");
            }

            if(!contact.FirstName){
                fieldNames.push("First Name");

            }

            if(!contact.LastName){
                fieldNames.push("Last Name");
            }
         
            if(fieldNames.length>0){
                rowsValidation[contact.id]={
                    title: 'We found an error/s.',
                    messages: [
                        'Please enter valid value for the ff. fields',
                        ...fieldNames
                    ],
                    fieldNames : fieldNames
                };
            }

            return{
                ...contact,
                MobileLocale: contactLocale
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
       

            this.contacts = result.map((contact,index)=> {
                let id=index+1+"";
                    return {
                    ...contact,
                    Birthdate :  contact.Birthdate ?  this.convertDate(contact.Birthdate) : '',
                    id
                    }
            });
           
            if (this.contacts.length > this.courseOffering.availableSeats) {
                this.contacts = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Reminder",
                        message:
                            "There are not enough seats available to complete this transaction.",
                        variant: "warning"
                    })
                );
            } else {
                if(this.productCategoryCheck){
                    this.totalAmount = this.contacts.length * this.productDetails.PricebookEntries[0].UnitPrice; 
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success!",
                        message: "Contacts are created based on CSV file.",
                        variant: "success"
                    })
                );
            }
        })
        .catch(error => {
            this.error = error;
            console.log('error', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: ERROR_MSG,
                    variant: 'warning',
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
        }else if(error){
            this.generateToast('Error.',ERROR_MSG,'warning');
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
            Promise.all([loadStyle(this, customCCECSS + "/QUTCCEComponent.css")]);
        }else{
        }
    
    }

    showDuplicateErrors(event){
        let errorsTemp = JSON.parse(JSON.stringify(event.detail));
        this.errors = errorsTemp;
    }

    convertDate(date, separator = '-'){
        if(date.includes('/')){
            let d;
            let [day, month, year] = date.split('/');

            if (month.length == 1){
                month = "0" + month;
            }

            if (day.length == 1){
                day = '0' + day;
            }

            d = year + separator + month + separator + day;
            var newDay  = new Date(d)

            if(d.includes('undefined')){
                d = '';
            }else if(newDay == 'Invalid Date'){
                d = '';
            }
            return d;
        }else{
            return '';
        }
      };
}