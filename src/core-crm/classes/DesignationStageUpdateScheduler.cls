/**
 * @description Scheduler for DesignationStageUpdateBatch
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		       | March. 15, 2022       | DEPP-8210              | Created file                 | 
 */
public with sharing class DesignationStageUpdateScheduler implements Schedulable {

    /**
    * @description Method for calling Publishing End Date batch job
    */
    public void execute (SchedulableContext context){
        DesignationStageUpdateBatch batch = new DesignationStageUpdateBatch();
		Database.executeBatch(batch);
    }
}