/**
 * @description Interface for CommunicationQueuesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                     |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------|
 *    | eccarius.munoz                 | August 30, 2023       | DEPP-6138              | Created file                       |
 *    | alexander.cadalin              | March 07, 2024        | DEPP-8035              | Added queryLocatorNoAnswerSMSQueue |
 */
public interface ICommunicationQueuesDAO extends DmlInterface{

    Database.QueryLocator queryLocatorScheduledCommunicationQueue();

    Database.QueryLocator queryLocatorSentCommunicationQueue();

    Database.QueryLocator queryLocatorNoAnswerSMSQueue();

    List<Communication_Queue__c> getComminicationQueueRecordsByStatus(
        Set<String> status, 
        AccessLevel accessLevel
    );
    List<Communication_Queue__c> getCommsQueueRecordsByStatusAndLastModifiedToday(
        Set<String> status, 
        AccessLevel accessLevel
    );
    List<Communication_Queue__c> getComminicationQueueRecordsByIdSets(
        Set<Id> createdCommunicationsQueueIdSet, 
        AccessLevel accessLevel
    );
    List<Communication_Queue__c> getFutureScheduledCommsQueuesByCadenceStepTrackerIds(
        Set<String> trackerIdSet,
        AccessLevel accessLevel
    ); 
}