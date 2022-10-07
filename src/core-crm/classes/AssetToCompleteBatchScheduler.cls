/**
 * @description Scheduler for AssetToCompleteBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin		       | Aug. 11, 2022 	       | DEPP-3481              | Created file                 |
 */
public with sharing class AssetToCompleteBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling Publishing End Date batch job
    */
    public void execute (SchedulableContext context){
        AssetToCompleteBatch batch = new AssetToCompleteBatch();
		Database.executeBatch(batch);
    }
}