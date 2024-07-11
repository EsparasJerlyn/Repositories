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
      | roy.nino.s.regala		       | Nov 03, 2023     	   | DEPP-7145              | called resetLeadScore method |
 */

public with sharing class ProgramEnrollmentTriggerHandler implements Disableable, BeforeUpdate, AfterInsert, AfterUpdate {


   /**
    * @description afterInsert trigger event
    * @param newItems - List of hed__Program_Enrollment__c.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
        getContactFromProgramEnrollment((List<hed__Program_Enrollment__c>) newItems.values(),null);
        ProgEnrollLeadScoreHelper.processLeadScoreCalculation((List<hed__Program_Enrollment__c>) newItems.values(), null);
        ProgramEnrollmentTriggerHelper.processAddressValidation((List<hed__Program_Enrollment__c>) newItems.values(), null);
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
        getContactFromProgramEnrollment((List<hed__Program_Enrollment__c>) newItems.values(),(Map<Id, hed__Program_Enrollment__c>) oldItems);
        ProgramEnrollmentTriggerHelper.processAddressValidation((List<hed__Program_Enrollment__c>) newItems.values(), (Map<Id, hed__Program_Enrollment__c>) oldItems);
    }

    /**
     * @description beforeUpdate trigger event
     * @param newItems - List of hed__Program_Enrollment__c.Trigger.new
     * @param oldItems - List of hed__Program_Enrollment__c.Trigger.old
     */
    public void beforeUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ){
        ProgramEnrollmentTriggerHelper.resetLeadScore((List<hed__Program_Enrollment__c>) newItems.values(), (Map<Id, hed__Program_Enrollment__c>) oldItems);
        ProgEnrollLeadScoreHelper.processLeadScoreCalculation((List<hed__Program_Enrollment__c>) newItems.values(), (Map<Id, hed__Program_Enrollment__c>) oldItems);
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
        Set<String> enrollmentStatuses = new Set<String>{
            ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED,
            ProgramEnrollmentsDAO.ENROLLMENT_STATUS_PASSED,
            ProgramEnrollmentsDAO.ENROLLMENT_STATUS_WITHDRAWN
        };     

        for (hed__Program_Enrollment__c pr : newItems) {
            //checks student enrollment status if admitted withdrawn or passed and updates student flag.
            if(String.isNotEmpty(pr.hed__Contact__c) && enrollmentStatuses.contains(pr.Enrollment_Status__c)){ 
                contactIds.add(pr.hed__Contact__c);
            }
            //checks if ProgramEnrollment deletes the contact link.
            if(oldItems != null && String.isEmpty(pr.hed__Contact__c)) {            
                hed__Program_Enrollment__c oldApp = oldItems.get(pr.Id);
                if(String.isNotEmpty(oldApp.hed__Contact__c)){
                    contactIds.add(oldApp.hed__Contact__c); 
                }                 
            }
            //checks if ProgramEnrollment changes it's contact.
            if(oldItems != null && String.isNotEmpty(pr.hed__Contact__c)) {
                if(String.isNotEmpty(pr.hed__Contact__c) && oldItems.get(pr.Id)?.hed__Contact__c != pr.hed__Contact__c){
                    contactIds.add(oldItems.get(pr.Id).hed__Contact__c); 
                }
            } 
        }
        
        if(!contactIds.isEmpty()){
            ContactPersonaFlagsService.processContactIds(contactIds,'updateContactOnStudentFlag');
        }     
    }
}