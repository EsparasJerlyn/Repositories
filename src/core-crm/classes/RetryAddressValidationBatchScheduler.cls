/**
 * @description Scheduler for RetryAddressValidationBatch
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | gabriel.p.ventayen             | Jun 11, 2024          | DEPP-8953              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class RetryAddressValidationBatchScheduler implements Schedulable{
    public static void execute (SchedulableContext context){
        Database.executeBatch(new RetryAddressValidationBatch());
    }
}