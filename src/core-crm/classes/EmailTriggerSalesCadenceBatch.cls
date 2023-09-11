/**
 * @description Batch class to send email for cadence
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 29, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class EmailTriggerSalesCadenceBatch implements Database.Batchable<sObject> {

    /**
    * @description Retrieve scheduled communication queue that is created/last modified by communication automation user
    * @param bc - BatchableContext
    * @return query - filtered query of scheduled communication queue
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        return CommunicationQueuesDAO.newInstance().queryLocatorScheduledCommunicationQueue();
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param assetList - List of assets
    */
    public void execute(Database.BatchableContext bc, List<Communication_Queue__c> communicationQueueList){
        try{ 
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new SalesCadenceEmailRequestCommand(communicationQueueList));
            cmd.executeCommand();
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class EmailTriggerSalesCadenceBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    } 

    /**
    * @description chain current batch job to Calculated Cadence batch job
    * @param bc - BatchableContext
    */
    public void finish(Database.BatchableContext bc) {
        NurturingTrackLeadBatch nurturetrackLeadBatch = new NurturingTrackLeadBatch();
        Database.executeBatch(nurturetrackLeadBatch); 
        
        NurturingTrackContactBatch nurturetrackContactBatch = new NurturingTrackContactBatch();
        Database.executeBatch(nurturetrackContactBatch); 
    }
}