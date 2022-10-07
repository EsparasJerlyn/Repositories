/**
 * @description A custom LWC for handling the customPageLayout/customSectionLayout LWC 
 *              and assigning values to display the correct layout
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 3, 2022      | DEPP-1257           | Created file                                           |
      | john.m.tambasen           | July 05, 2022         | DEPP-2590           | SOA product request                                    | 
      | eccarius.munoz            | July 11, 2022         | DEPP-2035           | Added handling for Consultancy Object                  | 
      | kathy.cornejo             | August 8, 2022        | DEPP-2186           | Added handling for Program Without Pathway             |
      | john.m.tambasen           | July 27, 2022         | DEPP-3480           | Corporate Bundle product request                       |
*/
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import PL_ProductRequest_Design from '@salesforce/label/c.PL_ProductRequest_Design';
import PL_ProductRequest_Release from '@salesforce/label/c.PL_ProductRequest_Release';
import RT_ProductRequest_SOA from '@salesforce/label/c.RT_ProductRequest_SOA';
import RT_ProductRequest_Program_Without_Pathway from '@salesforce/label/c.RT_ProductRequest_Program_Without_Pathway';
import RT_ProductRequest_Educ_Consultancy from '@salesforce/label/c.RT_ProductRequest_Educ_Consultancy';
import RT_ProductRequest_Corporate_Bundle from '@salesforce/label/c.RT_ProductRequest_Corporate_Bundle';
import RT_ProductSpecification_OPE from '@salesforce/label/c.RT_ProductSpecification_OPEProgramSpecification';
import COURSE_OBJ from '@salesforce/schema/hed__Course__c';
import C_PRODUCT_REQUEST from '@salesforce/schema/hed__Course__c.ProductRequestID__c';
import PRODUCT_OBJ from '@salesforce/schema/Product2';
import P_COURSE from '@salesforce/schema/Product2.Course__c';
import P_PROGRAM_PLAN from '@salesforce/schema/Product2.Program_Plan__c';
import PRODUCT_REQUEST_OBJ from '@salesforce/schema/Product_Request__c';
import PR_RT_DEV_NAME from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import PS_RT_DEV_NAME from '@salesforce/schema/Product_Request__c.Product_Specification__r.RecordType.DeveloperName';
import PROGRAM_PLAN_OBJ from '@salesforce/schema/hed__Program_Plan__c';
import PP_PRODUCT_REQUEST from '@salesforce/schema/hed__Program_Plan__c.Product_Request__c';
import BUYER_GRP_OBJ from '@salesforce/schema/BuyerGroup';
import BG_PRODUCT_REQUEST from '@salesforce/schema/BuyerGroup.Product_Request__c';
import DIAGNOSTIC_TYPE from '@salesforce/schema/hed__Course__c.Diagnostic_Tool_Type__c';
import PROG_DELIVERY_STRUCTURE from '@salesforce/schema/hed__Program_Plan__c.Program_Delivery_Structure__c';
import DIAGNOSTIC_RT from '@salesforce/label/c.RT_ProductRequest_Diagnostic_Tool';
import PROGRAM_WITHOUT_PATHWAY_RT from '@salesforce/label/c.RT_ProductRequest_Program_Without_Pathway';
import EDUC_CONSULTANCY_OBJ from '@salesforce/schema/Consultancy__c';
import EDUC_CONS_PRODUCT_REQUEST from '@salesforce/schema/Consultancy__c.Product_Request__c';
import ASSET_OBJ from '@salesforce/schema/Asset';
import ASSET_PRODUCT_REQUEST from '@salesforce/schema/Asset.Product_Request__c';

//level 1 is a direct relationship to parent
//defaults to Course/Program Plan objects
const LEVEL_ONE = {
    COURSE : {
        childObject : COURSE_OBJ.objectApiName,
        parentObject : PRODUCT_REQUEST_OBJ.objectApiName,
        parentField : C_PRODUCT_REQUEST.fieldApiName
    },
    PROGRAM_PLAN : {
        childObject : PROGRAM_PLAN_OBJ.objectApiName,
        parentObject : PRODUCT_REQUEST_OBJ.objectApiName,
        parentField : PP_PRODUCT_REQUEST.fieldApiName
    },
    BUYER_GROUP : {
        childObject : BUYER_GRP_OBJ.objectApiName,
        parentObject : PRODUCT_REQUEST_OBJ.objectApiName,
        parentField : BG_PRODUCT_REQUEST.fieldApiName
    },
    EDUC_CONSULTANCY : {
        childObject : EDUC_CONSULTANCY_OBJ.objectApiName,
        parentObject : PRODUCT_REQUEST_OBJ.objectApiName,
        parentField : EDUC_CONS_PRODUCT_REQUEST.fieldApiName
    },
    ASSET : {
        childObject : ASSET_OBJ.objectApiName,
        parentObject : PRODUCT_REQUEST_OBJ.objectApiName,
        parentField : ASSET_PRODUCT_REQUEST.fieldApiName
    }
};
//for level 2 traversals, child object defaults to Product
//can be overwritten for other use-cases
const LEVEL_TWO = {
    COURSE : {
        childObject : PRODUCT_OBJ.objectApiName,
        parentObject : COURSE_OBJ.objectApiName,
        parentField : P_COURSE.fieldApiName,
        grandParentField : C_PRODUCT_REQUEST.fieldApiName
    },
    PROGRAM_PLAN : {
        childObject : PRODUCT_OBJ.objectApiName,
        parentObject : PROGRAM_PLAN_OBJ.objectApiName,
        parentField : P_PROGRAM_PLAN.fieldApiName,
        grandParentField : PP_PRODUCT_REQUEST.fieldApiName
    }
}

const FIELD_DEPENDENT_LAYOUTS = {
    Diagnostic_Tool : {
        fieldApiName : DIAGNOSTIC_TYPE.fieldApiName,
        childObject : COURSE_OBJ.objectApiName,
        parentField : C_PRODUCT_REQUEST.fieldApiName,
        recordType : DIAGNOSTIC_RT,
        fullyCustom : true
    },

    Program_Without_Pathway : {
        fieldApiName : PROG_DELIVERY_STRUCTURE.fieldApiName,
        childObject : PROGRAM_PLAN_OBJ.objectApiName,
        parentField : PP_PRODUCT_REQUEST.fieldApiName,
        recordType : PROGRAM_WITHOUT_PATHWAY_RT,
        fullyCustom : true
    }


}


export default class OpeCustomPageLayout extends LightningElement {
    @api recordId; //id of the record
    @api objectApiName; //api name of the object
    @api tab; //tab where the layout is placed
    @api sectionLabel //section label of a particular part of the layout
    @api isGrandchild; //determines if there is 2-level traversal
    @api grandchildObject; //overwrite the default child object of level 2 traversals
    @api showEditButton; //determines if layout is editable

    @track layoutInfo = {};
    hasLoaded = false;
    isProgram = false;
    isProgramWithoutPathway = false;
    isBuyerGroup = false;
    recordType = '';
    fieldDependencyLayout = {};
    isEducConsultancy = false;
    isAsset = false;
    isOPE = true;

    /**
     * gets parent record details
     */
    @wire(getRecord, { recordId: '$recordId', fields: [PR_RT_DEV_NAME, PS_RT_DEV_NAME] })
    handleParentRecord(result){
        if(result.data){
            this.recordType = getFieldValue(result.data,PR_RT_DEV_NAME);
            this.isProgram = getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Program;
            this.isProgramWithoutPathway = getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Program_Without_Pathway;
            this.isBuyerGroup = getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_SOA;
            this.isEducConsultancy = getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Educ_Consultancy;
            this.isAsset = getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Corporate_Bundle;
            this.isOPE = getFieldValue(result.data, PS_RT_DEV_NAME) == RT_ProductSpecification_OPE;
            console.log(PS_RT_DEV_NAME);
            console.log(getFieldValue(result.data, PS_RT_DEV_NAME));
            console.log(RT_ProductSpecification_OPE);
            console.log(this.isOPE);
            if(this.tab && this.tab.split(',').includes(PL_ProductRequest_Design)){
                //only 1 level of traversal is needed (e.g. Course/Program Plan -> Product Request)
                this.assignLevelOne();
            }else if(this.tab && this.tab.split(',').includes(PL_ProductRequest_Release)){
                //release tab defaults to Product object as the child
                //2 levels of traversal are needed (e.g. Product -> Course/Program Plan -> Product Request)
                if(this.isBuyerGroup || this.isAsset){
                    this.assignLevelOne();
                }else{
                    this.assignLevelTwo();
                }
            //this condition is for Section use-case only of the customPageLayout
            //unlikely of the Design/Release tabs which use full layouts
            }else if(!this.tab && this.sectionLabel){
                if(this.isGrandchild){
                    if(this.grandchildObject){
                        this.assignLevelTwoOverwrite();
                    }else{
                        this.assignLevelTwo();
                    }
                }else{
                    this.assignLevelOne();
                }
            }
            this.hasLoaded = true;
        }
    }

    assignLevelOne(){
        //this.layoutInfo = this.isProgram ? LEVEL_ONE.PROGRAM_PLAN : LEVEL_ONE.COURSE;
        if(this.isProgram || this.isProgramWithoutPathway){
            this.layoutInfo = LEVEL_ONE.PROGRAM_PLAN;
            if(FIELD_DEPENDENT_LAYOUTS[this.recordType]){
                this.fieldDependencyLayout = FIELD_DEPENDENT_LAYOUTS[this.recordType];
            }
            if(this.isProgramWithoutPathway && this.isOPE)
                this.fieldDependencyLayout = {};

        }else if (this.isBuyerGroup){
            this.layoutInfo = LEVEL_ONE.BUYER_GROUP;
        }else if (this.isEducConsultancy){
            this.layoutInfo = LEVEL_ONE.EDUC_CONSULTANCY;
        }else if (this.isAsset){
            this.layoutInfo = LEVEL_ONE.ASSET;
        }else {
            this.layoutInfo = LEVEL_ONE.COURSE;

            if(FIELD_DEPENDENT_LAYOUTS[this.recordType]){
                this.fieldDependencyLayout = FIELD_DEPENDENT_LAYOUTS[this.recordType];
            }
        }
    }

    assignLevelTwo(){
        this.layoutInfo = this.isProgram || this.isProgramWithoutPathway ? LEVEL_TWO.PROGRAM_PLAN : LEVEL_TWO.COURSE;
    }

    assignLevelTwoOverwrite(){
        this.layoutInfo = this.isProgram || this.isProgramWithoutPathway ? this.overwriteChild(LEVEL_TWO.PROGRAM_PLAN) : this.overwriteChild(LEVEL_TWO.COURSE);
    }

    overwriteChild(info){
        let _info = {...info};
        _info.childObject = this.grandchildObject;
        return _info;
    }
}