System.debug(LoggingLevel.DEBUG, 'schedule-ELCEvaluationScheduler.apex');//NOPMD
 
String cronExp = '0 0 7 ? * TUE-THU';
String ClassName='ELCEvaluationScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new ELCEvaluationScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD