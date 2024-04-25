System.debug(LoggingLevel.DEBUG, 'schedule-ApplicantFlagBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Applicant_Flag_Cron_Expression;
String ClassName='ApplicantFlagBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
    AND Status != 'Aborted'
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new ApplicantFlagBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD