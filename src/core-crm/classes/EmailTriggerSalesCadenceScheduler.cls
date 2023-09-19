/**
 * @description Scheduleder for EmailTriggerSalesCadenceBatch
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
public with sharing class EmailTriggerSalesCadenceScheduler implements Schedulable{
    
    /**
    * @description Method for calling EmailTriggerSalesCadenceBatch
    */
    public void execute (SchedulableContext context){
        EmailTriggerSalesCadenceBatch batch = new EmailTriggerSalesCadenceBatch();
		Database.executeBatch(batch);
    }
}