/**
 * @description DAO Class for EngagementList Criteria Object. Contains soql and constants related to the EngagementList Criteria object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 |  May 1, 2024          | DEPP-8492              | Created file                 |
 */

 public inherited sharing class EngagementListCriteriasDAO extends DmlBase implements IEngagementListCriteriasDAO {
   /*  public static final Id entryCriteriaRecordTypeId = Schema.SObjectType.Engagement_List_Criteria__c.getRecordTypeInfosByName().get('Entry_Criteria').getRecordTypeId(); */
    
    public Schema.SObjectType getSObjectType() {
        return Engagement_List_Criteria__c.SObjectType;
    }

    public static IEngagementListCriteriasDAO newInstance() {
        return (IEngagementListCriteriasDAO) ImplementationSelector.DAO.newInstance(Engagement_List_Criteria__c.SObjectType);
    }

    public static List<Engagement_List_Criteria__c> findActiveEngagementListCriteria(Date executionDate,AccessLevel accessLevel) {

        if(executionDate == null){
            return new List<Engagement_List_Criteria__c>();
        }

        return Database.query(
            'SELECT Id, ' +
            'Engagement_List_Configuration__r.Engagement_List_Configuration_Status__c, ' +
            'Engagement_List_Configuration__r.Start_Date__c, ' +
            'Engagement_List_Configuration__r.End_Date__c, ' +
            'Is_Active__c, ' +
            'End_Date__c, ' +
            'Start_Date__c, ' +
            'Engagement_List_Criteria_Type__c ' +
            'FROM Engagement_List_Criteria__c ' +
            'WHERE Engagement_List_Configuration__r.Engagement_List_Configuration_Status__c = \'Active\' ' +
            'AND Engagement_List_Configuration__r.Start_Date__c <= :executionDate ' +
            'AND Engagement_List_Configuration__r.End_Date__c >= :executionDate ' +
            'AND Start_Date__c <= :executionDate ' +
            'AND End_Date__c >= :executionDate',
            accessLevel
        );
    }
    
}