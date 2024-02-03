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
      | roy.nino.s.regala         | April 20, 2022        | DEPP-2318    | Added option to add new contact/facilitator            |
      | eccarius.munoz            | May 03, 2022          | DEPP-2314    | Added handling for Program Plan - Prescribed           |
      | alexander.cadalin         | June 17, 2022         | DEPP-1944    | Added handling for CCE - Coaching Product Requests     |
      | arsenio.jr.dayrit         | June 29, 2022         | DEPP-3239    | Added validation End Date toast message                |
      | rhea.b.torres             | July 18, 2022         | DEPP-2002    | Added logic for Diagnostic Tool recordtype             |
      | kathy.cornejo             | July 8, 2022          | DEPP-1770    | Enabled Print Name Badges for Prescribed Program       |
      | kathy.cornejo             | July 20, 2022         | DEPP-3521    | Removed Manage App Section for CCE Unit, Act, Module   |
      | kathy.cornejo             | July 28, 2022         | DEPP-3608    | Added Manage App Section for OPE Activity and Module   |
      | john.m.tambasen           | August, 16 2022       | DEPP-1946    | Single/Group Coaching changes                          |
      | kathy.cornejo             | September 13, 2022    | DEPP-4297    | Fixed Creation of Product Offering                     |
*/
import { LightningElement, api, wire, track } from 'lwc';
import { 
    getRecord, 
    getFieldValue, 
    createRecord, 
    updateRecord, 
    getRecordNotifyChange  
} from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';
import HAS_PERMISSION from "@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest";
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import RT_ProductRequest_Indiv_Coaching from '@salesforce/label/c.RT_ProductRequest_Indiv_Coaching';
import RT_ProductRequest_Group_Coaching from '@salesforce/label/c.RT_ProductRequest_Group_Coaching';
import RT_ProductRequest_Diagnostic_Tool from "@salesforce/label/c.RT_ProductRequest_Diagnostic_Tool";
import RT_ProductRequest_Unit from "@salesforce/label/c.RT_ProductRequest_Unit";
import RT_ProductRequest_Activity from "@salesforce/label/c.RT_ProductRequest_Activity";
import RT_ProductRequest_Module from "@salesforce/label/c.RT_ProductRequest_Module";
import RT_ProductRequest_PWP from "@salesforce/label/c.RT_ProductRequest_Program_Without_Pathway";
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';
import PL_ProgramPlan_PrescribedProgram from '@salesforce/label/c.PL_ProgramPlan_PrescribedProgram';
import RT_ProductSpecs_CCE from '@salesforce/label/c.RT_ProductSpecification_CCEProgramSpecification';
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import LWC_Error_EndDate from "@salesforce/label/c.LWC_Error_EndDate";
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
import PROD_SPECS_DEV_NAME from '@salesforce/schema/Product_Request__c.Product_Specification__r.RecordType.DeveloperName';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PR_PROGRAM_TYPE from '@salesforce/schema/Product_Request__c.OPE_Program_Plan_Type__c';
import PRESCRIBED_CHILD from '@salesforce/schema/Product_Request__c.Child_of_Prescribed_Program__c';
import PROD_REQ_OBJECT from '@salesforce/schema/Product_Request__c';
import getProductOfferingData from "@salesforce/apex/ProductOfferingCtrl.getProductOfferingData";
import getTermId from "@salesforce/apex/ProductOfferingCtrl.getTermId";
import getParentProgram from "@salesforce/apex/ProductOfferingCtrl.getParentProgram";
import updateCourseConnections from "@salesforce/apex/ProductOfferingCtrl.updateCourseConnections";
import getOfferingLayout from '@salesforce/apex/ProductOfferingCtrl.getOfferingLayout';
import getSearchContacts from "@salesforce/apex/ProductOfferingCtrl.getSearchContacts";
import updateCourseOfferings from "@salesforce/apex/ProductOfferingCtrl.updateCourseOfferings";
import getProdReqAndCourse from "@salesforce/apex/OpeProgramStructureCtrl.getProdReqAndCourse";
import getFacilitatorBios from "@salesforce/apex/ProductOfferingCtrl.getFacilitatorBios";
import isNewFacilitator from '@salesforce/apex/ProductOfferingCtrl.isNewFacilitator';
import updateCourseConnection from '@salesforce/apex/ProductOfferingCtrl.updateCourseConnection';

