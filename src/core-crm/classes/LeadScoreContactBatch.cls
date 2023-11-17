
/**
  * @description Chained Batch job from LeadScoreConfigRecalculationBatch to recalculate lead score for Contact related records.
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 07, 2023     | DEPP-7155              | Created file to handle lead score calculation  |
  */

public with sharing class LeadScoreContactBatch implements Database.Batchable<sObject>, Database.Stateful{

    private Set<Id> contactIdSet;

    public void recalculateLeadScore(Set<Id> contactIdSet){
        this.contactIdSet = contactIdSet;
        Database.executeBatch(this);
    }

    /**
    * @description Retrieves Contact records associated from the lead score detail
    * @param bc - BatchableContext
    * @return query - filtered query of Contact records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){        
        return ContactsDAO.newInstance().queryLocatorGetContactsByIds(contactIdSet);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of Contact
    */
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        try{ 
            LeadScoreCalculatorService.ObjectMap objMap = ContactLeadScoreHelper.setObjectMap(new Map<Id, Contact>(contactList));
            if(!contactList.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactIdSet, Contact.getSObjectType());
            }  
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreContactBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}