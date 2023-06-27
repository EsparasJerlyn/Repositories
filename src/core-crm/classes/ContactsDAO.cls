/**
 * @description DAO Class for Contact Object. Contains soql and constants related to the Contact object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                   |
      | eugene.andrew.abuan            | June 08, 2023         | DEPP-5414              | Added new method checkWorkEmailFlowInputExist  |

 */
public inherited sharing class ContactsDAO extends DmlBase implements IContactsDAO {
    /**
     * Contact Constants
     */
    public static final String PERSON_RECORDTYPE = System.Label.RT_Contact_Person;
    public static final Id PERSON_RECORDTYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get(PERSON_RECORDTYPE)
        .getRecordTypeId();

    public static IContactsDAO newInstance() {
        return (IContactsDAO) ImplementationSelector.DAO.newInstance(Contact.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    public static List<Contact> getExistingPersonContactsWithMatchingEmails(
        Set<String> allEmailsToMatch,
        Set<Id> newContactIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Email, QUT_Learner_Email__c, QUT_Staff_Email__c, Work_Email__c ' +
                'FROM Contact ' +
                'WHERE Id NOT IN: newContactIds ' +
                'AND RecordTypeId =: PERSON_RECORDTYPE_ID ' +
                'AND (Email IN: allEmailsToMatch ' +
                'OR QUT_Learner_Email__c IN: allEmailsToMatch ' +
                'OR QUT_Staff_Email__c IN: allEmailsToMatch ' +
                'OR Work_Email__c IN: allEmailsToMatch) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Contact> getPersonContactsWithLimit(Integer recordsCount) {
        return [
            SELECT
                Id,
                LastName,
                Email,
                QUT_Learner_Email__c,
                QUT_Staff_Email__c,
                Work_Email__c,
                hed__Preferred_Email__c,
                hed__AlternateEmail__c
            FROM Contact
            WHERE RecordTypeId = :PERSON_RECORDTYPE_ID
            WITH USER_MODE
            LIMIT :recordsCount
        ];
    }

    public List<Contact> checkWorkEmailFlowInputExist(String emailInput) {
        return [
            SELECT Id, Work_Email__c, QUT_Learner_Email__c, Email, QUT_Staff_Email__c
            FROM Contact
            WHERE
                RecordTypeId = :PERSON_RECORDTYPE_ID
                AND (Work_Email__c = :emailInput
                OR Email = :emailInput
                OR QUT_Learner_Email__c = :emailInput
                OR QUT_Staff_Email__c = :emailInput)
            WITH USER_MODE
            LIMIT 1
        ];
    }
}
