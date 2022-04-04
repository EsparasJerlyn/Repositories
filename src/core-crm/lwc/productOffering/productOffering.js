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
import { getRecord, getFieldValue, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from 'lightning/platformResourceLoader';
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';
import HAS_PERMISSION from "@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest";
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';
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
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import getProductOfferingData from "@salesforce/apex/ProductOfferingCtrl.getProductOfferingData";
import getTermId from "@salesforce/apex/ProductOfferingCtrl.getTermId";
import updateCourseConnections from "@salesforce/apex/ProductOfferingCtrl.updateCourseConnections";
import getOfferingLayout from '@salesforce/apex/ProductOfferingCtrl.getOfferingLayout';

const DATE_OPTIONS = { year: 'numeric', month: 'short', day: '2-digit' };
const PROGRAM_OFFERING_FIELDS = 'Id,Delivery_Type__c,Start_Date__c,End_Date__c,IsActive__c,CreatedDate';
const COURSE_OFFERING_FIELDS = 'Id,Delivery_Type__c,hed__Start_Date__c,hed__End_Date__c,IsActive__c,CreatedDate';

export default class ProductOffering extends LightningElement {
    @api recordId;
    @api objectApiName;
    
    parentInfoMap;
    childInfoMap;
    activeMainSections = [];
    @track productOfferings = [];
    isLoading = true;
    newRecord = false;
    isOpeProgramRequest= false;
    objectToCreate = '';
    parentIdToCreate;
    parentId;
    termId;
    layoutMap = {};
    layoutItem;
    isStatusCompleted;

    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    //decides to show helptext when there's no offering
    get showProductOfferings(){
        return this.productOfferings.length > 0 && this.layoutItem;
    }

    //decides to show edit buttons
    get showEditButton(){
        return !this.isStatusCompleted;
    }

    //gets QUTeX Term id and loads css
    connectedCallback(){
        Promise.all([
            loadStyle(this, customDataTableStyle)
        ])
        .then(() => { 
            return getTermId({});
        })
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

    //gets product request details
    //assigns if data is for course or program plan
    @wire(getRecord, { recordId: '$recordId', fields: [PR_RT_DEV_NAME,PR_STATUS] })
    handleProductRequest(result){
        if(result.data){
            this.isStatusCompleted = getFieldValue(result.data,PR_STATUS) == PL_ProductRequest_Completed;
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
            if(!this.layoutItem){
                this.handleGetOfferingLayout();
            }
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
        if(result.data){
            this.offeringResult = result;
            this.parentId = this.offeringResult.data.parentId;
            this.productOfferings = this.formatOfferingData(this.offeringResult.data);
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    //gets the layout for the offering details
    handleGetOfferingLayout(){
        getOfferingLayout({})
        .then((layoutMap) => {
            Object.keys(layoutMap).forEach(key => {
                this.layoutMap[key] = this.formatLayout(layoutMap[key][0]);
            });
            this.layoutItem = this.layoutMap[this.childInfoMap.objectType];
        })
        .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        });
    }

    //gets product offering overview layout from metadata
    formatLayout(layout){
        return {
            sectionLabel : layout.MasterLabel,
            leftColumn : 
                layout.Left_Column_Long__c ?
                JSON.parse(layout.Left_Column_Long__c) : null,
            rightColumn : 
                layout.Right_Column_Long__c ? 
                JSON.parse(layout.Right_Column_Long__c) : null,
            singleColumn : layout.Single_Column_Long__c ? 
                JSON.parse(layout.Single_Column_Long__c) : null
        };
    }
    
    //formats offering data into a display-ready type
    formatOfferingData(offeringData){
        let offerings = [];
        offeringData.productOfferings.forEach(offering => {
            let facis = offeringData.relatedFacilitators.filter(faci => faci[this.childInfoMap.objectType] == offering.Id);
            let sesh = offeringData.relatedSessions.filter(sesh => sesh.Course_Offering__c == offering.Id);
            let relFaci = this.formatFacilitators(facis);
            let relSesh = this.formatSessions(sesh,relFaci);
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
                    badgeClass: offering.IsActive__c ?
                        'slds-badge slds-theme_success section-button section-badge' :
                        'slds-badge slds-badge_inverse section-button section-badge',
                    badgeIcon: offering.IsActive__c ? 'utility:success' : 'utility:choice',
                    badgeLabel: offering.IsActive__c ? 'Active' : 'Inactive',
                    label : offering.Delivery_Type__c + ' (' + startDate + ' to ' + endDate + ')',
                    relatedFacilitators : relFaci,
                    relatedSessions : relSesh,
                    showFacilitatorTable : relFaci.length > 0,
                    showSessionTable : relSesh.length > 0,
                    disableSession : relFaci.length == 0 || this.isStatusCompleted,
                    showHelp : relFaci.length == 0 && this.showEditButton
                }
            );
        });
        this.activeMainSections = offerings.filter(
            offer => offer.IsActive__c
        ).map(
            offer => {return offer.Id}
        );
        this.isLoading = false;
        return offerings;
    }

    //formats facilitators into a display-ready type
    formatFacilitators(facilitators){
        return facilitators.map((item,index) => {
            return {
                ...item,
                rowId: 'row-'+index,
                contactName: item.Facilitator_Bio__r.Facilitator__r.Name,
                contactId:item.Facilitator_Bio__r.Facilitator__c,
                bio:item.Facilitator_Bio__r.Facilitator_Professional_Bio__c,
                customLookupClass: 'slds-cell-edit',
                customRichtextClass: 'slds-cell-edit',
                editable: this.showEditButton,
                helpText: item.hed__Primary__c?'Unset As Primary':'Set As Primary',
                variantName: item.hed__Primary__c?'Brand':'',
                disableSetAsPrimary: this.isStatusCompleted         
            }
        });
    }

    //formats sessions into a display-ready type
    formatSessions(sessions,relatedFacis){
        return sessions.map((item,index) => {
            return {
                ...item,
                rowId: 'row-'+index,
                contactName:item.Course_Connection__r.hed__Contact__c ? item.Course_Connection__r.hed__Contact__r.Name : '',
                relatedFacilitators: relatedFacis.map(item =>{
                    return {
                        id:item.Id,
                        label:item.contactName,
                        meta:item.Name,
                    }
                }),
                customPicklistClass: 'slds-cell-edit',
                customSearchClass: 'slds-cell-edit',
                customStartTimeClass: 'slds-cell-edit',
                customEndTimeClass: 'slds-cell-edit',
                customLookupClass: 'slds-cell-edit',
                editable: this.showEditButton,
            }
        });
    }

    //converts date fields in AU format
    formatDate(date){
        return new Date(date).toLocaleDateString('en-AU',DATE_OPTIONS);
    }

    //opens create modal for course/program offering
    handleNewOffering(){
        this.newRecord = true;
        this.objectToCreate = this.childInfoMap.objectType;
        this.parentIdToCreate = this.parentId;
    }

    //refreshes data
    handleRefreshData(){
        this.isLoading = true;
        refreshApex(this.offeringResult)
        .then(() => {
            this.isLoading = false;
        });
    }

    //creates course connection for selected facilitator on search
    handleSearchSelect(event){
        let selected = event.detail;
        let bioFields = {
            Id: selected.value,
            Facilitator__c: selected.contactId
        }
        this.parentIdToCreate = selected.parent;
        this.handleCreateCourseConnection(bioFields); 
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
        this.handleRefreshData();
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

    //handles field assignments before committing to the database
    async handleSaveRecord(event){
        let fields = {...event.detail};
        if(this.objectToCreate == FACILITATOR_BIO.objectApiName){
            const recordInput = { apiName: FACILITATOR_BIO.objectApiName, fields };
            try{
                const createdFaci = await createRecord(recordInput);
                fields.Id = createdFaci.id;
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

    //updates course connections when Set as Primary is selected
    handleUpdateFacilitators(event){
        let facilitatorId = event.detail.value;
        this.isLoading = true;
        let valuesToUpdate = [];
        let isFaciRelated;
        for (let i = 0; i < this.productOfferings.length; i++) {
            isFaciRelated = this.productOfferings[i].relatedFacilitators.find(faci => faci.Id == facilitatorId);
            if(isFaciRelated){
                valuesToUpdate = this.productOfferings[i].relatedFacilitators.map(faci => {
                    let newItem = {};
                    newItem.Id = faci.Id;
                    if(faci.Id == facilitatorId){
                        newItem.hed__Primary__c = !faci.hed__Primary__c;
                    }else{
                        newItem.hed__Primary__c = false;
                    }
                    return newItem;
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
            this.handleRefreshData();
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
            this.handleRefreshData();
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