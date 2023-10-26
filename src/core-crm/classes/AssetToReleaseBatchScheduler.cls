/**
 * @description Scheduler for AssetToReleaseBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | August 11, 2023       | DEPP-6240              | Created file                 |
 */
public with sharing class AssetToReleaseBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling Asset To Release batch job
    */
    public void execute (SchedulableContext context){
        AssetToReleaseBatch batch = new AssetToReleaseBatch();
		Database.executeBatch(batch);
    }
}