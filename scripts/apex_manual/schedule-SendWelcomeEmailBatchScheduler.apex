System.debug(LoggingLevel.DEBUG, 'schedule-SendWelcomeEmailBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Send_Welcome_Email_Cron_Expression;
String ClassName='SendWelcomeEmailBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName AND Status = 'Queued'
];
 
if(aJob.size()>0){
    System.debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new SendWelcomeEmailBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD