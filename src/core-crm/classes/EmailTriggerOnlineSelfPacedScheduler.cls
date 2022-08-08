global without sharing class EmailTriggerOnlineSelfPacedScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EmailTriggerOnlineSelfPacedBatch(),1);
    }
}
