/**
 * @description Mock DAO Class for Contact Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                       |
      |--------------------------------|-----------------------|------------------------|--------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                         |   
      | eugene.andrew.abuan            | June 08, 2023         | DEPP-5414              | Added checkWorkEmailFlowInputExist   |

 */
@isTest
public inherited sharing class ContactsDAOMock extends DmlBaseMock implements IContactsDAO {
    public Map<Id, Contact> contactsMap;

    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    public ContactsDAOMock() {
        super(new Map<Id, Contact>(), Schema.Contact.SObjectType);
        this.contactsMap = (Map<Id, Contact>) super.records;
    }

    public List<Contact> getExistingPersonContactsWithMatchingEmails(
        Set<String> allEmailsToMatch,
        Set<Id> newContactIds,
        String accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (
                (!newContactIds.contains(record.Id) &&
                record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
                (allEmailsToMatch.contains(record.Email) ||
                allEmailsToMatch.contains(record.Work_Email__c) ||
                allEmailsToMatch.contains(record.QUT_Learner_Email__c) ||
                allEmailsToMatch.contains(record.QUT_Staff_Email__c)))
            ) {
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getPersonContactsWithLimit(Integer recordsCount) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID) {
                contactList.add(record);
            }

            if (contactList.size() == recordsCount) {
                break;
            }
        }
        return contactList;
    }

    public List<Contact> checkWorkEmailFlowInputExist(String emailInput){
        List<Contact> contactList = new List<Contact>();
        for(Contact record : contactsMap.values()){
            if(
                record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
                (emailInput.contains(record.Email) ||
                emailInput.contains(record.Work_Email__c) ||
                emailInput.contains(record.QUT_Learner_Email__c) ||
                emailInput.contains(record.QUT_Staff_Email__c))){
                contactList.add(record);
            }
        }
        return contactList;
    }
}
