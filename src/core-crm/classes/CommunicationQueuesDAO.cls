/**
 * @description DAO class for Communication_Queue__c
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------|
      | eccarius.munoz                 | August 30, 2023       | DEPP-6138              | Created file                                                  |
      |                                |                       |                        |                                                               |
      | mark.j.mahilum                 | Oct 17, 2023          | DEPP-6926              | Added method getCommsQueueRecordsByStatusAndLastModifiedToday |
      |                                |                       |                        | to get the record updated today                               |
 */
public with sharing class CommunicationQueuesDAO extends DmlBase implements ICommunicationQueuesDAO{

    public static final String STATUS_SCHEDULED = System.Label.PL_CommsQueue_Scheduled;
    public static final String STATUS_SENT = System.Label.PL_CommsQueue_Sent;
    public static final String STATUS_FAILED = System.Label.PL_CommsQueue_Failed;
    public static final String STATUS_RETRY = System.Label.PL_CommsQueue_Retry;
    public static final Set<String> EMAIL_STATUS_FOR_SENDING = new Set<String>{
        STATUS_SCHEDULED,
        STATUS_RETRY
    };
    public static final Set<String> EMAIL_STATUS_FOR_COMPLETION = new Set<String>{
        STATUS_SENT,
        STATUS_FAILED
    };

    public Schema.SObjectType getSObjectType(){
		return Communication_Queue__c.SObjectType;
	}

    public static ICommunicationQueuesDAO newInstance(){
		return (ICommunicationQueuesDAO) ImplementationSelector.DAO.newInstance(Communication_Queue__c.SObjectType);
	}
  
    public Database.QueryLocator queryLocatorScheduledCommunicationQueue() {        
        String query =
            'SELECT Id, Status__c, WhoId__c, Retry_Count__c, Sender__c, Business_Process__c, Template_Id__c, ActionCadenceStepTrackerId__c, Mobile__c, Message__c, Due_Date__c, Type__c  ' + 
            'FROM Communication_Queue__c ' + 
            'WHERE Status__c IN: EMAIL_STATUS_FOR_SENDING ORDER BY CreatedDate ';
        return Database.getQueryLocator(query);
    }

    public Database.QueryLocator queryLocatorSentCommunicationQueue() {        
        String query =
            'SELECT Id, Status__c, WhoId__c, Retry_Count__c, Sender__c, Business_Process__c, Template_Id__c, ActionCadenceStepTrackerId__c  ' + 
              'FROM Communication_Queue__c ' + 
             'WHERE Status__c IN: EMAIL_STATUS_FOR_COMPLETION';
        return Database.getQueryLocator(query);
    }

    public List<Communication_Queue__c> getComminicationQueueRecordsByStatus(Set<String> status, AccessLevel accessLevel) {
        return Database.query(
            'SELECT Id, Status__c, WhoId__c, Retry_Count__c, Sender__c, Business_Process__c, Template_Id__c, ActionCadenceStepTrackerId__c ' + 
              'FROM Communication_Queue__c ' + 
             'WHERE Status__c IN: status', accessLevel
        );
    }

    public List<Communication_Queue__c> getCommsQueueRecordsByStatusAndLastModifiedToday(Set<String> status, AccessLevel accessLevel) {
        return Database.query(
            'SELECT Id, Status__c, WhoId__c, Retry_Count__c, Sender__c, Business_Process__c, Template_Id__c, ActionCadenceStepTrackerId__c ' + 
              'FROM Communication_Queue__c ' + 
             'WHERE Status__c IN: status AND LastModifiedDate = TODAY AND Type__c = \'Email\' ', accessLevel
        );
    }
}   