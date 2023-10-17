/**
 * @description Scheduler class of AdhocCommunicationBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | October 06, 2023      | DEPP-6616              | Created file                 |
 */
public with sharing class AdhocCommunicationBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling the AdhocCommunication Batch that will send an email every 7am
    */
    public void execute (SchedulableContext context){
        AdhocCommunicationBatch batch = new AdhocCommunicationBatch();
		Database.executeBatch(batch);
    }
}
