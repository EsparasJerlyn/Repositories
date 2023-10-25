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
      | julie.jane.alegre              | Sept 05, 2023         | DEPP-5965              | Added new method getContactsFromConvertedLead             |
      | roy.nino.s.regala              | Sept 20, 2023         | DEPP-6714              | Added new method getPersonContactsBySetIds                |
      | neil.s.h.lesidan               | Sept 20, 2023         | DEPP-6478              | Added getPersonContactsByEmailOrName                      |
      | neil.s.h.lesidan               | Sept 20, 2023         | DEPP-6478              | Added QueryParamWrapperEmailOrName                        |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added method for getContactByCaseMobile                   |
      | julie.jane.alegre              | Sept 20, 2023         | DEPP-6667              | Added fields in method getPersonContactsBySetIds          |
      | roy.nino.s.regala              | Sep 22, 2023          | DEPP-6365              | Added addition fields for soql                            |
 *    | alexander.cadalin              | Sep 22, 2023          | DEPP-6652              | method getContactsForQTACAddressUpdate                    |
 *    |                                |                       | DEPP-6652,6653,6654    | added fields to getPersonContactsBySetIds                 |
 *    |                                | Oct 19, 2023          | DEPP-6890              | null checker for queries checking for emails              |
 *    | julie.jane.alegre              | Oct 25, 2023          | DEPP-6955              | Added fields in method getPersonContactsBySetIds          |
 */
