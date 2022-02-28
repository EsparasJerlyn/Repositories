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
      |                           |                       |                     |                                                        |
*/
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import PL_ProductRequest_Design from '@salesforce/label/c.PL_ProductRequest_Design';
import PL_ProductRequest_Release from '@salesforce/label/c.PL_ProductRequest_Release';
import COURSE_OBJ from '@salesforce/schema/hed__Course__c';
import C_PRODUCT_REQUEST from '@salesforce/schema/hed__Course__c.ProductRequestID__c';
import PRODUCT_OBJ from '@salesforce/schema/Product2';
import P_COURSE from '@salesforce/schema/Product2.Course__c';
import P_PROGRAM_PLAN from '@salesforce/schema/Product2.Program_Plan__c';
import PRODUCT_REQUEST_OBJ from '@salesforce/schema/Product_Request__c';
import PR_RT_DEV_NAME from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import PROGRAM_PLAN_OBJ from '@salesforce/schema/hed__Program_Plan__c';
import PP_PRODUCT_REQUEST from '@salesforce/schema/hed__Program_Plan__c.Product_Request__c';

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
export default class OpeCustomPageLayout extends LightningElement {
    @api recordId; //id of the record
    @api objectApiName; //api name of the object
    @api tab; //tab where the layout is placed
    @api sectionLabel //section label of a particular part of the layout
    @api isGrandchild; //determines if there is 2-level traversal
    @api grandchildObject; //overwrite the default child object of level 2 traversals

    @track layoutInfo = {};
    hasLoaded = false;
    isProgram = false;

    /**
     * gets parent record details
     */
    @wire(getRecord, { recordId: '$recordId', fields: [PR_RT_DEV_NAME] })
    handleParentRecord(result){
        if(result.data){
            this.isProgram = getFieldValue(result.data,PR_RT_DEV_NAME) == RT_ProductRequest_Program;
            if(this.tab == PL_ProductRequest_Design){
                //design tab includes a mark as complete button
                //only 1 level of traversal is needed (e.g. Course/Program Plan -> Product Request)
                this.assignLevelOneOverwrite();
            }else if(this.tab == PL_ProductRequest_Release){
                //release tab defaults to Product object as the child
                //2 levels of traversal are needed (e.g. Product -> Course/Program Plan -> Product Request)
                this.assignLevelTwo();
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
        this.layoutInfo = this.isProgram ? LEVEL_ONE.PROGRAM_PLAN : LEVEL_ONE.COURSE;
    }

    assignLevelOneOverwrite(){
        this.layoutInfo = this.isProgram ? this.addBooleanKeys(LEVEL_ONE.PROGRAM_PLAN) : this.addBooleanKeys(LEVEL_ONE.COURSE);
    }

    assignLevelTwo(){
        this.layoutInfo = this.isProgram ? LEVEL_TWO.PROGRAM_PLAN : LEVEL_TWO.COURSE;
    }

    assignLevelTwoOverwrite(){
        this.layoutInfo = this.isProgram ? this.overwriteChild(LEVEL_TWO.PROGRAM_PLAN) : this.overwriteChild(LEVEL_TWO.COURSE);
    }

    addBooleanKeys(info){
        return {
            ...info,
            markAsComplete : true
        };
    }

    overwriteChild(info){
        let _info = {...info};
        _info.childObject = this.grandchildObject;
        return _info;
    }
}