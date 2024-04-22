/**
 * @description Service Class for Application Object use in trigger service class
 * 
 * @see ApplicationTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | mark.j.mahilum                 | June 19,2023          | DEPP-5846	            | Created File                  | 
 */
public without sharing class ApplicationServiceHelper {
    public static Map<String, Set<Id>>  mapOfContactIds;

    /**
     * Processes non-matching application records and performs necessary updates.
     *
     * @param newItems The list of hed__Application__c objects.
     * @return A list of updated hed__Application__c objects.
     */
    public static List<hed__Application__c> processNonMatchingContacts(List<hed__Application__c> newItems) {
        List<hed__Application__c> updateApplicationList = new List<hed__Application__c>();
        Map<String, hed__Application__c> newItemsapplication = new Map<String, hed__Application__c>();
        Set<String> applicationEmailsToMatch = new Set<String>();
        List<hed__Application__c> applicationStatusForLeadChecking = new List<hed__Application__c>();
        List<Lead> updateLeadRecords = new List<Lead>();
        
        for (hed__Application__c application : newItems) {
            Boolean isApplicationStatusNewUnsubmitted = application.Application_Status__c != null && (application.Application_Status__c == 'New' || application.Application_Status__c == 'Unsubmitted');
            
            if(isApplicationStatusNewUnsubmitted && application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID){
                if(application.Lead__c != null){
                    Lead lead = createLeadFromApplication(application);
                    lead.Id = application.Lead__c;
                    updateLeadRecords.add(lead);
                    continue;
                }
                applicationStatusForLeadChecking.add(application);
                applicationEmailsToMatch.add(application.Email__c);
                continue;
            }
            
            newItemsapplication.put(application.Email__c, application);          
        }
        
        updateApplicationList.addAll(checkForExistingDuplicateEmails(newItemsapplication));
        updateApplicationList.addAll(checkApplicationOnLeadRecords(applicationStatusForLeadChecking, applicationEmailsToMatch)); 
        
        LeadsDAO.newInstance().updateRecords(updateLeadRecords, false, AccessLevel.SYSTEM_MODE);
        
        return updateApplicationList;
    }

   /**
    * @description: Checks for existing duplicate emails in the given newItemsapplication map.
    * 				Creates contacts and performs necessary updates based on the matching logic.
    *
    * @param newItemsapplication A map of application IDs to hed__Application__c records
    */ 
    private static List<hed__Application__c> checkForExistingDuplicateEmails(Map<String, hed__Application__c> newItemsapplication) {
        List<Contact> conList = new List<Contact>();
        List<hed__Application__c>  updateApplicationList = new List<hed__Application__c>();
        List<Contact> existingContactsWithMatchingEmails = getContactsWithMatchingEmails(newItemsapplication.keySet());
        
        for (Contact con : existingContactsWithMatchingEmails) {
            if (hasMatchingEmail(con, newItemsapplication)) {
                hed__Application__c application = getMatchingApplication(con, newItemsapplication);
                mapOfContactIds.put(application.Id, new Set<Id>{ con.Id });
            }
        }
        
        for (hed__Application__c app : newItemsapplication.values()) {
            if (!mapOfContactIds.containsKey(app.Id)) {
                conList.add(createContactFromApplication(app));
            }
        }
        
        ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);
        updateApplicationList = updateApplicationApplicants(newItemsapplication, conList);
        
        return updateApplicationList;
    }
  
   /**
    * @description: Checks  if email contains in the map of newItemsApplication
    * @param Boolean return true if email is in the map else false
    */     
    private Static Boolean hasMatchingEmail(Contact con, Map<String, hed__Application__c> newItemsapplication) {
        return newItemsapplication.containsKey(con.Email) ||
               newItemsapplication.containsKey(con.QUT_Learner_Email__c) ||
               newItemsapplication.containsKey(con.QUT_Staff_Email__c) ||
               newItemsapplication.containsKey(con.Work_Email__c);
    }
    
   /**
    * @description: get the newItemsApplication details contains in the map
    * @param hed__Application__c return the matching application details
    */ 
    private static hed__Application__c getMatchingApplication(Contact con, Map<String, hed__Application__c> newItemsapplication) {
        if (newItemsapplication.containsKey(con.Email)) {
            return newItemsapplication.get(con.Email);
        }
        if (newItemsapplication.containsKey(con.QUT_Learner_Email__c)) {
            return newItemsapplication.get(con.QUT_Learner_Email__c);
        }
        if (newItemsapplication.containsKey(con.QUT_Staff_Email__c)) {
            return newItemsapplication.get(con.QUT_Staff_Email__c);
        }
        if (newItemsapplication.containsKey(con.Work_Email__c)) {
            return newItemsapplication.get(con.Work_Email__c);
        }
        return null;
    }
  
   /**
    * @description: Retrieves the list of Contacts with matching emails.
    * 
    * @param Set<String> email The email of the application records.
    * @return The list of Contacts with matching details.
    */     
    private static List<Contact> getContactsWithMatchingEmails(Set<String> emailsToMatch) {
        return ContactsDAO.newInstance()
            .getContactsWithMatchingEmails(
                emailsToMatch,
                'SYSTEM_MODE'
            );
    }

   /**
    * @description: mapping of application fields to contact
    * 
    * @param hed__Application__c   hed__Application__c objects.
    * @return Contact contact mapping details
    */      
    private static Contact createContactFromApplication(hed__Application__c application) {
        Contact contact = new Contact();
        contact.FirstName = application.FirstName__c;
        contact.MiddleName = application.MiddleName__c;
        contact.LastName = application.LastName__c;
        contact.Birthdate = application.BirthDate__c;
        contact.Email = application.Email__c;
        contact.MobilePhone = application.Mobile__c;
        contact.ATSI_Code__c = application.Indigenous_Status__c;
        contact.hed__Citizenship_Status__c = application.Citizenship_Status__c;
        contact.Citizenship_Country__c = application.Citizenship_Country__c;
        contact.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        return contact;
    }
    
   /**
    * @description: updateApplicationApplicants details to link the created contact
    * 
    * @param Map<String, hed__Application__c> map of application records to be updated
    * @param List<Contact> conList  a list of contact record that will be created.
    */       
    private static List<hed__Application__c> updateApplicationApplicants(Map<String, hed__Application__c> newItemsapplication, List<Contact> conList) {
        List<hed__Application__c> updateApplicationLink = new List<hed__Application__c>();
        
        for (Contact con : conList) {
            hed__Application__c applObject = new hed__Application__c();          
            hed__Application__c application = newItemsapplication.get(con.Email);
            applObject.Id = application.Id;
            applObject.hed__Applicant__c = con.Id;
                       
            updateApplicationLink.add(applObject);
        }
        
        return updateApplicationLink;
    }
    
   /**
    * @description: check an existing lead in the system with the application email
    * 
    * @param List<hed__Application__c> newItemsapplication 
    * @param Set<String> applicationEmailsToMatch
    */        
    private static List<hed__Application__c> checkApplicationOnLeadRecords(List<hed__Application__c> newItemsapplication, Set<String> applicationEmailsToMatch) {
        List<hed__Application__c> updateApplicationList = new List<hed__Application__c>();
        Map<String, Lead> newLeads = new Map<String, Lead>();
        Map<String, hed__Application__c> newMapApplication = new Map<String, hed__Application__c>();

        List<Lead> existingLeadsWithMatchingEmails = LeadsDAO.newInstance()
            .getExistingUnconvertedLeads(applicationEmailsToMatch, 'SYSTEM_MODE');

        Map<String, Lead> mapLeads = createLeadMapFromExistingLeads(existingLeadsWithMatchingEmails);

        for (hed__Application__c app : newItemsapplication) {
            if (mapLeads.containsKey(app.Email__c)) {
                hed__Application__c appNew = createApplicationWithLeadId(app, mapLeads.get(app.Email__c).Id);
                updateApplicationList.add(appNew);
            } else {
                Lead lead = createLeadFromApplication(app);
                newLeads.put(app.Email__c, lead);
                newMapApplication.put(app.Email__c, app);
            }
        }

        updateApplicationList.addAll(createNewLeadsAndApplications(newLeads, newMapApplication));
        return updateApplicationList;
    }
    
   /**
    * @description: get the existing lead and use email as a mapping key
    * 
    * @param List<Lead> leads existing leads 
    * @return Map<String, Lead> mapLeads
    */      
    private static Map<String, Lead> createLeadMapFromExistingLeads(List<Lead> leads) {
        Map<String, Lead> mapLeads = new Map<String, Lead>();
        for (Lead lead : leads) {
            if (lead.Email != null || lead.Work_Email__c != null) {
                String emailLead = (lead.Email != null)?lead.Email:lead.Work_Email__c;
                mapLeads.put(emailLead, lead);
            }
        }
        return mapLeads;
    }
    
   /**
    * @description: get the existing lead and use email as a mapping key
    * 
    * @param hed__Application__cleads new application mapping
    * @param Id leadId lead id to map
    * @return hed__Application__c application
    */   
    private static hed__Application__c createApplicationWithLeadId(hed__Application__c app, Id leadId) {
        hed__Application__c appNew = new hed__Application__c();
        appNew.Id = app.Id;
        appNew.Lead__c = leadId;
        return appNew;
    }
    
   /**
    * @description: map application details to lead fields
    * 
    * @param hed__Application__cleads new application mapping
    * @return lead object
    */      
    private static Lead createLeadFromApplication(hed__Application__c app) {
        Lead lead = new Lead();
        lead.FirstName = app.FirstName__c;
        lead.LastName = app.LastName__c;
        lead.Email = app.Email__c;
        lead.Mobile_No_Locale__c = app.Mobile__c;
        lead.Company = LeadsDAO.COMPANY_LEARNER;
        lead.Lead_Type__c = LeadsDAO.LEARNER_LEAD_TYPE;
        lead.Lead_Source_Category__c = LeadsDAO.LEAD_SOURCE_CATEGORY_STUDY_APPLICATION;
        lead.LeadSource = LeadsDAO.LEAD_SOURCE_STUDYLINK_STUDYLINK_UNSUBMITTED;
        return lead;
    }
    
   /**
    * @description: create a new lead record and update the application to link lead and application
    * 
    * @param Map<String, Lead> newLeads - new leads record to be created
    * @param Map<String, hed__Application__c> newMapApplication application record to be updated
    * @param List<hed__Application__c> updateApplicationList
    */   
    private static List<hed__Application__c> createNewLeadsAndApplications(
        Map<String, Lead> newLeads,
        Map<String, hed__Application__c> newMapApplication       
    ) {
        List<hed__Application__c> updateApplicationList = new List<hed__Application__c>();      
        LeadsDAO.newInstance().insertRecords(newLeads.values(), false, AccessLevel.SYSTEM_MODE);
        for (String key : newLeads.keySet()) {
            Lead newLead = newLeads.get(key);
            hed__Application__c app = newMapApplication.get(key);
            hed__Application__c updateApp = createApplicationWithLeadId(app, newLead.Id);
            updateApplicationList.add(updateApp);
        }
        
        return updateApplicationList;
    }
    
        
   /**
    * @description: Adds a contact to the contacts map for the specified identifier.
    *
    * @param contactsMap Map of contacts matching the applications
    * @param identifier  Application identifier
    * @param contact     Contact to add to the map
    */       
    public static void addToContactsMap(Map<String, Map<Id,Contact>> contactsMap, String identifier, Contact contact) {
        if (contactsMap.containsKey(identifier)) {
            Map<Id, Contact> existingContact = contactsMap.get(identifier);
            existingContact.put(contact.Id, contact);
        } else {
            Map<Id, Contact> newContacts = new Map<Id, Contact>();
            newContacts.put(contact.Id, contact);
            contactsMap.put(identifier, newContacts);
        }
    }

   /**
    * @description: Checks if a contact matches the given application based on specific fields.
    *
    * @param contact     Contact record to compare
    * @param application Application record to compare
    * @return True if the contact matches the application, false otherwise
    */    
    public static boolean contactMatchesApplication(Contact con, hed__Application__c app) {      
        boolean namesMatch = isFieldEqual(con.FirstName, app.FirstName__c) && isFieldEqual(con.LastName, app.LastName__c);
        boolean emailsMatch = isFieldEqual(con.Email, app.Email__c) || isFieldEqual(con.QUT_Learner_Email__c, app.Email__c) || 
          					  isFieldEqual(con.QUT_Staff_Email__c, app.Email__c) || isFieldEqual(con.Work_Email__c, app.Email__c);          
        boolean birthdateMatch = isFieldEqual(con.Birthdate, app.Birthdate__c);
        boolean isSAMSRecord = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
        boolean isNominated = app.Nominated_Student_ID__c !=null && app.Nominated_Student_ID__c == con.QUT_Student_ID__c && isSAMSRecord;
        
        return (namesMatch && emailsMatch) || (namesMatch && birthdateMatch) || isNominated;
    }  
       
   /**
    * @description: Checks if two fields are equal.
    *
    * @param field1 First field
    * @param field2 Second field
    * @return True if the fields are equal, false otherwise
    */ 
    private static boolean isFieldEqual(Object field1, Object field2) {
        return (field1 == null && field2 == null) || (field1 != null && field1.equals(field2));
    }

}