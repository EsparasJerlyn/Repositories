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
 *    | johanna.a.gibas                | November 24, 2023     | DEPP-7143              | Added Developed Nations Sub Category        |
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

    //CONFIGURATION CONSTANTS 
    public static final String CONFIG_DOMESTIC_UNDERGRAD = 'Total Max Score DUG';
    public static final String CONFIG_DOMESTIC_POSTGRAD = 'Total Max Score DPG';
    public static final String CONFIG_INTERNATIONAL_POSTGRAD = 'Total Max Score IPG';
    public static final String CONFIG_INTERNATIONAL_UNDERGRAD = 'Total Max Score IUG';
    public static final String CONFIG_UNDETERMINED_UNDETERMINED = 'Total Max Score UU';
    public static final String CONFIG_DOMESTIC_UNDETERMINED = 'Total Max Score DU';
    public static final String CONFIG_INTERNATIONAL_UNDETERMINED = 'Total Max Score IU';

    //CATEGORY CONSTANTS START
    public static final String CONFIG_CATEGORY_COUNTRY_TIER = 'Country Tier';
    public static final String CONFIG_CATEGORY_FUNDING = 'Funding';
    public static final String CONFIG_CATEGORY_EVENT_REG_ATTD = 'Event Registration and Attendance';
    public static final String CONFIG_CATEGORY_PROGRAM_ENGAGEMENT = 'Program Engagement';
    public static final String CONFIG_CATEGORY_ENQUIRIES = 'Enquiries';
    public static final String CONFIG_CATEGORY_DOWNLOADED_PDF = 'Downloaded PDF';
    public static final String CONFIG_CATEGORY_MATCH_MY_SKILLS = 'Match My Skills';
    public static final String CONFIG_CATEGORY_MKT_CONSENT = 'Marketing consent';
    public static final String CONFIG_CATEGORY_RESIDENCE = 'Residence';
    public static final String CONFIG_CATEGORY_PRIMARY_BSA = 'Primary BSA';
    public static final String CONFIG_CATEGORY_PRIMARY_NSA = 'Primary NSA';
    public static final String CONFIG_CATEGORY_PREF_INTAKE = 'Preferred Intake';
    public static final String CONFIG_CATEGORY_COURSE_LEVEL = 'Course Level';
    public static final String CONFIG_CATEGORY_INT_DOUBLE_DEG = 'Interested in Double Degrees';
    public static final String CONFIG_CATEGORY_INT_ENG_PATH = 'Interested in English Pathway Programs';
    public static final String CONFIG_CATEGORY_EMAIL_INTERACTION = 'Email Interaction';
    //CATEGORY CONSTANTS END    

    /***SUB CATEGORY CONSTANTS START**/
    //CONFIG_CATEGORY_COUNTRY_TIER
    public static final String CONFIG_SUB_CATEGORY_COUNTRY_TIER1 = 'Country Tier1';
    public static final String CONFIG_SUB_CATEGORY_COUNTRY_TIER2 = 'Country Tier2';
    public static final String CONFIG_SUB_CATEGORY_COUNTRY_TIER3 = 'Country Tier3';
    public static final String CONFIG_SUB_CATEGORY_UNRESTRICTED_COHORT = 'Untiered nationality - unrestricted cohort (ex. developed countries)';
    public static final String CONFIG_SUB_CATEGORY_RESTRICTED_COHORT = 'Untiered nationality - restricted cohort, Australian';
    public static final String CONFIG_SUB_CATEGORY_DEVELOPED_NATIONS = 'Developed Nations';
    public static final String CONFIG_SUB_CATEGORY_UNLISTED = 'Unlisted';
    //CONFIG_CATEGORY_FUNDING
    public static final String CONFIG_SUB_CATEGORY_COMPANY_FUNDED = 'Company Funded';
    public static final String CONFIG_SUB_CATEGORY_I_FUND_MY_STUDIES_MYSELF = 'I will fund my studies myself';
    public static final String CONFIG_SUB_CATEGORY_MY_FAMILY_WILL_FUND_MY_STUDIES = 'My family will fund my studies';
    public static final String CONFIG_SUB_CATEGORY_I_ALREADY_HAVE_A_SCHOLARSHIP_LOAN_OR_SPONSORSHIP = 'I already have a scholarship, loan or sponsorship';
    public static final String CONFIG_SUB_CATEGORY_I_AM_NOT_SURE = 'I am not sure';
    public static final String CONFIG_SUB_CATEGORY_I_NEED_A_FULL_SCHOLARSHIP = 'I need a full scholarship';
    //CONFIG_CATEGORY_EVENT_REG_ATTD
    public static final String CONFIG_SUB_CATEGORY_OPEN_DAY_REG = 'Open Day Registration';
    public static final String CONFIG_SUB_CATEGORY_OTHER_EVENT_REG = 'Other Event Registration';
    public static final String CONFIG_SUB_CATEGORY_OTHER_EVENT_ATTD = 'Other Event Attendance';
    //CONFIG_CATEGORY_PROGRAM_ENGAGEMENT
    public static final String CONFIG_SUB_CATEGORY_PROG_ENG_ATTD = 'Program Engagement attendance';
    //CONFIG_CATEGORY_ENQUIRIES
    public static final String CONFIG_SUB_CATEGORY_APPLYING_FOR_COURSE = 'Applying for a course';
    public static final String CONFIG_SUB_CATEGORY_ENTRY_REQ_STUDY_PATH = 'Entry requirements & study pathways';
    public static final String CONFIG_SUB_CATEGORY_FEES_COST_SCHOLARSHIP = 'Fees, costs and scholarships';
    public static final String CONFIG_SUB_CATEGORY_COURSE_INFO = 'Course information';
    public static final String CONFIG_SUB_CATEGORY_COURSE_APPLICATION_AND_OFFERS = 'Course application & offers';
    public static final String CONFIG_SUB_CATEGORY_PREPARING_TO_STUDY = 'Preparing to Study';
    public static final String CONFIG_SUB_CATEGORY_STUDY_LIFE = 'Student life';
    //CONFIG_CATEGORY_DOWNLOADED_PDF
    public static final String CONFIG_SUB_CATEGORY_COURSE_PAGE_PDF = 'Course Page PDF';
    public static final String CONFIG_SUB_CATEGORY_WELCOME_GUIDE = 'Welcome Guide';
    public static final String CONFIG_SUB_CATEGORY_COURSE_GUIDE = 'Course Guides';
    //CONFIG_CATEGORY_MATCH_MY_SKILLSF
    public static final String CONFIG_SUB_CATEGORY_MATCH_MY_SKILLS_COMP = 'Match My Skills completed';
    //CONFIG_CATEGORY_MKT_CONSENT
    public static final String CONFIG_SUB_CATEGORY_IS_BLANK = 'is blank';
    public static final String CONFIG_SUB_CATEGORY_YES = 'Yes';
    public static final String CONFIG_SUB_CATEGORY_NO = 'No';
    //CONFIG_CATEGORY_RESIDENCE
    public static final String CONFIG_SUB_CATEGORY_AU_ONSHORE = 'Australia (Onshore)';
    public static final String CONFIG_SUB_CATEGORY_NON_AU_OFFSHORE = 'Non-Australia (offshore)';
    //CONFIG_CATEGORY_PRIMARY_BSA / CONFIG_CATEGORY_PRIMARY_NSA
    public static final String CONFIG_SUB_CATEGORY_IS_UNSURE = 'Is unsure';
    public static final String CONFIG_SUB_CATEGORY_IS_NOT_BLANK = 'Is not blank';
    public static final String CONFIG_SUB_CATEGORY_IS_BLANK_UPPER = 'Is blank';
    //CONFIG_CATEGORY_PREF_INTAKE
    public static final String CONFIG_SUB_CATEGORY_ROLLING_EACH_YR = 'Is this year (rolling each year)';
    public static final String CONFIG_SUB_CATEGORY_NEXT_YEAR = 'Next year';
    //CONFIG_CATEGORY_COURSE_LEVEL
    public static final String CONFIG_SUB_CATEGORY_POSTGRAD = 'Postgraduate';
    public static final String CONFIG_SUB_CATEGORY_HIGHER_DEGREE = 'Higher Degree Research';
    public static final String CONFIG_SUB_CATEGORY_SHORT_COURSES = 'Short courses and Professional Development';
    public static final String CONFIG_SUB_CATEGORY_EXCHANGE_AND_STUDY = 'Exchange and Study Abroad (1 or 2 Semesters Only)';
    public static final String CONFIG_SUB_CATEGORY_UNDERGRAD = 'Undergraduate';
    //CONFIG_CATEGORY_EMAIL_INTERACTION
    public static final String CONFIG_SUB_CATEGORY_HAS_CLICKED_EMAIL = 'Has Clicked Email';
    /***SUB CATEGORY CONSTANTS END**/

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
                RecordType.DeveloperName,
                Score_Allocation__c,
                Time_Limit_Months__c
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

    public List<Lead_Score_Configuration__c> getLeadScoreConfigsById(Set<Id> leadScoreConfigIds, List<String> fields, AccessLevel accessLevel) {

        List<Lead_Score_Configuration__c> configList = new List<Lead_Score_Configuration__c>();

        if(!leadScoreConfigIds.isEmpty()){
            String fieldsToQuery = fields.size() > 0 ? 'Id, ' + String.join(fields, ',') : 'Id';
            configList = Database.query(
                'SELECT ' + String.escapeSingleQuotes(fieldsToQuery) + ' ' +
                  'FROM Lead_Score_Configuration__c ' +
                 'WHERE Id IN: leadScoreConfigIds', accessLevel
            );
        }

        return configList;

    }

    public Database.QueryLocator queryLocatorLeadScoreConfigByIds(Set<Id> leadScoreConfigIds){
        String query =
            'SELECT Id, Name, Domestic_International__c, Study_Level__c ' + 
              'FROM Lead_Score_Configuration__c ' + 
             'WHERE Id IN: leadScoreConfigIds';
        return Database.getQueryLocator(query);
    }

    public List<Lead_Score_Configuration__c> getCategoryLeadScoreConfigsById(Set<Id> leadScoreConfigIds, List<String> fields, AccessLevel accessLevel) {
        List<Lead_Score_Configuration__c> configList = new List<Lead_Score_Configuration__c>();
        if(!leadScoreConfigIds.isEmpty()){
            String fieldsToQuery = fields.size() > 0 ? 'Id, ' + String.join(fields, ',') : 'Id';
            configList = Database.query(
                'SELECT ' + String.escapeSingleQuotes(fieldsToQuery) + ' ' +
                  'FROM Lead_Score_Configuration__c ' +
                 'WHERE Id IN: leadScoreConfigIds AND RecordTypeId =: RECTYPE_ID_CATEGORY ', accessLevel
            );
        }
        return configList;
    }

} 
