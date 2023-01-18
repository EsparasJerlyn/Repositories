/**
 * @description An apex page controller that controls the Email trigger for Pre-session
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li                   | January 3, 2023       | N/A                    | Fix PMD issue                |
      |                                |                       |                        |                              |
 */
public without sharing class EmailTriggerPreSessionScheduler implements Schedulable{
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EmailTriggerPreSessionBatch(),1);
    }
}