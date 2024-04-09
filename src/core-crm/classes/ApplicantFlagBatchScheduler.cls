/**
 * @description Scheduler for ApplicantFlagBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | March 28, 2024        | DEPP-8382              | Created file                 |
 */
public with sharing class ApplicantFlagBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling ApplicantFlagBatch batch job
    */
    public void execute (SchedulableContext context){
        ApplicantFlagBatch batch = new ApplicantFlagBatch();
		Database.executeBatch(batch);
    }
}