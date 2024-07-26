/**
 * @description DAO Class for Lead Object. Contains soql and constants related to the Lead object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                    |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------|
      | rhea.b.torres                  | April 25, 2023        | DEPP-5567              | Created file                                                      |
      | mark.j.mahilum                 | June 26,2023          | DEPP-5846              | Added new method getExistingUnconvertedLeads                      |
      | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | Added new method                                                  |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new method getLeadsCalculatedCadenceByIds                   |
      | neil.s.h.lesidan               | Sept 20, 2023         | DEPP-6478              | Added getLeadByEmailOrName                                        |
      | neil.s.h.lesidan               | Sept 20, 2023         | DEPP-6478              | Added QueryParamWrapperEmailOrName                                |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added new method getLeadsByCaseMobile                             |
      | mark.j.mahilum                 | Oct 25, 2023          | DEPP-6985              | Added new method getLeadMobilePhoneByRecordIds                    |
      | roy.nino.s.regala              | Nov 01, 2023          | DEPP-7105              | Updated fields on soql for getLeadsByIdSet                        |
      | roy.nino.s.regala              | Nov 01, 2023          | DEPP-7060              | Added new method getLeadsWithLimit and  getLeadsByIdSet           |
      | alexander.cadalin              | November 9, 2023      | DEPP-7212              | Added excludeConverted to getLeadByEmailOrName                    |
      | neil.s.h.lesidan               | Nov 23, 2023          | DEPP-7280              | Fix conditional query getLeadByEmailOrName                        |
      | eccarius.munoz                 | March 4, 2024         | DEPP-7699              | Added static variables for lead source and lead source category   |
 */
