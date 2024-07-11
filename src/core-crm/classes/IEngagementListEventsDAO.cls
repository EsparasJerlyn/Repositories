/**
 * @description Interface for Engagement List Event DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 14, 2024          | DEPP-8484              | Created file
 */
public interface IEngagementListEventsDAO extends DmlInterface{
    
     List<Engagement_List_Event__c> getEngagementListEventsByRelatedRecordIds(
        Map<String, Set<Id>> relatedRecordIdMap,
        AccessLevel accessLevel
    );
    
    List<Engagement_List_Event__c> getEngagmentListEventByCaseId(
        Set<Id> caseIds,
        AccessLevel accessLevel
    );
}