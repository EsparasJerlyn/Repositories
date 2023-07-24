/**
 * @description helper class for ApplicationTriggerHelperHandler
 * @see ApplicationTriggerHelperHandler
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | July 12, 2023         | DEPP-5799              | Created file                                     |
 */
public with sharing class ApplicationTriggerHelper {
    
    /**
     * @description get the existing contact in the application record
     *
     * @param newItems  List of new hed__Application__c records
     * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
     */
     public static void getContactOnApplication(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems) {         
         Set<Id> contactIds = new Set<Id>();
         
         for (hed__Application__c app : newItems) {
             
             boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
             boolean isSAMSRecType = app.RecordTypeId == ApplicationsDAO.SAMS_RECTYPE_ID;
             boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
             boolean isValidRecType = isStudylinkRecType || isSAMSRecType || isQTACRecType;
                          
             if(String.isNotEmpty(app.hed__Applicant__c) && isValidRecType){
                 contactIds.add(app.hed__Applicant__c);
             }
                      
             if(oldItems != null && String.isEmpty(app.hed__Applicant__c)) {              
                 hed__Application__c oldApp = oldItems.get(app.Id);
                 if(String.isNotEmpty(oldApp.hed__Applicant__c)){
                     contactIds.add(oldApp.hed__Applicant__c); 
                 }                 
             }
         }
         
         if(!contactIds.isEmpty()){
             ContactPersonaFlagsService.processContactIds(contactIds,'updateContactOnApplication');
         }      
     }

}