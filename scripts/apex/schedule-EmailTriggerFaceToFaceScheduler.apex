System.debug(LoggingLevel.DEBUG, 'schedule-EmailTriggerFaceToFaceScheduler.apex');//NOPMD
 
String cronExp = Label.Email_Trigger_Cron_Expression;
String ClassName='EmailTriggerFaceToFaceScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new EmailTriggerFaceToFaceScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD