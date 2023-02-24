System.debug(LoggingLevel.DEBUG, 'schedule-AssetToCompleteBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Asset_Cron_Expression;
String ClassName='AssetToCompleteBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new AssetToCompleteBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD