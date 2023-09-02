/**
 * @description helper for AffiliationTriggerHandler
 * @see AffiliationTriggerHandler 
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | July 13, 2023         | DEPP-5799              | Created file                                     |
 */
public with sharing class AffiliationTriggerHelper {
    
    /**
     * @description Get the contactId from affiliation record
     *
     * @param newItems  List of new hed__Affiliation__c records
     * @param oldItems  Map of old hed__Affiliation__c records (Id => hed__Application__c)
     */
     public static void getContactFromAffiliation(List<hed__Affiliation__c> newItems, Map<Id, hed__Affiliation__c> oldItems) {
         
         Set<Id> contactIds = new Set<Id>();
         
         for (hed__Affiliation__c af : newItems) {
                          
             if(String.isNotEmpty(af.hed__Contact__c)){
                 contactIds.add(af.hed__Contact__c);
             }
         }
         
         if(!contactIds.isEmpty()){
             ContactPersonaFlagsService.processContactIds(contactIds,'updateContactOnAffiliation');
         }      
     }

}