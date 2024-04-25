System.debug(LoggingLevel.DEBUG, 'schedule-LeadScoreCalculationBatch.apex');//NOPMD
 
String cronExp = Label.Recalculate_Lead_Score_Cron_Expression;
String ClassName = 'LeadScoreCalculationScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: ' + aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: ' + ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new LeadScoreCalculationScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD