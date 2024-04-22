/**
 * @description Scheduleder for LeadSourceCanNurtureFlagBatch
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | March 05, 2024        | DEPP-8069              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadSourceCanNurtureFlagBatchScheduler implements Schedulable{
    
    /**
    * @description Method for calling LeadSourceCanNurtureFlagBatch
    */
    public void execute (SchedulableContext context){
        LeadSourceCanNurtureFlagBatch batch = new LeadSourceCanNurtureFlagBatch();
		Database.executeBatch(batch);
    } 
}