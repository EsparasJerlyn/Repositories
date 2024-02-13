/**
 * @description OpportunityContactRole object trigger handler class
 * @see OpportunityContactRoleTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | Aug 24, 2023          | DEPP-6367    | Created file                                |
*/
public with sharing class OpportunityContactRoleTriggerHandler implements Disableable,  AfterInsert, AfterUpdate {

   /**
    * @description afterInsert trigger event
    * @param newItems - List of OpportunityContactRole.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
        getContactFromOpportunityContactRole((List<OpportunityContactRole>) newItems.values(),null);
    }

   /**
    * @description performs beforeUpdate event for OpportunityContactRole object
    * @param newItems - Map of OpportunityContactRole.Trigger.newMap
    * @param oldItems - Map of OpportunityContactRole.Trigger.oldMap
    */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        getContactFromOpportunityContactRole((List<OpportunityContactRole>) newItems.values(),(Map<Id, OpportunityContactRole>) oldItems);
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
    * @description Get the contactId from OpportunityContactRole
    *
    * @param newItems  List of new OpportunityContactRole records
    * @param oldItems  Map of old OpportunityContactRole records (Id => OpportunityContactRole)
    */
    private static void getContactFromOpportunityContactRole(List<OpportunityContactRole> newItems, Map<Id, OpportunityContactRole> oldItems) {
        
        Set<Id> contactIds = new Set<Id>();        
        for (OpportunityContactRole ocr : newItems) {
            
            if(String.isNotEmpty(ocr.ContactId)){
                contactIds.add(ocr.ContactId);
            }
            
            if(oldItems != null) {              
                OpportunityContactRole oldrec = oldItems.get(ocr.Id);               
                Boolean isContactChanged = (ocr.ContactId != oldrec.ContactId);
                
                if(String.isNotEmpty(oldrec.ContactId) && isContactChanged){
                    contactIds.add(oldrec.ContactId); 
                }                 
            }
        }
        
        if(!contactIds.isEmpty()){
            ContactPersonaFlagsService.processContactIds(contactIds,'updateContactPartnerFlag');
        }  
    }

}