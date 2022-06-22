System.debug('schedule-EmailTriggerFaceToFaceScheduler.apex');
 
String cronExp = Label.Publishing_End_Date_Cron_Expression;
String ClassName='EmailTriggerFaceToFaceScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new EmailTriggerFaceToFaceScheduler());
}
 
System.debug('Complete');