/**
 * @description Controller class for opeProgramStructure LWC
 *
 * @see ../lwc/opeProgramStructure
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | adrian.c.habasa           | Febuary 04, 2022      | DEPP-1427 | Created file                    | 
      |                           |                       |           |                                 | 
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

                List<Product_Request__c> childAndParentProdRequestList = new List<Product_Request__c>();
                Map<Id,Product_Request__c> childAndParentProdRequestMap = new Map<Id,Product_Request__c>([SELECT Id, Name, RecordType.DeveloperName, RecordTypeId, Product_Request_Status__c, 
                                                                                                         Parent_Product_Request__c, Parent_Product_Request__r.Name, Product_Request_Name__c
                                                                                                         FROM Product_Request__c
                                                                                                         WHERE Id =: productRequestId 
                                                                                                         OR Parent_Product_Request__c =: productRequestId]);
                                                                                                    
                List<hed__Program_Plan__c> relatedProgramPlanList = new List<hed__Program_Plan__c>([SELECT Id, Name, Program_Type__c, hed__Start_Date__c, hed__End_Date__c 
                                                                                                        FROM hed__Program_Plan__c WHERE Product_Request__c =: productRequestId]);


                if(childAndParentProdRequestMap.get(productRequestId).RecordType.DeveloperName == opeProgramRequest){    
                    childAndParentProdRequestList = childAndParentProdRequestMap.values();
                }else{
                    childAndParentProdRequestList.add(childAndParentProdRequestMap.get(productRequestId));
                }

                List<hed__Course__c> coursesList =new List<hed__Course__c>([SELECT Id,Name,RecordType.Name, Start_Date__c, End_Date__c,
                                                                           (SELECT Id, hed__Sequence__c, hed__Category__c from hed__Plan_Requirements__r)
                                                                           FROM hed__Course__c 
                                                                           WHERE ProductRequestID__c in:childAndParentProdRequestList]);
                
                prodReqAndCourseData.courseList = coursesList;
                prodReqAndCourseData.productRequestList= childAndParentProdRequestList;
                prodReqAndCourseData.programPlanList= relatedProgramPlanList;

                return prodReqAndCourseData;

            }catch(Exception e){ throw auraEx; }
    }

    //wrapper class, Holds List of Courses, Product Request and Program Plan
    public class OpeProductRequestAndCourse{
        @AuraEnabled
        public List<hed__Course__c> courseList;
        @AuraEnabled
        public List<Product_Request__c> productRequestList;
        @AuraEnabled
        public List<hed__Program_Plan__c> programPlanList;
       
    }
}