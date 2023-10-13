System.debug(LoggingLevel.DEBUG, 'schedule-LoqateMobileValidationScheduler.apex');//NOPMD
 
String cronExp = Label.Loqate_Mobile_Validation_Cron_Expression;
String ClassName='LoqateMobileValidationScheduler';
 
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
    System.schedule(ClassName, cronExp, new LoqateMobileValidationScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD