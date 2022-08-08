global without sharing class EmailTriggerFaceToFaceScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EmailTriggerFaceToFaceBatch(),1);
    }
}
