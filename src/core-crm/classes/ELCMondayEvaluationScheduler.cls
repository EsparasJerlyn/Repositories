/**
 * @description Scheduler for Monday ELCEvaluatorBatch
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
public with sharing class ELCMondayEvaluationScheduler implements Schedulable {
    public static void execute(SchedulableContext sc) {
        List<ELCEvaluationJob> eLCEvaluationJobs = new List<ELCEvaluationJob>();
        Date monday = Date.today();

        Date friday = monday.addDays(-3);
        eLCEvaluationJobs.addAll(eLCEvaluationJobService.prepareELCEvaluationJobs(friday));
        
        Date saturday = monday.addDays(-2);
        eLCEvaluationJobs.addAll(eLCEvaluationJobService.prepareELCEvaluationJobs(saturday));

        Date sunday = monday.addDays(-1);
        eLCEvaluationJobs.addAll(eLCEvaluationJobService.prepareELCEvaluationJobs(sunday));

        eLCEvaluationJobs.addAll(eLCEvaluationJobService.prepareELCEvaluationJobs(monday));
        
        Database.executeBatch(new ELCEvaluatorBatch(eLCEvaluationJobs));
    }
  }