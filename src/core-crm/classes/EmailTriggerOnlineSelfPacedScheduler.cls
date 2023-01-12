/**
 * @description An apex page controller that controls the Email trigger for Online Self-Paced
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
public without sharing class EmailTriggerOnlineSelfPacedScheduler implements Schedulable{
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EmailTriggerOnlineSelfPacedBatch(),1);
    }
}
