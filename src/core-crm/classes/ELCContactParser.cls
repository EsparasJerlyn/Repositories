/**
 * @description Class to be used in parsing Engagement_List_Criteria__c to contact criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCContactParser{

    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private ContactsDAO.Criteria contactCriteria;

    public ELCContactParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        contactCriteria = new ContactsDAO.Criteria();
        parse();
    }

    private void parse() {
        contactCriteria = processCitizenshipStatus(engagementListCriteria, contactCriteria);
        contactCriteria = applyContactHiddenCriteria(contactCriteria);
    }

    //configurable criteria
    private ContactsDAO.Criteria processCitizenshipStatus(Engagement_List_Criteria__c engagementListCriteria, ContactsDAO.Criteria contactCriteria){
        if (String.isNotBlank(engagementListCriteria.Citizenship_Status__c)) {
            contactCriteria.setCitizenshipStatus(engagementListCriteria.Citizenship_Status__c);
        }
        return contactCriteria;
    }

    //hidden criteria
    private ContactsDAO.Criteria applyContactHiddenCriteria(ContactsDAO.Criteria contactCriteria) {
        contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
        contactCriteria.setIsQUTStudent(true);
        return contactCriteria;
    }

    public ContactsDAO.Criteria getContactCriteria() {
        return contactCriteria;
    }

}