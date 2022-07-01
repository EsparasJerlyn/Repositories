System.debug('schedule-EmailTriggerPostCourseScheduler.apex');
 
String cronExp = Label.Email_Trigger_Cron_Expression;
String ClassName='EmailTriggerPostCourseScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new EmailTriggerPostCourseScheduler());
}
 
System.debug('Complete');