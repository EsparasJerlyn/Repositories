/**
 * @description helper for LeadScoreDetailTriggerHandler
 * @see LeadScoreDetailTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | julie.jane.alegre              | Sept 07, 2023         | DEPP-5965              | Created file                                     |
 */
public with sharing class LeadScoreDetailTriggerHelper {
    /**
     * @description process records to be set as current preference
     * @param newItems - List of Lead_Score_Detail__c new records
     * @param oldItems - Map<Id, Lead_Score_Detail__c> old records map
     */
    public static void linkLeadScoreDetailToContact(Map<Id, Lead_Score_Detail__c> newItems){
        Map<Id,Id> leadScoreDetailMap = new Map<Id,Id>();
        List<Contact> contactToUpdate = new List<Contact>();
        //Get contact id link to the newly created lead score detail
        for(Lead_Score_Detail__c leadScoreDetail:newItems.values()){
            if( leadScoreDetail.Contact__c != null ){
                leadScoreDetailMap.put(leadScoreDetail.Contact__c, leadScoreDetail.Id);
            }
        }
        List<Contact> contactList = ContactsDAO.newInstance().getContactsFromConvertedLead(leadScoreDetailMap.keySet(), 'SYSTEM_MODE');

        for(Contact contacts: contactList){
            if(leadScoreDetailMap.containsKey(contacts.Id)){
                contacts.Lead_Score_Detail__c = leadScoreDetailMap.get(contacts.Id);
                contactToUpdate.add(contacts);
            }
        }
        if(!contactToUpdate.isEmpty()){
            ContactsDAO.newInstance().updateRecords(contactToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
    }
}
