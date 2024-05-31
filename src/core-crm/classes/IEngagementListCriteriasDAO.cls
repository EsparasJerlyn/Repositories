/**
 * @description Interface for EngagementList Criteria DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 | May 1, 2024           | DEPP-8492              | Created file
 */
public interface IEngagementListCriteriasDAO extends DmlInterface {
    List<Engagement_List_Criteria__c> findActiveEngagementListCriteriasByRecordtype(
        String recordType,
        Date executionDate, 
        AccessLevel accessLevel
    );

    Engagement_List_Criteria__c getEntryCriteriaById(Id recordId, AccessLevel accessLevel);
}