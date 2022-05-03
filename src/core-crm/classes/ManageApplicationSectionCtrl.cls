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
      | john.bo.a.pineda          | March 10, 2022        | DEPP-1463            | Modified Query to filter     |
      |                           |                       |                      | only Application Questions   |
      |                           |                       |                      |                              |
      | eccarius.karl.munoz       | May 03, 2022          | DEPP-2134            | Added handling for Program   |
      |                           |                       |                      | Prescribed and Updated Query |
      |                           |                       |                      | to remove course connection. |
*/
public with sharing class ManageApplicationSectionCtrl {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();

     /**
      * @description Retrieves list of Application details of students
      * @param offeringId - Course/Program Offering ID from record page
      * @return List of ManageApplicationDetails
      */     
     @AuraEnabled(cacheable=true)
     public static List<ManageApplicationDetails> getStudentApplications(String offeringId){
          List<ManageApplicationDetails> response = new List<ManageApplicationDetails>();
          
          if(offeringId == null){
               return new List<ManageApplicationDetails>();
          }

          List<Questionnaire_Response_Summary__c> questionnaireResponseList = [
               SELECT Id, Name, Contact__r.Name, Questionnaire__r.Questionnaire_Type__c, Application_Status__c, Reason_for_Rejection__c
                 FROM Questionnaire_Response_Summary__c
                WHERE Questionnaire__r.Questionnaire_Type__c = 'Application Questions' AND (Course_Offering__c =: offeringId OR Program_Offering__c  =: offeringId)
          ];         

          for(Questionnaire_Response_Summary__c qrs : questionnaireResponseList){
               ManageApplicationDetails appDetails = new ManageApplicationDetails();
               appDetails.id = qrs.Id;
               appDetails.contactFullName = qrs.Contact__r.Name;
               appDetails.applicationStatus = qrs.Application_Status__c;
               appDetails.reasonForRejection = qrs.Reason_for_Rejection__c;
               if(qrs.Questionnaire__r.Questionnaire_Type__c == 'Application Questions'){
                    appDetails.applicationURL = '/' + qrs.Id;
                    appDetails.applicationName = qrs.Name;
               }
               response.add(appDetails);
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