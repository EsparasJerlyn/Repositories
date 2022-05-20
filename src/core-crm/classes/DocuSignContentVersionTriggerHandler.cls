/**
 * @description TriggerHandler Class for ContentVersion
 * @see ..DocuSignContentVersionTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.dayrit@qut.edu.au      | November 10, 2021     | DEPP-503               | Created file                 | 
      |                                |                       |                        |                              | 
 */
public with sharing class DocuSignContentVersionTriggerHandler implements Disableable,
                                                                        BeforeInsert,
                                                                        BeforeUpdate{

    /**
   * @description update inserted Proposal title
   * @param newItems - List of ContentVersion.Trigger.new
   */                                                                      
    public void beforeInsert(List<SObject> newItems) {
        updateProposalTitle((List<ContentVersion>)newItems, null);
    }

     /**
   * @description update Proposal title
   * @param newItems - List of ContentVersion.Trigger.new
   * @param oldItems - Map of ContentVersion.Trigger.old
   */     
    public void beforeUpdate(Map<Id,SObject> newItems, Map<Id,SObject> oldItems) {
        updateProposalTitle((List<ContentVersion>)newItems.values(), (Map<Id,ContentVersion>)oldItems);   
    }
    
      /**
   * @description update new and old Proposal title
   * @param newList - List of ContentVersion.Trigger.new
   * @param oldMap - Map of ContentVersion.Trigger.old
   */    
    public void updateProposalTitle(List<ContentVersion> newList, Map<Id,ContentVersion> oldMap){
        try{
            for(ContentVersion contentVersions : newList){
                if(contentVersions.Title != null && contentVersions.Title.startsWith('Proposal') && (oldMap == null || contentVersions.Title != oldMap.get(contentVersions.Id).Title)){
                    contentVersions.Title = contentVersions.Title.substring(0, Math.min(contentVersions.Title.length(), 80));
                }  
            }
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Error on DocuSignContentVersionTriggerHandler.UpdateProposalTitle'); //NOPMD
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
}