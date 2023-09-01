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
    public static void createLeadScoreDetailToContact(List<Contact> newContacts) {

        List<Lead_Score_Detail__c> leadScoreDetailToInsert = new List<Lead_Score_Detail__c>();

        for(Contact contacts: newContacts){
            if(contacts.Parent_Person_Lead__c != null && 
               contacts.Parent_Person_Lead__r.IsConverted  == true &&
               contacts.Id == contacts.Parent_Person_Lead__r.ConvertedContactId
            ){
                leadScoreDetailToInsert.add(
                    new Lead_Score_Detail__c(  
                        Contact__c = contacts.Id
                        )
                );
            }
        }
        if(!leadScoreDetailToInsert.isEmpty()){
            LeadScoreDetailsDAO.newInstance().insertRecords(leadScoreDetailToInsert, false, AccessLevel.USER_MODE);
        }

    }
}
