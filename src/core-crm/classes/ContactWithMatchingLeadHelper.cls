/**
 * @description Helper class for detecting and handling Lead duplicate for Contacts
 * 
 * @see ContactTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
      |---------------------------|-----------------------|----------------------|-------------------------------------|
      | eccarius.munoz            | May 31, 2022          | DEPP-2281            | Created File                        |
      |                           |                       |                      |                                     |  
 */
public without sharing class ContactWithMatchingLeadHelper {

    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;

    public static void detectLeadDuplicates(Map<Id,Contact> newItems){
        Map<String, Contact> nameEmailContactsMap = new Map<String, Contact>();
        List<Lead> leads = new List<Lead>();
        for(Contact con : newItems.values()){
            if(!String.isBlank(con.FirstName) && !String.isBlank(con.LastName) && !String.isBlank(con.Email)){
                nameEmailContactsMap.put(con.Name_and_Email__c, con);
            }
        }

        if(!nameEmailContactsMap.isEmpty()){
            leads = [SELECT Id, Name_and_Email__c, 
            (SELECT Id, Contact__c FROM Marketing_Interactions__r),
            (SELECT Id, Contact__c FROM Marketing_Course_Applications__r),
            (SELECT Id, Contact__c FROM Marketing_Segmentations__r),
            (SELECT Id, Parent_Person_Contact__c FROM Contacts__r)
            FROM Lead 
            WHERE Name_and_Email__c IN : nameEmailContactsMap.keySet() AND Lead_Type__c = 'Learner'];
        }
        
        List<Marketing_Interaction__c> marketingInteractionsToUpdate = new List<Marketing_Interaction__c>();
        List<Marketing_Course_Application__c> marketingCourseAppsToUpdate = new List<Marketing_Course_Application__c>();
        List<Marketing_Segmentation__c> marketingSegmentationToInsert = new List<Marketing_Segmentation__c>();
        List<Contact> contactsToUpdate = new List<Contact>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        for(Lead lead : leads){
            for(Contact c : lead.Contacts__r){
                contactsToUpdate.add(new Contact(Id = c.Id, Parent_Person_Contact__c = nameEmailContactsMap.get(lead.Name_and_Email__c)?.Id));
            }
            for(Marketing_Interaction__c m : lead.Marketing_Interactions__r){
                Marketing_Interaction__c marketingInteraction = new Marketing_Interaction__c(
                    Id = m.Id,
                    Contact__c = nameEmailContactsMap.get(lead.Name_and_Email__c)?.Id
                );
                marketingInteractionsToUpdate.add(marketingInteraction);
            }
            for(Marketing_Course_Application__c m : lead.Marketing_Course_Applications__r){
                Marketing_Course_Application__c marketingCourseApp = new Marketing_Course_Application__c(
                    Id = m.Id,
                    Contact__c = nameEmailContactsMap.get(lead.Name_and_Email__c)?.Id
                );
                marketingCourseAppsToUpdate.add(marketingCourseApp);
            }
            for(Marketing_Segmentation__c m : lead.Marketing_Segmentations__r){
                Marketing_Segmentation__c marketingSegmentation = new Marketing_Segmentation__c(
                    Contact__c = nameEmailContactsMap.get(lead.Name_and_Email__c)?.Id
                );
                marketingSegmentationToInsert.add(marketingSegmentation);
            }
        }
        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
        if(!marketingInteractionsToUpdate.isEmpty()){
            update marketingInteractionsToUpdate;
        }
        if(!marketingCourseAppsToUpdate.isEmpty()){
            update marketingCourseAppsToUpdate;
        }
        if(!marketingSegmentationToInsert.isEmpty()){
            insert marketingSegmentationToInsert;
        }   
    }

    @Future
    public static void convertLead(List<Id> newItems){
        Map<String, Contact> nameEmailContactsMap = new Map<String, Contact>();
        List<Lead> leads = new List<Lead>();
        for(Contact con : [SELECT Id, Name_and_Email__c, AccountId, FirstName, LastName, Email FROM Contact WHERE Id IN : newItems]){
            if(!String.isBlank(con.FirstName) && !String.isBlank(con.LastName) && !String.isBlank(con.Email)){
                nameEmailContactsMap.put(con.Name_and_Email__c, con);
            }
        }

        if(!nameEmailContactsMap.keySet().isEmpty()){
            leads = [SELECT Id, Name_and_Email__c
            FROM Lead 
            WHERE Name_and_Email__c IN : nameEmailContactsMap.keySet() AND Lead_Type__c = 'Learner'];
        }
        
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        for(Lead lead : leads){
            Database.LeadConvert leadToConvert = new Database.LeadConvert();
            if(nameEmailContactsMap.get(lead.Name_and_Email__c) != null){
                leadToConvert.setLeadId(lead.Id);
                leadToConvert.setConvertedStatus(convertStatus.MasterLabel);
                leadToConvert.setContactId(nameEmailContactsMap.get(lead.Name_and_Email__c)?.Id);
                leadToConvert.setAccountId(nameEmailContactsMap.get(lead.Name_and_Email__c)?.AccountId);
                leadsToConvert.add(leadToConvert);
            }
        }
        if(!leadsToConvert.isEmpty()){
            Database.LeadConvertResult[] leadConvertResult = Database.convertLead(leadsToConvert, false); 
        }
    }
}
