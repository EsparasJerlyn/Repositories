System.debug(LoggingLevel.DEBUG, 'schedule-ProductLedgerEndedBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Product_Ledger_Ended_Cron_Expression;
String ClassName='ProductLedgerEndedBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new ProductLedgerEndedBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD