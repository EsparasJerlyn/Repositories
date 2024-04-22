/**
 * @description Batch class for sending Service Appointment Domestic No Answer SMS.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | March 07 2024         | DEPP-8035              | Created file                 |
 */
public with sharing class DomesticNoAnswerSMSBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    public Database.queryLocator start(Database.BatchableContext bc) {
        return CommunicationQueuesDAO.newInstance().queryLocatorNoAnswerSMSQueue();
    }

    public void execute(Database.BatchableContext bc, List<Communication_Queue__c> communicationQueueList) {
        try {
            RequestCommand cmd = new RequestCommand();
            if(!communicationQueueList.isEmpty()) {
                cmd.setCommand(new SalesCadenceSMSRequestCommand(communicationQueueList));
                cmd.executeCommand();
            }
        } catch(Exception e) {
            Logger.error('Exception caught in method execute in Apex class DomesticNoAnswerSMSBatch').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    public void execute(SchedulableContext context){
		Database.executeBatch(new DomesticNoAnswerSMSBatch(), 200);
    }

    public void finish(Database.BatchableContext bc) {
        try {
            System.scheduleBatch(new DomesticNoAnswerSMSBatch(), 'DomesticNoAnswerSMSBatchJob', 1, 200);
        } catch(Exception e) {
            Logger.error('Exception caught in method finish in class DomesticNoAnswerSMSBatchJob.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }
}