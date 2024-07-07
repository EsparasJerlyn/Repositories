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
 *    | mark.j.mahilum                 | Oct 25, 2023          | DEPP-6985              | Added query for getContactMobilePhoneByRecordIds          |
 *    | roy.nino.s.regala              | Nov 1, 2023           | DEPP-7015              | Added query for getPersonContactsBySetIds                 |
 *    | roy.nino.s.regala              | Nov 01, 2023          | DEPP-7060              | Added query for getPersonContactsWithLimit                |
 *    | julie.jane.alegre              | Nov 07, 2023          | DEPP-7152              | Added method getExistingMCPersonaContactsBySetIds         |
 *    | neil.s.h.lesidan               | Nov 23, 2023          | DEPP-7280              | Add Birthdate in getPersonContactsByEmailOrName           |
 *    | sebastianne.k.trias            | Feb 19, 2024          | DEPP-7750              | Added getPersonContactsByNameUsingSOSL method             |
 *    | eccarius.munoz                 | April 29, 2024        | DEPP-8041              | Added getQueryLocatorByCriteria and findByCriteria        |
 *    | eugene.andrew.abuan            | May 14, 2024          | DEPP-8485              | Added getContactByStudentId                               |
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
    public static final Id MC_PERSONA_RECORDTYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('MC_Persona')
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

    public static final string LEAD_SOURCE_CATEGORY_PARTNER_SOURCE ='Partner Sourced';

    public static final String CITIZENSHIP_STATUS_DOMESTIC = 'Domestic';
    public static final String CITIZENSHIP_STATUS_INTERNATIONAL = 'International';

    public static final String EXPLORE_JOURNEY_STATUS = 'Explore';
    public static final String APPLY_JOURNEY_STATUS = 'Apply';
    public static final String OFFER_JOURNEY_STATUS = 'Offer';
    public static final String ACCEPT_ADMIT_JOURNEY_STATUS = 'Accept-Admit';
    public static final String STUDY_JOURNEY_STATUS = 'Study';

    public static final String ATSI_CODE_ABORIGINAL = 'Aboriginal';
    public static final String ATSI_CODE_ISLANDER = 'Torres Strait Islander';
    public static final String ATSI_CODE_ABORIGINAL_ISLANDER = 'Aboriginal and Torres Strait Islander';

    public static final String LOW_SOCIO_ECONOMIC_STATUS_YES = 'Yes';
    public static final String LOW_SOCIO_ECONOMIC_STATUS_NO = 'No';
    public static final String LOW_SOCIO_ECONOMIC_STATUS_UNKNOWN = 'Unknown';
    public static final String REGIONAL_REMOTE_YES = 'Yes';
    public static final String REGIONAL_REMOTE_NO = 'No';
    public static final String REGIONAL_REMOTE_UNKNOWN = 'Unknown';

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
                Matching_Firstname__c,
                Matching_Lastname__c,
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
                hed__Citizenship_Status__c,
                HasOptedOutOfEmail,
                Email_Opt_In_DateTime__c,
                hed__Deceased__c,
                QUT_Student_ID__c,
                QUT_Employee_ID__c,
                MailingState,
                MailingCity,
                MailingStreet,
                MailingCountry,
                OtherState,
                OtherCity,
                OtherStreet,
                OtherCountry,
                Phone
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

    public List<Contact> getContactsByMatchingAttributes(
        Map<String,Set<String>> fieldSetMap,
        Set<Date> birthDateSet,
        AccessLevel accessLevel
    ) {

        boolean setsAreEmpty = fieldSetMap.isEmpty() && birthDateSet.isEmpty();
        Set<String> firstNameSet = fieldSetMap.get('firstName');
        Set<String> lastNameSet = fieldSetMap.get('lastName');
        Set<String> emailSet = fieldSetMap.get('email');
        Set<String> mobilePhoneSet = fieldSetMap.get('mobilePhone');
        Set<String> excludedIdsSet = fieldSetMap.get('excludedIds');

        if(setsAreEmpty){
            return new List<Contact>();
        }

        return Database.query(
            'SELECT Id, FirstName, LastName, Birthdate, Matching_Firstname__c, Matching_Lastname__c, ' +
            'Email, MobilePhone, QUT_Staff_Email__c, QUT_Learner_Email__c, Work_Email__c, ' +
            'QUT_Student_ID__c, QUT_Employee_ID__c ' +
            'FROM Contact ' +
            'WHERE RecordTypeId =: PERSON_RECORDTYPE_ID '+
            //Natural Key Matching
            'AND ((Matching_Firstname__c IN :firstNameSet ' +
            'AND Matching_Lastname__c IN :lastNameSet ' +
            'AND Birthdate IN :birthDateSet) ' +
            //Partial Key Matching OR First Name Stem
            'OR (Matching_Lastname__c IN :lastNameSet ' +
            'AND Birthdate IN :birthDateSet ' +
            'AND (Email IN :emailSet ' +
            'OR QUT_Staff_Email__c IN :emailSet ' +
            'OR QUT_Learner_Email__c IN :emailSet ' +
            'OR Work_Email__c IN :emailSet ' +
            'OR MobilePhone IN :mobilePhoneSet)) ' +
            //Maiden Name Matching
            'OR (Matching_Firstname__c IN :firstNameSet ' +
            'AND Birthdate IN :birthDateSet ' +
            'AND (Email IN :emailSet ' +
            'OR QUT_Staff_Email__c IN :emailSet ' +
            'OR QUT_Learner_Email__c IN :emailSet ' +
            'OR Work_Email__c IN :emailSet ' +
            'OR MobilePhone IN :mobilePhoneSet)) ' +
            //No DOB Matching
            'OR (Matching_Firstname__c IN :firstNameSet ' +
            'AND Matching_Lastname__c IN :lastNameSet ' +
            'AND (Email IN :emailSet ' +
            'OR QUT_Staff_Email__c IN :emailSet ' +
            'OR QUT_Learner_Email__c IN :emailSet ' +
            'OR Work_Email__c IN :emailSet ' +
            'OR MobilePhone IN :mobilePhoneSet))) ' + 
            'AND ID NOT IN: excludedIdsSet ',
            accessLevel
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
                Country_of_Residency__c,
                Partner_Sourced__c,
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
                'SELECT Id, Name, Email, MobilePhone, Mobile_No_Locale__c, Birthdate, Work_Email__c, QUT_Staff_Email__c, QUT_Learner_Email__c FROM Contact WHERE RecordTypeId =: PERSON_RECORDTYPE_ID AND (' +
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

        if(recordIds.isEmpty()){
            return new List<Contact>();
        }

        return Database.query(
            'SELECT Id, Current_Learner_Verified__c, Alumni_Verified__c, Lead_Score__c, Future_Student_Journey_Status__c, MiddleName, Salutation, ' +
            'IsStaff_Active__c, Staff_Verified__c, hed__Citizenship_Status__c, Can_Nurture__c, Birth_Country__c, Citizenship_Type__c, ' +
            'HasOptedOutOfEmail, Email_Opt_Out_DateTime__c, Learner_Email_Opt_Out__c, Learner_Email_Opt_Out_DateTime__c, Home_Language__c, ' +
            'Learner_Email_Opt_In_DateTime__c, Staff_Email_Opt_In_DateTime__c, Work_Email_Opt_In_DateTime__c, Work_SMS_Opt_In_DateTime__c, ' +
            'SMS_Opt_In_DateTime__c, QUT_Student_ID__c, QUT_Employee_ID__c, MailingAddress, OtherAddress, '+ 
            'Staff_Email_Opt_Out__c, Staff_Email_Opt_Out_DateTime__c, Work_Email_Opt_Out__c, Work_Email_Opt_Out_DateTime__c, ' +
            'Work_SMS_Opt_Out__c, Work_SMS_Opt_Out_DateTime__c, hed__SMS_Opt_Out__c, SMS_Opt_Out_DateTime__c, DoNotCall, ' +
            'Sync_to_MC__c, Do_Not_Sync_To_MC_Override__c, Dont_Market_Reason__c, QUT_Applicant__c, QUT_Lead__c, ' +
            'FirstName, LastName, Birthdate, Email_Opt_In_DateTime__c, Email, Work_Email__c, Registered_Email__c, Lead_Source_Category__c, ' +
            'Marketing_Segmentation__c, Cadence_Application__c, Calculated_Cadence__c, QUT_Staff_Email__c, QUT_Learner_Email__c, MobilePhone, ContactMobile_Locale__c, Mobile_No_Locale__c, ' +
            'Low_Socio_Economic_Status__c, Regional_Remote__c, Account.Is_Priority_Program__c, Account.RecordTypeId, ' +
            'ATSI_Code__c, Citizenship_Country__c, Is_Agent_Assisted__c, Agency_Name__c, Agency_Email__c, Is_International_Applicant__c, Applicant_Onshore__c, ' + 
            'Personal_Illness_Disability_Applicant__c, Elite_Athlete_Applicant__c, Education_Disruption_Applicant__c, Financial_Hardship_Applicant__c, First_In_Family_Applicant__c, QUT_Student__c '  +
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

    public List<Contact> getContactMobilePhoneByRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id,MobilePhone ' +
            'FROM Contact ' +
            'WHERE MobilePhone != NULL ' +
            'AND Id IN: recordIds ',
            accessLevel
        );
    }
    
    public List<Contact> getExistingMCPersonaContactsBySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT  Id ' +
                'FROM Contact ' +
                'WHERE Id IN: recordIds ' +
                'AND RecordTypeId =: MC_PERSONA_RECORDTYPE_ID ',
                accessLevel
        );
    }

    public Database.QueryLocator queryLocatorGetContactsByIds(
        Set<Id> recordIds
    ){
        String query =
        'SELECT Id, RecordTypeId, Email_Opt_In_DateTime__c, hed__Citizenship_Status__c ' +
          'FROM Contact ' +
         'WHERE Id IN: recordIds ' +
           'AND RecordTypeId =: PERSON_RECORDTYPE_ID';
        return Database.getQueryLocator(query);
    }

    public List<Contact> getContactsByParentPersonLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    ) {
        if(!leadIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Parent_Person_Contact__c, Parent_Person_Lead__c ' +
                'FROM Contact WHERE Parent_Person_Lead__c IN :leadIds',
                accessLevel
            );
        } else { return new List<Contact>(); }
    }

    public List<Contact> getContactsNoParentPersonContactByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        if(!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Email, Work_Email__c, AccountId ' +
                'FROM Contact WHERE Id IN :recordIds AND Parent_Person_Contact__c = null AND RecordTypeId =: PERSON_RECORDTYPE_ID',
                accessLevel
            );
        }  else { return new List<Contact>(); }
    }

    public List<Contact> getContactsWithParentPersonContactByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        if(!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Parent_Person_Contact__r.Id, Parent_Person_Contact__r.Email, ' +
                'Parent_Person_Contact__r.Work_Email__c, Parent_Person_Contact__r.AccountId ' +
                'FROM Contact WHERE Id IN :recordIds',
                accessLevel
            );
        }  else { return new List<Contact>(); }
    }

    public List<Contact> getMCPersonaContactsByParentPersonContactIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        return Database.query(
            'Select Id, Email, HasOptedOutOfEmail,Email_Opt_Out_DateTime__c,Email_Opt_In_DateTime__c, ' + 
            'Persona_Type__c,Parent_Person_Contact__c '+
            'FROM Contact '+
            'WHERE Parent_Person_Contact__c IN: recordIds ' +
            'AND RecordTypeId =: MC_PERSONA_RECORDTYPE_ID',
            accessLevel
        );
    }

    public List<Contact> getMCPersonaContactsByParentPersonLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        return Database.query(
            'Select Id, Email, HasOptedOutOfEmail,Email_Opt_Out_DateTime__c,Email_Opt_In_DateTime__c, ' + 
            'Persona_Type__c,Parent_Person_Lead__c, Parent_Person_Lead__r.Work_Email__c '+
            'FROM Contact '+
            'WHERE Parent_Person_Lead__c IN: recordIds ' +
            'AND RecordTypeId =: MC_PERSONA_RECORDTYPE_ID',
            accessLevel
        );
    }

    public List<Contact> getPersonContactsByNameUsingSOSL(
        String filterName
    ){
        filterName = '*'+ filterName + '*';
        List<List<Contact>> contactList = [FIND :filterName IN NAME FIELDS RETURNING Contact(name,email Where RecordTypeId = :PERSON_RECORDTYPE_ID limit 15 )];
        return contactList[0];
    }

    public String getWhereClauseByCriteria(
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ';
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ';
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ';
        }
        if(contactCriteria.getContactIdSet() != null){
            String contactIdString = DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet());
            soql += 'AND Id IN (' + contactIdString + ') ';
        }

        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
        
        return soql;
    }

    public Database.QueryLocator getQueryLocatorByCriteria(ContactsDAO.Criteria criteria) {        
        String query =
            'SELECT Id, hed__Citizenship_Status__c, QUT_Student_ID__c, Email, QUT_Learner_Email__c, Name, MobilePhone ' + 
              'FROM Contact ' + getWhereClauseByCriteria(criteria);
        return Database.getQueryLocator(query);
    }

    public Database.QueryLocator getQueryLocatorBySubQuery(String subQueryString) {   
        String query =
            'SELECT Id, hed__Citizenship_Status__c, QUT_Student_ID__c, Email, QUT_Learner_Email__c, Name, MobilePhone ' + 
              'FROM Contact WHERE Id IN (' + subQueryString + ')';
        return Database.getQueryLocator(query);
    }

    public List<Contact> findByCriteria(
        ContactsDAO.Criteria criteria, 
        AccessLevel accessLevel
    ){
        if(criteria != null && !criteria.isEmpty()){
            return Database.query(
                ' SELECT Id, hed__Citizenship_Status__c, QUT_Student_ID__c ' + 
                ' FROM Contact ' + getWhereClauseByCriteria(criteria),
                accessLevel
            );
        }
        return new List<Contact>();
    }  

    public List<Contact> getContactByStudentId(
        List<String> studentIdList,
        AccessLevel accessLevel
    ){
        if(studentIdList.isEmpty()){
            return new List<Contact>();
        }

        return Database.query(
            'SELECT Id, QUT_Student_ID__c, Name, MobilePhone, Email, QUT_Learner_Email__c FROM Contact ' +
            'Where RecordTypeId =: PERSON_RECORDTYPE_ID ' + 
            'AND QUT_Student__c = true ' +
            'AND QUT_Student_Id__c in :studentIdList', 
            accessLevel
        );
    }  

    public Database.QueryLocator getQueryLocatorContactByStudentId(
        List<String> studentIdList,
        AccessLevel accessLevel
    ){
        return Database.getQueryLocator(
            'SELECT Id, QUT_Student_ID__c, Name, MobilePhone, Email FROM Contact ' +
            'Where RecordTypeId =: PERSON_RECORDTYPE_ID ' + 
            'AND QUT_Student__c = true ' +
            'AND QUT_Student_Id__c in :studentIdList', 
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

    /**
     * @Description:Wrapper Class that represents the Criteria for Contact.
     */
    public class Criteria {
        private Boolean isQUTStudent;
        private String recordType;
        private Set<Id> contactIdSet; 
        private String citizenshipStatus;

        public Boolean getIsQUTStudent() {
            return isQUTStudent;
        }

        public void setIsQUTStudent(Boolean isQUTStudent) {
            this.isQUTStudent = isQUTStudent;
        }

        public String getRecordType() {
            return recordType;
        }

        public void setRecordType(String recordType) {
            this.recordType = recordType;
        }

        public Set<Id> getContactIdSet() {
            return contactIdSet;
        }

        public void setContactIdSet(Set<Id> contactIdSet) {
            this.contactIdSet = contactIdSet;
        }

        public String getCitizenshipStatus() {
            return citizenshipStatus;
        }

        public void setCitizenshipStatus(String citizenshipStatus) {
            this.citizenshipStatus = citizenshipStatus;
        }

        public Boolean isEmpty() {
            return isQUTStudent == null && recordType == null && contactIdSet == null && citizenshipStatus == null;
        }
    }
    
}