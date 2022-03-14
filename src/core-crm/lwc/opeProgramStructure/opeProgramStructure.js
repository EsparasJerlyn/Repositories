/**
 * @description An LWC component for ope program structure
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                            | Change Summary                              |
      |---------------------------|-----------------------|---------------------------------|---------------------------------------------|
      | adrian.c.habasa           | Febuary 4, 2022       | DEPP-1427                       | Created                                     |
      | roy.nino.s.regala         | March 10, 2022        | DEPP-1747                       | Updated to adapt to new field and data model|
 */
import { LightningElement,wire,api} from 'lwc';
import getProdReqAndCourse from '@salesforce/apex/OpeProgramStructureCtrl.getProdReqAndCourse';
import { refreshApex } from '@salesforce/apex';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';

const FLEXIBLE_TYPE = 'Flexible Program';
const PRESCRIBED_TYPE = 'Prescribed Program';
const OPTIONAL = 'Optional';
const REQUIRED = 'Required';

export default class OpeProgramStructure extends LightningElement {

    @api recordId;
    coursesData = [];
    programPlan={};
    tableData=[];
    hasPlanRequirementOnRender=false;
    isLoading= true;

    listOfRecords;
    @wire(getProdReqAndCourse,{productRequestId: '$recordId'})
    relatedRecords(result){
        if(result.data)
        {
            this.listOfRecords = result;
            let coursesList = this.listOfRecords.data.courseList;
            let programPlanTemp = this.listOfRecords.data.programPlanList?this.listOfRecords.data.programPlanList[0]:{};
            //check if atleast one course has a plan requirement already
            this.hasPlanRequirementOnRender = coursesList.find(filterKey => filterKey.hed__Plan_Requirements__r)?true:false; 
            this.programPlan = programPlanTemp;

            this.formatCourseData(coursesList);
            this.isLoading = false;
        }
        else if(result.error)
        {  
            this.generateToast('Error!',MSG_ERROR,'error');
            this.isLoading = false;
        }

    }

    /*
     *getter for default plan requirement category
     */
    get planRequirementCategory(){
        return this.programPlan?(this.programPlan.Program_Delivery_Structure__c === FLEXIBLE_TYPE?OPTIONAL:this.programPlan.Program_Delivery_Structure__c === PRESCRIBED_TYPE?REQUIRED:OPTIONAL):'';
    }

    /*
     * getter if child product request has course
     */
    get hasCourse()
    {
        return this.coursesData.length>0 && this.programPlan != null ? true: false;
    }

    get hasAccess(){
        return HAS_PERMISSION;
    }

    formatCourseData(listToFormat)
    {   
        let tableTemp = [];
        let coursesDataTemp=[];
        listToFormat.forEach(course =>{
            let courseTemp={};
            courseTemp.recordId = course.Id;
            courseTemp.recordUrl = '/' + course.Id;
            courseTemp.name = course.Name;
            courseTemp.sequence = course.hed__Plan_Requirements__r?course.hed__Plan_Requirements__r[0].hed__Sequence__c:'';
            let childPlanRequirement = this.formatPlanRequirementData(course.hed__Plan_Requirements__r, course , tableTemp.length + 1);
            if(childPlanRequirement.length > 0){
                tableTemp = [...childPlanRequirement, ...tableTemp];
            }

            coursesDataTemp=[courseTemp , ...coursesDataTemp];
        });
        this.tableData = this.sortMap(tableTemp);
        this.coursesData = this.sortMap(coursesDataTemp);
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
     *function that formats the structure for plan requirement
     */
    formatPlanRequirementData(listToFormat,course,counter){
        if(listToFormat){
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
            newItem.sequence = this.hasPlanRequirementOnRender?'':counter; //empty if there is already a saved plan requirement
            newItem.category = this.planRequirementCategory;
            newItem.recordtype = course.RecordType?course.RecordType.Name:'';
            newItem.coursename = course.Name;
            newItem.courseid = course.Id;
            return [newItem];
        }
    }
    
    saveProgramStructureRecord(){
        refreshApex(this.listOfRecords).finally(()=>{
            this.template.querySelector("c-program-structure").handleCancel();
        });
        
    }
}
