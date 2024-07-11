/**
 * @description Interface for LogEntries DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2024        | DEPP-7984              | Created file
 */
public interface ILogEntriesDAO extends DmlInterface {
     List<LogEntry__c> getLogEntriesByRelatedRecordId(Set<Id> recordIdSet, AccessLevel accessLevel);
     List<LogEntry__c> getLogEntriesByMessage(Set<String> messageSet, AccessLevel accessLevel);
}
