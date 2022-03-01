/**
 * @description Controller Class for manageRegistrationSection LWC
 * @see ../lwc/manageRegistrationSection
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 09, 2022     | DEPP-1482            | Created file                 | 
      | eccarius.karl.munoz       | February 28, 2022     | DEPP-1819            | Removed handling for Program | 
      |                           |                       |                      | Plan due to program offering | 
      |                           |                       |                      | id removal.                  | 
      |                           |                       |                      |                              | 
 */
public with sharing class ManageRegistrationSectionCtrl {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     
     /**
      * @description Retrieves list of Registration details of students
      * @param prodReqId - Record ID from record page
      * @return List of ManageRegistrationDetails
      */
     @AuraEnabled(cacheable=true)
     public static List<ManageRegistrationDetails> getRegistrationDetails(String prodReqId){          
          List<ManageRegistrationDetails> response = new List<ManageRegistrationDetails>();
          Product_Request__c productRequest = [SELECT RecordTypeId FROM Product_Request__c WHERE Id =: prodReqId LIMIT 1];       
          response = getNonProgPlanRegistrations(prodReqId);          
          return response;
     }

     /**
      * @description Retrieves list of Registration details of students for Non Program Plan
      * @param prodReqId - Record ID from record page
      * @return List of ManageRegistrationDetails
      */
     private static List<ManageRegistrationDetails> getNonProgPlanRegistrations(String prodReqId){
          List<ManageRegistrationDetails> response = new List<ManageRegistrationDetails>();
          Id courseOfferingId = [SELECT Id FROM hed__Course_Offering__c WHERE hed__Course__c IN (
                                   SELECT Id FROM hed__Course__c WHERE ProductRequestID__c =: prodReqId) LIMIT 1]?.Id;
          if(courseOfferingId == null){
               return new List<ManageRegistrationDetails>();
          }
          List<Questionnaire_Response_Summary__c> questionnaireResponseList = [
               SELECT Id, Name, Contact__c, Course_Offering__c, Questionnaire__c, Questionnaire__r.Questionnaire_Type__c, Registration_Status__c 
                 FROM Questionnaire_Response_Summary__c 
                WHERE Course_Offering__c =: courseOfferingId
          ];
          List<hed__Course_Enrollment__c > courseConnections = [
               SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Course_Offering__c, Paid_in_Full__c, hed__Status__c 
                 FROM hed__Course_Enrollment__c 
                WHERE hed__Course_Offering__c =: courseOfferingId AND RecordTypeId =: studentRecTypeId
          ];
          for(hed__Course_Enrollment__c student : courseConnections){
               for(Questionnaire_Response_Summary__c question : questionnaireResponseList){
                    if(question.Contact__c == student.hed__Contact__c){
                         ManageRegistrationDetails regDetails = new ManageRegistrationDetails();
                         regDetails.id = student.Id;
                         regDetails.questionId = question.Id;
                         regDetails.contactFullName = student.hed__Contact__r.Name;
                         regDetails.paidInFull = student.Paid_in_Full__c;
                         regDetails.registrationStatus = question.Registration_Status__c;
                         if(question.Questionnaire__r.Questionnaire_Type__c == 'Registration Questions'){
                              regDetails.applicationURL = '/' + question.Id;
                              regDetails.applicationName = question.Name;
                         }                         
                         response.add(regDetails);
                    }                    
               }
          }
          return response;
     }     

     /**
      * @description Updates Registration details of students
      * @param id - id of student selected
      * @param questionId - question id of student selected
      * @param registrationStatus - registration status of student selected
      * @param paidInFull - paid in full field of student selected
      * @return String
      */
     @AuraEnabled
     public static String updateRegistration(String id, String questionId, String registrationStatus, String paidInFull){ 
          hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
          student.Id = id;
          student.Paid_in_Full__c = paidInFull;
          Questionnaire_Response_Summary__c questionnaire = new Questionnaire_Response_Summary__c();
          questionnaire.Id = questionId;
          questionnaire.Registration_Status__c = registrationStatus;
          try {
               if(student.Id !=null){
                    update student;
               }
               if(questionnaire.Id !=null){
                    update questionnaire;
               }               
               return 'Success';
          }
          catch (Exception e) {
               return 'The following exception has occurred: ' + e.getMessage();
          }
     }  
      
     /**
      *  @description Retrieves list of picklist values for paid in full field
      *  @return List<String>
      */
     @AuraEnabled(cacheable=true)
     public static List<String> getPaidInFullValues(){
          List<String> response = new List<String>();
          String strObjectName = 'hed__Course_Enrollment__c';
          String strPicklistField = 'Paid_in_Full__c';
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
      *  @description Retrieves list of picklist values for registration status field
      *  @return List<String>
      */
     @AuraEnabled(cacheable=true)
     public static List<String> getRegistrationStatusValues(){
          List<String> response = new List<String>();
          String strObjectName = 'Questionnaire_Response_Summary__c';
          String strPicklistField = 'Registration_Status__c';
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
     public class ManageRegistrationDetails{
          @AuraEnabled
          public String id;
          @AuraEnabled
          public String questionId;
          @AuraEnabled
          public String contactFullName;
          @AuraEnabled
          public String paidInFull;
          @AuraEnabled
          public String registrationStatus;
          @AuraEnabled
          public String applicationName;      
          @AuraEnabled
          public String applicationURL;  
      }     
}