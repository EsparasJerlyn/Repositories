/**
 * @description Controller class for opeProgramStructure LWC
 *
 * @see ../lwc/opeProgramStructure
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                              |
      |---------------------------|-----------------------|-----------|---------------------------------------------|
      | adrian.c.habasa           | Febuary 04, 2022      | DEPP-1427 | Created file                                | 
      | roy.nino.s.regala         | March 10, 2022        | DEPP-1747 | Updated to adapt to new field and data model| 
*/
public with sharing class OpeProgramStructureCtrl {

    private static String opeProgramRequest = 'Program';

     /**`
     * @description get List of courses,product requests, and Program Plan
     * @param Product Request Record Id
     * @return list of course,product requests, and Program Plan
     */
    @AuraEnabled(cacheable=true)
    public static OpeProductRequestAndCourse getProdReqAndCourse (Id productRequestId)
    {
        AuraHandledException auraEx = new AuraHandledException('Error Message');  
        auraEx.setMessage('Error while getting Data.');
            try{

                OpeProductRequestAndCourse prodReqAndCourseData = new OpeProductRequestAndCourse();
                Set<Id> courseProdRequestIds = new Set<Id>();

                List<hed__Program_Plan__c> relatedProgramPlanList = new List<hed__Program_Plan__c>([SELECT Id, Name, Program_Delivery_Structure__c, hed__Start_Date__c, hed__End_Date__c 
                                                                                                        FROM hed__Program_Plan__c WHERE Product_Request__c =: productRequestId]);

                List<Related_Product_Request__c> relatedProductRequests = new List<Related_Product_Request__c>([SELECT Id, Program__c, Course__c 
                                                                                                                FROM Related_Product_Request__c 
                                                                                                                WHERE Program__c =: productRequestId]);                                                                                               
                for(Related_Product_Request__c relatedPR : relatedProductRequests){
                    courseProdRequestIds.add(relatedPR.Course__c);
                }
                List<hed__Course__c> coursesList = new List<hed__Course__c>([SELECT Id,Name,RecordType.Name, Start_Date__c, End_Date__c,
                                                                           (SELECT Id, hed__Sequence__c, hed__Category__c from hed__Plan_Requirements__r WHERE hed__Program_Plan__c =:relatedProgramPlanList)
                                                                           FROM hed__Course__c 
                                                                           WHERE ProductRequestID__c in:courseProdRequestIds]);

                                                                                                    
                
                
                prodReqAndCourseData.courseList = coursesList;
                prodReqAndCourseData.programPlanList= relatedProgramPlanList;

                return prodReqAndCourseData;

            }catch(Exception e){ throw auraEx; }
    }

    /**
     * @description insert Plan Requirement records
     * @param planRequirementToUpdate - plan requirement list to update
     */
    @AuraEnabled
    public static void upsertProgramPlanAndPlanRequirement(List<hed__Plan_Requirement__c> recordsToUpsert){
        if(!recordsToUpsert.isEmpty()){
            upsert(recordsToUpsert);
        }
    }

    //wrapper class, Holds List of Courses, Product Request and Program Plan
    public class OpeProductRequestAndCourse{
        @AuraEnabled
        public List<hed__Course__c> courseList;
        @AuraEnabled
        public List<hed__Program_Plan__c> programPlanList;
       
    }
}