global without sharing class EmailTriggerVirtualScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EmailTriggerVirtualBatch());
    }
}
