/**
 * @description Scheduleder for LeadScoreCalculationBatch
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 18, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreCalculationScheduler implements Schedulable{
    /**
    * @description Method for calling LeadScoreCalculationBatch
    */
    public void execute (SchedulableContext context){
        LeadScoreCalculationBatch batch = new LeadScoreCalculationBatch();
		Database.executeBatch(batch);
    }
}