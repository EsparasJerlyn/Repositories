/**
 * @description helper class for lead with case trigger handler
 *
 * @see LeadWithCaseHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | Oct 17, 2022          | DEPP-4220    | Created file                                |
*/
public with sharing class LeadWithCaseHelper {
    /**
     * @description reparent case to converted lead's contact
     * @param newItems - list inserted or updated leads
     * @param oldItems - map old leads before update
     */
    public static void updateCaseParentToContact(Map<Id,Lead> newItems, Map<Id, Lead> oldItems) {
     
        List<Id> convertedLeads = new List<Id>();
        List<Case> caseToUpdate = new List<Case>();
        List<Case> relatedCases = new List<Case>();
        
        //check converted leads
        for(Lead lead:newItems.values()){
            if( oldItems.get(lead.Id).IsConverted != lead.IsConverted && 
                lead.IsConverted == true && lead.ConvertedContactId != null){
                    convertedLeads.add(lead.Id);
            }
        }

        if(!convertedLeads.isEmpty()){
            //get related cases
            relatedCases = [ 
                SELECT Id, Lead__c
                FROM Case
                WHERE Lead__c IN: convertedLeads];
        }
        
        if(!relatedCases.isEmpty()){
            for(Case c: relatedCases){
                //update the case's contactid
                //nullify case's lead
                caseToUpdate.add(
                    new Case(  
                        Id = c.Id, 
                        Lead__c = null, 
                        ContactId = newItems.get(c.Lead__c).ConvertedContactId
                    )
                );
            }
        }

        if(!caseToUpdate.isEmpty()){
            update caseToUpdate;
        }
    }
}