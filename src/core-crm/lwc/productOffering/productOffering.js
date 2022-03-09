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
import getTermId from "@salesforce/apex/ProductOfferingCtrl.getTermId";
import getAllFacilitatorBio from "@salesforce/apex/ProductOfferingCtrl.getAllFacilitatorBio";
import updateCourseConnections from "@salesforce/apex/ProductOfferingCtrl.updateCourseConnections";
import getLayoutMapping from '@salesforce/apex/CustomLayoutCtrl.getLayoutMapping';

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
    allFacilitatorBios = [];
    processedBios = [];
    isLoading = false;
    newRecord = false;
    hasLoaded = false;
    isOpeProgramRequest= false;
    objectToCreate = '';
    parentIdToCreate;
    parentId;
    termId;
    layoutItem = {};

    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    //decides to show helptext when there's no offering
    get showProductOfferings(){
        return this.productOfferings.length > 0 && this.layoutItem;
    }

    //gets QUTeX Term id and loads css
    connectedCallback(){
        Promise.all([
            loadStyle(this, customDataTableStyle)
        ]).then(() => { });

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

    childRecordTypeDevName;
    @wire(getObjectInfo, { objectApiName: '$childInfoMap.objectType'})
    handleChildObjectInfo(result){
        if(result.data){
            //condition for layouts with no record types
            //metadata is named as All_OPE_<Object_Plural_Label>
            this.childRecordTypeDevName = 'All_OPE_' + result.data.labelPlural.replace(' ','_');
            this.getOfferingLayout();
        }
    }

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

    //gets product offering overview layout from metadata
    getOfferingLayout(){
        getLayoutMapping({
            objApiName : this.childInfoMap.objectType,
            rtDevName : this.childRecordTypeDevName,
            isOpe : true
        })
        .then(result => {
            this.layoutItem.sectionLabel = result[0].MasterLabel;
            this.layoutItem.leftColumn = 
                result[0].Left_Column_Long__c ? 
                JSON.parse(result[0].Left_Column_Long__c) : null;
            this.layoutItem.rightColumn = 
                result[0].Right_Column_Long__c ? 
                JSON.parse(result[0].Right_Column_Long__c) : null;
            this.layoutItem.singleColumn = 
                result[0].Single_Column_Long__c ? 
                JSON.parse(result[0].Single_Column_Long__c) : null;
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        });
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
                    disableSession : relFaci.length == 0,
                    biosToSearch : this.hasLoaded ? 
                        this.getBiosToSearch(facis.map(faci=>{return faci.Facilitator_Bio__c})) : []
                }
            );
        });
        this.activeMainSections = offerings.filter(
            offer => offer.IsActive__c
        ).map(
            offer => {return offer.Id}
        );
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
                customRichtextClass: 'slds-cell-edit'
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
                customLookupClass: 'slds-cell-edit'
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

    //refreshes data
    handleRefreshData(event){
        this.isLoading = true;
        refreshApex(this.offeringResult)
        .then(() => {
            this.isLoading = false;
        });
        if(event && event.detail){
            if(event.detail.refreshBio){
                refreshApex(this.bioResult);
            }
        }
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