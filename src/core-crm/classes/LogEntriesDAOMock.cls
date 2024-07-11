/**
 * @description Mock DAO Class for LogEntry__c Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2024        | DEPP-7984              | Created file
 */
@isTest
public inherited sharing class LogEntriesDAOMock extends DmlBaseMock implements ILogEntriesDAO {

	public Map<Id, LogEntry__c> logEntriesMap;

    public Schema.SObjectType getSObjectType()
	{
		return LogEntry__c.SObjectType;
	}

	public LogEntriesDAOMock() {
		super(new Map<Id, LogEntry__c>(), Schema.LogEntry__c.SObjectType);
		this.logEntriesMap = (Map<Id, LogEntry__c>) super.records;
	}

	public List<LogEntry__c> getLogEntriesByRelatedRecordId(Set<Id> recordIdSet, AccessLevel accessLevel){
		List<LogEntry__c> logEntriesList = new List<LogEntry__c>();

		for(LogEntry__c logEntry: logEntriesMap.values()){
			if(recordIdSet.contains(logEntry.RecordId__c)){
				logEntriesList.add(logEntry);
			}
		}

		return logEntriesList;
	}


	public List<LogEntry__c> getLogEntriesByMessage(Set<String> messageSet, AccessLevel accessLevel){

		List<LogEntry__c> logEntriesList = new List<LogEntry__c>();

		for(LogEntry__c logEntry: logEntriesMap.values()){
			if(messageSet.contains(logEntry.Message__c)){
				logEntriesList.add(logEntry);
			}
		}

		return logEntriesList;
	}

}