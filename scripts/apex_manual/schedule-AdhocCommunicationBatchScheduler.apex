System.debug(LoggingLevel.DEBUG, 'schedule-AdhocCommunicationBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Adhoc_Communication_Cron_Expression;
String ClassName='AdhocCommunicationBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new AdhocCommunicationBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD