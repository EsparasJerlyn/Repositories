/**
 * @description DAO Class for Contact Object. Contains soql and constants related to the Contact object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------           |
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                              |
      | eugene.andrew.abuan            | June 08, 2023         | DEPP-5414              | Added new method checkWorkEmailFlowInputExist             |
      | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added new method getContactsWithMatchingApplicationDetails|
      |                                |                       |                        | + and getContactsWithMatchingEmails                       |
      | arsenio.jr.dayrit              | July 06, 2023         | DEPP-5847              | Added new method getContactsWithMatchingSamsApplications  |
*     | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | Added method for DEPP-5677                                |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added method for DEPP-6215                                |
 */
public inherited sharing class ContactsDAO extends DmlBase implements IContactsDAO {
    /**
     * Contact Constants
     */
    public static final String PERSON_RECORDTYPE = System.Label.RT_Contact_Person;
    public static final Id PERSON_RECORDTYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get(PERSON_RECORDTYPE)
        .getRecordTypeId();

    public static final Set<String> CONTACT_HAS_APPLIED_STATUSES = new Set<String>{
        'Apply','Offer','Accept-Admit','Study'
    };

    public static final Set<String> CONTACT_HAS_OFFERED_STATUSES = new Set<String>{
        'Offer','Accept-Admit','Study'
    };

    public static final Set<String> CONTACT_HAS_ACCEPTED_STATUSES = new Set<String>{
        'Accept-Admit','Study'
    };

    public static final String EXPLORE_JOURNEY_STATUS = 'Explore';
    public static final String APPLY_JOURNEY_STATUS = 'Apply';
    public static final String OFFER_JOURNEY_STATUS = 'Offer';
    public static final String ACCEPT_ADMIT_JOURNEY_STATUS = 'Accept-Admit';
    public static final String STUDY_JOURNEY_STATUS = 'Study';

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
        return [//NOPMD
            SELECT
                Id,
                LastName,
                Email,
                QUT_Learner_Email__c,
                QUT_Staff_Email__c,
                QUT_Applicant__c,
                QUT_Student__c,
                Work_Email__c,
                hed__Preferred_Email__c,
                hed__AlternateEmail__c,
                Future_Student_Journey_Status__c,
                Lead_Score__c
            FROM Contact
            WHERE RecordTypeId = :PERSON_RECORDTYPE_ID
            WITH SYSTEM_MODE // only used in test class, can be used to verify record updates
            LIMIT :recordsCount
        ];
    }

    public List<Contact> checkWorkEmailFlowInputExist(String emailInput) {
        return [//NOPMD
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

    public static List<Contact> getContactsWithMatchingApplicationDetails(
        QueryParamWrapper queryParam,
        String accessLevel
    ) {
        Set<String> applicationEmailsToMatch = queryParam.emailsToMatch; //NOPMD
        Set<String> applicationFirstNames = queryParam.firstNames; //NOPMD
        Set<String> applicationLastNames = queryParam.lastNames; //NOPMD
        Set<Date> applicationBirthdates = queryParam.birthdates; //NOPMD
        return Database.query(
            'SELECT  Id, Email, QUT_Learner_Email__c, QUT_Staff_Email__c, Work_Email__c, ' +
                'FirstName, LastName, Birthdate ' +
                'FROM Contact ' +
                'WHERE RecordTypeId =: PERSON_RECORDTYPE_ID ' +
                'AND ((FirstName IN: applicationFirstNames ' +
                'AND LastName IN: applicationLastNames ' +
                'AND Birthdate IN: applicationBirthdates) ' +
                'OR (FirstName IN: applicationFirstNames ' +
                'AND LastName IN: applicationLastNames ' +
                'AND (Email IN: applicationEmailsToMatch ' +
                'OR QUT_Learner_Email__c IN: applicationEmailsToMatch ' +
                'OR QUT_Staff_Email__c IN: applicationEmailsToMatch ' +
                'OR Work_Email__c IN: applicationEmailsToMatch))) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Contact> getContactsWithMatchingEmails(
        Set<String> applicationEmailsToMatch,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Email, QUT_Learner_Email__c, QUT_Staff_Email__c, Work_Email__c ' +
                'FROM Contact ' +
                'WHERE RecordTypeId =: PERSON_RECORDTYPE_ID ' +
                'AND (Email IN: applicationEmailsToMatch ' +
                'OR QUT_Learner_Email__c IN: applicationEmailsToMatch ' +
                'OR QUT_Staff_Email__c IN: applicationEmailsToMatch ' +
                'OR Work_Email__c IN: applicationEmailsToMatch) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Contact> getContactsWithMatchingSamsApplications(
        QueryParamWrapper queryParam,
        String accessLevel
    ) {
        Set<String> applicationEmailsToMatch = queryParam.emailsToMatch; //NOPMD
        Set<String> applicationFirstNames = queryParam.firstNames; //NOPMD
        Set<String> applicationLastNames = queryParam.lastNames; //NOPMD
        Set<Date> applicationBirthdates = queryParam.birthdates; //NOPMD
        Set<String> appNominatedIds = queryParam.nominatedStudentId; //NOPMD
        return Database.query(
            'SELECT  Id, QUT_student_ID__c, Email, QUT_Learner_Email__c, QUT_Staff_Email__c, Work_Email__c, ' +
                'FirstName, LastName, Birthdate ' +
                'FROM Contact ' +
                'WHERE RecordTypeId =: PERSON_RECORDTYPE_ID ' +
                'AND ((QUT_student_ID__c IN: appNominatedIds) ' +
                'OR (FirstName IN: applicationFirstNames ' +
                'AND LastName IN: applicationLastNames ' +
                'AND Birthdate IN: applicationBirthdates) ' +
                'OR (FirstName IN: applicationFirstNames ' +
                'AND LastName IN: applicationLastNames ' +
                'AND (Email IN: applicationEmailsToMatch ' +
                'OR QUT_Learner_Email__c IN: applicationEmailsToMatch ' +
                'OR QUT_Staff_Email__c IN: applicationEmailsToMatch ' +
                'OR Work_Email__c IN: applicationEmailsToMatch))) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Contact> getPersonContactsByCalculatedCadences(
        Set<String> calculatedCadences
    ) {
        return [//NOPMD
            SELECT
                Id,
                Name,
                hed__Gender__c,
                Email,
                Citizenship_Country__c,
                Lead_Score__c,
                Marketing_Segmentation__r.My_Country_Of_Residency__c
            FROM Contact
            WHERE
                RecordTypeId = :PERSON_RECORDTYPE_ID
                AND Calculated_Cadence__c IN :calculatedCadences
                AND Can_Nurture__c = TRUE
            WITH USER_MODE
        ];
    }

    public List<Contact> getContactCalculatedCadenceByIds(
        Set<String> recordIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Calculated_Cadence__c ' +
            'FROM Contact ' +
            'WHERE RecordTypeId = :PERSON_RECORDTYPE_ID ' +
            'AND Id IN: recordIds ' +
            'AND Calculated_Cadence__c != NULL ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    /**
     * @Description:Wrapper Class that represents the extracted application details.
     */
    public class QueryParamWrapper {
        public Set<String> emailsToMatch;
        public Set<String> firstNames;
        public Set<String> lastNames;
        public Set<Date> birthdates;
        public Set<String> nominatedStudentId;

        public QueryParamWrapper() {
            emailsToMatch = new Set<String>();
            firstNames = new Set<String>();
            lastNames = new Set<String>();
            birthdates = new Set<Date>();
            nominatedStudentId = new Set<String>();
        }
    }
}