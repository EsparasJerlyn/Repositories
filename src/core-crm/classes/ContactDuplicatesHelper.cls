/**
 * @description Helper class for detecting and handling duplicates for Contacts
 * 
 * @see ContactTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
 *    |---------------------------|-----------------------|----------------------|------------------------------------------|
 *    | angelika.j.s.galang       | May 17, 2022          | DEPP-1455            | Created File                        | 
 *    | alexander.cadalin         | June 22, 2022         | DEPP-3056            | Appended detectDuplicateInEmails    |
 *    | alexander.cadalin         | July 30, 2022         | DEPP-3623            | Included within batch duplicate checking |
 */
public without sharing class ContactDuplicatesHelper {
    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
    private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RT_CONTACT_PERSON).getRecordTypeId();
    
    /**
     * @description Detects if emails used in inserted or updated contacts are 
     *              used in other existing records within the entire organization.
     * @param newItems - list inserted or updated contacts
     */
    public static void detectDuplicatesInEmails(List<Contact> newItems, Map<Id, Contact> oldItems) {
        Set<String> allEmailsToMatch = new Set<String>();
        Map<Id, Contact> newContacts = new Map<Id, Contact>();
        Map<String, Integer> newItemsEmailCount = new Map<String, Integer>();

        for(Contact con : newItems) {
            if(oldItems != null){
                Contact oldCon = oldItems.get(con.Id);
                if(
                    oldCon.Email == con.Email &&
                    oldCon.QUT_Learner_Email__c == con.QUT_Learner_Email__c &&
                    oldCon.QUT_Staff_Email__c == con.QUT_Staff_Email__c &&
                    oldCon.Work_Email__c == con.Work_Email__c
                ) { continue; }
            }
            
            if(con.RecordTypeId == RT_CONTACT_PERSON_ID){
                if(String.isNotBlank(con.Email)) {
                    allEmailsToMatch.add(con.Email);
                    if(newItemsEmailCount.containsKey(con.Email)) {
                        newItemsEmailCount.put(con.Email, newItemsEmailCount.get(con.Email) + 1);
                    } else {
                        newItemsEmailCount.put(con.Email, 1);
                	}
                }
                if(String.isNotBlank(con.QUT_Learner_Email__c)) {
                    allEmailsToMatch.add(con.QUT_Learner_Email__c);
                    if(newItemsEmailCount.containsKey(con.QUT_Learner_Email__c)) {
                        newItemsEmailCount.put(con.QUT_Learner_Email__c, newItemsEmailCount.get(con.QUT_Learner_Email__c) + 1);
                    } else {
                        newItemsEmailCount.put(con.QUT_Learner_Email__c, 1);
                    }
                }
                if(String.isNotBlank(con.QUT_Staff_Email__c)) {
                    allEmailsToMatch.add(con.QUT_Staff_Email__c);
                    if(newItemsEmailCount.containsKey(con.QUT_Staff_Email__c)) {
                        newItemsEmailCount.put(con.QUT_Staff_Email__c, newItemsEmailCount.get(con.QUT_Staff_Email__c) + 1);
                    } else {
                        newItemsEmailCount.put(con.QUT_Staff_Email__c, 1);
                	}
                }
                if(String.isNotBlank(con.Work_Email__c)) {
                    allEmailsToMatch.add(con.Work_Email__c);
                    if(newItemsEmailCount.containsKey(con.Work_Email__c)) {
                        newItemsEmailCount.put(con.Work_Email__c, newItemsEmailCount.get(con.Work_Email__c) + 1);
                    } else {
                        newItemsEmailCount.put(con.Work_Email__c, 1);
                	}
                }
                if(String.isNotBlank(con.Id)) { newContacts.put(con.Id, con); }
            }
        }
        
        List<Contact> existingContactsWithMatchingEmails = new List<Contact>(
            [
                SELECT 
                    Id, Email, 
                    QUT_Learner_Email__c, 
                    QUT_Staff_Email__c,
                    Work_Email__c
                FROM Contact
                WHERE
                	Id NOT IN :newContacts.keySet()
                    AND RecordTypeId = :RT_CONTACT_PERSON_ID
                    AND Parent_Person_Contact__c = null
                    AND (
                        Email IN :allEmailsToMatch
                        OR QUT_Learner_Email__c IN :allEmailsToMatch
                        OR QUT_Staff_Email__c IN :allEmailsToMatch
                        OR Work_Email__c IN :allEmailsToMatch
                    )
            ]
        );
        
        if(!existingContactsWithMatchingEmails.isEmpty()) {
            for(Contact newCon : (oldItems == null ? newItems : newContacts.values())) {
                if(newCon.RecordTypeId == RT_CONTACT_PERSON_ID){
                    // Within batch checking
                    if(newItemsEmailCount?.get(newCon.Email) > 1) {
                        newCon.addError('Email', 'Email must be unique across the organization and this batch.');
                    }
                    if(newItemsEmailCount?.get(newCon.QUT_Learner_Email__c) > 1) {
                        newCon.addError('QUT_Learner_Email__c', 'Work Email must be unique across the organization and this batch.');
                    }
                    if(newItemsEmailCount?.get(newCon.QUT_Staff_Email__c) > 1) {
                        newCon.addError('QUT_Staff_Email__c', 'Work Email must be unique across the organization and this batch.');
                    }
                    if(newItemsEmailCount?.get(newCon.Work_Email__c) > 1) {
                        newCon.addError('Work_Email__c', 'Work Email must be unique across the organization and this batch.');
                    }
                    // Within organization checking
                    for(Contact existingCon : existingContactsWithMatchingEmails) {
                        if(
                            String.isNotBlank(newCon.Email) &&
                            (
                                (existingCon.Email)?.toLowerCase() == newCon.Email.toLowerCase() ||
                                (existingCon.QUT_Learner_Email__c)?.toLowerCase() == newCon.Email.toLowerCase() ||
                                (existingCon.QUT_Staff_Email__c)?.toLowerCase() == newCon.Email.toLowerCase() ||
                                (existingCon.Work_Email__c)?.toLowerCase() == newCon.Email.toLowerCase()
                            )
                        ) {
                            newCon.addError('Email', 'Email must be unique across the organization.');
                        }
                        if(
                            String.isNotBlank(newCon.QUT_Learner_Email__c) &&
                            (
                                (existingCon.Email)?.toLowerCase() == newCon.QUT_Learner_Email__c.toLowerCase() ||
                                (existingCon.QUT_Learner_Email__c)?.toLowerCase() == newCon.QUT_Learner_Email__c.toLowerCase() ||
                                (existingCon.QUT_Staff_Email__c)?.toLowerCase() == newCon.QUT_Learner_Email__c.toLowerCase() ||
                                (existingCon.Work_Email__c)?.toLowerCase() == newCon.QUT_Learner_Email__c.toLowerCase()
                            )
                        ) {
                            newCon.addError('QUT_Learner_Email__c', 'Student Email must be unique across the organization.');
                        }
                        if(
                            String.isNotBlank(newCon.QUT_Staff_Email__c) &&
                            (
                                (existingCon.Email)?.toLowerCase() == newCon.QUT_Staff_Email__c.toLowerCase() ||
                                (existingCon.QUT_Learner_Email__c)?.toLowerCase() == newCon.QUT_Staff_Email__c.toLowerCase() ||
                                (existingCon.QUT_Staff_Email__c)?.toLowerCase() == newCon.QUT_Staff_Email__c.toLowerCase() ||
                                (existingCon.Work_Email__c)?.toLowerCase() == newCon.QUT_Staff_Email__c.toLowerCase()
                            )
                        ) {
                            newCon.addError('QUT_Staff_Email__c', 'Staff Email must be unique across the organization.');
                        }
                        if(
                            String.isNotBlank(newCon.Work_Email__c) &&
                            (
                                (existingCon.Email)?.toLowerCase() == newCon.Work_Email__c.toLowerCase() ||
                                (existingCon.QUT_Learner_Email__c)?.toLowerCase() == newCon.Work_Email__c.toLowerCase() ||
                                (existingCon.QUT_Staff_Email__c)?.toLowerCase() == newCon.Work_Email__c.toLowerCase() ||
                                (existingCon.Work_Email__c)?.toLowerCase() == newCon.Work_Email__c.toLowerCase()
                            )
                        ) {
                            newCon.addError('Work_Email__c', 'Work Email must be unique across the organization.');
                        }
                    }
                }
            }
        }
    }

    /**
     * @description detects exact and partial duplicates of contact records
    * @param newItems - map of newly inserted contacts
    */
    
    // public static void detectDuplicates(Map<Id,Contact> newItems){
    //     //map containing filtered main Person contacts
    //     Map<Id,Contact> newContacts = new Map<Id,Contact>();

    //     List<Date> birthdatesToMatch = new List<Date>();
    //     List<String> emailsToMatch = new List<String>();
    //     List<String> lastNamesToMatch = new List<String>();
    //     List<String> firstNamesToMatch = new List<String>();
    //     List<String> studentIdsToMatch = new List <String>();
    //     List<String> employeeIdsToMatch = new List<String>();
    //     //collect values for soql matching
    //     for(Contact con : newItems.values()){
    //         if(con.RecordTypeId == RT_CONTACT_PERSON_ID && String.isBlank(con.Parent_Person_Contact__c)){
    //             if(con.Birthdate != null){birthdatesToMatch.add(con.Birthdate);}
    //             if(String.isNotBlank(con.Email)){emailsToMatch.add(con.Email);}
    //             if(String.isNotBlank(con.LastName)){lastNamesToMatch.add(con.LastName);}
    //             if(String.isNotBlank(con.FirstName)){firstNamesToMatch.add(con.FirstName);}
    //             if(String.isNotBlank(con.QUT_Student_ID__c)){studentIdsToMatch.add(con.QUT_Student_ID__c);}
    //             if(String.isNotBlank(con.QUT_Employee_ID__c)){employeeIdsToMatch.add(con.QUT_Employee_ID__c);}

    //             newContacts.put(con.Id, con);
    //         }
    //     }

    //     List<Potential_Duplicate__c> potentialDuplicatesToInsert = new List<Potential_Duplicate__c>();

    //     /* ---------- EXACT MATCH (Start) ---------- */
    //     List<Contact> existingContactsExact = new List<Contact>(
    //         [
    //             SELECT Id,
    //                 Birthdate, 
    //                 Email, Work_Email__c, QUT_Learner_Email__c, QUT_Staff_Email__c, 
    //                 LastName
    //             FROM Contact
    //             WHERE Id NOT IN :newContacts.keySet()
    //             AND RecordTypeId = :RT_CONTACT_PERSON_ID
    //             AND Parent_Person_Contact__c = null
    //             AND Birthdate IN :birthdatesToMatch
    //             AND 
    //             (
    //                 Email IN :emailsToMatch OR
    //                 Work_Email__c IN :emailsToMatch OR
    //                 QUT_Learner_Email__c IN :emailsToMatch OR
    //                 QUT_Staff_Email__c IN :emailsToMatch
    //             )
    //             AND LastName IN :lastNamesToMatch
    //         ]
    //     );
        
    //     Map<Id,List<Id>> exactMatchContacts = new Map<Id,List<Id>>();
    //     if(!existingContactsExact.isEmpty()){
    //         for(Contact newCon : newContacts.values()){
    //             for(Contact existingCon : existingContactsExact){
    //                 if(
    //                     (
    //                         newCon.Birthdate != null && 
    //                         existingCon.Birthdate == newCon.Birthdate
    //                     ) &&
    //                     (
    //                         String.isNotBlank(newCon.Email) &&
    //                         (
    //                             (existingCon.Email)?.toLowerCase() == newCon.Email.toLowerCase() ||
    //                             (existingCon.Work_Email__c)?.toLowerCase() == newCon.Email.toLowerCase() ||
    //                             (existingCon.QUT_Learner_Email__c)?.toLowerCase() == newCon.Email.toLowerCase() ||
    //                             (existingCon.QUT_Staff_Email__c)?.toLowerCase() == newCon.Email.toLowerCase() 
    //                         )
    //                     ) &&
    //                     existingCon.LastName.toLowerCase() == newCon.LastName.toLowerCase()
    //                 ){
    //                     if(!exactMatchContacts.containsKey(newCon.Id)){
    //                         exactMatchContacts.put(newCon.Id,new List<Id>{existingCon.Id});
    //                     }else{
    //                         exactMatchContacts.get(newCon.Id).add(existingCon.Id);
    //                     }
    //                 }
    //             }
    //         }
    //         Map<Id,List<Id>> potentialDuplicatesExact = new Map<Id,List<Id>>();
    //         for(Id newConId : exactMatchContacts.keySet()){
    //             //add error to records with exactly 1 match
    //             if(exactMatchContacts.get(newConId).size() == 1){
    //                 newContacts.get(newConId).addError('Duplicate contact found: ' + exactMatchContacts.get(newConId)[0]);
    //             //create potential duplicates for more than 1 match
    //             }else if(exactMatchContacts.get(newConId).size() > 1){
    //                 potentialDuplicatesExact.put(newConId,exactMatchContacts.get(newConId));
    //             }
    //         }
    //         if(!potentialDuplicatesExact.isEmpty()){
    //             potentialDuplicatesToInsert.addAll(createPotentialDuplicates(potentialDuplicatesExact));
    //         }
    //     }

    //     /* ---------- EXACT MATCH (End) ---------- */

    //     /* ---------- PARTIAL MATCH (Start) ---------- */

    //     List<Contact> existingContactsPartial = new List<Contact>(
    //         [
    //             SELECT Id, 
    //                 Email, Work_Email__c, QUT_Learner_Email__c, QUT_Staff_Email__c, 
    //                 LastName,
    //                 Birthdate,
    //                 FirstName,
    //                 QUT_Student_ID__c,
    //                 QUT_Employee_ID__c
    //             FROM Contact
    //             WHERE Id NOT IN :newContacts.keySet()
    //             AND RecordTypeId = :RT_CONTACT_PERSON_ID
    //             AND Parent_Person_Contact__c = null
    //             AND 
    //             (
    //                 Email IN :emailsToMatch OR
    //                 Work_Email__c IN :emailsToMatch OR
    //                 QUT_Learner_Email__c IN :emailsToMatch OR
    //                 QUT_Staff_Email__c IN :emailsToMatch
    //             )
    //             AND 
    //             (
    //                 LastName IN :lastNamesToMatch OR
    //                 Birthdate IN :birthdatesToMatch OR
    //                 FirstName IN :firstNamesToMatch OR
    //                 QUT_Student_ID__c IN :studentIdsToMatch OR
    //                 QUT_Employee_ID__c IN :employeeIdsToMatch
    //             )
    //         ]
    //     );
        
    //     Map<Id,List<Id>> potentialDuplicatesPartial = new Map<Id,List<Id>>();
    //     if(!existingContactsPartial.isEmpty()){
    //         for(Contact newCon : newContacts.values()){
    //             //check if new contact has not been exact matched
    //             if(!exactMatchContacts.keySet().contains(newCon.Id)){
    //                 for(Contact existingCon : existingContactsPartial){
    //                     if(
    //                         (
    //                             String.isNotBlank(newCon.Email) &&
    //                             (
    //                                 (existingCon.Email)?.toLowerCase() == newCon.Email.toLowerCase() ||
    //                                 (existingCon.Work_Email__c)?.toLowerCase() == newCon.Email.toLowerCase() ||
    //                                 (existingCon.QUT_Learner_Email__c)?.toLowerCase() == newCon.Email.toLowerCase() ||
    //                                 (existingCon.QUT_Staff_Email__c)?.toLowerCase() == newCon.Email.toLowerCase() 
    //                             )
    //                         ) &&
    //                         (
    //                             existingCon.LastName.toLowerCase() == newCon.LastName.toLowerCase() ||
    //                             (
    //                                 newCon.Birthdate != null &&
    //                                 existingCon.Birthdate == newCon.Birthdate
    //                             ) ||
    //                             (
    //                                 String.isNotBlank(newCon.FirstName) &&
    //                                 (existingCon.FirstName)?.toLowerCase() == newCon.FirstName.toLowerCase()
    //                             ) ||
    //                             (
    //                                 String.isNotBlank(newCon.QUT_Student_ID__c) &&
    //                                 (existingCon.QUT_Student_ID__c)?.toLowerCase() == newCon.QUT_Student_ID__c.toLowerCase()
    //                             ) ||
    //                             (
    //                                 String.isNotBlank(newCon.QUT_Employee_ID__c) &&
    //                                 (existingCon.QUT_Employee_ID__c)?.toLowerCase() == newCon.QUT_Employee_ID__c.toLowerCase() 
    //                             )
    //                         )
    //                     ){
    //                         if(!potentialDuplicatesPartial.containsKey(newCon.Id)){
    //                             potentialDuplicatesPartial.put(newCon.Id,new List<Id>{existingCon.Id});
    //                         }else{
    //                             potentialDuplicatesPartial.get(newCon.Id).add(existingCon.Id);
    //                         }
    //                     }
    //                 }
    //             }
    //         }

    //         if(!potentialDuplicatesPartial.isEmpty()){
    //             potentialDuplicatesToInsert.addAll(createPotentialDuplicates(potentialDuplicatesPartial));
    //         }
    //     }
    //     /* ---------- PARTIAL MATCH (End) ---------- */

    //     if(!potentialDuplicatesToInsert.isEmpty()){
    //         insert potentialDuplicatesToInsert;
    //     }
    // }
    

    // /**
    //  * @description creates Potential Duplicate records
    // * @param potentialDuplicates - map of new contact Id's and list of existing partial matched contact Id's
    // * @return dupes - list of potential duplicate records for contacts
    // */
    // private static List<Potential_Duplicate__c> createPotentialDuplicates(Map<Id,List<Id>> potentialDuplicates){
    //     List<Potential_Duplicate__c> dupes = new List<Potential_Duplicate__c>();
    //     for(Id newConId : potentialDuplicates.keySet()){
    //         for(Id existingConId : potentialDuplicates.get(newConId)){
    //             dupes.add(
    //                 new Potential_Duplicate__c(
    //                     Contact__c = existingConId,
    //                     Duplicate_Contact__c = newConId
    //                 )
    //             );
    //         }
    //     }
    //     return dupes;
    // }

}