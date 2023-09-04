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
     */
    public static void createLeadScoreDetailToContact(Map<Id,Lead> newItems, Map<Id, Lead> oldItems) {
        List<Lead_Score_Detail__c> leadScoreDetailToInsert = new List<Lead_Score_Detail__c>();
        List<Contact> contactConverted = new Lis<Contact>();
        Set<Id> contactIDSet = new Set<Id>();
        //Create Lead Score Detail record for the Contact converted
        for(Lead lead:newItems.values()){
            if( oldItems.get(lead.Id).IsConverted != lead.IsConverted && 
                lead.IsConverted == true && lead.ConvertedContactId != null){
                    leadScoreDetailToInsert.add(
                        new Lead_Score_Detail__c(  
                            Contact__c = lead.ConvertedContactId
                        )
                    );
                    contactIDSet.add(lead.ConvertedContactId);
            }
        }
        if(!leadScoreDetailToInsert.isEmpty()){
            LeadScoreDetailsDAO.newInstance().insertRecords(leadScoreDetailToInsert, false, AccessLevel.USER_MODE);
        }
        contactConverted = ContactsDAO.newInstance().getContactsFromConvertedLead(contactIDSet, 'USER_MODE');

    }
    private static void updateConvertedContact(Set<Id> contactIDSet){
        Map<Id, Lead_Score_Detail__c> leadScoreDetailMap = new Map<Id, Lead_Score_Detail__c>();
        // List<Lead_Score_Detail__C>  
        
    }


}
