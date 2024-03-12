/**
 * @description Interface for Lists DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | September 15, 2023    | DEPP-6510              | Created file                 |
 */
public interface IListsDAO extends DmlInterface {
    List<List__c> getListRecords(Integer recordscount);
    List<List__c> getListRecordsByRelatedEngagementOpportunitySetIds(Set<Id> recordIds,
    AccessLevel accessLevel);
    List<List__c> getListByRecordIdName(
        Id recordId,
        String filterString,
        AccessLevel accessLevel
    );
    List<List__c> getRecordsBySetIds(Set<Id> ids);
}
