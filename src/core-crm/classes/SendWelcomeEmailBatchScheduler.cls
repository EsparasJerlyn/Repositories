/**
 * @description Handler for SendWelcomeEmailBatchScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		       | July  30, 2022	       | DEPP-3577              | Created file                 | 
      |                                |                       |                        |                              | 
 */
public with sharing class SendWelcomeEmailBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling Publishing End Date batch job
    */
    public void execute (SchedulableContext context){
        SendWelcomeEmailBatch batch = new SendWelcomeEmailBatch();
		Database.executeBatch(batch);
    }
}