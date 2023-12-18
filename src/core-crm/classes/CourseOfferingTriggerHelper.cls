/**
 * @description TriggerHelper for hed__Course_Offerring__c
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
public with sharing class CourseOfferingTriggerHelper{
    /**
     * @description updates hed__Course_Offering__c.LMS_Integration_Status__c to 'isChanged' if Registration_Start_Date__c or Registration_End_Date__c is updated
     * 				and LMS_Integration_Status__c is Success and IsActive__c is True
     * @param 
     * newItems - List of hed__Course_Offering__c.Trigger.new
     * oldItems - Map of hed__Course_Offering__c.Trigger.old
     */
    public static void setLMSIntegrationStatusToIsChanged(List<hed__Course_Offering__c> newItems, Map<Id, hed__Course_Offering__c> oldItems){
        for(hed__Course_Offering__c courseOffering : newItems){
            if((courseOffering.hed__Start_Date__c != oldItems.get(courseOffering.Id).hed__Start_Date__c ||
            courseOffering.hed__End_Date__c != oldItems.get(courseOffering.Id).hed__End_Date__c) &&
            courseOffering.LMS_Integration_Status__c == 'Success' &&
            courseOffering.IsActive__c == true){
                courseOffering.LMS_Integration_Status__c = 'isChanged';
            }            
        }
    }
}