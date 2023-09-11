/**
 * @description Interface for CommunicationQueuesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 30, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
public interface ICommunicationQueuesDAO extends DmlInterface{

    Database.QueryLocator queryLocatorScheduledCommunicationQueue();

    List<Communication_Queue__c> getComminicationQueueRecordsByStatus(
        Set<String> status, 
        AccessLevel accessLevel
    );
        
}