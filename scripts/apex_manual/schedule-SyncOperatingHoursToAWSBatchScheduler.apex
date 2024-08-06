System.debug(LoggingLevel.DEBUG, 'schedule-SyncOperatingHoursToAWSBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Sync_Operating_Hours_Cron_Expression;
String ClassName='SyncOperatingHoursToAWSBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new SyncOperatingHoursToAWSBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD