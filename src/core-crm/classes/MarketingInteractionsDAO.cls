/**
 * @description DAO Class for Marketing_Interaction__c Object. Contains SOQL and Constants related to the Marketing_Interaction__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                     |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------|
 *    | julie.jane.alegre              | September 18, 2023    |DEPP-6667               | Created File                       |
 */
public inherited sharing class MarketingInteractionsDAO extends DmlBase implements IMarketingInteractionsDAO {

    public static final String LEAD_SOURCE_CATEGORY_EVENT = 'Event';

    public static final String LEAD_SOURCE_COURSE_PAGE_PDF = 'Course Page PDF Download';
    public static final String LEAD_SOURCE_WELCOME_GUIDE = 'Welcome Guide Download';
    public static final String LEAD_SOURCE_COURSE_GUIDE = 'Course Guide Download';
    public static final String LEAD_SOURCE_MMS = 'MMS';

    public static final String MATCH_MY_SKILL_COMPLETION_UPPER = 'TRUE';

    public static final String EVENT_TYPE_OPEN_DAY = 'Open day';

    public static IMarketingInteractionsDAO newInstance() {
        return (IMarketingInteractionsDAO) ImplementationSelector.DAO.newInstance(Marketing_Interaction__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Marketing_Interaction__c.SObjectType;
    }

    public static List<Marketing_Interaction__c> getMarketingInteractionByApplicantIds(
        Set<Id> applicantIds,
        AccessLevel accessLevel
    ) {
        String marketingInteractionQuery = 
            'SELECT' +
            ' Id, Contact__c, Lead_Source__c' +
            ' FROM' + 
            ' Marketing_Interaction__c' +
            ' WHERE' +
            ' Contact__c IN:applicantIds' +
            ' AND Lead_Source__c != \'QTAC\'';
        
        return Database.query(marketingInteractionQuery, accessLevel);
    }

    public static List<Marketing_Interaction__c> getMarketingInteractionsByContactOrLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Event_Type__c, Lead_Source_Category__c, Has_Attended__c, Contact__c, Lead__c, Event_Date__c, Interaction_DateTime__c, Lead_Source__c, Match_My_Skill_Completion__c, Lead_Score_Reset__c ' +
              'FROM Marketing_Interaction__c ' +
             'WHERE Contact__c IN : recordIds OR Lead__c IN : recordIds ',
            accessLevel
        );
    }

    public Database.QueryLocator queryLocatorGetMarketingInteractionsByContactOrLeadIds(
        Set<Id> recordIds
    ){
        String query =
            'SELECT Id, Event_Type__c, Lead_Source_Category__c, Has_Attended__c, Contact__c, Lead__c, Event_Date__c, Interaction_DateTime__c, Lead_Source__c, Match_My_Skill_Completion__c, Lead_Score_Reset__c ' +
              'FROM Marketing_Interaction__c ' +
             'WHERE Contact__c IN : recordIds OR Lead__c IN : recordIds';
        return Database.getQueryLocator(query);
    }

}
