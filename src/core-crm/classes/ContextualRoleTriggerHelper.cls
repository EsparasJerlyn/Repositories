/**
 * @description helper for ContextualRoleTriggerHelper
 * @see ContextualRoleTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | July 13, 2023         | DEPP-5799              | Created file                                     |
 */
public with sharing class ContextualRoleTriggerHelper {
    
    /**
     * @description Get the contactId from affiliation record
     *
     * @param newItems  List of new hed__Affiliation__c records
     * @param oldItems  Map of old hed__Affiliation__c records (Id => hed__Application__c)
     */
     public static void getContactFromContextualRole(List<Contextual_Role__c> newItems, Map<Id, Contextual_Role__c> oldItems) {
         
         Set<Id> contactIds = new Set<Id>();
         
         for(Contextual_Role__c cr : newItems) {
             
             if(cr.RecordTypeId == ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID && String.isNotEmpty(cr.Contact__c)){
                contactIds.add(cr.Contact__c); 
             }
         }
         
         if(!contactIds.isEmpty()){
             ContactPersonaFlagsService.processContactIds(contactIds,'updateContactOnContextualRole');
         }      
     }

}