/**
 * @description Interface for Lists DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
 *    | carl.alvin.cabiles             | September 15, 2023    | DEPP-6510              | Created file                                    |
 *    | ryan.j.a.dela.cruz             | April 30, 2024        | N/A - ST FIX           | Added accessLevel param for getListRecords      |
 */
public interface IListsDAO extends DmlInterface {
    List<List__c> getListRecords(Integer recordscount, AccessLevel accessLevel);
    List<List__c> getListRecordsByRelatedEngagementOpportunitySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    );
    List<List__c> getListByRecordIdName(Id recordId, String filterString, AccessLevel accessLevel);
}
