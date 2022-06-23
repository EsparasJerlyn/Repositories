System.debug('schedule-EmailTriggerVirtualScheduler.apex');
 
String cronExp = Label.Email_Trigger_Cron_Expression;
String ClassName='EmailTriggerVirtualScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new EmailTriggerVirtualScheduler());
}
 
System.debug('Complete');