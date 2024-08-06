/**
 * @description Scheduler for SyncOperatingHoursToAWSBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.aldric.s.seril		       | Jul. 26, 2024 	       | DEPP-9834              | Created file                 |
*/
public with sharing class SyncOperatingHoursToAWSBatchScheduler implements Schedulable {
    /**
    * @description Method for calling Syncing of OperatingHours batch job
    */
    public void execute (SchedulableContext context){
        SyncOperatingHoursToAWSBatch batch = new SyncOperatingHoursToAWSBatch();
		Database.executeBatch(batch);
    }
}