public inherited sharing class LeadsDAO extends DmlBase implements ILeadsDAO {
    /**
     * Lead Constants
     */
    public static final String AU_LOCALE = 'Australia (+61)';
    public static final String CCE_CORPORATE_PARTNER = 'CCE Corporate Partner'; 
    public static final String QUALIFIED_STATUS = 'Qualified';
    public static final String NEW_STATUS = 'New';
    public static final String ENGAGING_STATUS = 'Engaging';
    public static final String NURTURING_STATUS = 'Nurturing';
    public static final String EXPLORE_JOURNEY_STATUS = 'Explore';
    public static final String APPLY_JOURNEY_STATUS = 'Apply';
    public static final String OFFER_JOURNEY_STATUS = 'Offer';
    public static final String ACCEPT_ADMIT_JOURNEY_STATUS = 'Accept-Admit';
    public static final String STUDY_JOURNEY_STATUS = 'Study';
    public static final String LEARNER_LEAD_TYPE = 'Learner';
    public static final String COMPANY_LEARNER = 'Learner';

    //Lead source category
    public static final string LEAD_SOURCE_CATEGORY_PARTNER_SOURCED = 'Partner Sourced';
    public static final string LEAD_SOURCE_CATEGORY_STUDY_APPLICATION = 'Study Application';
    public static final string LEAD_SOURCE_CATEGORY_ONLINE_INTERACTION = 'Online Interaction';
    public static final string LEAD_SOURCE_CATEGORY_OTHER = 'Other';

    //Lead source
    public static final string LEAD_SOURCE_STUDYLINK_STUDYLINK_UNSUBMITTED = 'Studylink Unsubmitted';
    public static final string LEAD_SOURCE_ENQUIRY_FORM = 'Enquiry Form';
    public static final string LEAD_SOURCE_MANUAL_CREATE = 'Manual Create';

    public static ILeadsDAO newInstance() {
        return (ILeadsDAO) ImplementationSelector.DAO.newInstance(Lead.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Lead.SObjectType;
    }

    public List<Lead> getExistingUnconvertedLeadsByEmail(
        Set<String> allEmailsToMatch,
        Set<Id> excludedLeadsRecordsSet,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Email, Work_Email__c, IsConverted ' +
                'FROM Lead ' +
                'WHERE Id NOT IN: excludedLeadsRecordsSet ' +
                'AND (Email IN: allEmailsToMatch ' +
                'OR Work_Email__c IN: allEmailsToMatch) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Lead> getLeadsWithLimit(Integer recordsCount) {
        return [//NOPMD
            SELECT Email, Work_Email__c, Status, Future_Student_Journey_Status__c, Can_Nurture__c, Lead_Source_Category__c, 
            Lead_Score__c, Calculated_Cadence__c, HasOptedOutOfEmail, Marketing_Segmentation__r.My_Citizenship_Status__c, MobilePhone, IsConverted,
            Email_Opt_In_DateTime__c, LeadSource, LastName
            FROM Lead
            WITH SYSTEM_MODE//Only used in test class to verify record insert/update
            LIMIT :recordsCount
        ];
    }

    public List<Lead> getExistingUnconvertedLeads(
        Set<String> allEmailsToMatch,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Email, Work_Email__c, IsConverted ' +
                'FROM Lead ' +
                'WHERE IsConverted = FALSE ' +
                'AND (Email IN: allEmailsToMatch ' +
                'OR Work_Email__c IN: allEmailsToMatch) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Lead> getLearnerLeadsByCalculatedCadences(Set<String> calculatedCadences) {
        return [ //NOPMD
            SELECT
                Id,
                Name,
                hed__Gender__c,
                Email,
                Lead_Score__c,
                Marketing_Segmentation__r.My_Country_Of_Residency__c,
                Marketing_Segmentation__r.My_Country_Of_Citizenship__c,
                Marketing_Segmentation__r.My_Primary_BSA__c
            FROM Lead
            WHERE
                Lead_Type__c = 'Learner'
                AND Calculated_Cadence__c IN :calculatedCadences
                AND IsConverted = FALSE
                AND Can_Nurture__c = TRUE
            WITH USER_MODE
        ];
    }

    public List<Lead> getLeadsCalculatedCadenceByIds(
        Set<String> recordIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Calculated_Cadence__c ' +
            'FROM Lead ' +
            'WHERE IsConverted = FALSE ' +
            'AND Id IN: recordIds ' +
            'AND Calculated_Cadence__c != NULL ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<Lead> getLeadsByCaseMobile(
        Set<String> caseMobile,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id,MobilePhone ' +
            'FROM Lead ' +
            'WHERE MobilePhone != NULL ' +
            'AND MobilePhone IN: caseMobile ' +
            'AND IsConverted = FALSE ',
            accessLevel
        );
    }

    public List<Lead> getLeadsByIdSet(
        Set<Id> recordIdSet,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id,Future_Student_Journey_Status__c, Can_Nurture__c, Status, Email,Marketing_Segmentation__r.My_Citizenship_Status__c, Email_Opt_In_DateTime__c, HasOptedOutOfEmail, Lead_Source_Category__c, ' +
            'Marketing_Segmentation__c, Cadence_Application__c, Calculated_Cadence__c, LeadMobile_Locale__c, Mobile_No_Locale__c, MobilePhone, Work_Email__c, Lead_Type__c FROM Lead ' +
            'WHERE Id IN: recordIdSet ',
            accessLevel
        );
    }

    public List<Lead> getLeadsByIdSetAndType(
        Set<Id> recordIdSet,
        String leadType,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id,Future_Student_Journey_Status__c, Can_Nurture__c, Status, Email_Opt_In_DateTime__c ' +
              'FROM Lead ' +
             'WHERE Id IN: recordIdSet AND Lead_Type__c =: leadType',
            accessLevel
        );
    }

    public List<Lead> getLeadByEmailOrName(
        QueryParamWrapperEmailOrName queryParam,
        Boolean excludeConverted,
        AccessLevel accessLevel
    ) {
        List<Lead> leadList = new List<Lead>();
        String email = queryParam.email; //NOPMD
        String firstName = queryParam.firstName; //NOPMD
        String lastName = queryParam.lastName; //NOPMD
        String mobile = queryParam.mobile; //NOPMD
        String toQuery = removeEmptyParamsInQueryEmail(queryParam);
        toQuery = removeEmptyParamsInQueryName(queryParam, toQuery);
        toQuery = removeEmptyParamsInQueryMobile(queryParam, toQuery);

        if(excludeConverted) {
            toQuery = toQuery != '' ? '(' + toQuery + ') AND ' : toQuery;
            toQuery = toQuery != '' ? toQuery + '(IsConverted = false)' : toQuery;
        }

        if (!String.isBlank(toQuery)) {
            leadList = Database.query(
                'SELECT Id, Name, Email, MobilePhone, Mobile_No_Locale__c, Work_Email__c FROM Lead WHERE ' +
                toQuery,
                AccessLevel
            );
        }

        return leadList;

    }

    private String removeEmptyParamsInQueryEmail(QueryParamWrapperEmailOrName queryParam) {
        String email = queryParam.email;
        String toQuery = '';

        if (email != null && email != '') {
            toQuery = toQuery + '(Email =: email OR Work_Email__c =: email)';
        }

        return toQuery;
    }

    private String removeEmptyParamsInQueryName(QueryParamWrapperEmailOrName queryParam, String toQuery) {
        String firstName = queryParam.firstName;
        String lastName = queryParam.lastName;

        if (firstName != null && firstName != '' && lastName != null  && lastName != '') {
            toQuery = toQuery != '' ? toQuery + ' OR ' : toQuery;
            toQuery = toQuery + '(FirstName =: firstName AND LastName =: lastName )';
        }

        return toQuery;
    }

    private String removeEmptyParamsInQueryMobile(QueryParamWrapperEmailOrName queryParam, String toQuery) {
        String mobile = queryParam.mobile;

        if (mobile != null && mobile != '') {
            toQuery = toQuery != '' ? toQuery + ' OR ' : toQuery;
            toQuery = toQuery + '(MobilePhone =: mobile)';
        }

        return toQuery;
    }

    public Database.QueryLocator queryLocatorGetLeadsByIds(
        Set<Id> recordIds,
        String leadType
    ){
        String query =
            'SELECT Id,Future_Student_Journey_Status__c, Can_Nurture__c, Status, Email_Opt_In_DateTime__c ' +
              'FROM Lead ' +
             'WHERE Id IN: recordIds AND Lead_Type__c =: leadType';
        return Database.getQueryLocator(query);
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

    public List<Lead> getLeadMobilePhoneByRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id,MobilePhone ' +
            'FROM Lead ' +
            'WHERE MobilePhone != NULL ' +
            'AND Id IN: recordIds ',
            accessLevel
        );
    }

    public List<Lead> getUnconvertedLeadsByIdSet(
        Set<Id> recordIdSet,
        AccessLevel accessLevel
    ){
        if(recordIdSet.isEmpty()){
            return new List<Lead>();
        }
        return Database.query(
            'SELECT Id ' +
              'FROM Lead ' +
             'WHERE Id IN: recordIdSet AND IsConverted = FALSE',
            accessLevel
        );
    }

    
    public List<Lead> getLearnerLeadsByEmailOrWorkEmail(
        Set<String> emails,
        AccessLevel accessLevel
    ) {
        if(!emails.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Email, Work_Email__c, ' +
                '(SELECT Id, Contact__c FROM Marketing_Interactions__r), ' +
                '(SELECT Id, Contact__c FROM Marketing_Course_Applications__r), ' +
                '(SELECT Id, hed__Applicant__c FROM Applications__r), ' +
                '(SELECT Id, Parent_Person_Contact__c FROM Contacts__r) ' +
                'FROM Lead ' +
                'WHERE (Email IN :emails OR Work_Email__c IN :emails) ' +
                'AND Lead_Type__c = :LEARNER_LEAD_TYPE',
                accessLevel
            );
        } else { return new List<Lead>(); }
    }

    public List<Lead> getLearnerLeadsByEmailOrWorkEmail(
        Set<String> emails,
        Set<String> workEmails,
        AccessLevel accessLevel
    ) {
        if((!emails.isEmpty() || !workEmails.isEmpty())  && accessLevel != null) {
            return Database.query(
                'SELECT Id, Email, Work_Email__c, Name FROM Lead ' +
                'WHERE ((Email IN :emails OR Email IN :workEmails) ' +
                'OR (Work_Email__c IN :workEmails OR Work_Email__c IN :emails)) ' +
                'AND Lead_Type__c = :LEARNER_LEAD_TYPE',
                accessLevel
            );
        } else { return new List<Lead>(); }
    }
}