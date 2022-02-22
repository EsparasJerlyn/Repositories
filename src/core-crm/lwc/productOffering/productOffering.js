/**
 * @description A custom LWC for the product offering tab of product requests
 *
 * @see ../classes/ProductOfferingCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 8, 2022      | DEPP-1258    | Created file                                           | 
      |                           |                       |              |                                                        |
*/
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import HAS_PERMISSION from "@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest";
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import COURSE from "@salesforce/schema/hed__Course__c";
import COURSE_OFFERING from "@salesforce/schema/hed__Course_Offering__c";
import CO_COURSE from "@salesforce/schema/hed__Course_Offering__c.hed__Course__c";
import COURSE_CONNECTION from "@salesforce/schema/hed__Course_Enrollment__c";
import FACILITATOR_BIO from "@salesforce/schema/Facilitator_Bio__c";
import PROGRAM_OFFERING from "@salesforce/schema/Program_Offering__c";
import PO_PROGRAM_PLAN from "@salesforce/schema/Program_Offering__c.hed_Program_Plan__c";
import PROGRAM_PLAN from "@salesforce/schema/hed__Program_Plan__c";
import C_PRODUCT_REQUEST from '@salesforce/schema/hed__Course__c.ProductRequestID__c';
import PP_PRODUCT_REQUEST from '@salesforce/schema/hed__Program_Plan__c.Product_Request__c';
import PR_RT_DEV_NAME from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import getProductOfferingData from "@salesforce/apex/ProductOfferingCtrl.getProductOfferingData";
import cloneProductOfferingData from "@salesforce/apex/ProductOfferingCtrl.cloneProductOfferingData";
import getTermId from "@salesforce/apex/ProductOfferingCtrl.getTermId";
import getAllFacilitatorBio from "@salesforce/apex/ProductOfferingCtrl.getAllFacilitatorBio";
import updateCourseConnections from "@salesforce/apex/ProductOfferingCtrl.updateCourseConnections";

const SESSION_ACTIONS = [
    {label: 'Delete', name: 'delete' }
];
const SESSION_COLUMNS = [
    { label: 'Session Name', fieldName: 'Session_Name__c', wrapText: true},
    { label: 'Session Type', fieldName: 'Session_Type__c', wrapText: true },
    { label: 'Facilitator', fieldName: 'contactUrl', type: 'url',
        typeAttributes: { label: { fieldName: 'contactName' } }
    },
    { label: 'Start Time', fieldName: 'Start_Time__c', wrapText: true },
    { label: 'End Time', fieldName: 'End_Time__c', wrapText: true },
    { label: 'Location', fieldName: 'locUrl', type: 'url',
        typeAttributes: { label: { fieldName: 'locName' } }
    },
    { label: 'Location Details', fieldName: 'Location_Detail__c', wrapText: true },
    { type: 'action', typeAttributes: { rowActions: SESSION_ACTIONS } }
];
const DATE_OPTIONS = { year: 'numeric', month: 'short', day: '2-digit' };
const DATETIME_OPTIONS = { ...DATE_OPTIONS, hour:'2-digit', minute:'2-digit' };
const PROGRAM_OFFERING_FIELDS = 
    'Id,Delivery_Type__c,Start_Date__c,Registration_Start_Date__c,'+
    'Registration_End_Date__c,End_Date__c,hed_Program_Plan__c';
const COURSE_OFFERING_FIELDS = 
    'Id,Delivery_Type__c,hed__Start_Date__c,Registration_Start_Date__c,'+
    'Registration_End_Date__c,hed__End_Date__c,hed__Course__c,hed__Term__c';

export default class ProductOffering extends LightningElement {
    @api recordId;
    
    facilitatorColumns = [];
    sessionColumns = SESSION_COLUMNS;
    parentInfoMap;
    childInfoMap;
    activeMainSections = [];
    @track productOfferings = [];
    productOfferingsToClone = [];
    allFacilitatorBios = [];
    processedBios = [];
    isLoading = false;
    showConfirmClone = false;
    showPopover = false;
    newRecord = false;
    hasLoaded = false;
    isOpeProgramRequest= false;
    objectToCreate = '';
    parentIdToCreate;
    parentId;
    termId;
    offeringToClone;

