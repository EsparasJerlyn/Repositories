/**
 * @description Mock DAO Class for Communication_Queue__c Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 30, 2023       |DEPP-6138               | Created File                        |
 *    | alexander.cadalin              | March 07, 2024        | DEPP-8035              | Added queryLocatorNoAnswerSMSQueue  |
 */
@isTest
public inherited sharing class CommunicationQueuesDAOMock extends DmlBaseMock implements ICommunicationQueuesDAO {

    public Map<Id, Communication_Queue__c> commsQueueMap;

    public CommunicationQueuesDAOMock() {
        super(new Map<Id, Communication_Queue__c>(), Schema.Communication_Queue__c.SObjectType);
        this.commsQueueMap = (Map<Id, Communication_Queue__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Communication_Queue__c.SObjectType;
    }

    public Database.QueryLocator queryLocatorScheduledCommunicationQueue() {
        return null;
    }

    public Database.QueryLocator queryLocatorSentCommunicationQueue() {
        return null;
    }
    
    public Database.QueryLocator queryLocatorNoAnswerSMSQueue() {
        return null;
    }

    public List<Communication_Queue__c> getComminicationQueueRecordsByStatus(
        Set<String> status,     
        AccessLevel accessLevel){

        List<Communication_Queue__c> commsQueueList = new List<Communication_Queue__c>();
        for (Communication_Queue__c record : commsQueueMap.values()) {
            if (status.contains(record.Status__c)) {
                commsQueueList.add(record);
            }
        }

        return commsQueueList;
    }
    
    public List<Communication_Queue__c> getCommsQueueRecordsByStatusAndLastModifiedToday(
        Set<String> status,     
        AccessLevel accessLevel){

        List<Communication_Queue__c> commsQueueList = new List<Communication_Queue__c>();
        for (Communication_Queue__c record : commsQueueMap.values()) {
            if (status.contains(record.Status__c)) {
                commsQueueList.add(record);
            }
        }

        return commsQueueList;
    }

    public List<Communication_Queue__c> getComminicationQueueRecordsByIdSets(Set<Id> createdCommunicationsQueueIdSet, AccessLevel accessLevel){
        List<Communication_Queue__c> commsQueueList = new List<Communication_Queue__c>();
        for (Communication_Queue__c record : commsQueueMap.values()) {
            if (createdCommunicationsQueueIdSet.contains(record.Id)) {
                commsQueueList.add(record);
            }
        }

        return commsQueueList;
    }

    
}