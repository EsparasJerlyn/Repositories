/**
 * @description Interface for Marketing Segmentation DAO 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Created file                                              |
      | arsenio.jr.dayrit              | October 23, 2023      | DEPP-6929              | Added constant for Lead Score Calculation                 |
      | roy.nino.s.regala              | November 01, 2023     | DEPP-7060              | Added field for getMarketingSegmentationByContactOrLead   |
      | johanna.a.gibas                | Jan 04, 2024          | ApexCRUDViolationFix   | Added method for getExistingMarketingSegmentations        |
      | roy.nino.s.regala              | Jan 11, 2024          | DEPP-7142              | Added fields used for marketing segmentation calculation  |
      | roy.nino.s.regala              | Feb 23, 2024          | DEPP-7738              | Added checker to reduce soqls                             |
 */
public inherited sharing class MarketingSegmentationsDAO extends DmlBase implements IMarketingSegmentationsDAO {

    public static final String PRIMARY_STUDY_LEVEL_UNDERGRAD = 'Undergraduate';
    public static final String PRIMARY_STUDY_LEVEL_POSTGRAD = 'Postgraduate';
    public static final String PRIMARY_STUDY_LEVEL_UNDETERMINED = 'Undetermined';

    public static final String CITIZENSHIP_STATUS_DOMESTIC_AU = 'Australian Citizen or Permanent Resident';   
    public static final String CITIZENSHIP_STATUS_DOMESTIC_NZ = 'New Zealand Citizen';
    public static final String CITIZENSHIP_STATUS_INTERNATIONAL = 'International Student';

    //SUB CATEGORY CONSTANTS START
    public static final String CONFIG_SUB_CATEGORY_I_FUND_MY_STUDIES_MYSELF = 'I will fund my studies myself';
    public static final String CONFIG_SUB_CATEGORY_MY_FAMILY_WILL_FUND_MY_STUDIES = 'My family will fund my studies';
    public static final String CONFIG_SUB_CATEGORY_I_ALREADY_HAVE_A_SCHOLARSHIP_LOAN_OR_SPONSORSHIP = 'I already have a scholarship, loan or sponsorship';
    public static final String CONFIG_SUB_CATEGORY_I_AM_NOT_SURE = 'I am not sure';
    public static final String CONFIG_SUB_CATEGORY_I_NEED_A_FULL_SCHOLARSHIP = 'I need a full scholarship';

    public static final String COUNTRY_AU = 'Australia';

    public static final String PRIMARY_NSA_BSA_IM_NOT_SURE = 'I am not sure';

    public static final String STUDY_LEVEL_POSTGRAD = 'Postgraduate';
    public static final String STUDY_LEVEL_HIGHER_DEGREE = 'Higher Degree Research';
    public static final String STUDY_LEVEL_SHORT_COURSES = 'Short courses and Professional Development';
    public static final String STUDY_LEVEL_EXCHANGE_AND_STUDY = 'Exchange and Study Abroad (1 or 2 Semesters Only)';
    public static final String STUDY_LEVEL_UNDERGRAD = 'Undergraduate';

    public static final Set<String> LEAD_SCORE_CALCULATION_FIELDS = new Set<String>{
        'My_Citizenship_Status__c','My_Country_Of_Residency__c','My_Country_Of_Citizenship__c',
        'My_Funding_Source__c','My_Primary_BSA__c','My_Primary_NSA__c','My_Double_Degree__c',
        'My_Interested_English_Pathways__c','My_Expected_Admission_Year__c','My_Primary_Study_Level__c'
    };

    public Schema.SObjectType getSObjectType(){
        return Marketing_Segmentation__c.SObjectType;
	}

    public static IMarketingSegmentationsDAO newInstance(){
        return (IMarketingSegmentationsDAO) ImplementationSelector.DAO.newInstance(Marketing_Segmentation__c.SObjectType);
	}

    public List<Marketing_Segmentation__c> getMarketingSegmentationByContactIds(
        Set<Id> contactIds,
        AccessLevel accessLevel
    ) {

        if (contactIds.isEmpty()) {
            return new List<Marketing_Segmentation__c>();
        }

        String marketingSegmentationQuery = 
            'SELECT' +
            ' Id, Contact__c, My_Primary_Study_Level__c, My_Expected_Admission_Year__c, My_Citizenship_Status__c ' +
            ' FROM' + 
            ' Marketing_Segmentation__c' +
            ' WHERE' +
            ' Contact__c IN:contactIds';
        
        return Database.query(marketingSegmentationQuery, accessLevel);
    }

    public List<Marketing_Segmentation__c> getMarketingSegmentationByLeadIds(
      Set<Id> leadIds,
      AccessLevel accessLevel
    ) {
        String marketingSegmentationQuery = 
            'SELECT' +
            ' Id, Lead__c, My_Primary_Study_Level__c, My_Citizenship_Status__c ' +
            ' FROM' + 
            ' Marketing_Segmentation__c' +
            ' WHERE' +
            ' Lead__c IN:leadIds';
    
        return Database.query(marketingSegmentationQuery, accessLevel);
    }

    public static List<Marketing_Segmentation__c> getMarketingSegmentationByContactOrLead(
        Set<Id> contactIdSet, 
        Set<Id> leadIdSet,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Lead__c, Contact__c, My_Primary_Study_Level__c, My_Citizenship_Status__c, Contact__r.hed__Citizenship_Status__c, ' +
            'My_Funding_Source__c, My_Primary_BSA__c, My_Primary_NSA__c, My_Expected_Admission_Year__c, My_Country_Of_Citizenship__c, ' +
            'My_Country_Of_Residency__c, My_Double_Degree__c, My_Interested_English_Pathways__c, My_Education_Level__c, Contact__r.RecordTypeId, Lead__r.Lead_Type__c, Lead__r.IsConverted ' +
            'FROM Marketing_Segmentation__c ' +
            'WHERE Contact__c IN : contactIdSet OR Lead__c IN : leadIdSet ',
            accessLevel
        );
    }

    public static List<Marketing_Segmentation__c> getLinkedMarketingSegByContactOrLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        if(!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Lead__c, Contact__c, Migration_Key__c,Prospects_Behaviour__c,Prospects_Rank__c, ' +
                'Prospects_Score__c,Previous_Educational_Institution__c,Secondary_School_Name__c, ' +
                'Alumnus_Educational_Institution__c,Course_Referrer__c,My_Profile_Persona__c,My_Citizenship_Status__c, ' +
                'My_Indigenous_Status_ATSI__c,My_Country_Of_Citizenship__c,My_Country_Of_Residency__c,My_Expected_Admission_Year__c, ' +
                'My_Year_12_Expected_Completion_Year__c,My_Studying_Australian_Curriculum__c,My_Funding_Source__c, ' +
                'My_Moving_To_Brisbane__c,My_High_Achieving_Student__c,My_Elite_Athlete__c,My_Organisation__c, ' +
                'My_Position__c,My_Industry__c,My_Primary_Study_Level__c,My_Primary_BSA__c,My_Primary_NSA__c, ' +
                'My_Secondary_Study_Level__c,My_Secondary_BSA__c,My_Secondary_NSA__c,My_Double_Degree__c, ' +
                'My_Interested_Pathway_Program_or_Diploma__c,My_Interested_English_Pathways__c,My_Interested_Financial_Assistance__c, ' +
                'My_Interested_Entrepreneurship__c,My_Interested_Languages__c,My_Interested_ESport_Interest__c,My_Postcode__c, ' +
                'My_State__c,My_Suburb__c,SE_Profile_Persona__c,SE_Citizenship_Status__c,SE_Indigenous_Status_ATSI__c, ' +
                'SE_Country_Of_Citizenship__c,SE_Country_Of_Residency__c,SE_Expected_Admission_Year__c,SE_Education_Level__c, SE_Year_12_Expected_Completion_Year__c, ' +
                'SE_Studying_Australian_Curriculum__c,SE_Funding_Source__c,SE_Moving_To_Brisbane__c,SE_High_Achieving_Student__c, ' +
                'SE_Elite_Athlete__c,SE_Organisation__c,SE_Position__c,SE_Industry__c,SE_Primary_Study_Level__c,SE_Primary_BSA__c, ' +
                'SE_Primary_NSA__c,SE_Secondary_Study_Level__c,SE_Secondary_BSA__c,SE_Secondary_NSA__c,SE_Double_Degree__c, ' +
                'SE_Interested_Pathway_Program_or_Diploma__c,SE_Interested_English_Pathways__c,SE_Interested_Financial_Assistance__c, ' +
                'SE_Interested_Entrepreneurship__c,SE_Interested_Languages__c,SE_Interested_ESport_Interest__c,SE_Interested_Course_Name__c, ' +
                'SE_Postcode__c,SE_State__c,SE_Suburb__c,ORG_Profile_Persona__c,ORG_Indigenous_Status_ATSI__c,ORG_Country_Of_Residency__c, ' +
                'ORG_Organisation__c,ORG_Position__c,ORG_Industry__c,ORG_Primary_Study_Level__c,ORG_Primary_BSA__c,ORG_Primary_NSA__c, ' +
                'ORG_Secondary_Study_Level__c,ORG_Secondary_BSA__c,ORG_Secondary_NSA__c,ORG_Interested_Languages__c,ORG_Interested_Course_Name__c, ' +
                'ORG_Postcode__c,ORG_State__c, ORG_Education_Level__c, ORG_Suburb__c, My_Education_Level__c,External_Key__c, ' +
                'Mailing_Address_Country__c FROM Marketing_Segmentation__c WHERE Contact__c IN :recordIds OR Lead__c IN :recordIds',
                accessLevel
            );
        } else { return new List<Marketing_Segmentation__c>(); }
    }

    public Database.QueryLocator queryLocatorGetMarketingSegmentationsByContactOrLeadIds(
        Set<Id> recordIds
    ){
        String query =
        'SELECT Lead__c, Contact__c, My_Primary_Study_Level__c, My_Citizenship_Status__c, Contact__r.hed__Citizenship_Status__c, ' +
                'My_Funding_Source__c, My_Primary_BSA__c, My_Primary_NSA__c, My_Expected_Admission_Year__c, My_Country_Of_Citizenship__c, ' +
                'My_Country_Of_Residency__c, My_Double_Degree__c, My_Interested_English_Pathways__c, My_Education_Level__c ' +
          'FROM Marketing_Segmentation__c ' +
         'WHERE Contact__c IN : recordIds OR Lead__c IN : recordIds';
        return Database.getQueryLocator(query);
    }

    public static List<Marketing_Segmentation__c> getExistingMarketingSegmentations(
        Map<String, Contact> emailToContactMap,
        AccessLevel accessLevel
    ) {
        if (emailToContactMap.keySet().isEmpty()) {
            return new List<Marketing_Segmentation__c>();
        }

        Set<String> emailSet = emailToContactMap.keySet();//NOPMD

        return Database.query(
            'SELECT Id, My_Profile_Persona__c, ' +
                'My_Primary_Study_Level__c, My_Secondary_Study_Level__c, ' +
                'Contact__c, Contact__r.Email, Contact__r.Registered_Email__c, ' +
                'Contact__r.Work_Email__c, Contact__r.QUT_Staff_Email__c, ' +
                'Contact__r.QUT_Learner_Email__c ' +
                'FROM Marketing_Segmentation__c ' +
                'WHERE Contact__r.Registered_Email__c IN: emailSet ' +
                'OR Contact__r.Email IN: emailSet ' +
                'OR Contact__r.Work_Email__c IN: emailSet ' +
                'OR Contact__r.QUT_Staff_Email__c IN: emailSet ' +
                'OR Contact__r.QUT_Learner_Email__c IN: emailSet ',
            accessLevel
        );
    }
}
