/**
 * @description DAO Class for Lead_Score_Configuration__c Object. Contains soql and constants related to the Lead_Score_Configuration__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | Created file                                |
 *    | eccarius.munoz                 | September 25, 2023    | DEPP-5866              | Added constants for Lead Score Calculation  |
 *    | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Added getLeadScoreConfig                    |
 *    | arsenio.jr.dayrit              | October 23, 2023      | DEPP-6929              | Added constant for Lead Score Calculation   |
 */
public inherited sharing class LeadScoreConfigurationDAO extends DmlBase implements ILeadScoreConfigurationDAO {
    public static final Id RECTYPE_ID_CONFIG = Schema.SObjectType.Lead_Score_Configuration__c.getRecordTypeInfosByDeveloperName()
        .get('Configuration')
        .getRecordTypeId();
    public static final Id RECTYPE_ID_CATEGORY = Schema.SObjectType.Lead_Score_Configuration__c.getRecordTypeInfosByDeveloperName()
        .get('Category')
        .getRecordTypeId();
    public static final Id RECTYPE_ID_SUB_CATEGORY = Schema.SObjectType.Lead_Score_Configuration__c.getRecordTypeInfosByDeveloperName()
        .get('Sub_Category')
        .getRecordTypeId();
    public static final Set<Id> RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY = new Set<Id>{
        RECTYPE_ID_CATEGORY,
        RECTYPE_ID_SUB_CATEGORY
    };

    public static final String RECORD_TYPE_CONFIGURATION = 'Configuration';

    public static final String DOMESTIC = 'Domestic';
    public static final String INTERNATIONAL = 'International';
    public static final String UNDETERMINED = 'Undetermined';

    public static final String PRIMARY_STUDY_LEVEL_UNDERGRAD = 'Undergraduate';
    public static final String PRIMARY_STUDY_LEVEL_POSTGRAD = 'Postgraduate';
    public static final String PRIMARY_STUDY_LEVEL_UNDETERMINED = 'Undetermined';

    //CATEGORY CONSTANTS START
    public static final String CONFIG_CATEGORY_COUNTRY_TIER = 'Country Tier';
    public static final String CONFIG_CATEGORY_FUNDING = 'Funding';
    public static final String CONFIG_CATEGORY_EVENT_REG_ATTD = 'Event Registration and Attendance';
    //CATEGORY CONSTANTS END

    //SUB CATEGORY CONSTANTS START
    public static final String CONFIG_SUB_CATEGORY_COUNTRY_TIER1 = 'Country Tier1';
    public static final String CONFIG_SUB_CATEGORY_COUNTRY_TIER2 = 'Country Tier2';
    public static final String CONFIG_SUB_CATEGORY_COUNTRY_TIER3 = 'Country Tier3';
    public static final String CONFIG_SUB_CATEGORY_UNRESTRICTED_COHORT = 'Untiered nationality - unrestricted cohort (ex. developed countries)';
    public static final String CONFIG_SUB_CATEGORY_RESTRICTED_COHORT = 'Untiered nationality - restricted cohort, Australian';
    public static final String CONFIG_SUB_CATEGORY_COMPANY_FUNDED = 'Company Funded';
    public static final String CONFIG_SUB_CATEGORY_I_FUND_MY_STUDIES_MYSELF = 'I will fund my studies myself';
    public static final String CONFIG_SUB_CATEGORY_MY_FAMILY_WILL_FUND_MY_STUDIES = 'My family will fund my studies';
    public static final String CONFIG_SUB_CATEGORY_I_ALREADY_HAVE_A_SCHOLARSHIP_LOAN_OR_SPONSORSHIP = 'I already have a scholarship, loan or sponsorship';
    public static final String CONFIG_SUB_CATEGORY_I_AM_NOT_SURE = 'I am not sure';
    public static final String CONFIG_SUB_CATEGORY_I_NEED_A_FULL_SCHOLARSHIP = 'I need a full scholarship';
    public static final String CONFIG_SUB_CATEGORY_OPEN_DAY_REG = 'Open Day Registration';
    public static final String CONFIG_SUB_CATEGORY_OTHER_EVENT_REG = 'Other Event Registration';
    public static final String CONFIG_SUB_CATEGORY_OTHER_EVENT_ATTD = 'Other Event Attendance';
    //SUB CATEGORY CONSTANTS END

    public Schema.SObjectType getSObjectType() {
        return Lead_Score_Configuration__c.SObjectType;
    }

    public static ILeadScoreConfigurationDAO newInstance() {
        return (ILeadScoreConfigurationDAO) ImplementationSelector.DAO.newInstance(
            Lead_Score_Configuration__c.SObjectType
        );
    }

    public List<Lead_Score_Configuration__c> getLeadScoreConfigByCitizenshipStudyLvl(
        String citizenshipStatus,
        String primaryStudyLevel
    ) {
        return [
            //NOPMD
            SELECT
                Id,
                Max_Score__c,
                Study_Level__c,
                Domestic_International__c,
                RecordType.DeveloperName
            FROM Lead_Score_Configuration__c
            WHERE
                Domestic_International__c = :citizenshipStatus
                AND Study_Level__c = :primaryStudyLevel
            WITH USER_MODE
        ];
    }

    public List<Lead_Score_Configuration__c> getLeadScoreConfigByRecordTypeIds(
        AccessLevel accessLevel,
        Set<Id> recordTypes
    ) {
        return Database.query(
            'SELECT Id, Name, RecordTypeId, Description__c, Domestic_International__c, Max_Score__c, ' + 
            'Parent_Category__c, Parent_Category__r.Name, Score_Allocation__c, Study_Level__c, Time_Limit_Months__c ' +
            'FROM Lead_Score_Configuration__c ' +
            'WHERE RecordTypeId IN : recordTypes ',
            accessLevel
        );
    }
}
