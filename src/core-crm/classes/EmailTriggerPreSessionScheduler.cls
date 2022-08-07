global without sharing class EmailTriggerPreSessionScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EmailTriggerPreSessionBatch(),1);
    }
}