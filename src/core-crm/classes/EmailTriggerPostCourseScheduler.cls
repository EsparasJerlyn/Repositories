global without sharing class EmailTriggerPostCourseScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EmailTriggerPostCourseBatch());
    }
}

