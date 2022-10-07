System.debug('schedule-ProductLedgerEndedBatchScheduler.apex');
 
String cronExp = Label.Product_Ledger_Ended_Cron_Expression;
String ClassName='ProductLedgerEndedBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new ProductLedgerEndedBatchScheduler());
}
 
System.debug('Complete');