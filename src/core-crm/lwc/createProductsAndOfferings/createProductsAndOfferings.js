/**
 * @description An LWC component for creating products and offerings
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                            | Change Summary                       |
      |---------------------------|-----------------------|---------------------------------|--------------------------------------|
      | roy.nino.s.regala         | October 18, 2021      | DEPP-425 DEPP-476               | Created                              |
      | eugene.andrew.abuan       | November 9, 2021      | DEPP-35                         | Added a getProductRequests function  |
      | roy.nino.s.reagala        | November 15, 2021     | DEPP-362 DEPP-38 DEPP-37 DEPP-35| Added program request RT scenario    | 
 */
import { LightningElement,wire,api} from 'lwc';
import getCourses from '@salesforce/apex/CreateProductsAndOfferingsCtrl.getRelatedCourse';
import updateProductRequests from '@salesforce/apex/CreateProductsAndOfferingsCtrl.updateProductRequests'; 
import COURSE_OFFERING_SCHEMA from '@salesforce/schema/hed__Course_Offering__c';
import PROGRAM_OFFERING_SCHEMA from '@salesforce/schema/Program_Offering__c';
import PRODUCT_SCHEMA from '@salesforce/schema/Product2';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {createRecord, updateRecord } from 'lightning/uiRecordApi';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import LWC_HelpText_PrescribedProgram from '@salesforce/label/c.LWC_HelpText_PrescribedProgram';
import LWC_HelpText_FlexibleProgram	 from '@salesforce/label/c.LWC_HelpText_FlexibleProgram';
import LWC_Error_ProgramRequest_ChildrenNotInReleaseStage	 from '@salesforce/label/c.LWC_Error_ProgramRequest_ChildrenNotInReleaseStage';
import LWC_Error_MultiRecordTypes_CompleteStageOnParent	 from '@salesforce/label/c.LWC_Error_MultiRecordTypes_CompleteStageOnParent';

const MSG_ERROR = LWC_Error_General;
const TAB_BOLD = "tab-bold";
const MULTI_RT = ['Activity_Request','Coaching_Request','Diagnostic_Tool_Request','Educational_Consultancy_Request'];
const PROGRAM_REQUEST_RT = 'Program_Request';
const FLEXIBLE_TYPE = 'Flexible Program';
const PRESCRIBED_TYPE = 'Prescribed Program';
const OPTIONAL = 'Optional';
const REQUIRED = 'Required';
const UNCLICKABLE = 'noclick';
const SIX_COLUMNS = 'slds-col slds-size_1-of-6';
const FIVE_COLUMNS = 'slds-col slds-size_1-of-5';
const TO_RIGHT = ' slds-col_bump-left';

export default class CreateProductsAndOfferings extends LightningElement{
    childNotInReleaseError = LWC_Error_ProgramRequest_ChildrenNotInReleaseStage;
    completeReleaseOnParent = LWC_Error_MultiRecordTypes_CompleteStageOnParent;
    isCreateRecord=false;
    isEditRecord=false;
    multiCreate = false;
    prefields = {};
    pbentries = {};
    recordid;
    hasProductOnRender=false;
    hasOfferingsOnRender = false;
    coursesData = [];
    isProgramTab = false;
    isProductTab = false;
    isOfferingTab = false;
    isLoading = true;
    isProdWithParent = false;
    isParent = true;
    isCompleteChild=false;
    noParent = false;
    filterParent;
    parentName;
    parentId;
    notInRelease = false;
    currentRecordType;
    currentRecord;
    programStructureComplete=false;
    createProductComplete=false;
    createOfferingComplete=false;
    tableData = [];
    programPlan = {};
    programPlanData = {};
    programPlanHasProduct;
    programPlanHasProgramOffering;
    prescribedHelpText = LWC_HelpText_PrescribedProgram;
    flexibleHelpText = LWC_HelpText_FlexibleProgram;
    hasPlanRequirementOnRender = false;

    @api recordId;

    /*
    *gets courses, products, offerings, program offering, program plan, 
    */
    listCourses;
    @wire(getCourses,{productRequestId: '$recordId'})
    relatedCourse(result){
        if(result.data){
            this.listCourses = result;
            let coursesList = this.listCourses.data.courseList;
            let productTemp = this.listCourses.data.productMap;
            let offeringsTemp = this.listCourses.data.offeringMap;
            let programPlanTemp = this.listCourses.data.programPlanList?this.listCourses.data.programPlanList[0]:{};
            let programPlanProductTemp = this.listCourses.data.programPlanProductMap;
            let productRequestList = this.listCourses.data.productRequestList; //child and parent prod request

            this.programPlanHasProduct = Object.keys(programPlanProductTemp).length > 0;
            this.programPlanHasProgramOffering = programPlanTemp?programPlanTemp.Program_Offering__r?programPlanTemp.Program_Offering__r.length > 0?true:false:false:false;
            this.filterParent = productRequestList.filter( (result) => result.Id !== this.recordId); 
            this.currentRecord = productRequestList.filter( (result) => result.Id === this.recordId)[0];
            this.programPlan = programPlanTemp;

            this.programStructureComplete = this.currentRecord.Program_Structure_Complete__c; //variable that indicates that program structure stage is complete
            this.createProductComplete = this.currentRecord.Create_Product_Complete__c; //variable that indicates that create product stage is complete
            this.createOfferingComplete = this.currentRecord.Create_Offering_Complete__c;  //variable that indicates that create offering stage is complete
            this.currentRecordType = this.currentRecord.RecordType.DeveloperName;

            this.hasProductOnRender = this.listCourses.data.courseList.length === Object.keys(this.listCourses.data.productMap).length?true:false; //each course has product
            this.hasOfferingsOnRender = this.listCourses.data.courseList.length === Object.keys(this.listCourses.data.offeringMap).length?true:false; //each course has offering

            //filterParent length null - it's either child or no parent
            //you are on a solo record
            if(this.filterParent.length === 0){
                productRequestList.forEach( hasChild => {
                    let hasParentReq = hasChild.Parent_Product_Request__r;
                    // Child Product Request
                    if(hasParentReq){
                      this.parentName = hasParentReq.Name;
                      this.parentId = '/' + hasParentReq.Id;
                      this.isProdWithParent = true;
                      this.isParent = false;
                      this.isCompleteChild = hasChild.Create_Offering_Complete__c; //release stage is complete
                    }else{ // No Parent Product Request
                        this.noParent = true;
                    }
                });
            }
            //filterParent length > 1 - it's a parent
            //you are on a parent record and this contains the child records
            else if(this.filterParent.length > 0){
                this.filterParent.forEach(parent =>{
                    let childStatus = parent.Product_Request_Status__c;
                    this.isParent = true;
                    if(childStatus !== "Release"){
                        //checks if All Status of child is Release -> for story DEPP 326
                        this.notInRelease = true;
                    }
                });
            }
            this.formatCourseData(coursesList,productTemp,offeringsTemp);
            if(this.programPlan){
                this.formatProgramPlan(programPlanTemp,programPlanProductTemp);
            }
            this.isLoading = false; 
        }
        else if(result.error){
            this.isLoading = false; 
            this.generateToast('Error!',MSG_ERROR,'error');
        }
    }

    /*
    *getter for class of tabs, makes tab clickable or bold
    */
    get tabClass(){
        let tabClassObj = {};
        tabClassObj.program = this.selectionTab.isProgramStructure?TAB_BOLD:this.programStructureComplete?'':UNCLICKABLE;
        tabClassObj.product = this.selectionTab.isCreateProduct?TAB_BOLD:this.programStructureComplete?'':UNCLICKABLE;
        tabClassObj.offering = this.selectionTab.isCreateOfferings?TAB_BOLD:this.createProductComplete?'':UNCLICKABLE;
        return tabClassObj;
    }

    /*
    *getter for selection tabs, decides which page the user lands to
    */
    get selectionTab(){
        let selectionTabObj = {};
        selectionTabObj.isProgramStructure = (!this.programStructureComplete && this.isProgramRequest && !this.isProductTab && !this.isOfferingTab) || this.isProgramTab;
        selectionTabObj.isCreateProduct = (((this.programStructureComplete && this.isProgramRequest) || (!this.programStructureComplete && !this.isProgramRequest)) && !this.createProductComplete && !this.isProgramTab && !this.isOfferingTab) || this.isProductTab;
        selectionTabObj.isCreateOfferings = (this.programStructureComplete && this.createProductComplete && !this.isProductTab && !this.isProgramTab) || this.isOfferingTab;
        return selectionTabObj;
    }

    /*
    *getter for disabling mark as complete button
    */
    get isDisabledMarkAsComplete(){
        return ((this.programStructureComplete || !this.hasPlanRequirementOnRender) && this.selectionTab.isProgramStructure) || 
                ((this.createProductComplete || !this.hasProductOnRender || (this.isProgramRequest && (!this.programPlanHasProduct || !this.hasProductOnRender))) && this.selectionTab.isCreateProduct) ||
                ((this.createOfferingComplete || !this.hasOfferingsOnRender || (this.isProgramRequest && this.programPlan && this.programPlan.Program_Type__c === PRESCRIBED_TYPE && (!this.programPlanHasProgramOffering || !this.hasOfferingsOnRender))) && this.selectionTab.isCreateOfferings);
    }

    /*
    *getter for disabling create/edit product and offerings buttons for courses
    */
    get isDisabledButton(){
        return (this.programStructureComplete  && this.selectionTab.isProgramStructure) || 
                (this.createProductComplete && this.selectionTab.isCreateProduct) ||
                (this.createOfferingComplete && this.selectionTab.isCreateOfferings);
    }

    /*
    * getter for parentValidation
    * returns true if record is a child, release stage is not completed and record type is one of the MULTI_RT
    */
    get parentValidation(){
        return !((this.isParent || this.noParent) || (this.isProdWithParent && this.isCompleteChild)) && MULTI_RT.includes(this.currentRecordType);
    }

    /*
    * getter for childValidation
    * returns true if record is parent, recordtype is program request and not all children is not in release stage
    */
    get childValidation(){
        return this.isParent && !this.noParent && this.isProgramRequest && (this.notInRelease);
    }

    /*
    * getter for hasNoCourse, there are no courses found
    */
    get hasNoCourse(){
        return !this.coursesData.length > 0;
    }

    /*
    * getter for isProgramREquest, tells UI that RT of current record is Program Request
    */
    get isProgramRequest(){
        return this.currentRecordType === PROGRAM_REQUEST_RT;
    }

    /*
    * getter for showMarkAsComplete, decides if mark as complete is shown
    */
    get showMarkAsComplete(){
        return this.hasNoCourse || this.childValidation || this.parentValidation;
    }

    /*
    *getter that checks if a program plan exists
    */
    get hasProgramPlan(){
        return this.programPlan?true:false;
    }

    /*
    *getter for disabling create program offering, dependent to program plan's program type
    */
    get disableCreateProgramOffering(){
        return  this.createOfferingComplete || (this.programPlan && this.programPlan.Program_Type__c === FLEXIBLE_TYPE) || 
                (this.programPlanHasProgramOffering && this.programPlan && this.programPlan.Program_Type__c === PRESCRIBED_TYPE);
    }

    /*
    *getter for default plan requirement category
    */
    get planRequirementCategory(){
        return this.programPlan?(this.programPlan.Program_Type__c === FLEXIBLE_TYPE?OPTIONAL:this.programPlan.Program_Type__c === PRESCRIBED_TYPE?REQUIRED:OPTIONAL):'';
    }

    /*
    *getter for grid column size, column depends on record type
    */
    get colSize(){
        let colSizeObj = {};
        colSizeObj.column = this.isProgramRequest?SIX_COLUMNS:FIVE_COLUMNS;
        colSizeObj.button = this.isProgramRequest?SIX_COLUMNS+TO_RIGHT:FIVE_COLUMNS+TO_RIGHT;
        return colSizeObj;
    }

    /*
    *getter for programn plan url
    */
    get programNameUrl(){
        return this.programPlan?'/' + this.programPlan.Id:'';
    }

    /*
    *function that sorts courses by sequence
    */
    sortMap(dataMap){
        let sortBySequence = dataMap.slice(0);
        sortBySequence.sort((a,b)  => {
            return a.sequence - b.sequence;
        });
        return sortBySequence;
    }

    /*
    *function that formats the structure for program plan
    */
    formatProgramPlan(planWithOffering,planWithProduct){
        let programPlanDataTemp = {};
        programPlanDataTemp.recordUrl = '/' + this.programPlan.Id;
        programPlanDataTemp.products = planWithProduct[this.programPlan.Id]?this.formatProductData(planWithProduct[this.programPlan.Id],''):[] ;
        programPlanDataTemp.offerings = planWithOffering.Program_Offering__r?this.formatProgramOffering(planWithOffering.Program_Offering__r):[] ;
        this.programPlanData = programPlanDataTemp;
    }

    /*
    *function that formats the structure for course data
    */
    formatCourseData(listToFormat,productTemp,offeringsTemp){
        let tableTemp = [];
        let coursesDataTemp = [];
        listToFormat.forEach(course =>{
            let courseTemp = {};
            courseTemp.recordId = course.Id;
            courseTemp.recordUrl = '/' + course.Id;
            courseTemp.sequence = course.hed__Plan_Requirements__r?course.hed__Plan_Requirements__r[0].hed__Sequence__c:'';
            courseTemp.disableCreateOffering = this.createOfferingComplete || (this.programPlan && this.programPlan.Program_Type__c === PRESCRIBED_TYPE && !this.programPlanHasProgramOffering);
            courseTemp.fields = [
                                    { label:"Course Name"   , value: course.Name,showCol : true,isUrl: true},
                                    { label:"Record Type"   , value: course.RecordType?course.RecordType.Name:'',showCol : true},
                                    { label:"Start Date"    , value: course.Start_Date__c?new Date(course.Start_Date__c).toLocaleDateString('en-US'):''},
                                    { label:"End Date"      , value: course.End_Date__c?new Date(course.End_Date__c).toLocaleDateString('en-US'):''},
                                    { label:"Sequence"      , value: courseTemp.sequence, isSequence: true}
                                ];         
                let childOfferings =  offeringsTemp[course.Id] ?  this.formatOfferingData(offeringsTemp[course.Id]) : [];
                let childProduct = productTemp[course.Id] ? this.formatProductData(productTemp[course.Id],courseTemp.sequence):[] ;
                let childPlanRequirement = this.formatPlanRequirementData(course.hed__Plan_Requirements__r, course , tableTemp.length + 1);

                if(childOfferings.length > 0){
                    courseTemp.offerings = [...childOfferings];
                    courseTemp.disableCreateOffering = this.createOfferingComplete || (this.programPlan && this.programPlan.Program_Type__c === PRESCRIBED_TYPE);
                }
                if(childProduct.length > 0){
                    courseTemp.hasProduct = true; //tells us that course already has a product
                    courseTemp.products =[...childProduct];
                }
                if(childPlanRequirement.length > 0){
                    tableTemp = [...childPlanRequirement, ...tableTemp];
                }
                
                coursesDataTemp = [courseTemp, ...coursesDataTemp];
                
        });  
        this.coursesData = this.sortMap(coursesDataTemp);
        this.tableData = this.sortMap(tableTemp);
    }

    /*
    *function that formats the structure for course oferrings data
    */
    formatOfferingData(listToFormat){
        return listToFormat.map(item =>{
            let newItem = {};

            newItem.recordId = item.Id;
            newItem.recordUrl = '/' + item.Id;
            newItem.fields = [
                                {label:   "Course Offering Name" , value: item.Name,isUrl: true},
                                {label:   "Record Type"          , value: item.hed__Course__r.RecordType?item.hed__Course__r.RecordType.Name:''},
                                {label:   "Start Date"           , value: item.hed__Start_Date__c?new Date(item.hed__Start_Date__c).toLocaleDateString('en-US'):''},
                                {label:   "End Date"             , value: item.hed__End_Date__c?new Date(item.hed__End_Date__c).toLocaleDateString('en-US'):''},
                            ];

            return newItem;
        });
    }

    /*
    *function that formats the structure for program oferrings data
    */
    formatProgramOffering(listToFormat){
        return listToFormat.map(item =>{
            let newItem = {};
            
            newItem.recordId = item.Id;
            newItem.recordUrl = '/' + item.Id;
            newItem.fields = [
                                {label:   "Program Offering Name" , value: item.Name,isUrl: true},
                                {label:   "Start Date"            , value: item.Start_Date__c?new Date(item.Start_Date__c).toLocaleDateString('en-US'):''},
                                {label:   "End Date"              , value: item.End_Date__c?new Date(item.End_Date__c).toLocaleDateString('en-US'):''},
                            ];

            return newItem;
        });
    }

    /*
    *function that formats the structure for product data
    */
    formatProductData(listToFormat,sequence){
        return listToFormat.map(item =>{
            let newItem = {};
            newItem.recordId = item.Id;
            newItem.recordUrl = '/' + item.Id;
            newItem.fields = [
                        {label:"Product Name" , value: item.Name,isUrl: true},
                        {label:"Product Price", value: item.PricebookEntries?item.PricebookEntries[0].UnitPrice?parseInt(item.PricebookEntries[0].UnitPrice).toLocaleString('en-US', { style: 'currency', currency: 'USD' }):'':''},
                        {label:"Start Date"   , value: item.Start_Date__c?new Date(item.Start_Date__c).toLocaleDateString('en-US'):''},
                        {label:"End Date"     , value: item.End_Date__c?new Date(item.End_Date__c).toLocaleDateString('en-US'):''},
                        {label:"Sequence"     , value: sequence, isSequence: true}
            ];
            return newItem;
        });
    }

    /*
    *function that formats the structure for plan requirement
    */
    formatPlanRequirementData(listToFormat,course,counter){
        if(listToFormat){
            this.hasPlanRequirementOnRender = true;
            return listToFormat.map(item =>{
                let newItem = {};
                newItem.recordId = item.Id;
                newItem.sequence = item.hed__Sequence__c;
                newItem.category = this.planRequirementCategory;
                newItem.recordtype = course.RecordType?course.RecordType.Name:'';
                newItem.coursename = course.Name;
                newItem.courseid = course.Id;
                return newItem;
            });
        }else{
            let newItem = {};
            newItem.recordId = null;
            newItem.sequence = counter;
            newItem.category = this.planRequirementCategory;
            newItem.recordtype = course.RecordType?course.RecordType.Name:'';
            newItem.coursename = course.Name;
            newItem.courseid = course.Id;
            return [newItem];
        }
    }

    /*
    *function that handles data needed to create product for course
    */
    handleProductInsert(event){
        this.prefields = {Course__c:event.target.value};
        this.objApiName = PRODUCT_SCHEMA.objectApiName;
        this.isCreateRecord = true;
        this.multiCreate = false;
    }
    
     /*
    *function that handles data needed to create product for program plan
    */
    handleProductInsertForProgramPlan(event){
        this.prefields = {Program_Plan__c:event.target.value};
        this.objApiName = PRODUCT_SCHEMA.objectApiName;
        this.isCreateRecord = true;
        this.multiCreate = false;
    }

    /*
    *function that handles data needed to edit product
    */
    handleProductEdit(event){
        this.recordid = event.target.value;
        this.isEditRecord = true;
        this.objApiName = PRODUCT_SCHEMA.objectApiName;
    }

    /*
    *function that handles data needed to create offerings
    */
    handleOfferingInsert(event){
        this.prefields = this.isProgramRequest && this.programPlan && this.programPlan.Program_Type__c === PRESCRIBED_TYPE?{hed__Course__c:event.target.value,Program_Offering__c:this.programPlanData.offerings[0].recordId}:{hed__Course__c:event.target.value};
        this.multiCreate = this.isProgramRequest && this.programPlan && this.programPlan.Program_Type__c === PRESCRIBED_TYPE?false:true;
        this.objApiName = COURSE_OFFERING_SCHEMA.objectApiName;
        this.isCreateRecord = true;
    }

    /*
    *function that handles data needed to edit course offerings
    */
    handleOfferingEdit(event){
        this.recordid = event.target.value;
        this.isEditRecord = true;
        this.objApiName = COURSE_OFFERING_SCHEMA.objectApiName;
    }

    /*
    *function that handles data needed to create program offerings
    */
    handleProgramOfferingInsert(event){
        this.prefields = {hed_Program_Plan__c:event.target.value};
        this.objApiName = PROGRAM_OFFERING_SCHEMA.objectApiName;
        this.isCreateRecord = true;
        this.multiCreate = false;
    }

     /*
    *function that handles data needed to edit program offerings
    */
    handleProgramOfferingEdit(event){
        this.recordid = event.target.value;
        this.isEditRecord = true;
        this.objApiName = PROGRAM_OFFERING_SCHEMA.objectApiName;
    }
    /*
    *function that shows or hide program structure page
    */
    handleProgramStructure(){
        this.isProgramTab = true;
        this.isOfferingTab = false;
        this.isProductTab = false;
    }

    /*
    *function that shows or hide create product page
    */
    handleCreateProducts(){
        this.isProgramTab = false;
        this.isProductTab = true;
        this.isOfferingTab = false;
    }

    /*
    *function that shows or hide create offerings page
    */
    handleCreateOfferings(){
        this.isProgramTab = false;
        this.isProductTab = false;
        this.isOfferingTab = true;
    }

    /*
    *function that handles mark as complete button and sets completion satus to true for program structure, product and offerings
    */
    markAsComplete(){
        this.isProgramTab = false;
        this.isProductTab = false;
        this.isOfferingTab = false;
        if(this.selectionTab.isProgramStructure){
            this.createProdRequestRecord(true,false,false);
        }else if(this.selectionTab.isCreateProduct){
            this.createProdRequestRecord(true,true,false);
        }else if(this.selectionTab.isCreateOfferings){
            this.createProdRequestRecord(true,true,true);
        }
    }

    /*
    *function that creates a list of product request records to update
    */
    createProdRequestRecord(programStatus,productStatus,offeringStatus){
        let recordsToUpdate = this.listCourses.data.productRequestList.map(key =>{
            return{
                Id:key.Id,
                Program_Structure_Complete__c:programStatus,
                Create_Product_Complete__c:productStatus,
                Create_Offering_Complete__c:offeringStatus,
            }});
        this.updateStages(recordsToUpdate);
    }

    /*
    *function that updates product request release stages
    */
    updateStages(recordsToUpdate){
        updateProductRequests({prToUpdate:recordsToUpdate})
        .then(() =>{
            this.generateToast('Success!','Stage Complete!','success');
            this.refreshData();
        }).finally(() => {
            refreshApex(this.listCourses);
        }).catch(() =>{
            this.generateToast('Error.',MSG_ERROR,'error');
        });
    }

    /*
    *function that closes the modal
    */
    closeModal(){
        this.isCreateRecord = false;
        this.isEditRecord = false;
    }

    /*
    *function that handles save button 
    */
    handleSave(event){
        this.upsertRecords(event.detail);          
    }

    /*
    *function that refreshes the course,offering, and product data
    */
    refreshData(){
        this.coursesData = [];
        this.isLoading = true;
    }

    /*
    *function that handles insert or update records
    */
    upsertRecords(record){
        if(record.Id){
            this.handleUpdateRecord(record);
        }else{
            this.handleCreateRecord(record);
        }
    }

    /**
     * creates record given object api name and fields
     */
    handleCreateRecord(fieldsToCreate){
        const fields = {...fieldsToCreate};
        const recordInput = { apiName: this.objApiName, fields };

        createRecord(recordInput)
        .then(() => {
            this.refreshData();
            this.generateToast('Success!','Record created.','success');
        })
        .catch(() => {
            this.generateToast('Error.',MSG_ERROR,'error');
        })
        .finally(() => {
            refreshApex(this.listCourses);
        });
    }

     /**
     * updates record given fields
     */
    handleUpdateRecord(fieldsToUpdate){
        const fields = {...fieldsToUpdate};
        const recordInput = { fields };
        
        updateRecord(recordInput)
        .then(() => {
            this.refreshData();
            this.generateToast('Success!','Record updated','success');
        })
        .catch(() => {
            this.generateToast('Error.',MSG_ERROR,'error');
        })
        .finally(() => {
            refreshApex(this.listCourses);
        });
    }

    /**
     * refreshes the program structure page when program structure is saved
     */
    savePromgramStructureRecords(){
        refreshApex(this.listCourses).finally(()=>{
            this.template.querySelector("c-program-structure").handleCancel();
        });
    }

    /**
     * creates toast notification
     */
    generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}