const DATE_OPTIONS = { year: 'numeric', month: 'short', day: '2-digit' };
const PROGRAM_OFFERING_FIELDS = 'Id,Name,Delivery_Type__c,Start_Date__c,End_Date__c,IsActive__c,CreatedDate';
const COURSE_OFFERING_FIELDS = 'Id,Name,Delivery_Type__c,hed__Start_Date__c,hed__End_Date__c,IsActive__c,CreatedDate';
const NO_OFFERING_ERROR = 'No product offering found.'
const PRES_PROGRAM_ERROR = 'Please set up and save a program plan delivery structure under Design tab before proceeding.';
const CHILD_PRES_PROGRAM_ERROR = NO_OFFERING_ERROR + ' Set up an offering in the parent ';
const EXISTING_FACIBIOS_COLUMNS = [
    { label: 'Bio Title', fieldName: 'Bio_Title__c', initialWidth: 100  },
    { label: 'Professional Bio', fieldName: 'Professional_Bio__c'}
];
export default class ProductOffering extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    
    parentInfoMap;
    childInfoMap;
    activeMainSections = [];
    @track productOfferings = [];
    isLoading = true;
    newRecord = false;
    newRecordHaveError = false;
    isCCEProductRequest;
    isProgramRequest= false;
    isCoachingOrDiagnosticProductRequest = false;
    isDiagnosticProductRequest = false;
    objectToCreate = '';
    parentIdToCreate;
    parentId;
    termId;
    layoutMap = {};
    layoutItem;
    isStatusCompleted;
    childOfPrescribedProgram = false;
    prePopulatedFields = {};
    parentRecord;
    newFacilitatorBio;
    objectLabel;
    parentProgramId;
    isCoachingProductRequest;
    noOfCoachingSessions;
    productCategory;
    maxParticipants;
    createFromContactId;
    linkFacilitator = false;
    contactSearchItems = [];
    contactSIP = false;
    contactLabelName = 'Contact';
    existingFaciBiosColumns = EXISTING_FACIBIOS_COLUMNS;
    existingFaciBios = [];
    showContactError = false;
    showNoExistingBioError = false;
    hasNotSelectedAFaciBio = true;
    hasNotSelectedAContact = true;
    selectedFaciBio = [];
    offeringIdForFaci;
    isNewFaci = true;

    //for prescribed program
    isPrescribed = false;
    childCourseList = [];
    prescribedOfferingLayout = [];
    singleOfferingLayout = [];
    childOfferingLayout = [];
    hasPlanRequirementOnRender;
    newPrescribedOffering = false;
    isPrescribedLoading = false;
    countOfChildOfferingSaved = 0;
    courseOfferingLayoutItem = {};
    displayAccordion = false;

    //custom contact lookup variables
    contactSearchItems = [];
    showContactError = false;
    searchContactInProgress = false;
    selectedContactId;
    saveInProgress = false;
    facilitatorObj = 'Facilitator_Bio__c';
    objectLabelName = 'Facilitator';
    contactName = '';
    contactEmail = '';
    newlyCreatedOffering;
    newCourseOffering = false;
    isCourseOfferingLoading = false;
    recordType;
    
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
        return !this.childOfPrescribedProgram && !this.isStatusCompleted;
    }

    //disables print name badges
    get disablePrintNameBadges(){
        return this.isStatusCompleted;
    }

    //decides to show Add Product Offering button
    get showProductOffering(){
        return !this.childOfPrescribedProgram;
    }

    //disables Add Product Offering button
    get disableProductOffering(){
        return (this.isPrescribed && !this.hasPlanRequirementOnRender) || this.isStatusCompleted;
    }

    //returns appropriate empty message
    get errorMessage(){
        let msg = '<p><strong>';
        if(this.isPrescribed && !this.hasPlanRequirementOnRender){
            msg += PRES_PROGRAM_ERROR;
        }else if(this.childOfPrescribedProgram && this.parentProgramId){
            msg += CHILD_PRES_PROGRAM_ERROR + 
                '<a href="/' + this.parentProgramId + '" target="_top">Program</a>.';
        }else{
            msg += NO_OFFERING_ERROR;
        }
        msg += '</strong></p>'
        return msg;
    }

    //gets QUTeX Term id, parent program Id, and loads css
    connectedCallback(){
        Promise.all([
            loadStyle(this, customDataTableStyle)
        ])
        .then(() => { 
            return getTermId({});
        })
        .then((termIdResult) => {
            this.termId = termIdResult;
            return getParentProgram({productRequestId : this.recordId});
        })
        .then((programIdResult) => {
            this.parentProgramId = programIdResult;
        })
        .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        });
    }

    @wire(getProdReqAndCourse,{productRequestId: '$recordId'})
    relatedRecords(result){
        if(result.data){
            this.childCourseList = result.data.courseList;
            if(this.childCourseList.length == 0){
                this.hasPlanRequirementOnRender = false;
            }else{
                //check if all courses have plan requirement sequence already set up
                this.hasPlanRequirementOnRender = true;
                for(let i = 0; i < this.childCourseList.length; i++){
                    if(!this.childCourseList[i].hed__Plan_Requirements__r){
                        this.hasPlanRequirementOnRender = false;
                        break;
                    }
                }
                if(this.hasPlanRequirementOnRender){
                    this.childCourseList = this.childCourseList.map(course => {
                        return {
                            ...course,
                            sequence:course.hed__Plan_Requirements__r[0].hed__Sequence__c
                        }
                    }).sort((a,b)  => {
                        return a.sequence - b.sequence;
                    });
                }
            }
        }
        else if(result.error){  
            this.generateToast("Error.", LWC_Error_General, "error");
        }
    }

    //stores object info of course connection
    @wire(getObjectInfo, { objectApiName: COURSE_CONNECTION.objectApiName })
    courseConnectionInfo;

    //stores object info of product request    
    @wire(getObjectInfo, { objectApiName: PROD_REQ_OBJECT })
    productRequestInfo;
    
    //gets product request details
    //assigns if data is for course or program plan
    @wire(getRecord, { recordId: '$recordId', fields: [PR_RT_DEV_NAME, PR_STATUS, PRESCRIBED_CHILD, PR_PROGRAM_TYPE, PROD_SPECS_DEV_NAME] })
    handleProductRequest(result){
        if(result.data){
            this.isStatusCompleted = getFieldValue(result.data,PR_STATUS) == PL_ProductRequest_Completed;
            this.isProgramRequest = 
                getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Program ||
                getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_PWP;
            this.isCoachingProductRequest = (getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Indiv_Coaching || getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Group_Coaching);
            //cce: check if product request is coaching (regardless of indiv or group)
            this.isCCEProductRequest = (
                (getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Indiv_Coaching ||
                getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Group_Coaching ||
                getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Diagnostic_Tool ||
                getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Unit ||
                getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Activity ||
                getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_PWP ||
                getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Module) && 
                getFieldValue(result.data,PROD_SPECS_DEV_NAME) == RT_ProductSpecs_CCE
            );
            this.isDiagnosticProductRequest = getFieldValue(result.data,PR_RT_DEV_NAME) === RT_ProductRequest_Diagnostic_Tool;
            this.isPrescribed = getFieldValue(result.data, PR_PROGRAM_TYPE) == PL_ProgramPlan_PrescribedProgram;
            this.childOfPrescribedProgram = getFieldValue(result.data,PRESCRIBED_CHILD);
            this.displayAccordion = this.isProgramRequest == this.isPrescribed;
            this.parentInfoMap = {
                field : this.isProgramRequest ? PP_PRODUCT_REQUEST.fieldApiName : C_PRODUCT_REQUEST.fieldApiName,
                objectType : this.isProgramRequest ? PROGRAM_PLAN.objectApiName :COURSE.objectApiName
            };
            this.childInfoMap = {
                fields : this.isProgramRequest ? PROGRAM_OFFERING_FIELDS : COURSE_OFFERING_FIELDS,
                objectType : this.isProgramRequest ? PROGRAM_OFFERING.objectApiName : COURSE_OFFERING.objectApiName,
                conditionField : this.isProgramRequest ? PO_PROGRAM_PLAN.fieldApiName : CO_COURSE.fieldApiName
            };
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    recordTypeName;
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
            this.productCategory = this.offeringResult.data.productCategory;
            this.maxParticipants = this.offeringResult.data.capacity;
            this.recordType = this.offeringResult.data.recordTypeName;
            this.parentId = this.offeringResult.data.parentId;
            this.parentRecord = this.offeringResult.data.parentRecord;
            this.noOfCoachingSessions = this.offeringResult.data.noOfSessions;
            this.productOfferings = this.formatOfferingData(this.offeringResult.data);
            if(!this.layoutItem){
                this.handleGetOfferingLayout();
            }
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
            let childLayoutItem = this.layoutMap[COURSE_OFFERING.objectApiName];
            this.layoutItem = this.layoutMap[this.childInfoMap.objectType];
            this.courseOfferingLayoutItem.leftColumn = childLayoutItem.leftColumn.filter(layout => 
                layout.field !== 'Minimum_Participants__c' && layout.field !== 'Registration_Start_Date__c'
            );
            this.courseOfferingLayoutItem.rightColumn = childLayoutItem.rightColumn.filter(layout => 
                layout.field !== 'hed__Capacity__c' && layout.field !== 'Registration_End_Date__c'
            );
            this.layoutItem = this.childOfPrescribedProgram ? this.courseOfferingLayoutItem : this.layoutItem;

            if(this.childInfoMap.objectType == PROGRAM_OFFERING.objectApiName){
                
                for(let i = 0; i < this.layoutItem.leftColumn.length; i++){
                    this.prescribedOfferingLayout.push(this.layoutItem.leftColumn[i]);
                    this.prescribedOfferingLayout.push(this.layoutItem.rightColumn[i]);
                }
                this.prescribedOfferingLayout = this.prescribedOfferingLayout.map(layout => {
                    let _layout = {...layout};
                    if(layout.field == 'Minimum_Participants__c'){
                        _layout.value = this.parentRecord.Minimum_Participants__c;
                    }
                    if(layout.field == 'hed_Capacity__c'){
                        _layout.value = this.parentRecord.Maximum_Participants__c;
                    }
                    return _layout;
                });
                let loopLimit = this.courseOfferingLayoutItem.leftColumn.length > this.courseOfferingLayoutItem.rightColumn.length?
                                this.courseOfferingLayoutItem.leftColumn.length:this.courseOfferingLayoutItem.rightColumn.length;
                for(let i = 0; i < loopLimit; i++){
                    if(this.courseOfferingLayoutItem.leftColumn[i]){
                        this.childOfferingLayout.push(this.courseOfferingLayoutItem.leftColumn[i]);
                    }
                    if(this.courseOfferingLayoutItem.rightColumn[i]){
                        this.childOfferingLayout.push(this.courseOfferingLayoutItem.rightColumn[i]);
                    }
                }
                this.childOfferingLayout = this.childOfferingLayout.map(layout => {
                    let _layout = {...layout};
                    if(layout && layout.field == 'LMS_Integration_Status__c' && layout.readOnly){
                        _layout.disabled = true;
                    }
                    return _layout;
                });
            }else if(this.childInfoMap.objectType == COURSE_OFFERING.objectApiName){
                for(let i = 0; i < this.layoutItem.leftColumn.length; i++){
                    this.singleOfferingLayout.push(this.layoutItem.leftColumn[i]);
                    this.singleOfferingLayout.push(this.layoutItem.rightColumn[i]);
                }

                this.singleOfferingLayout = this.singleOfferingLayout.map(layout => {
                    let _layout = {...layout};
                    if(layout && layout.field == 'Minimum_Participants__c'){
                        _layout.value = this.parentRecord.Minimum_Participants__c;
                    }
                    if(layout && layout.field == 'hed__Capacity__c'){
                        _layout.value = this.parentRecord.Maximum_Participants__c;
                    }
                    if(layout && layout.field == 'LMS_Integration_Status__c'){
                        _layout.disabled = true;
                    }
                    return _layout;
                });
            }
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
            let primaryFaci = facis.find(faci => faci.hed__Primary__c);
            let sesh = offeringData.relatedSessions.filter(sesh => sesh.Course_Offering__c == offering.Id);
            let seshPerLearner = offeringData.relatedSessions.filter(sesh => sesh.Course_Offering__c == offering.Id && sesh.RecordType.DeveloperName == 'Specialised_Session');
            let relFaci = this.formatFacilitators(facis);
            let relSesh = this.formatSessions(sesh,relFaci);
            let relSeshPerLearner = this.formatSessions(seshPerLearner,relFaci);
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
                    registeredLearnerEmails:[],
                    badgeClass: offering.IsActive__c ?
                        'slds-badge slds-theme_success section-button section-badge' :
                        'slds-badge slds-badge_inverse section-button section-badge',
                    badgeIcon: offering.IsActive__c ? 'utility:success' : 'utility:choice',
                    badgeLabel: offering.IsActive__c ? 'Active' : 'Inactive',
                    label : offering.Delivery_Type__c + ' (' + startDate + ' to ' + endDate + ')',
                    relatedFacilitators : relFaci,
                    primaryFaci: primaryFaci ? primaryFaci.Id : '',
                    relatedSessions : relSesh,
                    relatedSessionsPerLearner : relSeshPerLearner,
                    showFacilitatorTable : relFaci.length > 0,
                    showSessionTable : relSesh.length > 0,
                    showSessionTablePerLearner : relSeshPerLearner.length > 0,
                    disableSession : relFaci.length == 0 || this.isStatusCompleted,
                    showHelp : relFaci.length == 0 && this.showEditButton,
                    childCourseOfferings : this.isPrescribed ? 
                        offeringData.childCourseOfferings.filter(child => 
                            child.Program_Offering__c == offering.Id
                        ).map(child => {
                            return {
                                ...child,
                                courseName : child.hed__Course__r.Name,
                                productRequestUrl : '/' + child.hed__Course__r.ProductRequestID__c,
                                sequence : this.childCourseList.find(course => 
                                    course.Id == child.hed__Course__c
                                )?.sequence
                            }
                        }).sort((a,b)  => {
                            return a.sequence - b.sequence;
                        }) : [] 
                }
            );

        });
        this.isLoading = false;
        return offerings;
    }

    //formats facilitators into a display-ready type
    formatFacilitators(facilitators){
        return facilitators.map((item,index) => {
            return {
                ...item,
                rowId: 'row-'+index,
                contactName: item.Facilitator_Bio__c ? item.Facilitator_Bio__r.Facilitator__c ? item.Facilitator_Bio__r.Facilitator__r.Name: null : null,
                contactId: item.Facilitator_Bio__c ? item.Facilitator_Bio__r.Facilitator__c : null,
                bio: item.Facilitator_Bio__c ? item.Facilitator_Bio__r.Professional_Bio__c : null,
                bioTitle: item.Facilitator_Bio__c ? item.Facilitator_Bio__r.Bio_Title__c : null,
                customLookupClass: 'slds-cell-edit',
                editable: this.showEditButton,
                helpText: item.hed__Primary__c?'Unset As Primary':'Set As Primary',
                variantName: item.hed__Primary__c?'Brand':'',
                disableSetAsPrimary: this.isStatusCompleted || !item.IsActive__c         
            }
        });
    }

    //formats sessions into a display-ready type
    formatSessions(sessions,relatedFacis){
        return sessions.map((item,index) => {
            return {
                ...item,
                rowId: 'row-'+index,
                contactName:
                    item.Course_Connection__c && item.Course_Connection__r.hed__Contact__c ? 
                    item.Course_Connection__r.hed__Contact__r.Name : '',
                relatedFacilitators: relatedFacis.map(item =>{
                    return {
                        id:item.Id,
                        label:item.contactName,
                        meta:item.Name,
                    }
                }),
                learnerName: item.Name,
                customPicklistClass: 'slds-cell-edit',
                customSearchClass: 'slds-cell-edit',
                customStartTimeClass: 'slds-cell-edit',
                customEndTimeClass: 'slds-cell-edit',
                customLookupClass: 'slds-cell-edit',
                customRichtextClass: 'slds-cell-edit',
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
        if(this.isPrescribed){
            this.newPrescribedOffering = true;
        }else{
            this.newCourseOffering = true;
        }
    }

    //handles product offering details update
    handleProductOfferingUpdate(event){
        if(event.detail.apiName == PROGRAM_OFFERING.objectApiName){
            let childOfferingsToUpdate = this.productOfferings.find(
                data => data.Id == event.detail.id
            )?.childCourseOfferings.map(offering => {
                return {
                    Id : offering.Id,
                    IsActive__c : event.detail.fields.IsActive__c.value
                }
            });
            updateCourseOfferings({courseOfferings : childOfferingsToUpdate})
            .then(result => {
                getRecordNotifyChange(childOfferingsToUpdate.map(child => {
                    return {
                        recordId : child.Id
                    }
                }));
            })
            .catch(error =>{
                this.generateToast('Error.',LWC_Error_General,'error');
            });
        }
        this.handleRefreshData();
        
    }

    handleSectionToggle(event) {
        this.activeMainSections = event.detail.openSections;
    }

    //refreshes data
    handleRefreshData(){
        this.isLoading = true;
        refreshApex(this.offeringResult)
        .then(() => {
            if(this.newlyCreatedOffering){
                this.activeMainSections = [...this.activeMainSections,this.newlyCreatedOffering];
            }
            this.isLoading = false;
        })
        .finally(()=>{
            this.isLoading = false;
            this.newlyCreatedOffering = undefined;
            this.saveInProgress = false;
            this.isPrescribedLoading = false;
            this.isCourseOfferingLoading = false;
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

    //creates course connection for selected facilitator on search
    handleSaveConnection(){
        if(this.isNewFaci) {
            let bioFields = {
                Id: this.selectedFaciBio.Id,
                Facilitator__c: this.selectedContactId
            }
            this.parentIdToCreate = this.offeringIdForFaci;
            this.handleCreateCourseConnection(bioFields);
            this.handleCloseLinkFacilitator();
        } else {
            this.isLoading = true;
            this.linkFacilitator = false;
            updateCourseConnection({ 
                offeringId: this.offeringIdForFaci, 
                contactId: this.selectedContactId, 
                facilitatorBioId: this.selectedFaciBio.Id 
            })
            .finally(() => {
                this.handleCloseLinkFacilitator();
                this.handleRefreshData();
            })
            .catch(error =>{
                this.generateToast('Error.',LWC_Error_General,'error');
                this.linkFacilitator = true;
            });
        }
    }

    //opens create modal for facilitator
    handleAddFacilitator(){
        this.parentIdToCreate = this.offeringIdForFaci;
        this.createFromContactId = this.selectedContactId;
        this.newFacilitatorBio = true;
        this.linkFacilitator = false;
        this.objectLabel = 'Contact';
        this.objectToCreate = FACILITATOR_BIO.objectApiName;
    }

    handleCancelNewFacilitator() {
        this.linkFacilitator = true;
        this.newFacilitatorBio = false;
    }

    //opens create modal for session
    handleAddSession(event){
        this.parentIdToCreate = event.detail.offeringId;
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

    //handle submission of facilitator bio details
    handleSubmitFacilitator(event){
        event.preventDefault();
        let eventObj = {
            detail:event.detail.fields
        };

        if(!this.selectedContactId){
            this.showOwnerError = true;
        }else{
            this.handleSaveRecord(eventObj);
        }
    }

    //returns list of contacts based on input
    handleContactSearch(event){
        this.searchContactInProgress = true;
        getSearchContacts({ filterString: event.detail.filterString })
        .then(result =>{
            this.contactSearchItems = result;
        })
        .finally(()=>{
            this.searchContactInProgress = false;
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }


    //handles field assignments before committing to the database
    async handleSaveRecord(event){
        this.saveInProgress = true;
        let fields = {...event.detail};
        if(fields.FirstName && fields.LastName){
            this.objectToCreate = 'Contact';
            this.contactName = fields.FirstName + ' ' + fields.LastName;
            this.contactEmail = fields.Email;
        }
        if(this.objectToCreate == FACILITATOR_BIO.objectApiName){
            const recordInput = { apiName: FACILITATOR_BIO.objectApiName, fields };
            try{
                const createdFaci = await createRecord(recordInput);
                this.selectedFaciBio.Id = createdFaci.id;
                this.selectedContactId = fields.Facilitator__c;
                this.handleSaveConnection();
            }catch(error){
                this.generateToast("Error.", LWC_Error_General, "error");
            }
            this.handleCloseNewBio();
        }else{
            this.handleCreateRecord(fields,this.objectToCreate);
        }
    }

    //submits prescribed program offering form
    handleSaveOfferings(){
        this.isPrescribedLoading = true;
    
        if(this.validateFields()) {
            this.template.querySelector(
                'lightning-record-edit-form[data-id="prescribedOfferingForm"]'
            ).submit();
        }else{
            this.isPrescribedLoading = false;
        }
    }

    //submits prescribed program offering form
    handleSaveCourseOffering(){
        this.isCourseOfferingLoading = true;
    
        if(this.validateFields()) {
            this.template.querySelector(
                'lightning-record-edit-form[data-id="singleCourseOfferingForm"]'
            ).submit();
        }else{
            this.isCourseOfferingLoading = false;
        }
    }
    
    handleCourseOfferingSucces(event){
        this.newlyCreatedOffering = event.detail.id;
        this.newCourseOffering = false;
        this.handleRefreshData();
        this.handleCloseCourseOffering();
    }

    validateFields() {
        return [...this.template.querySelectorAll('lightning-input-field[data-id="toValidate"]')].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }

    //submits child course offering form/s
    handlePrescribedOfferingSuccess(event){
        this.newlyCreatedOffering = event.detail.id;
        this.template.querySelectorAll('lightning-input-field[data-id="programOfferingId"]').forEach((field) => {
            field.value = event.detail.id;
        });
        this.template.querySelectorAll(
            'lightning-record-edit-form[data-id="childOfferingForm"]'
        ).forEach((form) => {
            form.submit();
        });


    }

    //sets modal loading to false if all records have been created
    handleChildOfferingSuccess(){
        this.countOfChildOfferingSaved += 1;
        if(this.countOfChildOfferingSaved == this.childCourseList.length){
            this.isPrescribedLoading = false;
            this.countOfChildOfferingSaved = 0;
            this.handleRefreshData();
            this.handleClosePrescribedOffering();
        }
    }

    //stops spinner when an error is encountered
    handleError(event){
        this.isPrescribedLoading = false;
        this.isCourseOfferingLoading = false;
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
        if(this.template.querySelector('c-custom-create-edit-record').isSaving == false && this.newRecordHaveError == false && this.saveInProgress == false){
            this.newRecord = false;
            this.newRecordHaveError = false;
            this.prePopulatedFields = {};
            if(this.objectToCreate == 'Contact'){
                this.handleReopenAddFacilitator();
            }
        }else{
            this.newRecordHaveError = false;
        }
    }

    //closes prescribed program offering modal
    handleClosePrescribedOffering(){
        this.newPrescribedOffering = false;
    }

    handleCloseCourseOffering(){
        this.newCourseOffering = false;
    }

    //opens create modal for facilitator
    handleReopenAddFacilitator(){
        this.objectToCreate = FACILITATOR_BIO.objectApiName;
        this.newFacilitatorBio = true;
        this.objectLabel = 'Contact';
    }

    //close new faci bio
    handleCloseNewBio(){
        this.newFacilitatorBio = false;
        this.showContactError = false;
        this.saveInProgress = false;
        this.selectedContactId = '';
        this.objectToCreate = '';
        this.handleCloseLinkFacilitator();
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

           if(objectType === COURSE_OFFERING.objectApiName || objectType === PROGRAM_OFFERING.objectApiName){
                this.newlyCreatedOffering = record.id;
           }

           if(objectType == 'Contact'){
               this.selectedContactId = record.id;
               let item = {};
               item.id = record.id;
               item.label = this.contactName;
               item.meta  = this.contactEmail;
               this.contactSearchItems = [...this.contactSearchItems,item];
           }
        })
        .catch(error => {
            if(this.template.querySelector('c-custom-create-edit-record') !== null && (objectType == 'Contact' && this.newRecord == true)){
                this.template.querySelector('c-custom-create-edit-record').showValidationMessage(error);
                this.newRecordHaveError = true;
            }
            else if(error.body && error.body.output && error.body.output.errors[0] && error.body.output.errors[0] && error.body.output.errors[0].errorCode == 'DUPLICATES_DETECTED'){
                this.generateToast('Error.',error.body.output.errors[0].message,'error');
            }else {
                this.generateToast('Error.',LWC_Error_General,'error');
            }
        })
        .finally(() => {
            if(objectType == 'Contact'){
                this.saveInProgress = false;
               this.handleCloseRecord();
               this.isLoading = false;
            }else{
                this.handleRefreshData();
            }
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

    //redirects user to offering record page
    handlePrintNameBadges(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.name,
                objectApiName: this.childInfoMap.objectType,
                actionName: 'view'
            }
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

    //stores registered learners' emails from manageRegistraionSection
    setLearnerEmails(event){
        let learnerEmails = event.detail.value;
        let offeringId =event.detail.offeringId;
        if(this.productOfferings.length > 0){
            this.productOfferings = this.productOfferings.map(item =>{
                return {
                    ...item,
                    registeredLearnerEmails: 
                    item.Id  === offeringId?
                    learnerEmails : item.registeredLearnerEmails
                }
            });
        }
    }

    // handle closing modal to link faci to offering
    handleCloseLinkFacilitator() {
        this.linkFacilitator = false; 
        this.selectedContactId = undefined;
        this.handleContactRemove();
    }
    
    // handle opening of modal to link faci to offering
    handleLinkFacilitator(event) {
        this.linkFacilitator = true;
        this.offeringIdForFaci = event.detail;
    }

    // handle contact searching in link faci modal
    handleContactSearch(event){
        this.contactSIP = true;
        getSearchContacts({ filterString: event.detail.filterString })
        .then(result =>{
            this.contactSearchItems = result;
        })
        .finally(()=>{
            this.contactSIP = false;
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

    // handle contact selection in search box in link faci modal
    handleContactSelect(event) {
        this.showContactError = false;
        this.selectedContactId = event.detail.value;
        let triggeringOffering = this.productOfferings.find(pO => pO.Id == this.offeringIdForFaci);
        getFacilitatorBios ({ 
            contactId: event.detail.value,
            addedFacilitators: triggeringOffering.relatedFacilitators.map(cc => {
                return cc.Facilitator_Bio__c
            })
        })
        .then(result => {
            if(result.length == 0) {
                this.showNoExistingBioError = true;
            } else {
                this.showNoExistingBioError = false;
                this.existingFaciBios = result;
            }
            this.hasNotSelectedAContact = false;
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        });
        isNewFacilitator({ offeringId: this.offeringIdForFaci, contactId: event.detail.value })
        .then(result => {
            if(result > 0) {
                this.isNewFaci = false;
            } else {
                this.isNewFaci = true;
            }
        })
        .catch(error =>{
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

    // handle deselecting contact in search box in link faci modal
    handleContactRemove() {
        this.hasNotSelectedAFaciBio = true;
        this.hasNotSelectedAContact = true;
        this.selectedContactId = undefined;
        this.contactSearchItems = [];
        this.existingFaciBios = [];
        this.selectedFaciBio = [];
        this.showNoExistingBioError = false;
        this.isNewFaci = true;
    }
    
    // handle when a faci bio is selected in the table in the link faci modal
    handleFaciBioSelected(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedFaciBio = selectedRows[0];
        this.hasNotSelectedAFaciBio = selectedRows.length == 0 ? true : false;
    }
}