System.debug('schedule-SendWelcomeEmailBatchScheduler.apex');
 
String cronExp = Label.Send_Welcome_Email_Cron_Expression;
String ClassName='SendWelcomeEmailBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new SendWelcomeEmailBatchScheduler());
}
 
System.debug('Complete');