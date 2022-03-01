/**
 * @description Controller Class for manageApplicationSection LWC
 * @see ../lwc/manageApplicationSection
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 08, 2022     | DEPP-1483            | Created file                 | 
      | eccarius.karl.munoz       | February 28, 2022     | DEPP-1819            | Removed handling for Program | 
      |                           |                       |                      | Plan due to program offering | 
      |                           |                       |                      | id removal.                  | 
      |                           |                       |                      |                              | 
 */
public with sharing class ManageApplicationSectionCtrl {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     
     /**
      * @description Retrieves list of Application details of students
      * @param prodReqId - Record ID from record page
      * @return List of ManageApplicationDetails
      */
     @AuraEnabled(cacheable=true)
     public static List<ManageApplicationDetails> getStudentApplications(String prodReqId){
          List<ManageApplicationDetails> response = new List<ManageApplicationDetails>();
          Product_Request__c productRequest = [SELECT RecordTypeId FROM Product_Request__c WHERE Id =: prodReqId LIMIT 1];                 
          response = getNonProgPlanApplications(prodReqId);
          return response;
     }

     /**
      * @description Retrieves list of Application details of students for Non Program Plan
      * @param prodReqId - Record ID from record page
      * @return List of ManageApplicationDetails
      */
     private static List<ManageApplicationDetails> getNonProgPlanApplications(String prodReqId){
          List<ManageApplicationDetails> response = new List<ManageApplicationDetails>();
          
          Id courseOfferingId = [SELECT Id FROM hed__Course_Offering__c WHERE hed__Course__c IN (
                                   SELECT Id FROM hed__Course__c WHERE ProductRequestID__c =: prodReqId)]?.Id;
          if(courseOfferingId == null){
               return new List<ManageApplicationDetails>();
          }
          List<Questionnaire_Response_Summary__c> questionnaireResponseList = [
               SELECT Id, Name, Contact__c, Questionnaire__r.Questionnaire_Type__c, Application_Status__c, Reason_for_Rejection__c 
                 FROM Questionnaire_Response_Summary__c 
                WHERE Course_Offering__c =: courseOfferingId 
          ];
          List<hed__Course_Enrollment__c > courseConnections = [
               SELECT Id, hed__Contact__c, hed__Contact__r.Name 
                 FROM hed__Course_Enrollment__c 
                WHERE hed__Course_Offering__c =: courseOfferingId AND RecordTypeId =: studentRecTypeId
          ];

          for(hed__Course_Enrollment__c student : courseConnections){
               for(Questionnaire_Response_Summary__c question : questionnaireResponseList){
                    if(question.Contact__c == student.hed__Contact__c){
                         ManageApplicationDetails appDetails = new ManageApplicationDetails();
                         appDetails.id = question.Id;
                         appDetails.contactFullName = student.hed__Contact__r.Name;
                         appDetails.applicationStatus = question.Application_Status__c;
                         appDetails.reasonForRejection = question.Reason_for_Rejection__c;
                         if(question.Questionnaire__r.Questionnaire_Type__c == 'Application Questions'){
                              appDetails.applicationURL = '/' + question.Id;
                              appDetails.applicationName = question.Name;
                         }                         
                         response.add(appDetails);
                    }                    
               }
          }
          return response;
     }

     /**
      * @description Updates Application details of students
      * @param id
      * @param applicationStatus
      * @param reasonForRejection 
      * @return String
      */
     @AuraEnabled
     public static String updateStudentApplication(String id, String applicationStatus, String reasonForRejection){ 
          Questionnaire_Response_Summary__c questionnaire = new Questionnaire_Response_Summary__c();
          questionnaire.Id = id;
          questionnaire.Application_Status__c = applicationStatus;
          questionnaire.Reason_for_Rejection__c = reasonForRejection;
          try {
               update questionnaire;
               return 'Success';
          }
          catch (Exception e) {
               return 'The following exception has occurred: ' + e.getMessage();
          }
     }   
     
     @AuraEnabled(cacheable=true)
     public static List<String> getApplicationStatusValues(){
          List<String> response = new List<String>();
          String strObjectName = 'Questionnaire_Response_Summary__c';
          String strPicklistField = 'Application_Status__c';
          Map<String, String> mapPickListValues = new Map<String, String>();
          Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
          Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
          Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
          List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
          for (Schema.PicklistEntry objPickList : lstPickListValues) {
               String val = objPickList.getValue();
               response.add(val);
          }
          return response;
     }

     /**
      * @description Wrapper class that holds data to be displayed
      */
     public class ManageApplicationDetails{
          @AuraEnabled
          public String id;
          @AuraEnabled
          public String contactFullName;
          @AuraEnabled
          public String applicationURL;
          @AuraEnabled
          public String applicationName;
          @AuraEnabled
          public String applicationStatus;
          @AuraEnabled
          public String reasonForRejection;          
      }

}