/**
 * @description helper class for lead with lead score detail trigger handler.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | August 31, 2023       |DEPP-5965               | Created File                        |
 */
public with sharing class LeadWithLeadScoreDetails {
    /**
     * @description creating Lead Score Detail to converted lead's contact
     * @param newItems - list inserted or updated leads
     * * @param oldItems - list inserted or updated leads
     */
    public static void createLeadScoreDetailToContact(Map<Id,Lead> newItems, Map<Id, Lead> oldItems) {
        List<Lead_Score_Detail__c> leadScoreDetailToInsert = new List<Lead_Score_Detail__c>();
        Set<Id> convertedContactIds = new Set<Id>();
        //Create Lead Score Detail record for the Contact converted
        for(Lead lead:newItems.values()){
            if( oldItems.get(lead.Id).IsConverted != lead.IsConverted && 
                lead.IsConverted == true && lead.ConvertedContactId != null){
                    leadScoreDetailToInsert.add(
                        new Lead_Score_Detail__c(  
                            Contact__c = lead.ConvertedContactId
                        )
                    );
                    convertedContactIds.add(lead.ConvertedContactId);
            }
        }
        if(!leadScoreDetailToInsert.isEmpty()){
            LeadScoreDetailsDAO.newInstance().insertRecords(leadScoreDetailToInsert, false, AccessLevel.SYSTEM_MODE);
        }
        updateConvertedContact(convertedContactIds);
    }
    /**
     * @description updating new Contact from a converted Lead
     * @param convertedContactIds - set of converted Contact Ids
     */
    @Future
    public static void updateConvertedContact(Set<Id> convertedContactIds){
        List<Contact> contactList = ContactsDAO.newInstance().getContactsFromConvertedLead(convertedContactIds, 'USER_MODE');
        List<Lead_Score_Detail__c> leadScoreDetailList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailByContactSetIds(convertedContactIds, 'USER_MODE');
        Map<Id, Id> leadScoreDetaildMap = new Map<Id, Id>();
        List<Contact> contactToUpdate = new List<Contact>();
        for(Lead_Score_Detail__c lsd: leadScoreDetailList){
            leadScoreDetaildMap.put(lsd.Contact__c, lsd.Id);
        }
        //Update Contact to get the newly created Lead Score Detail
        for(Contact contacts: contactList){
            if(leadScoreDetaildMap.containsKey(contacts.Id)){
                contacts.Lead_Score_Detail__c = leadScoreDetaildMap.get(contacts.Id);
                contactToUpdate.add(contacts);
            }
        }
        if(!contactToUpdate.isEmpty()){
            ContactsDAO.newInstance().updateRecords(contactToUpdate, false, AccessLevel.USER_MODE);
        }
    }
}
