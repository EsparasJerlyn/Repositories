/**
 * @description Helper class for detecting and handling Lead duplicate for Contacts
 * 
 * @see ContactTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                              |
      |---------------------------|-----------------------|----------------------|---------------------------------------------|
      | eccarius.munoz            | May 31, 2022          | DEPP-2281            | Created File                                |
      |                           |                       |                      |                                             | 
      | eccarius.munoz            | June 28, 2022         | DEPP-3235            | Modified exact match handling to            |
      |                           |                       |                      | email and work email only.                  |  
      |                           |                       |                      |                                             |  
      |                           |                       |                      | Modified handling of marketing seg-         |  
      |                           |                       |                      | mentation to always clone if                |  
      |                           |                       |                      | there's any record(s) found.                |  
      |                           |                       |                      |                                             | 
      | eccarius.munoz            | June 29, 2022         | DEPP-3250            | Modified handling of marketing seg-         | 
      |                           |                       |                      | mentation.                                  |   
      |                           |                       |                      |                                             |
      | mark.j.mahilum            | July 03, 2023         | DEPP-5961            | Updated Marketing Course Application object |
      |                           |                       |                      | and replaced by Application object          |
      | mark.j.mahilum            | August 18, 2023       | DEPP-6391            | Marketing Course Application retrofit       |
      | mark.j.mahilum            | May 06, 2024          | DEPP-7987            | Updated method name of convertLeadOnInsert  |
      |                           |                       |                      | check if method should run as async or not  |
 */
public without sharing class ContactWithMatchingLeadHelper {
    
    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;

    private static final List<String> MARKETING_SEGMENTATION_FIELDS = new List<String>{
        'Migration_Key__c','Prospects_Behaviour__c','Prospects_Rank__c',
        'Prospects_Score__c','Previous_Educational_Institution__c','Secondary_School_Name__c',
        'Alumnus_Educational_Institution__c','Course_Referrer__c','My_Profile_Persona__c','My_Citizenship_Status__c',
        'My_Indigenous_Status_ATSI__c','My_Country_Of_Citizenship__c','My_Country_Of_Residency__c','My_Expected_Admission_Year__c',
        'My_Year_12_Expected_Completion_Year__c','My_Studying_Australian_Curriculum__c','My_Funding_Source__c',
        'My_Moving_To_Brisbane__c','My_High_Achieving_Student__c','My_Elite_Athlete__c','My_Organisation__c',
        'My_Position__c','My_Industry__c','My_Primary_Study_Level__c','My_Primary_BSA__c','My_Primary_NSA__c',
        'My_Secondary_Study_Level__c','My_Secondary_BSA__c','My_Secondary_NSA__c','My_Double_Degree__c',
        'My_Interested_Pathway_Program_or_Diploma__c','My_Interested_English_Pathways__c','My_Interested_Financial_Assistance__c',
        'My_Interested_Entrepreneurship__c','My_Interested_Languages__c','My_Interested_ESport_Interest__c','My_Postcode__c',
        'My_State__c','My_Suburb__c','SE_Profile_Persona__c','SE_Citizenship_Status__c','SE_Indigenous_Status_ATSI__c',
        'SE_Country_Of_Citizenship__c','SE_Country_Of_Residency__c','SE_Expected_Admission_Year__c','SE_Education_Level__c', 'SE_Year_12_Expected_Completion_Year__c',
        'SE_Studying_Australian_Curriculum__c','SE_Funding_Source__c','SE_Moving_To_Brisbane__c','SE_High_Achieving_Student__c',
        'SE_Elite_Athlete__c','SE_Organisation__c','SE_Position__c','SE_Industry__c','SE_Primary_Study_Level__c','SE_Primary_BSA__c',
        'SE_Primary_NSA__c','SE_Secondary_Study_Level__c','SE_Secondary_BSA__c','SE_Secondary_NSA__c','SE_Double_Degree__c',
        'SE_Interested_Pathway_Program_or_Diploma__c','SE_Interested_English_Pathways__c','SE_Interested_Financial_Assistance__c',
        'SE_Interested_Entrepreneurship__c','SE_Interested_Languages__c','SE_Interested_ESport_Interest__c','SE_Interested_Course_Name__c',
        'SE_Postcode__c','SE_State__c','SE_Suburb__c','ORG_Profile_Persona__c','ORG_Indigenous_Status_ATSI__c','ORG_Country_Of_Residency__c',
        'ORG_Organisation__c','ORG_Position__c','ORG_Industry__c','ORG_Primary_Study_Level__c','ORG_Primary_BSA__c','ORG_Primary_NSA__c',
        'ORG_Secondary_Study_Level__c','ORG_Secondary_BSA__c','ORG_Secondary_NSA__c','ORG_Interested_Languages__c','ORG_Interested_Course_Name__c',
        'ORG_Postcode__c','ORG_State__c', 'ORG_Education_Level__c', 'ORG_Suburb__c', 'My_Education_Level__c','External_Key__c',
        'Mailing_Address_Country__c'
    };

    public static void processLeadMatching(List<Contact> newItems, Map<Id, Contact> oldItems){

        List<Id> contactIds = new List<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        // handle both update and insert
        for(Contact con: newItems){
            boolean isInsert = oldItems == null;
            boolean isOneOfEmailPopulated = con.Email != null || con.Work_Email__c != null;
            boolean isOneOfEmailUpdated = !isInsert && (oldItems.get(con.Id).Email != con.Email || oldItems.get(con.Id).Work_Email__c != con.Work_Email__c);

            if((isInsert || isOneOfEmailUpdated ) && isOneOfEmailPopulated && con.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID){
                contactIds.add(con.Id);
                contactMap.put(con.Id,con);
            }
        }

        if(contactIds.isEmpty()){
            return;
        }

        Boolean isAsync = System.isBatch() || System.isFuture() || System.isScheduled() || System.isQueueable();
        if(isAsync) {
            //Current transaction is running asynchronously
            convertLead(contactIds);
            detectLeadDuplicates(contactMap);
        } else {
            //Current transaction is not running asynchronously;
            convertLeadOnAsync(contactIds);
            detectLeadDuplicatesAsync(contactIds);
        }
    }

    
    @Future
    public static void convertLeadOnAsync(List<Id> contactIds){
        convertLead(contactIds);
    }

    @Future
    public static void detectLeadDuplicatesAsync(List<Id> contactIds){
        Map<Id,Contact> newItems = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>(contactIds), AccessLevel.SYSTEM_MODE));
        detectLeadDuplicates(newItems);
    }

    public static void detectLeadDuplicates(Map<Id,Contact> newItems){
        Map<String, Contact> contactsByEmailMap = new Map<String, Contact>(); // groups contacts by email or work email
        Map<Id, Lead> matchingLeadsMap;
        Map<Id, Marketing_Segmentation__c> marketingSegmentationsMap = new Map<Id, Marketing_Segmentation__c>();
        Set<Id> segmentationParentIds = new Set<Id>();
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Map<Id, Marketing_Interaction__c> marketingInteractionsToUpdate = new Map<Id, Marketing_Interaction__c>();
        Map<Id, hed__Application__c> applicationToUpdate = new Map<Id, hed__Application__c>();
        Map<Id, Marketing_Segmentation__c> marketingSegmentationToUpdate = new Map<Id, Marketing_Segmentation__c>();
        Map<Id, Marketing_Course_Application__c> marketingCourseAppsToUpdate = new Map<Id, Marketing_Course_Application__c>();
        Set<Id> leadIdsSet = new  Set<Id>();
        Marketing_Segmentation__c marSegToUpdate;

        //group contacts by email or work email
        contactsByEmailMap = groupContactsByEmail(newItems.values());
        
        // get learner leads with matching email or work email to contact
        matchingLeadsMap = new Map<Id,Lead>(LeadsDAO.newInstance().getLearnerLeadsByEmailOrWorkEmail(contactsByEmailMap.keySet(), AccessLevel.SYSTEM_MODE));
        leadIdsSet = matchingLeadsMap.keySet();
        // collect lead and contact ids
        segmentationParentIds.addAll(leadIdsSet);
        segmentationParentIds.addAll(newItems.keySet());
        // collect Segmentations by parent Leads 
        marketingSegmentationsMap = getSegmentationsByParentIds(segmentationParentIds); 

        Id matchingContactId;

        for(Lead lead : matchingLeadsMap.values()){

            // get the matching contact through lead's email or work email
            matchingContactId = contactsByEmailMap.containsKey(lead.Email)?contactsByEmailMap.get(lead.Email).Id:contactsByEmailMap.get(lead.Work_Email__c).Id;

            // map child contact to the new parent contact
            for(Contact c : lead.Contacts__r){
                c.Parent_Person_Contact__c = matchingContactId;
                contactsToUpdate.put(c.Id, c);
            }

            // map child interaction to the matched contact
            for(Marketing_Interaction__c mi : lead.Marketing_Interactions__r){
                mi.Contact__c = matchingContactId;
                marketingInteractionsToUpdate.put(mi.Id,mi);
            }

            // map child course application to the matched contact
            for(Marketing_Course_Application__c mca : lead.Marketing_Course_Applications__r){
                mca.Contact__c = matchingContactId;
                marketingCourseAppsToUpdate.put(mca.Id,mca);
            }
            
            // map child applicatio to the matched contact
            for(hed__Application__c app : lead.Applications__r){
                app.hed__Applicant__c = matchingContactId;
                applicationToUpdate.put(app.Id, app);
            }

            marSegToUpdate = mapMarketingSegmenations(marketingSegmentationsMap, lead.Id, matchingContactId);
            marketingSegmentationToUpdate.put(marSegToUpdate.Id, marSegToUpdate);
        }

        ContactsDAO.newInstance().updateRecords(contactsToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        MarketingInteractionsDAO.newInstance().updateRecords(marketingInteractionsToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        MarketingCourseApplicationsDAO.newInstance().updateRecords(marketingCourseAppsToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        ApplicationsDAO.newInstance().updateRecords(applicationToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        MarketingSegmentationsDAO.newInstance().updateRecords(marketingSegmentationToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
    }

    private static Map<String,Contact> groupContactsByEmail(List<Contact> contactList){
        Map<String,Contact> contactsMap = new Map<String,Contact>();
        for(Contact con : contactList){
            if(!String.isBlank(con.Email)){
                contactsMap.put(con.Email, con);
            }

            if(!String.isBlank(con.Work_Email__c)){
                contactsMap.put(con.Work_Email__c, con);
            }
        }
        return contactsMap;
    }

    private static Map<Id, Marketing_Segmentation__c> getSegmentationsByParentIds(Set<Id> segmentationParentIds){
        Map<Id,Marketing_Segmentation__c> marketingSegmentationsMap = new Map<Id,Marketing_Segmentation__c>();
        for(Marketing_Segmentation__c ms : MarketingSegmentationsDAO.newInstance()
                                            .getLinkedMarketingSegByContactOrLeadIds(
                                                segmentationParentIds,
                                                AccessLevel.SYSTEM_MODE
                                                )){                                   
            if(ms.Contact__c != null){
                marketingSegmentationsMap.put(ms.Contact__c, ms);
            }
            if(ms.Lead__c != null){
                marketingSegmentationsMap.put(ms.Lead__c, ms);
            }            
        }
        return marketingSegmentationsMap;
    }

    private static Marketing_Segmentation__c mapMarketingSegmenations(Map<Id, Marketing_Segmentation__c> marketingSegmentationsMap, Id leadId, Id contactId){
        Marketing_Segmentation__c mktSegTemp = new Marketing_Segmentation__c();
        // only proceed if lead and contact has existing marketing segmentations
        if(marketingSegmentationsMap.containsKey(leadId) && marketingSegmentationsMap.containsKey(contactId)){
            // Assumption is contact will always have a marketing segmentaton record
            // Update the contact's marketing segmenation using the current lead's marketing segmentation in the loop
            Marketing_Segmentation__c msFromContact = marketingSegmentationsMap.get(contactId);
            Marketing_Segmentation__c msFromLead = marketingSegmentationsMap.get(leadId);
            
            mktSegTemp.put('Id', msFromContact.Id);                        
            for(String fieldName: MARKETING_SEGMENTATION_FIELDS){
                if(msFromContact.get(fieldName) == null && msFromLead.get(fieldName) != null){    
                    mktSegTemp.put(fieldName, msFromLead.get(fieldName));
                }
            }
        }

        return mktSegTemp;
    }

    private static void convertLead(List<Id> newItems){
        Map<String, Contact> initContactEmailMap = new Map<String, Contact>();
        Map<String, Contact> initContactWorkEmailMap = new Map<String, Contact>();
        Set<Id> contactIds = new Set<Id>();
        contactIds.addAll(newItems);
        List<Contact> initContactList = ContactsDAO.newInstance().getContactsNoParentPersonContactByIds(
            contactIds, AccessLevel.SYSTEM_MODE
        );
        for(Contact c : initContactList){
            if(!String.isBlank(c.Email)){
                initContactEmailMap.put(c.Email, c);
            }
            if(!String.isBlank(c.Work_Email__c)){
                initContactWorkEmailMap.put(c.Work_Email__c, c);
            }
        }
        List<Lead> initLeads = new List<Lead>();
        initLeads = LeadsDAO.newInstance().getLearnerLeadsByEmailOrWorkEmail(
            initContactEmailMap.keySet(),
            initContactWorkEmailMap.keySet(),
            AccessLevel.SYSTEM_MODE
        );
        LeadStatus convertStatus = LeadStatusesDAO.newInstance().getConvertedLeadStatus(AccessLevel.SYSTEM_MODE);
        Map<Id, Database.LeadConvert> leadsToConvertMap = new Map<Id, Database.LeadConvert>();     
        if(initLeads != null && !initLeads.isEmpty()){
            for(Lead lead : initLeads){
                Database.LeadConvert leadToConvert = new Database.LeadConvert();
                leadToConvert.setLeadId(lead.Id);
                leadToConvert.setConvertedStatus(convertStatus.MasterLabel);
                leadToConvert.setDoNotCreateOpportunity(true);
                if(initContactEmailMap.containsKey(lead.Email)){
                    leadToConvert.setContactId(initContactEmailMap.get(lead.Email)?.Id);
                    leadToConvert.setAccountId(initContactEmailMap.get(lead.Email)?.AccountId);      
                }else if(initContactEmailMap.containsKey(lead.Work_Email__c)){
                    leadToConvert.setContactId(initContactEmailMap.get(lead.Work_Email__c)?.Id);
                    leadToConvert.setAccountId(initContactEmailMap.get(lead.Work_Email__c)?.AccountId);
                }else if(initContactWorkEmailMap.containsKey(lead.Work_Email__c)){
                    leadToConvert.setContactId(initContactWorkEmailMap.get(lead.Work_Email__c)?.Id);
                    leadToConvert.setAccountId(initContactWorkEmailMap.get(lead.Work_Email__c)?.AccountId);      
                }else if(initContactWorkEmailMap.containsKey(lead.Email)){
                    leadToConvert.setContactId(initContactWorkEmailMap.get(lead.Email)?.Id);
                    leadToConvert.setAccountId(initContactWorkEmailMap.get(lead.Email)?.AccountId);
                }
                leadsToConvertMap.put(lead.Id, leadToConvert); 
            }
        }else{
            Map<String, Contact> contactEmailMap = new Map<String, Contact>();
            Map<String, Contact> contactWorkEmailMap = new Map<String, Contact>();   
            List<Contact> parentContactList = ContactsDAO.newInstance()
                .getContactsWithParentPersonContactByIds(
                    contactIds,
                    AccessLevel.SYSTEM_MODE
                );
            for(Contact c : parentContactList){
                if(!String.isBlank(c.Parent_Person_Contact__r.Email)){
                    contactEmailMap.put(c.Parent_Person_Contact__r.Email, c);
                }
                if(!String.isBlank(c.Parent_Person_Contact__r.Work_Email__c)){
                    contactWorkEmailMap.put(c.Parent_Person_Contact__r.Work_Email__c, c);
                }
            }
            List<Lead> leads = new List<Lead>();
            leads = LeadsDAO.newInstance().getLearnerLeadsByEmailOrWorkEmail(
                contactEmailMap.keySet(),
                contactWorkEmailMap.keySet(),
                AccessLevel.SYSTEM_MODE
            );

            for(Lead lead : leads){
                Database.LeadConvert leadToConvert = new Database.LeadConvert();
                leadToConvert.setLeadId(lead.Id);
                leadToConvert.setConvertedStatus(convertStatus.MasterLabel);
                leadToConvert.setDoNotCreateOpportunity(true);
                if(contactEmailMap.containsKey(lead.Email)){
                    leadToConvert.setContactId(contactEmailMap.get(lead.Email)?.Parent_Person_Contact__r.Id);
                    leadToConvert.setAccountId(contactEmailMap.get(lead.Email)?.Parent_Person_Contact__r.AccountId);      
                }else if(contactEmailMap.containsKey(lead.Work_Email__c)){
                    leadToConvert.setContactId(contactEmailMap.get(lead.Work_Email__c)?.Parent_Person_Contact__r.Id);
                    leadToConvert.setAccountId(contactEmailMap.get(lead.Work_Email__c)?.Parent_Person_Contact__r.AccountId);
                }else if(contactWorkEmailMap.containsKey(lead.Work_Email__c)){
                    leadToConvert.setContactId(contactWorkEmailMap.get(lead.Work_Email__c)?.Parent_Person_Contact__r.Id);
                    leadToConvert.setAccountId(contactWorkEmailMap.get(lead.Work_Email__c)?.Parent_Person_Contact__r.AccountId);
                }else if(contactWorkEmailMap.containsKey(lead.Email)){
                    leadToConvert.setContactId(contactWorkEmailMap.get(lead.Email)?.Parent_Person_Contact__r.Id);
                    leadToConvert.setAccountId(contactWorkEmailMap.get(lead.Email)?.Parent_Person_Contact__r.AccountId);
                }                
                leadsToConvertMap.put(lead.Id, leadToConvert); 
            }
        }

        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        if(!leadsToConvertMap.isEmpty()){
            for(Id leadId : leadsToConvertMap.keySet()){
                leadsToConvert.add(leadsToConvertMap.get(leadId));
            }
            Database.convertLead(leadsToConvert, false); 
        }
    }
}