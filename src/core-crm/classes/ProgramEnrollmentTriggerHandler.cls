/**
 * @description Program Enrollment object trigger handler class
 * @see ProgramEnrollmentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum		           | July 23, 2023     	   | DEPP-5799              | Created file                 |
 */

public with sharing class ProgramEnrollmentTriggerHandler implements Disableable,  AfterInsert, AfterUpdate {
    public static Boolean isRunning = false;

   /**
    * @description afterInsert trigger event
    * @param newItems - List of hed__Program_Enrollment__c.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
        
        if(!isRunning ){
            isRunning = true;
            getContactFromProgramEnrollment((List<hed__Program_Enrollment__c>) newItems.values(),null);
        }
    }

   /**
    * @description performs beforeUpdate event for hed__Program_Enrollment__c object
    * @param newItems - Map of hed__Program_Enrollment__c.Trigger.newMap
    * @param oldItems - Map of hed__Program_Enrollment__c.Trigger.oldMap
    */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        if(!isRunning ){
            isRunning = true;
            getContactFromProgramEnrollment((List<hed__Program_Enrollment__c>) newItems.values(),(Map<Id, hed__Program_Enrollment__c>) oldItems);
        }
    }
    
   /**
    * @description indicates it the trigger is disabled
    * @return disabled bypass
    */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
    
   /**
    * @description Get the contactId from program enrollment record
    *
    * @param newItems  List of new hed__Application__c records
    * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
    */
    public static void getContactFromProgramEnrollment(List<hed__Program_Enrollment__c> newItems, Map<Id, hed__Program_Enrollment__c> oldItems) {
        
        Set<Id> contactIds = new Set<Id>();
        Set<String> enrollmentStatuses = new Set<String>{'Admitted','Passed','Withdrawn'};     
            
            for (hed__Program_Enrollment__c pr : newItems) {
                
                if(String.isNotEmpty(pr.hed__Contact__c) && enrollmentStatuses.contains(pr.Enrollment_Status__c)){
                    contactIds.add(pr.hed__Contact__c);
                }
                
                if(oldItems != null && String.isEmpty(pr.hed__Contact__c)) {              
                    hed__Program_Enrollment__c oldApp = oldItems.get(pr.Id);
                    if(String.isNotEmpty(oldApp.hed__Contact__c)){
                        contactIds.add(oldApp.hed__Contact__c); 
                    }                 
                }
            }
        
        if(!contactIds.isEmpty()){
            ContactPersonaFlagsService.processContactIds(contactIds,'updateContactOnProgramEnrollment');
        }      
    }
}