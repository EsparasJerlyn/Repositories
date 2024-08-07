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
      | mark.j.mahilum                 | March 07, 2024        | DEPP-8243              | Fixed an issue where the     |
      |                                |                       |                        | Communication queue for Email|
      |                                |                       |                        | is getting pick up by SMS job|
      |                                |                       |                        | that created SMS tasks       |
      | mark.j.mahilum                 | May 21, 2024          | DEPP-8766              | Added new command class for  |
      |                                |                       |                        | generic email sending        |
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
            List<Communication_Queue__c> nurturingEmailComsQueueList = new List<Communication_Queue__c>();
            List<Communication_Queue__c> smsComsQueueList = new List<Communication_Queue__c>();

            for (Communication_Queue__c rec : communicationQueueList) {              
                
                switch on rec.Type__c {
                    when 'Email' {
                        if (rec.Due_Date__c <= Date.today()) {
                            switch on rec.Business_Process__c {
                                when 'Domestic Automated Cadence Email','International Automated Cadence Email' {
                                    nurturingEmailComsQueueList.add(rec);
                                }
                                when else {
                                    emailComsQueueList.add(rec);
                                }
                            }
                        }
                    }
                    when 'SMS' {
                        smsComsQueueList.add(rec);
                    }
                }

            }
            
            RequestCommand cmd = new RequestCommand();
            if(!nurturingEmailComsQueueList.isEmpty()){
                cmd.setCommand(new SalesCadenceEmailRequestCommand(nurturingEmailComsQueueList));
                cmd.executeCommand();
            }
            if(!smsComsQueueList.isEmpty()){
                cmd.setCommand(new SalesCadenceSMSRequestCommand(smsComsQueueList));
                cmd.executeCommand();
            }
            if(!emailComsQueueList.isEmpty()){
                cmd.setCommand(new CommunicationQueueEmailRequestCommand(emailComsQueueList));
                cmd.executeCommand();
            }
            
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class EmailTriggerSalesCadenceBatch.').setExceptionDetails(e);
        } finally {

            //Publish Communication Queue Events
            publishCommunicationQueueEvents(communicationQueueList);
            
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

   /**
    * @description publish the communication queue event record
    * @param List<Communication_Queue__c> comsQueueList 
    */
    private static void publishCommunicationQueueEvents(List<Communication_Queue__c> comsQueueList){
        if(comsQueueList.isEmpty()){
            return;
        }
        
        List<Communication_Processed__e> platformEvents = new List<Communication_Processed__e>();
        for(Communication_Queue__c comsqueue: comsQueueList){
            
            if(CommunicationQueuesDAO.EMAIL_STATUS_FOR_SENDING.contains(comsqueue.Status__c)){
                continue;
            }
            
            platformEvents.add(
                new Communication_Processed__e(
                    Communication_Queue_Id__c = comsqueue.Id,
                    Business_Process__c = comsqueue.Business_Process__c,
                    Success__c = (comsqueue.Status__c == CommunicationQueuesDAO.STATUS_SENT) ? true:false,
                    Type__c = comsqueue.Type__c,
                    What_Id__c = (String.isNotBlank(comsqueue.WhatId__c)) ? comsqueue.WhatId__c : comsqueue.WhoId__c
                )
            );
        }
        
        //publish the Communication Queue platform events
        if(!platformEvents.isEmpty()){
            EventBus.publish(platformEvents);
        }       
    }
}