public inherited sharing class ContactsDAO extends DmlBase implements IContactsDAO { //NOPMD
    /**
     * Contact Constants
     */
    public static final String PERSON_RECORDTYPE = System.Label.RT_Contact_Person;
    public static final String ID_PREFIX = '003'; //Constant contact Id prefix see: https://help.salesforce.com/s/articleView?id=000385203&type=1
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

    public static final String CITIZENSHIP_STATUS_DOMESTIC = 'Domestic';
    public static final String CITIZENSHIP_STATUS_INTERNATIONAL = 'International';

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
                FirstName,
                LastName,
                Birthdate,
                Email,
                QUT_Learner_Email__c,
                QUT_Staff_Email__c,
                QUT_Applicant__c,
                QUT_Student__c,
                Work_Email__c,
                hed__Preferred_Email__c,
                hed__AlternateEmail__c,
                Future_Student_Journey_Status__c,
                Lead_Score__c,
                Lead_Score_Detail__c,
                Calculated_Cadence__c,
                hed__Citizenship_Status__c                
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
                'AND ((Email != NULL AND Email IN: applicationEmailsToMatch) ' +
                'OR (QUT_Learner_Email__c != NULL AND QUT_Learner_Email__c IN: applicationEmailsToMatch) ' +
                'OR (QUT_Staff_Email__c !=NULL AND QUT_Staff_Email__c IN: applicationEmailsToMatch) ' +
                'OR (Work_Email__c !=NULL AND Work_Email__c IN: applicationEmailsToMatch)))) ' +
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
            'AND ((Email != NULL AND Email IN: applicationEmailsToMatch) ' +
            'OR (QUT_Learner_Email__c != NULL AND QUT_Learner_Email__c IN: applicationEmailsToMatch) ' +
            'OR (QUT_Staff_Email__c !=NULL AND QUT_Staff_Email__c IN: applicationEmailsToMatch) ' +
            'OR (Work_Email__c !=NULL AND Work_Email__c IN: applicationEmailsToMatch)) ' +
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
                'AND ((Email != NULL AND Email IN: applicationEmailsToMatch) ' +
                'OR (QUT_Learner_Email__c != NULL AND QUT_Learner_Email__c IN: applicationEmailsToMatch) ' +
                'OR (QUT_Staff_Email__c !=NULL AND QUT_Staff_Email__c IN: applicationEmailsToMatch) ' +
                'OR (Work_Email__c !=NULL AND Work_Email__c IN: applicationEmailsToMatch)))) ' +
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
                Is_Agent_Assisted__c,
                Marketing_Segmentation__r.My_Country_Of_Residency__c,
                Marketing_Segmentation__r.My_Primary_BSA__c
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

    public static List<Contact> getContactsFromConvertedLead(
        Set<Id> recordIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Lead_Score_Detail__c ' +
                'FROM Contact ' +
                'WHERE Id IN: recordIds ' +
                'AND RecordTypeId =: PERSON_RECORDTYPE_ID ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Contact> getPersonContactsByEmailOrName(
        QueryParamWrapperEmailOrName queryParam,
        AccessLevel accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        String email = queryParam.email; //NOPMD
        String firstName = queryParam.firstName; //NOPMD
        String lastName = queryParam.lastName; //NOPMD
        String mobile = queryParam.mobile; //NOPMD
        String toQuery = removeEmptyParamsInQueryEmail(queryParam);
        toQuery = removeEmptyParamsInQueryName(queryParam, toQuery);
        toQuery = removeEmptyParamsInQueryMobile(queryParam, toQuery);

        if (!String.isBlank(toQuery)) {
            contactList = Database.query(
                'SELECT Id, Name, Email, MobilePhone, Mobile_No_Locale__c, Work_Email__c, QUT_Staff_Email__c, QUT_Learner_Email__c FROM Contact WHERE RecordTypeId =: PERSON_RECORDTYPE_ID AND (' +
                toQuery + ')',
                AccessLevel
            );
        }

        return contactList;
    }

    private static String removeEmptyParamsInQueryEmail(QueryParamWrapperEmailOrName queryParam) {
        String email = queryParam.email;
        String toQuery = '';

        if (email != null && email != '') {
            toQuery = toQuery + '(Email =: email OR hed__WorkEmail__c =: email OR QUT_Learner_Email__c =: email OR QUT_Staff_Email__c =: email)';
        }

        return toQuery;
    }

    private static String removeEmptyParamsInQueryName(QueryParamWrapperEmailOrName queryParam, String toQuery) {
        String firstName = queryParam.firstName;
        String lastName = queryParam.lastName;

        if (firstName != null && firstName != '' && lastName != null  && lastName != '') {
            toQuery = toQuery != '' ? toQuery + ' OR ' : toQuery;
            toQuery = toQuery + '(FirstName =: firstName AND LastName =: lastName )';
        }

        return toQuery;
    }

    private static String removeEmptyParamsInQueryMobile(QueryParamWrapperEmailOrName queryParam, String toQuery) {
        String mobile = queryParam.mobile;

        if (mobile != null && mobile != '') {
            toQuery = toQuery != '' ? toQuery + ' OR ' : toQuery;
            toQuery = toQuery + '(MobilePhone =: mobile)';
        }

        return toQuery;
    }

    public List<Contact> getPersonContactsBySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id, Current_Learner_Verified__c, Alumni_Verified__c, Lead_Score__c, Future_Student_Journey_Status__c, ' +
            'IsStaff_Active__c, Staff_Verified__c, hed__Citizenship_Status__c, Can_Nurture__c, ' +
            'HasOptedOutOfEmail, Email_Opt_Out_DateTime__c, Learner_Email_Opt_Out__c, Learner_Email_Opt_Out_DateTime__c, ' +
            'Staff_Email_Opt_Out__c, Staff_Email_Opt_Out_DateTime__c, Work_Email_Opt_Out__c, Work_Email_Opt_Out_DateTime__c, ' +
            'Work_SMS_Opt_Out__c, Work_SMS_Opt_Out_DateTime__c, hed__SMS_Opt_Out__c, SMS_Opt_Out_DateTime__c, DoNotCall, ' +
            'Sync_to_MC__c, Do_Not_Sync_To_MC_Override__c, Dont_Market_Reason__c, QUT_Applicant__c, QUT_Lead__c, ' +
            'FirstName, LastName, Birthdate, Email_Opt_In_DateTime__c,  Email, Work_Email__c, Registered_Email__c ' +
                'FROM Contact ' +
                'WHERE Id IN: recordIds ' +
                'AND RecordTypeId =: PERSON_RECORDTYPE_ID ',
                accessLevel
        );
    }
    
    public static List<Contact> getContactsForQTACAddressUpdate(
        Set<Id> qtacApplicantIdSet,
        AccessLevel accessLevel
    ) {
        return Database.query( 'SELECT Id, (' +
            'SELECT hed__Address_Type__c, hed__MailingStreet__c, hed__MailingStreet2__c, ' +
            'hed__MailingCity__c, hed__MailingState__c, hed__MailingCountry__c, ' +
            'hed__MailingPostalCode__c, hed__Parent_Contact__c ' +
            'FROM hed__Addresses__r' +
            ') FROM Contact WHERE Id IN :qtacApplicantIdSet',
            accessLevel
        );
    }

    public List<Contact> getContactByCaseMobile(
        Set<String> caseMobile,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id,MobilePhone ' +
                'FROM Contact ' +
                'WHERE MobilePhone != NULL ' +
                'AND MobilePhone IN: caseMobile ' +
                'AND RecordTypeId =: PERSON_RECORDTYPE_ID ',
                accessLevel
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

    public class QueryParamWrapperEmailOrName{
        public String email;
        public String firstName;
        public String lastName;
        public String mobile;

        public QueryParamWrapperEmailOrName(String strEmail, String strFirstName, String strLastName, String strMobile) { //NOPMD
            email = strEmail;
            firstName = strFirstName;
            lastName = strLastName;
            mobile = strMobile;
        }
    }
}