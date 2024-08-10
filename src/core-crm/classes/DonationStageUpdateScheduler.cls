/**
 * @description Scheduler for DonationStageUpdateBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Created file                 | 
 */

public with sharing class DonationStageUpdateScheduler implements Schedulable{
    /**
    * @description Method for calling Donation batch job
    */
    public void execute (SchedulableContext context){
        DonationStageUpdateBatch batch = new DonationStageUpdateBatch();
		Database.executeBatch(batch);
    }
}