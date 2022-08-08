/**
 * @description Helper class for detecting and handling duplicates for Leads
 * 
 * @see LeadTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
      |---------------------------|-----------------------|------------|-------------------------------------|
      | angelika.j.s.galang       | May 17, 2022          | DEPP-1455            | Created File                        | 
	  | alexander.cadalin         | June 22, 2022         | DEPP-3056            | Appended detectDuplicatesInEmails   |
	  | alexander.cadalin         | July 29, 2022         | DEPP-3623  | Fixed issues with batch operations  |
 */
public without sharing class LeadDuplicatesHelper {
    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
    private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RT_CONTACT_PERSON).getRecordTypeId();

    /**
     * @description Detects if emails used in inserted or updated contacts are 
     *              used in other existing records within the entire organization
     *              including within the same batch in a batch operation.
     * @param newItems - list inserted or updated leads
     * @param oldItems - map old leads before update
     */
    public static void detectDuplicatesInEmails(List<Lead> newItems, Map<Id, Lead> oldItems) {
        Set<String> allEmailsToMatch = new Set<String>();
        Map<Id, Lead> newLeads = new Map<Id, Lead>();
        Map<String, Integer> newItemsEmailCount = new Map<String, Integer>();

        for(Lead ld : newItems) {
            if(oldItems != null) {
                Lead oldLd = oldItems.get(ld.Id);
                if(
                    oldLd.Email == ld.Email &&
                    oldLd.Work_Email__c == oldLd.Work_Email__c
                ) { continue; }
            }
            if(String.isNotBlank(ld.Email)) {
                allEmailsToMatch.add(ld.Email);
                if(newItemsEmailCount.containsKey(ld.Email)) {
                    newItemsEmailCount.put(ld.Email, newItemsEmailCount.get(ld.Email) + 1);
                } else {
                    newItemsEmailCount.put(ld.Email, 1);
                }
            }
            if(String.isNotBlank(ld.Work_Email__c)) {
                allEmailsToMatch.add(ld.Work_Email__c);
                if(newItemsEmailCount.containsKey(ld.Work_Email__c)) {
                    newItemsEmailCount.put(ld.Work_Email__c, newItemsEmailCount.get(ld.Work_Email__c) + 1);
                } else {
                    newItemsEmailCount.put(ld.Work_Email__c, 1);
                }
            }
            if(String.isNotBlank(ld.Id)) { newLeads.put(ld.Id, ld); }
        }
        
        List<Lead> existingLeadsWithMatchingEmails = new List<Lead>(
            [
                SELECT 
                    Id, Email, Work_Email__c, IsConverted
                FROM Lead
                WHERE
                	Id NOT IN :newLeads.keySet()
                    AND (
                        Email IN :allEmailsToMatch
                        OR Work_Email__c IN :allEmailsToMatch
                    )
                	AND IsConverted = false
            ]
        );
        
        if(!existingLeadsWithMatchingEmails.isEmpty() || !newItemsEmailCount.isEmpty()) {
            for(Lead newLd : (oldItems == null ? newItems : newLeads.values())) {
                // Within batch checking
                if(newItemsEmailCount?.get(newLd.Email) > 1) {
                    newLd.addError('Email', 'Email must be unique across the organization and this batch.');
                }
                if(newItemsEmailCount?.get(newLd.Work_Email__c) > 1) {
                    newLd.addError('Work_Email__c', 'Work Email must be unique across the organization and this batch.');
                }
                // Within organization checking
                for(Lead existingLd : existingLeadsWithMatchingEmails) {
                    if(
                        String.isNotBlank(newLd.Email) &&
                        (
                            (existingLd.Email)?.toLowerCase() == newLd.Email.toLowerCase() ||
                            (existingLd.Work_Email__c)?.toLowerCase() == newLd.Email.toLowerCase()
                        )
                    ) {
                        newLd.addError('Email', 'Email must be unique across the organization.');
                    }
                    if(
                        String.isNotBlank(newLd.Work_Email__c) &&
                        (
                            (existingLd.Email)?.toLowerCase() == newLd.Work_Email__c.toLowerCase() ||
                            (existingLd.Work_Email__c)?.toLowerCase() == newLd.Work_Email__c.toLowerCase()
                        )
                    ) {
                        newLd.addError('Work_Email__c', 'Work Email must be unique across the organization.');
                    }
                }
            }
        }
    }

}