/**
 * @description Helper class for detecting and handling duplicates for Leads
 * 
 * @see LeadTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
      |---------------------------|-----------------------|----------------------|-------------------------------------|
      | angelika.j.s.galang       | May 17, 2022          | DEPP-1455            | Created File                        | 
 */
public without sharing class LeadDuplicatesHelper {
    
    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
    private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RT_CONTACT_PERSON).getRecordTypeId();

    /**
     * @description detects exact and partial duplicates of lead records
    * @param newItems - map of newly inserted leads
    */
    public static void detectDuplicates(Map<Id,Lead> newLeads){
        List<String> firstNamesToMatch = new List<String>();
        List<String> emailsToMatch = new List<String>();
        List<String> lastNamesToMatch = new List<String>();
        //collect values for soql matching
        for(Lead ld : newLeads.values()){
            if(String.isNotBlank(ld.FirstName)){firstNamesToMatch.add(ld.FirstName);}
            if(String.isNotBlank(ld.Email)){emailsToMatch.add(ld.Email);}
            if(String.isNotBlank(ld.LastName)){lastNamesToMatch.add(ld.LastName);}
        }

        List<Potential_Duplicate__c> potentialDuplicatesToInsert = new List<Potential_Duplicate__c>();

        /* ---------- EXACT MATCH (Start) ---------- */
        //LEAD TO LEAD
        List<Lead> existingLeadsExact = new List<Lead>(
            [
                SELECT Id,
                    FirstName, 
                    Email, Work_Email__c, 
                    LastName
                FROM Lead
                WHERE Id NOT IN :newLeads.keySet()
                AND FirstName IN :firstNamesToMatch
                AND 
                (
                    Email IN :emailsToMatch OR
                    Work_Email__c IN :emailsToMatch
                )
                AND LastName IN :lastNamesToMatch
            ]
        );
        
        Map<Id,List<Id>> exactMatchLeads = new Map<Id,List<Id>>();
        if(!existingLeadsExact.isEmpty()){
            for(Lead newLead : newLeads.values()){
                for(Lead existingLead : existingLeadsExact){
                    if(
                        (
                            String.isNotBlank(newLead.FirstName) &&
                            (existingLead.FirstName)?.toLowerCase() == newLead.FirstName.toLowerCase()
                        ) &&
                        (
                            String.isNotBlank(newLead.Email) &&
                            (
                                existingLead.Email.toLowerCase() == newLead.Email.toLowerCase() ||
                                (existingLead.Work_Email__c)?.toLowerCase() == newLead.Email.toLowerCase()
                            )
                        ) &&
                        existingLead.LastName.toLowerCase() == newLead.LastName.toLowerCase()
                    ){
                        if(!exactMatchLeads.containsKey(newLead.Id)){
                            exactMatchLeads.put(newLead.Id,new List<Id>{existingLead.Id});
                        }else{
                            exactMatchLeads.get(newLead.Id).add(existingLead.Id);
                        }
                    }
                }
            }
            Map<Id,List<Id>> potentialDuplicatesExactLeads = new Map<Id,List<Id>>();
            for(Id newLeadId : exactMatchLeads.keySet()){
                //add error to records with exactly 1 match
                if(exactMatchLeads.get(newLeadId).size() == 1){
                    newLeads.get(newLeadId).addError('Duplicate lead found: ' + exactMatchLeads.get(newLeadId)[0]);
                //create potential duplicates for more than 1 match
                }else if(exactMatchLeads.get(newLeadId).size() > 1){
                    potentialDuplicatesExactLeads.put(newLeadId,exactMatchLeads.get(newLeadId));
                }
            }
            if(!potentialDuplicatesExactLeads.isEmpty()){
                potentialDuplicatesToInsert.addAll(createPotentialDuplicates(potentialDuplicatesExactLeads,false));
            }
        }

        //LEAD TO CONTACT
        List<Contact> existingContactsExact = new List<Contact>(
            [
                SELECT Id,
                    FirstName, 
                    Email, hed__WorkEmail__c, 
                    LastName
                FROM Contact
                WHERE RecordTypeId = :RT_CONTACT_PERSON_ID
                AND Parent_Person_Contact__c = null
                AND FirstName IN :firstNamesToMatch
                AND 
                (
                    Email IN :emailsToMatch OR
                    hed__WorkEmail__c IN :emailsToMatch
                )
                AND LastName IN :lastNamesToMatch
            ]
        );

        Map<Id,List<Id>> exactMatchContacts = new Map<Id,List<Id>>();
        if(!existingContactsExact.isEmpty()){
            for(Lead newLead : newLeads.values()){
                for(Contact existingCon : existingContactsExact){
                    if(
                        (
                            String.isNotBlank(newLead.FirstName) &&
                            (existingCon.FirstName)?.toLowerCase() == newLead.FirstName.toLowerCase()
                        ) &&
                        (
                            String.isNotBlank(newLead.Email) &&
                            (
                                (existingCon.Email)?.toLowerCase() == newLead.Email.toLowerCase() ||
                                (existingCon.hed__WorkEmail__c)?.toLowerCase() == newLead.Email.toLowerCase()
                            )
                        ) &&
                        existingCon.LastName.toLowerCase() == newLead.LastName.toLowerCase()
                    ){
                        if(!exactMatchContacts.containsKey(newLead.Id)){
                            exactMatchContacts.put(newLead.Id,new List<Id>{existingCon.Id});
                        }else{
                            exactMatchContacts.get(newLead.Id).add(existingCon.Id);
                        }
                    }
                }
            }
            Map<Id,List<Id>> potentialDuplicatesExactContacts = new Map<Id,List<Id>>();
            for(Id newLeadId : exactMatchContacts.keySet()){
                //add error to records with exactly 1 match
                if(exactMatchContacts.get(newLeadId).size() == 1){
                    newLeads.get(newLeadId).addError('Duplicate contact found: ' + exactMatchContacts.get(newLeadId)[0]);
                //create potential duplicates for more than 1 match
                }else if(exactMatchContacts.get(newLeadId).size() > 1){
                    potentialDuplicatesExactContacts.put(newLeadId,exactMatchContacts.get(newLeadId));
                }
            }
            if(!potentialDuplicatesExactContacts.isEmpty()){
                potentialDuplicatesToInsert.addAll(createPotentialDuplicates(potentialDuplicatesExactContacts,true));
            }
        }
        /* ---------- EXACT MATCH (End) ---------- */

        /* ---------- PARTIAL MATCH (Start) ---------- */
        //LEAD TO CONTACT
        List<Contact> existingContactsPartial = new List<Contact>(
            [
                SELECT Id, 
                    Email, hed__WorkEmail__c, QUT_Learner_Email__c, QUT_Staff_Email__c, 
                    LastName,
                    FirstName
                FROM Contact
                WHERE RecordTypeId = :RT_CONTACT_PERSON_ID
                AND Parent_Person_Contact__c = null
                AND 
                (
                    Email IN :emailsToMatch OR
                    hed__WorkEmail__c IN :emailsToMatch OR
                    QUT_Learner_Email__c IN :emailsToMatch OR
                    QUT_Staff_Email__c IN :emailsToMatch
                )
                AND 
                (
                    LastName IN :lastNamesToMatch OR
                    FirstName IN :firstNamesToMatch
                )
            ]
        );
        
        Map<Id,List<Id>> potentialDuplicatesPartial = new Map<Id,List<Id>>();
        if(!existingContactsPartial.isEmpty()){
            for(Lead newLead : newLeads.values()){
                //check if new lead has not been exact matched
                if(!exactMatchLeads.keySet().contains(newLead.Id) && !exactMatchContacts.keySet().contains(newLead.Id)){
                    for(Contact existingCon : existingContactsPartial){
                        if(
                            (
                                String.isNotBlank(newLead.Email) &&
                                (
                                    (existingCon.Email)?.toLowerCase() == newLead.Email.toLowerCase() ||
                                    (existingCon.hed__WorkEmail__c)?.toLowerCase() == newLead.Email.toLowerCase() ||
                                    (existingCon.QUT_Learner_Email__c)?.toLowerCase() == newLead.Email.toLowerCase() ||
                                    (existingCon.QUT_Staff_Email__c)?.toLowerCase() == newLead.Email.toLowerCase()
                                ) 
                            ) &&
                            (
                                existingCon.LastName.toLowerCase() == newLead.LastName.toLowerCase() ||
                                (
                                    String.isNotBlank(newLead.FirstName) &&
                                    (existingCon.FirstName)?.toLowerCase() == newLead.FirstName.toLowerCase()
                                ) 
                            )
                        ){
                            if(!potentialDuplicatesPartial.containsKey(newLead.Id)){
                                potentialDuplicatesPartial.put(newLead.Id,new List<Id>{existingCon.Id});
                            }else{
                                potentialDuplicatesPartial.get(newLead.Id).add(existingCon.Id);
                            }
                        }
                    }
                }
            }

            if(!potentialDuplicatesPartial.isEmpty()){
                potentialDuplicatesToInsert.addAll(createPotentialDuplicates(potentialDuplicatesPartial,true));
            }
        }
        /* ---------- PARTIAL MATCH (End) ---------- */

        if(!potentialDuplicatesToInsert.isEmpty()){
            insert potentialDuplicatesToInsert;
        }
    }

    /**
     * @description creates Potential Duplicate records
    * @param potentialDuplicates - map of new contact Id's and list of existing partial matched contact Id's
    * @param leadToContact - boolean to determine whether the potential duplicate is for lead-lead or lead-contact matching
    * @return dupes - list of potential duplicate records for leads
    */
    private static List<Potential_Duplicate__c> createPotentialDuplicates(Map<Id,List<Id>> potentialDuplicates,Boolean leadToContact){
        List<Potential_Duplicate__c> dupes = new List<Potential_Duplicate__c>();
        for(Id newLeadId : potentialDuplicates.keySet()){
            for(Id existingRecordId : potentialDuplicates.get(newLeadId)){
                if(leadToContact){
                    dupes.add(
                        new Potential_Duplicate__c(
                            Contact__c = existingRecordId,
                            Duplicate_Lead__c = newLeadId
                        )
                    );
                }else{
                    dupes.add(
                        new Potential_Duplicate__c(
                            Lead__c = existingRecordId,
                            Duplicate_Lead__c = newLeadId
                        )
                    );
                }
            }
        }
        return dupes;
    }

}
