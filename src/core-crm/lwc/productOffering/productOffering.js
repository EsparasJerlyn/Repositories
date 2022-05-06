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
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';
import PL_ProgramPlan_PrescribedProgram from '@salesforce/label/c.PL_ProgramPlan_PrescribedProgram';
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
import PR_PROGRAM_TYPE from '@salesforce/schema/Product_Request__c.OPE_Program_Plan_Type__c';
import PRESCRIBED_CHILD from '@salesforce/schema/Product_Request__c.Child_of_Prescribed_Program__c';
import getProductOfferingData from "@salesforce/apex/ProductOfferingCtrl.getProductOfferingData";
import getTermId from "@salesforce/apex/ProductOfferingCtrl.getTermId";
import getParentProgram from "@salesforce/apex/ProductOfferingCtrl.getParentProgram";
import updateCourseConnections from "@salesforce/apex/ProductOfferingCtrl.updateCourseConnections";
import getOfferingLayout from '@salesforce/apex/ProductOfferingCtrl.getOfferingLayout';
import getSearchContacts from "@salesforce/apex/ProductOfferingCtrl.getSearchContacts";
import updateCourseOfferings from "@salesforce/apex/ProductOfferingCtrl.updateCourseOfferings";
import getProdReqAndCourse from "@salesforce/apex/OpeProgramStructureCtrl.getProdReqAndCourse";

const DATE_OPTIONS = { year: 'numeric', month: 'short', day: '2-digit' };
const PROGRAM_OFFERING_FIELDS = 'Id,Name,Delivery_Type__c,Start_Date__c,End_Date__c,IsActive__c,CreatedDate';
const COURSE_OFFERING_FIELDS = 'Id,Name,Delivery_Type__c,hed__Start_Date__c,hed__End_Date__c,IsActive__c,CreatedDate';
const NO_OFFERING_ERROR = 'No product offering found.'
const PRES_PROGRAM_ERROR = 'Please set up and save a program plan delivery structure under Design tab before proceeding.';
const CHILD_PRES_PROGRAM_ERROR = NO_OFFERING_ERROR + ' Set up an offering in the parent ';
export default class ProductOffering extends NavigationMixin(LightningElement) {
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
    registeredLearnerEmails = [];
    childOfPrescribedProgram = false;
    prePopulatedFields = {};
    parentRecord;
    newFacilitatorBio;
    objectLabel;
    parentProgramId;

    //for prescribed program
    isPrescribed = false;
    childCourseList = [];
    prescribedOfferingLayout = [];
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
    saveInProgress;
    facilitatorObj = 'Facilitator_Bio__c';
    objectLabelName = 'Facilitator';
    contactName = '';
    contactEmail = '';
    newlyCreatedOffering;
    
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

    //disables print name badges
    get disablePrintNameBadges(){
        return this.isStatusCompleted || this.childInfoMap.objectType == PROGRAM_OFFERING.objectApiName;
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
    
    //gets product request details
    //assigns if data is for course or program plan
    @wire(getRecord, { recordId: '$recordId', fields: [PR_RT_DEV_NAME, PR_STATUS, PRESCRIBED_CHILD, PR_PROGRAM_TYPE] })
    handleProductRequest(result){
        if(result.data){
            this.isStatusCompleted = getFieldValue(result.data,PR_STATUS) == PL_ProductRequest_Completed;
            this.isOpeProgramRequest = getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Program;
            this.isPrescribed = getFieldValue(result.data, PR_PROGRAM_TYPE) == PL_ProgramPlan_PrescribedProgram;
            this.childOfPrescribedProgram = getFieldValue(result.data,PRESCRIBED_CHILD);
            this.displayAccordion = this.isOpeProgramRequest == this.isPrescribed;
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
        if(result.data){
            this.offeringResult = result;
            this.parentId = this.offeringResult.data.parentId;
            this.parentRecord = this.offeringResult.data.parentRecord;
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
                for(let i = 0; i < this.courseOfferingLayoutItem.leftColumn.length; i++){
                    this.childOfferingLayout.push(this.courseOfferingLayoutItem.leftColumn[i]);
                    this.childOfferingLayout.push(this.courseOfferingLayoutItem.rightColumn[i]);
                }
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
                    primaryFaci: primaryFaci ? primaryFaci.Id : '',
                    relatedSessions : relSesh,
                    showFacilitatorTable : relFaci.length > 0,
                    showSessionTable : relSesh.length > 0,
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
                contactName: item.Facilitator_Bio__r.Facilitator__r.Name,
                contactId:item.Facilitator_Bio__r.Facilitator__c,
                bio:item.Facilitator_Bio__r.Professional_Bio__c,
                customLookupClass: 'slds-cell-edit',
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
            this.newRecord = true;
            this.objectToCreate = this.childInfoMap.objectType;
            this.parentIdToCreate = this.parentId;
            if(this.objectToCreate == COURSE_OFFERING.objectApiName){
                this.prePopulatedFields = {
                    'Minimum_Participants__c':this.parentRecord.Minimum_Participants__c,
                    'hed__Capacity__c': this.parentRecord.Maximum_Participants__c
                }
            }
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
        if(event && event.detail){
            this.parentIdToCreate =event.detail;
        }
        this.newFacilitatorBio = true;

        this.objectLabel = 'Contact';
        this.objectToCreate = FACILITATOR_BIO.objectApiName;
    }

    //handle creation of new contact modal
    handleNewContact(){
        this.newRecord = true;
        this.objectToCreate = 'Contact';
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

    //sets selected contact id
    handleContactSelect(event){
        this.showContactError = false;
        this.selectedContactId = event.detail.value;
    }

    //removes selected contact
    handleContactRemove(){
        this.selectedContactId = undefined;
        this.contactSearchItems = [];
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
            fields.Facilitator__c = this.selectedContactId;
            const recordInput = { apiName: FACILITATOR_BIO.objectApiName, fields };
            try{
                const createdFaci = await createRecord(recordInput);
                fields.Id = createdFaci.id;
                this.handleCreateCourseConnection(fields);
                this.handleCloseNewBio();
            }catch(error){
                this.generateToast("Error.", LWC_Error_General, "error");
                this.handleCloseNewBio();
            }
        }else{
            if(this.objectToCreate == COURSE_OFFERING.objectApiName){
                fields.hed__Course__c = this.parentIdToCreate;
                fields.hed__Term__c = this.termId;
            }
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
        this.prePopulatedFields = {};
        if(this.objectToCreate == 'Contact'){
            this.handleReopenAddFacilitator();
        }
    }

    //closes prescribed program offering modal
    handleClosePrescribedOffering(){
        this.newPrescribedOffering = false;
    }

    //opens create modal for facilitator
    handleReopenAddFacilitator(){
        this.objectToCreate = FACILITATOR_BIO.objectApiName;
        this.newFacilitatorBio = true;
        this.objectLabel = 'Contact';
    }

    handleCloseNewBio(){
        this.newFacilitatorBio = false;
        this.showContactError = false;
        this.saveInProgress = false;
        this.selectedContactId = '';
        this.objectToCreate = '';
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
            if(error.body && error.body.output && error.body.output.errors[0] && error.body.output.errors[0] && error.body.output.errors[0].errorCode == 'DUPLICATES_DETECTED'){
                this.generateToast('Error.',error.body.output.errors[0].message,'error');
            }else{
                this.generateToast('Error.',LWC_Error_General,'error');
            }
        })
        .finally(() => {
            if(objectType == 'Contact'){
               this.handleCloseRecord();
               this.isLoading = false;
               this.saveInProgress = false;
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
        this.registeredLearnerEmails = event.detail.value;
    }
}