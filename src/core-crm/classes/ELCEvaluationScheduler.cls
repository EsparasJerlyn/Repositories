/**
 * @description Scheduler for ELCEvaluatorBatch
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | gabriel.p.ventayen             | May 13, 2024          | DEPP-8490              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class ELCEvaluationScheduler implements Schedulable{
    public static void execute (SchedulableContext context){
        Date executionDate = Date.today(); 

        List<ELCEvaluationJob> eLCEvaluationJobs = ELCEvaluationJobService.prepareELCEvaluationJobs(executionDate);
        if (!eLCEvaluationJobs.isEmpty()){
            Database.executeBatch(new ELCEvaluatorBatch(eLCEvaluationJobs));
        }
    }
}