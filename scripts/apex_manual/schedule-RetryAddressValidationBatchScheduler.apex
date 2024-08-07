System.debug(LoggingLevel.DEBUG, 'schedule-RetryAddressValidationBatchScheduler.apex');//NOPMD
 
String cronExp = '0 0 2 ? * *';
String ClassName = 'RetryAddressValidationBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new RetryAddressValidationBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD