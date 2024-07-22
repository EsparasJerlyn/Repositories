/**
 * @description Scheduleder for EmailTriggerSalesCadenceBatch
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 29, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class EmailTriggerSalesCadenceScheduler implements Schedulable{
    
    /**
    * @description Method for calling EmailTriggerSalesCadenceBatch
    */
    public void execute (SchedulableContext context){
        Set<String> jobNames = new Set<String>();
        jobNames.add(AsyncApexJobsDAO.EMAIL_TRIGGER_SALES_CADENCE_BATCH);

        List<AsyncApexJob> runningJobs = AsyncApexJobsDAO.newInstance().getRunningJobsByNameAndIdExemption(jobNames, new Set<Id>(), AccessLevel.USER_MODE);
        if(runningJobs.isEmpty()) {
            EmailTriggerSalesCadenceBatch batch = new EmailTriggerSalesCadenceBatch();
            Database.executeBatch(batch);
        }
    }
}