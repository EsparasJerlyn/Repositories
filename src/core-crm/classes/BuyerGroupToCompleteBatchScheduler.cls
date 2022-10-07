/**
 * @description Scheduler for BuyerGroupToCompleteBatch
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
public with sharing class BuyerGroupToCompleteBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling Publishing End Date batch job
    */
    public void execute (SchedulableContext context){
        BuyerGroupToCompleteBatch batch = new BuyerGroupToCompleteBatch();
		Database.executeBatch(batch);
    }
}