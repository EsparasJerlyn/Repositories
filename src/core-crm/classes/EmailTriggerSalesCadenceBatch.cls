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
      | eccarius.munoz                 | September 26, 2023    | DEPP-6763              | Updated finish method to add |
      |                                |                       |                        | batch class for completing   |
      |                                |                       |                        | the cadence with sent emails |
      |                                |                       |                        |                              |
      | mark.j.mahilum                 | March 07, 2024        | DEPP-8243              | Fixed issue where SMS task   |
      |                                |                       |                        | is getting created for       |
      |                                |                       |                        |  International Student       |
 */
public with sharing class EmailTriggerSalesCadenceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

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
    * @param communicationQueueList - List of Communication_Queue__c
    */
    public void execute(Database.BatchableContext bc, List<Communication_Queue__c> communicationQueueList){
        try{ 
            List<Communication_Queue__c> emailComsQueueList = new List<Communication_Queue__c>();
            List<Communication_Queue__c> smsComsQueueList = new List<Communication_Queue__c>();

            for(Communication_Queue__c rec: communicationQueueList){
                if(rec.Type__c =='Email' && rec.Due_Date__c <= System.today()){
                    emailComsQueueList.add(rec);
                }
                if(rec.Type__c =='SMS'){
                    smsComsQueueList.add(rec);
                }               
            }
            
            RequestCommand cmd = new RequestCommand();
            if(!emailComsQueueList.isEmpty()){
                cmd.setCommand(new SalesCadenceEmailRequestCommand(emailComsQueueList));
                cmd.executeCommand();
            }
            if(!smsComsQueueList.isEmpty()){
                cmd.setCommand(new SalesCadenceSMSRequestCommand(smsComsQueueList));
                cmd.executeCommand();
            }
            
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class EmailTriggerSalesCadenceBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    } 

    /**
    * @description chain current batch job to Complete Cadence job
    * @param bc - BatchableContext
    */
    public void finish(Database.BatchableContext bc) {
        CompleteCadenceBatch completeCadenceBatch = new CompleteCadenceBatch();
        Database.executeBatch(completeCadenceBatch);
    }
}