/**
 * @description Controller Class for diagnosticSessionDetailSection LWC
 * @see ../lwc/ * @description Controller Class for diagnosticSessionDetailSection LWC
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | rhea.b.torres             | July 17, 2022         | DEPP-2002            | Created file                 |
      | rhea.b.torres             | August 18, 2022       | DEPP-2002            | Updated logic to support     |
      |                           |                       |                      | Session__c RecordTypes       |
*/

public with sharing class DiagnosticSessionDetailSectionCtrl {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c
          .getRecordTypeInfosByDeveloperName()
          .get(studentRT)
          .getRecordTypeId();

     /**
      * @description Retrieves list of registered learners for a course offering
      * @param childRecordId - Record ID of course offering
      * @return List of DiagnosticSessionSectionDetails
      */
     @AuraEnabled(cacheable=true)
     public static List<DiagnosticSessionSectionDetails> getRegisteredLearners(String childRecordId){
          List<DiagnosticSessionSectionDetails> response = new List<DiagnosticSessionSectionDetails>();

          if(childRecordId != null){
               // Get all Learners associated with childRecordId course offering
               Map<Id, hed__Course_Enrollment__c> courseConnectionMap 
                    = new Map<Id, hed__Course_Enrollment__c>( [SELECT Id, 
                                                                      hed__Contact__r.Name,
                                                                      hed__Contact__c 
                                                                 FROM hed__Course_Enrollment__c 
                                                                 WHERE hed__Course_Offering__c =:childRecordId
                                                                      AND recordTypeId =:studentRecTypeId
                                                                      AND hed__Status__c = 'Active']);

               if(courseConnectionMap != null && !courseConnectionMap.isEmpty()){
                    // Get Session details of learner
                    for(Session__c session : [SELECT Id, Course_Connection__c, Session_Status__c, Completion_Date__c 
                                                  FROM Session__c
                                                  WHERE Course_Connection__c IN :courseConnectionMap.keySet()]){
                         DiagnosticSessionSectionDetails learnerDetails = new DiagnosticSessionSectionDetails();
                         learnerDetails.id = session.Id;
                         learnerDetails.learnerName = courseConnectionMap.get(session.Course_Connection__c).hed__Contact__r.Name;
                         learnerDetails.contactId = courseConnectionMap.get(session.Course_Connection__c).hed__Contact__c;
                         learnerDetails.completionDate = session.Completion_Date__c;
                         learnerDetails.sessionStatus = session.Session_Status__c;
                         response.add(learnerDetails);     
                    }
               }
          }

          return response;
     }

     /**
      *  @description Retrieves list of picklist values for Session Status field
      *  @return List<String>
      */
      @AuraEnabled(cacheable=true)
      public static List<String> getSessionStatusValues(){
           List<String> response = new List<String>();
           String strObjectName = 'Session__c';
           String strPicklistField = 'Session_Status__c';
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
     public class DiagnosticSessionSectionDetails{
          @AuraEnabled
          public String id;
          @AuraEnabled
          public String learnerName;
          @AuraEnabled
          public Date completionDate;
          @AuraEnabled
          public String sessionStatus;
          @AuraEnabled
          public String contactId;
     }
}