/**
 * @description Batch class to complete cadence from comms queue with sent status
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 26, 2023    | DEPP-6763              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class CompleteCadenceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    /**
    * @description Retrieves sent communication queue
    * @param bc - BatchableContext
    * @return query - filtered query of communication queue
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        return CommunicationQueuesDAO.newInstance().queryLocatorSentCommunicationQueue();
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param communicationQueueList - List of Communication_Queue__c
    */
    public void execute(Database.BatchableContext bc, List<Communication_Queue__c> communicationQueueList){
        try{ 
                        
            List<String> actionCadenceStepIds = new List<String>();  
            for(Communication_Queue__c cq : communicationQueueList){
                actionCadenceStepIds.add(cq.ActionCadenceStepTrackerId__c);
            }

            List<ActionCadenceStepTracker> actionStepTrackerList = ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(actionCadenceStepIds, AccessLevel.SYSTEM_MODE);
            Set<Id> completedCadenceIds = new Set<Id>();
            for(ActionCadenceStepTracker ac : actionStepTrackerList){
                Boolean isValidUser = ac.ActionCadenceTracker.OwnerId == UserInfo.getUserId();
                if(isValidUser){
                    completedCadenceIds.add(ac.Id); 
                }
            }
            
            Set<Id> targets = new Set<Id>();
            for(Communication_Queue__c cq : communicationQueueList){
                Boolean isValid = cq.ActionCadenceStepTrackerId__c != null && completedCadenceIds.contains(cq.ActionCadenceStepTrackerId__c);
                if(isValid){
                    targets.add(cq.ActionCadenceStepTrackerId__c);
                }
            }

            if(!targets.isEmpty()){
                SalesCadenceCalloutService.updateCadenceStepTracker(targets, 'Skip');
            }
            

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class CompleteCadenceBatch.').setExceptionDetails(e);
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