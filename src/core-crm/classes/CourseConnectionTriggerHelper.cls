/**
 * @description TriggerHelper for hed__Course_Enrollment__c
 * @see CourseOfferingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | September 22, 2023    | DEPP-6629              | Created file                 |
      |                                |                       |                        |                              |
      
 */
public with sharing class CourseConnectionTriggerHelper{    
    /**
     * @description updates hed__Course_Enrollment__c.LMS_Integration_Status__c to null if hed__Status__c is changed to cancelled
     * @param 
     * newItems - List of hed__Course_Enrollment__c.Trigger.new
     * oldItems - Map of hed__Course_Enrollment__c.Trigger.old
     */
    public static void setLMSIntegrationStatusToNull(List<hed__Course_Enrollment__c> newItems, Map<Id,hed__Course_Enrollment__c> oldItems){
        for(hed__Course_Enrollment__c courseConnection : newItems){
            if(courseConnection.hed__Status__c != oldItems.get(courseConnection.Id).hed__Status__c && courseConnection.hed__Status__c == 'Cancelled'){
                courseConnection.LMS_Integration_Status__c = null;
            }
        }
    }
}