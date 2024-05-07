/**
 * @description DAO Class for Log Entry Object. Contains soql and constants related to the Log Entry object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2024        | DEPP-7984              | Created file
 */
public inherited sharing class LogEntriesDAO extends DmlBase implements ILogEntriesDAO{

    public Schema.SObjectType getSObjectType()
	{
		return LogEntry__c.SObjectType;
	}

    public static ILogEntriesDAO newInstance()
	{
		return (ILogEntriesDAO) ImplementationSelector.DAO.newInstance(LogEntry__c.SObjectType);
	}

	public List<LogEntry__c> getLogEntriesByRelatedRecordId(Set<Id> recordIdSet, AccessLevel accessLevel){
		if(recordIdSet.isEmpty()){
			return new List<LogEntry__c>();
		}

		return Database.query(
			'SELECT Id, Message__c, RecordId__c ' +
			'FROM LogEntry__c ' +
			'WHERE RecordId__c IN: recordIdSet '
			,accessLevel
		);
	}

	public List<LogEntry__c> getLogEntriesByMessage(Set<String> messageSet, AccessLevel accessLevel){
		if(messageSet.isEmpty()){
			return new List<LogEntry__c>();
		}

		List<LogEntry__c> logEntries = new List<LogEntry__c>();

		for(LogEntry__c logEntry: Database.query(
			'SELECT Id, Message__c, RecordId__c ' +
			'FROM LogEntry__c ' +
			'LIMIT 10000'
			,accessLevel
		)){
			if(messageSet.contains(logEntry.Message__c)){
				logEntries.add(logEntry);
			}
		}
		
		return logEntries;
	}

}