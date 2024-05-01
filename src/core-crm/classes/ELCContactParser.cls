/**
 * @description Class to be used in parsing Engagement_List_Criteria__c to contact criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 1, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCContactParser{
    
    public static ContactsDAO.Criteria processContactCriteria(Engagement_List_Criteria__c engagementListCriteria, ContactsDAO.Criteria contactCriteria){
        contactCriteria = processCitizenshipStatus(engagementListCriteria, contactCriteria);
        contactCriteria = applyContactHiddenCriteria(contactCriteria);
        return contactCriteria;
    }

    //criterion
    public static ContactsDAO.Criteria processCitizenshipStatus(Engagement_List_Criteria__c engagementListCriteria, ContactsDAO.Criteria contactCriteria){
        if (engagementListCriteria.Citizenship_Status__c != null) {
            if (contactCriteria == null) {
                contactCriteria = new ContactsDAO.Criteria();
            }
            contactCriteria.citizenshipStatus = engagementListCriteria.Citizenship_Status__c;
        }
        return contactCriteria;
    }

    //hidden criteria
    public static ContactsDAO.Criteria applyContactHiddenCriteria(ContactsDAO.Criteria contactCriteria) {
        if (contactCriteria == null) {
            contactCriteria = new ContactsDAO.Criteria();
        }
        contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
        contactCriteria.isQUTStudent = true;
        return contactCriteria;
    }
    
}