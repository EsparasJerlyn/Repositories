/**
 * @description DAO Class for Lead_Score_Detail__c Object. Contains soql and constants related to the Lead_Score_Detail__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | August 31, 2023       |DEPP-5965               | Created File                        |
 *    | eccarius.munoz                 | October 04, 2023      |DEPP-5866               | Added method to get by con/lead     |
 */
public inherited sharing class LeadScoreDetailsDAO extends DmlBase implements ILeadScoreDetailsDAO{

    public static final String DOMESTIC = 'Domestic';
    public static final String INTERNATIONAL = 'International';
    public static final String UNDETERMINED = 'Undetermined';

    public static final String STUDY_LEVEL_UNDERGRAD = 'Undergraduate';
    public static final String STUDY_LEVEL_POSTGRAD = 'Postgraduate';
    public static final String STUDY_LEVEL_UNDETERMINED = 'Undetermined';
    
    public Schema.SObjectType getSObjectType(){
		return Lead_Score_Detail__c.SObjectType;
	}

    public static ILeadScoreDetailsDAO newInstance(){
		return (ILeadScoreDetailsDAO) ImplementationSelector.DAO.newInstance(Lead_Score_Detail__c.SObjectType);
	}

    public static List<Lead_Score_Detail__c> getLeadScoreDetailWithLimit(Integer recordsCount) {
        return [//NOPMD
            SELECT Id, Contact__c, Total_Lead_Score__c
            FROM Lead_Score_Detail__c
            WITH SYSTEM_MODE//Only used in test class to verify record insert/update
            LIMIT :recordsCount
        ];
    }

    public static List<Lead_Score_Detail__c> getLeadScoreDetailsByContactOrLeadId(Set<Id> contactLeadIdSet, AccessLevel accessLevel){
        return Database.query(
            'SELECT Id, Contact__c, Lead__c, Total_Lead_Score__c ' +
            'FROM Lead_Score_Detail__c ' +
            'WHERE Contact__c IN: contactLeadIdSet OR Lead__c IN: contactLeadIdSet ',
            accessLevel
        );
    }

    @SuppressWarnings('PMD.UnusedLocalVariable')//variable not detected in string query
    public Database.QueryLocator getLeadScoreDetailsWithContactOrLead(){
        String personRecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID; 

        String query =
            'SELECT Id, Contact__c, Lead__c ' + 
              'FROM Lead_Score_Detail__c ' + 
             'WHERE (Contact__c != null  AND Contact__r.RecordTypeId =: personRecordTypeId) OR (Lead__c != null AND Lead__r.IsConverted = FALSE)';
        return Database.getQueryLocator(query);
    }

    public static List<Lead_Score_Detail__c> getLeadScoreDetailsByCitizenshipAndStudyLevel(
        Set<String> citizenshipStatusSet,
        Set<String> primaryStudyLevelSet,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id, Contact__c, Lead__c, Domestic_International__c, Study_Level__c ' +
              'FROM Lead_Score_Detail__c ' +
             'WHERE Domestic_International__c IN :citizenshipStatusSet ' + 
               'AND Study_Level__c IN : primaryStudyLevelSet ',
            accessLevel
        );
    }

    @SuppressWarnings('PMD.UnusedLocalVariable')//variable not detected in string query
    public Database.QueryLocator queryLocatorLeadScoreDetailsByCitizenshipAndStudyLevel(
        Set<String> citizenshipStatusSet,
        Set<String> primaryStudyLevelSet
    ){
        String personRecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID; 
        String query =
            'SELECT Id, Contact__c, Lead__c, Domestic_International__c, Study_Level__c ' + 
              'FROM Lead_Score_Detail__c ' + 
             'WHERE Domestic_International__c IN :citizenshipStatusSet ' + 
               'AND Study_Level__c IN : primaryStudyLevelSet AND ((Contact__c != null  AND Contact__r.RecordTypeId =: personRecordTypeId) ' +
               'OR (Lead__c != null AND Lead__r.IsConverted = FALSE))';
        return Database.getQueryLocator(query);
    }
    
}
