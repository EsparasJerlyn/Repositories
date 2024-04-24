System.debug(LoggingLevel.DEBUG, 'schedule-PublishingEndDateBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Publishing_End_Date_Cron_Expression;
String ClassName='PublishingEndDateBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new PublishingEndDateBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD