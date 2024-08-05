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

    public static Set<Id> detectLeadDuplicates(Map<Id,Contact> newItems){
        Map<String, Contact> contactsMap = new Map<String, Contact>();
        Set<Id> contactIdSet = new Set<Id>();
        List<Lead> leads = new List<Lead>();
        List<Contact> contactList = new List<Contact>();
        List<Marketing_Interaction__c> marketingInteractions = new List<Marketing_Interaction__c>();
        List<hed__Application__c> applicationRecords = new List<hed__Application__c>();
        List<Marketing_Segmentation__c> contactMarketingSegmentations = new List<Marketing_Segmentation__c>();
        List<Marketing_Segmentation__c> marketingSegmentations = new List<Marketing_Segmentation__c>();
        List<Marketing_Course_Application__c> marketingCourseApps = new List<Marketing_Course_Application__c>();
        Set<Id> contactWithNewMarketingSegmentations = new Set<Id>();

        for(Contact con : newItems.values()){
            if(!String.isBlank(con.Email)){
                contactsMap.put(con.Email, con);
            }

            if(!String.isBlank(con.Work_Email__c)){
                contactsMap.put(con.Work_Email__c, con);
            }

            if(!String.isBlank(con.Email) || !String.isBlank(con.Work_Email__c)){
            contactIdSet.add(con.Id);
        }
        }
        if(!contactsMap.keySet().isEmpty()){
            leads = LeadsDAO.newInstance().getLearnerLeadsByEmailOrWorkEmail(contactsMap.keySet(), AccessLevel.SYSTEM_MODE);
        }
        

        Set<Id> leadIdSet = new Set<Id>();
        for(Lead lead : leads){ leadIdSet.add(lead.Id); }

        Map<Id, List<Contact>> contactsLeadMap = new Map<Id, List<Contact>>();

        if(!leadIdSet.isEmpty()){
            contactList = ContactsDAO.newInstance().getContactsByParentPersonLeadIds(leadIdSet, AccessLevel.SYSTEM_MODE);
        }

        for(Contact c : contactList){
            if(contactsLeadMap.containsKey(c.Parent_Person_Lead__c)){
                contactsLeadMap.get(c.Parent_Person_Lead__c).add(c);
            }else{
                List<Contact> cList = new List<Contact>();
                cList.add(c);
                contactsLeadMap.put(c.Parent_Person_Lead__c, cList);
            }
        }

        Map<Id, List<Marketing_Interaction__c>> marketingInteractionsMap = new Map<Id, List<Marketing_Interaction__c>>();
        if(!leadIdSet.isEmpty()){
            marketingInteractions = MarketingInteractionsDAO.newInstance().getMarketingInteractionsByContactOrLeadIds(
                leadIdSet, AccessLevel.SYSTEM_MODE
            );
        }
        
        for(Marketing_Interaction__c mi : marketingInteractions){
            if(marketingInteractionsMap.containsKey(mi.Lead__c)){
                marketingInteractionsMap.get(mi.Lead__c).add(mi);
            }else{
                List<Marketing_Interaction__c> miList = new List<Marketing_Interaction__c>();
                miList.add(mi);
                marketingInteractionsMap.put(mi.Lead__c, miList);
            }
        }

        Map<Id, List<Marketing_Course_Application__c>> marketingCourseAppsMap = new Map<Id, List<Marketing_Course_Application__c>>();
        if(!leadIdSet.isEmpty()){
            marketingCourseApps = MarketingCourseApplicationsDAO.newInstance().getMrktngCourseAppsByLeadIds(
                leadIdSet, AccessLevel.SYSTEM_MODE
            );          
        }

        for(Marketing_Course_Application__c mca : marketingCourseApps){
            if(marketingCourseAppsMap.containsKey(mca.Lead__c)){
                marketingCourseAppsMap.get(mca.Lead__c).add(mca);
            }else{
                List<Marketing_Course_Application__c> mcaList = new List<Marketing_Course_Application__c>();
                mcaList.add(mca);
                marketingCourseAppsMap.put(mca.Lead__c, mcaList);
            }
        }

        Map<Id, List<hed__Application__c>> applicationMap = new Map<Id, List<hed__Application__c>>();
        if(!leadIdSet.isEmpty()){
            applicationRecords = ApplicationsDAO.newInstance().getApplicationsByLeadIds(leadIdSet,'SYSTEM_MODE');           
        }
        
        for(hed__Application__c app : applicationRecords){
            if(applicationMap.containsKey(app.Lead__c)){
                applicationMap.get(app.Lead__c).add(app);
            }else{
                List<hed__Application__c> appList = new List<hed__Application__c>();
                appList.add(app);
                applicationMap.put(app.Lead__c, appList);
            }
        }

        if(!contactIdSet.isEmpty()){
            contactMarketingSegmentations = MarketingSegmentationsDAO.newInstance()
                .getLinkedMarketingSegByContactOrLeadIds(
                    contactIdSet,
                    AccessLevel.SYSTEM_MODE
                );
        }
         
        if(!leadIdSet.isEmpty()){
            marketingSegmentations = MarketingSegmentationsDAO.newInstance()
                .getLinkedMarketingSegByContactOrLeadIds(
                    leadIdSet,
                    AccessLevel.SYSTEM_MODE
                );
        }

        Map<Id, Marketing_Segmentation__c> leadMarketingSegmentationsMap = new Map<Id, Marketing_Segmentation__c>();
        Map<Id, List<Marketing_Segmentation__c>> marketingSegmentationsMap = new Map<Id, List<Marketing_Segmentation__c>>();
        for(Marketing_Segmentation__c ms : marketingSegmentations){            
            if(marketingSegmentationsMap.containsKey(ms.Lead__c)){
                marketingSegmentationsMap.get(ms.Lead__c).add(ms);
            }else{
                List<Marketing_Segmentation__c> msList = new List<Marketing_Segmentation__c>();
                msList.add(ms);
                marketingSegmentationsMap.put(ms.Lead__c, msList);
            }
            leadMarketingSegmentationsMap.put(ms.Lead__c, ms);
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Marketing_Interaction__c> marketingInteractionsToUpdate = new List<Marketing_Interaction__c>();
        List<hed__Application__c> applicationToUpdate = new List<hed__Application__c>();
        List<Marketing_Segmentation__c> marketingSegmentationToInsert = new List<Marketing_Segmentation__c>();
        List<Marketing_Segmentation__c> marketingSegmentationToUpdate = new List<Marketing_Segmentation__c>();
        List<Marketing_Course_Application__c> marketingCourseAppsToUpdate = new List<Marketing_Course_Application__c>();
        
        for(Lead lead : leads){
            if(contactsLeadMap.containsKey(lead.Id)){
                for(Contact c : contactsLeadMap.get(lead.Id)){
                    Contact contact = new Contact(
                        Id = c.Id,
                        Parent_Person_Contact__c = contactsMap.get(lead.Email)?.Id != null ? contactsMap.get(lead.Email).Id : contactsMap.get(lead.Work_Email__c).Id
                    );
                    contactsToUpdate.add(contact);
                }
            }
            if(marketingInteractionsMap.containsKey(lead.Id)){
                for(Marketing_Interaction__c m : marketingInteractionsMap.get(lead.Id)){
                    Marketing_Interaction__c marketingInteraction = new Marketing_Interaction__c(
                        Id = m.Id,
                        Contact__c = contactsMap.get(lead.Email)?.Id != null ? contactsMap.get(lead.Email).Id : contactsMap.get(lead.Work_Email__c).Id
                    );
                    marketingInteractionsToUpdate.add(marketingInteraction);
                }
            }
            if(marketingCourseAppsMap.containsKey(lead.Id)){
                for(Marketing_Course_Application__c m : marketingCourseAppsMap.get(lead.Id)){
                    Marketing_Course_Application__c marketingCourseApp = new Marketing_Course_Application__c(
                        Id = m.Id,
                        Contact__c = contactsMap.get(lead.Email)?.Id != null ? contactsMap.get(lead.Email).Id : contactsMap.get(lead.Work_Email__c).Id
                    );
                    marketingCourseAppsToUpdate.add(marketingCourseApp);
                }
            }
            if(applicationMap.containsKey(lead.Id)){
                for(hed__Application__c app : applicationMap.get(lead.Id)){
                    hed__Application__c appRec = new hed__Application__c(
                        Id = app.Id,
                        hed__Applicant__c = contactsMap.get(lead.Email)?.Id != null ? contactsMap.get(lead.Email).Id : contactsMap.get(lead.Work_Email__c).Id
                    );
                    applicationToUpdate.add(appRec);
                }
            }
            
            if(marketingSegmentationsMap.containsKey(lead.Id) && (contactMarketingSegmentations != null && !contactMarketingSegmentations.isEmpty())){
                for(Marketing_Segmentation__c msFromContact : contactMarketingSegmentations){
                    sObject obj = Schema.getGlobalDescribe().get('Marketing_Segmentation__c').newSObject();
                    obj.put('Id', msFromContact.Id);                        
                    for(String fieldName: MARKETING_SEGMENTATION_FIELDS){
                        if(msFromContact.get(fieldName) == null){    
                            obj.put(fieldName, leadMarketingSegmentationsMap.get(lead.Id).get(fieldName)  );
                        }
                    }
                    Marketing_Segmentation__c marketingSegmentation = (Marketing_Segmentation__c) obj;
                    marketingSegmentationToUpdate.add(marketingSegmentation);
                }
            }else if(marketingSegmentationsMap.containsKey(lead.Id) && contactMarketingSegmentations.isEmpty()){
                for(Marketing_Segmentation__c m : marketingSegmentationsMap.get(lead.Id)){
                    sObject obj = Schema.getGlobalDescribe().get('Marketing_Segmentation__c').newSObject();
                    obj.put('Contact__c', contactsMap.get(lead.Email)?.Id != null ? contactsMap.get(lead.Email).Id : contactsMap.get(lead.Work_Email__c).Id);
                    contactWithNewMarketingSegmentations.add((Id)obj.get('Contact__c'));
                    for(String fieldName: MARKETING_SEGMENTATION_FIELDS){
                        if(m.get(fieldName) != null){
                            obj.put(fieldName, m.get(fieldName));
                        }
                    }
                    Marketing_Segmentation__c marketingSegmentation = (Marketing_Segmentation__c) obj;
                    marketingSegmentationToInsert.add(marketingSegmentation);
                }
            }
        }
        if(!contactsToUpdate.isEmpty()){
            Database.update(contactsToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
        if(!marketingInteractionsToUpdate.isEmpty()){
            Database.update(marketingInteractionsToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
        if(!marketingCourseAppsToUpdate.isEmpty()){
            Database.update(marketingCourseAppsToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
        if(!applicationToUpdate.isEmpty()){
            ApplicationsDAO.newInstance().updateRecords(applicationToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
        if(!marketingSegmentationToInsert.isEmpty()){
            Database.insert(marketingSegmentationToInsert, false, AccessLevel.SYSTEM_MODE);
        }   
        if(!marketingSegmentationToUpdate.isEmpty()){
            Database.update(marketingSegmentationToUpdate, false, AccessLevel.SYSTEM_MODE);
        }

        return contactWithNewMarketingSegmentations;
    }

    @Future
    public static void convertLeadOnAsync(List<Id> newItems){
        convertLead(newItems);
    }
    
    public static void convertLeadOnSync(List<Id> newItems){
        convertLead(newItems);
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