/**
 * @description Scheduler for DonationCauseStageUpdateBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		       | March. 15, 2022       | DEPP-8210              | Created file                 | 
 */
public with sharing class DonationCauseStageUpdateScheduler implements Schedulable {
    
    /**
    * @description Method for calling Publishing End Date batch job
    */
    public void execute (SchedulableContext context){
        DonationCauseStageUpdateBatch batch = new DonationCauseStageUpdateBatch();
		Database.executeBatch(batch);
    }
}