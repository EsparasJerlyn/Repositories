/**
 * @description Scheduler for DistributionMgtStatusUpdateBatch
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay      	       | April 11, 2024        | DEPP-8453              | Created file                 |
 */
public with sharing class DistributionMgtStatusUpdateScheduler implements Schedulable{
    /**
    * @description Method for calling Distribution Management Status Update batch job
    */
    public void execute (SchedulableContext context){
        DistributionMgtStatusUpdateBatch batch = new DistributionMgtStatusUpdateBatch();
		Database.executeBatch(batch);
    }
}