    //constructs columns for facilitator table
    constructor(){
        super();
        this.facilitatorColumns = [
            { label: 'ID', fieldName: 'Name' },
            { label: 'Facilitator', fieldName: 'contactUrl', type: 'url',
                typeAttributes: { label: { fieldName: 'contactName' } }
            },
            { label: 'Professional Bio', fieldName: 'professionalBio', wrapText: true },
            { label: 'Is Primary?', fieldName: 'hed__Primary__c', type:'boolean' },
            { type: 'action', typeAttributes: { rowActions: this.facilitatorActions } }
        ];
    }

    //dynamic setting of facilitator actions
    facilitatorActions(row, doneCallback){
        const actions = [
            {label: 'Set as Primary', name: 'favorite', disabled : row.hed__Primary__c },
            {label: 'Delete', name: 'delete', disabled : row.disableRemove }
        ];
        doneCallback(actions);
    }

    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    //decides to show helptext when there's no offering
    get showProductOfferings(){
        return this.productOfferings.length > 0;
    }

    //gets QUTeX Term id on load
    connectedCallback(){
        getTermId({})
        .then((termIdResult) => {
            this.termId = termIdResult;
        })
        .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        });
    }
    
    //stores object info of course connection
    @wire(getObjectInfo, { objectApiName: COURSE_CONNECTION.objectApiName })
    courseConnectionInfo;

    //gets all facilitator bios available
    bioResult;
    @wire(getAllFacilitatorBio)
    handleBio(result){
        if(result.data){
            this.bioResult = result;
            this.allFacilitatorBios = this.bioResult.data;
            this.processedBios = this.allFacilitatorBios.map(bio => {
                return {
                    id:bio.Id,
                    label:bio.Facilitator__r.Name,
                    meta:
                        bio.Facilitator_Professional_Bio__c ? 
                        this.removeHtmlTags(bio.Facilitator_Professional_Bio__c) : ''
                }
            });
            this.formatBios();
        }
    }

    //gets product request details
    //assigns if data is for course or program plan
    @wire(getRecord, { recordId: '$recordId', fields: [PR_RT_DEV_NAME] })
    handleProductRequest(result){
        if(result.data){
            this.isOpeProgramRequest = getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Program;
            this.parentInfoMap = {
                field : this.isOpeProgramRequest ? PP_PRODUCT_REQUEST.fieldApiName : C_PRODUCT_REQUEST.fieldApiName,
                objectType : this.isOpeProgramRequest ? PROGRAM_PLAN.objectApiName :COURSE.objectApiName
            };
            this.childInfoMap = {
                fields : this.isOpeProgramRequest ? PROGRAM_OFFERING_FIELDS : COURSE_OFFERING_FIELDS,
                objectType : this.isOpeProgramRequest ? PROGRAM_OFFERING.objectApiName : COURSE_OFFERING.objectApiName,
                conditionField : this.isOpeProgramRequest ? PO_PROGRAM_PLAN.fieldApiName : CO_COURSE.fieldApiName
            };
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    //gets all related offerings, facilitators, and sessions of product request
    offeringResult = [];
    @wire(getProductOfferingData, { 
        productRequestId : "$recordId", 
        parentInfo : "$parentInfoMap",
        childInfo : "$childInfoMap"
    })
    handleGetProductOfferingData(result){
        this.isLoading = true;
        if(result.data){
            this.offeringResult = result;
            this.parentId = this.offeringResult.data.parentId;
            this.productOfferings = this.formatOfferingData(this.offeringResult.data);
            this.isLoading = false;
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    //formats offering data into a display-ready type
    formatOfferingData(offeringData){
        this.productOfferingsToClone = [];
        let offerings = [];
        let ctr = 1;
        offeringData.productOfferings.forEach(offering => {
            let facis = offeringData.relatedFacilitators.filter(faci => faci[this.childInfoMap.objectType] == offering.Id);
            let sesh = offeringData.relatedSessions.filter(sesh => sesh.Course_Offering__c == offering.Id);
            let relFaci = this.formatFacilitators(facis,sesh);
            let relSesh = this.formatSessions(sesh);
            let startDate = 
                this.childInfoMap.objectType == COURSE_OFFERING.objectApiName ?
                this.formatDate(offering.hed__Start_Date__c) :
                this.formatDate(offering.Start_Date__c);
            let endDate = 
                this.childInfoMap.objectType == COURSE_OFFERING.objectApiName ?
                this.formatDate(offering.hed__End_Date__c) :
                this.formatDate(offering.End_Date__c);
            offerings.push(
                {
                    ...offering,
                    Registration_Start_Date__c: this.formatDate(offering.Registration_Start_Date__c),
                    Registration_End_Date__c: this.formatDate(offering.Registration_End_Date__c),
                    Start_Date__c:startDate,
                    End_Date__c:endDate,
                    label : 'Product Offering ' + ctr + ' (' + startDate + ' to ' + endDate + ')',
                    relatedFacilitators : relFaci,
                    relatedSessions : relSesh,
                    showFacilitatorTable : relFaci.length > 0,
                    showSessionTable : relSesh.length > 0,
                    disableSession : relFaci.length == 0,
                    biosToSearch : this.hasLoaded ? 
                        this.getBiosToSearch(facis.map(faci=>{return faci.Facilitator_Bio__c})) : []
                }
            );
            this.productOfferingsToClone.push(
                {
                    ...offering,
                    facilitators:facis.map(({ Id,Name, ...item }) => item),
                    sessions:sesh.map(({ Id, ...item }) => item)
                }
            );
            ctr++;
        });
        this.activeMainSections = offerings.map(offer => {return offer.Id});
        return offerings;
    }

    //formats facilitators into a display-ready type
    formatFacilitators(facilitators,relatedSessions){
        return facilitators.map(item => {
            return {
                ...item,
                contactName:item.Facilitator_Bio__r.Facilitator__r.Name,
                contactUrl:'/'+item.Facilitator_Bio__r.Facilitator__c,
                professionalBio:item.Facilitator_Bio__r.Facilitator_Professional_Bio__c ? 
                    this.removeHtmlTags(
                        item.Facilitator_Bio__r.Facilitator_Professional_Bio__c
                    ) : '',
                disableRemove : 
                    relatedSessions.map(sesh => {return sesh.Course_Connection__c}).
                    includes(item.Id) || item.hed__Primary__c
            }
        });
    }

    //formats sessions into a display-ready type
    formatSessions(sessions){
        return sessions.map(item => {
            return {
                ...item,
                contactName:item.Course_Connection__r.hed__Contact__c ? item.Course_Connection__r.hed__Contact__r.Name : '',
                contactUrl:item.Course_Connection__r.hed__Contact__c ? '/'+item.Course_Connection__r.hed__Contact__c : '',
                locName:item.Location__c ? item.Location__r.Name : '',
                locUrl:item.Location__c ? '/'+item.Location__c : '',
                Start_Time__c:item.Start_Time__c ? this.formatDateTime(item.Start_Time__c) : '',
                End_Time__c:item.End_Time__c ? this.formatDateTime(item.End_Time__c) : ''
            }
        });
    }

    //formats bios not added to offering for search feature (on load)
    formatBios(){
        this.productOfferings = this.productOfferings.map(offer => {
            let relatedFaciIds = offer.relatedFacilitators.map(faci=>{return faci.Facilitator_Bio__c});
            return {
                ...offer,
                biosToSearch:this.getBiosToSearch(relatedFaciIds)
            }
        });
        this.hasLoaded = true;
    }

    //formats bios not added to offering for search feature
    getBiosToSearch(relatedFaciIds){
        return this.processedBios.filter(bio => 
            !relatedFaciIds.includes(bio.id)
        );
    }

    //converts date fields in AU format
    formatDate(date){
        return new Date(date).toLocaleDateString('en-AU',DATE_OPTIONS);
    }

    //converts datetime fields in AU format
    formatDateTime(dateTime){
        return new Date(dateTime).toLocaleDateString('en-AU',DATETIME_OPTIONS);
    }

    //removes html tags from rich text fields
    removeHtmlTags(str){
        return str.replace(/(<([^>]+)>)/gi, "");
    }

    //opens create modal for course/program offering
    handleNewOffering(){
        this.newRecord = true;
        this.objectToCreate = this.childInfoMap.objectType;
        this.parentIdToCreate = this.parentId;
    }

    //creates course connection for selected facilitator on search
    handleSearchSelect(event){
        let selected = event.detail;
        let bioFields = {
            Id: selected.value,
            Facilitator__c:this.allFacilitatorBios.find(bio => 
                bio.Id == selected.value).Facilitator__c
        }
        this.parentIdToCreate = selected.parent;
        this.handleCreateCourseConnection(bioFields);
        
    }

    //shows confirmation modal for clone
    handleCloneOffering(event){
        this.showConfirmClone = true;
        this.offeringToClone = this.productOfferings.find(offer => offer.Id == event.target.dataset.name);
    }

    //calls apex method that clones selected offering and related data
    handleConfirmClone(event){
        this.handleCloseClone();
        this.isLoading = true;
        this.offeringToClone = this.productOfferingsToClone.find(offer => offer.Id == event.target.dataset.name);
        let _productOffering = {...this.offeringToClone};
        delete _productOffering.Id;
        delete _productOffering.facilitators;
        delete _productOffering.sessions;
        cloneProductOfferingData({
            objectType: this.childInfoMap.objectType,
            productOffering : _productOffering,
            facilitators: this.offeringToClone.facilitators,
            sessions: this.offeringToClone.sessions
        })
        .then(() => {
            this.generateToast("Success!", "Product Offering cloned.", "success");
        })
        .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        })
        .finally(() => {
            refreshApex(this.offeringResult)
            .then(() => {
                this.isLoading = false
            });
        });
    }

    //hides confirmation modal for clone
    handleCloseClone(){
        this.showConfirmClone = false;
    }

    //opens create modal for facilitator
    handleAddFacilitator(event){
        this.newRecord = true;
        this.objectToCreate = FACILITATOR_BIO.objectApiName;
        this.parentIdToCreate = event.target.dataset.name;
    }

    //opens create modal for session
    handleAddSession(event){
        this.parentIdToCreate = event.target.dataset.name;
        this.productOfferings.forEach(offering => {
            if(offering.Id == this.parentIdToCreate){
                offering.newSession = true;
            }
        })
    }

    //refreshes data and hides create modal of session upon successful save
    handleSuccessSession(){
        refreshApex(this.offeringResult);
        this.handleCloseSession();
    }

    //hides create modal of session
    handleCloseSession(){
        this.productOfferings.forEach(offering => {
            if(offering.Id == this.parentIdToCreate){
                offering.newSession = false;
            }
        })
    }

    //shows info for offering
    handleShowPopover(event){
        this.productOfferings.forEach(offering => {
            if(offering.Id == event.target.dataset.name){
                offering.showPopover = true;
            }
        })
    }

    //hides info for offering
    handleHidePopover(event){
        this.productOfferings.forEach(offering => {
            if(offering.Id == event.target.dataset.name){
                offering.showPopover = false;
            }
        })
    }

    //handles field assignments before committing to the database
    async handleSaveRecord(event){
        let fields = {...event.detail};
        if(this.objectToCreate == FACILITATOR_BIO.objectApiName){
            const recordInput = { apiName: FACILITATOR_BIO.objectApiName, fields };
            try{
                const createdFaci = await createRecord(recordInput);
                fields.Id = createdFaci.id;
                refreshApex(this.bioResult);
                this.handleCreateCourseConnection(fields);
            }catch(error){
                this.generateToast("Error.", LWC_Error_General, "error");
            }
        }else{
            if(this.objectToCreate == COURSE_OFFERING.objectApiName){
                fields.hed__Course__c = this.parentIdToCreate;
                fields.hed__Term__c = this.termId;
            }else if(this.objectToCreate == PROGRAM_OFFERING.objectApiName){
                fields.hed_Program_Plan__c = this.parentIdToCreate;
            }
            this.handleCreateRecord(fields,this.objectToCreate);
        }
    }

    //creates course connection for facilitator added
    handleCreateCourseConnection(facilitatorBio){
        let rtInfo = this.courseConnectionInfo.data.recordTypeInfos;
        let relatedOffering = this.productOfferings.find(offer => offer.Id == this.parentIdToCreate);
        let courseConnectionFields = {
            Facilitator_Bio__c:facilitatorBio.Id,
            hed__Contact__c:facilitatorBio.Facilitator__c,
            hed__Primary__c:relatedOffering.relatedFacilitators.length == 0,
            hed__Course_Offering__c:this.parentIdToCreate,
            RecordTypeId:Object.keys(rtInfo).find(rti => rtInfo[rti].name == 'Faculty')
        };
        this.handleCreateRecord(
            courseConnectionFields,
            COURSE_CONNECTION.objectApiName,
            courseConnectionFields.hed__Primary__c
        );
    }

    //handles row action for facilitator and session tables
    handleRowAction(event){
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.Id;
        if(actionName == 'favorite'){
            this.handleUpdateFacilitators(rowId);
        }else if(actionName == 'delete'){
            this.handleDeleteRow(rowId);
        }
    }

    //updates course connections when Set as Primary is selected
    handleUpdateFacilitators(facilitatorId){
        this.isLoading = true;
        let valuesToUpdate = [];
        let isFaciRelated;
        for (let i = 0; i < this.productOfferings.length; i++) {
            isFaciRelated = this.productOfferings[i].relatedFacilitators.find(faci => faci.Id == facilitatorId);
            if(isFaciRelated){
                valuesToUpdate = this.productOfferings[i].relatedFacilitators.map(faci => {
                    return {
                        Id:faci.Id,
                        hed__Primary__c:faci.Id == facilitatorId
                    }
                });
                break;
            }
        }
        updateCourseConnections({courseConnections : valuesToUpdate})
        .then(() => {
            const fields = {
                Id:isFaciRelated.hed__Course_Offering__c,
                Primary_Facilitator__c:facilitatorId
            };
            this.handleUpdateRecord(fields);
        })
        .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        })
        .finally(() => {
            refreshApex(this.offeringResult)
            .then(() => {
                this.isLoading = false
            });
        });
    }

    //hides create modal
    handleCloseRecord(){
        this.newRecord = false;
    }

    //saves record into the database
    handleCreateRecord(fieldsToCreate,objectType,updateOffering){
        this.isLoading = true;
        const fields = {...fieldsToCreate};
        const recordInput = { apiName: objectType, fields };

        createRecord(recordInput)
        .then(record => {
           this.generateToast('Success!','Record created.','success')
           if(updateOffering){
                const offeringFields = {
                    Id:fields.hed__Course_Offering__c,
                    Primary_Facilitator__c:record.id
                };
                this.handleUpdateRecord(offeringFields);
           }
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        .finally(() => {
            refreshApex(this.offeringResult)
            .then(() => {
                this.isLoading = false
            });
        });
    }

    //updates record and saves to the database
    handleUpdateRecord(fields){
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
        })
         .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        });
    }

    //deletes record from the database
    handleDeleteRow(recordToDelete) {
        this.isLoading = true;
        deleteRecord(recordToDelete)
        .then(() => {
           this.generateToast('Success!','Record deleted.','success')
        })
        .catch((error) => {
           this.generateToast("Error.", LWC_Error_General, "error");
        })
        .finally(() => {
            refreshApex(this.offeringResult)
            .then(() => {
                this.isLoading = false
            });
        });
    }

    //creates toast notification
    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant
        });
        this.dispatchEvent(evt);
    }
}