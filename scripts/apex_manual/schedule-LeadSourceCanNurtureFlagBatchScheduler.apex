System.debug(LoggingLevel.DEBUG, 'schedule-LeadSourceCanNurtureFlagBatchScheduler');//NOPMD
 
String cronExp = Label.Lead_Source_Can_Nurture_Cron_Expression;
String ClassName = 'LeadSourceCanNurtureFlagBatchScheduler';
 
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
    System.schedule(ClassName, cronExp, new LeadSourceCanNurtureFlagBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD