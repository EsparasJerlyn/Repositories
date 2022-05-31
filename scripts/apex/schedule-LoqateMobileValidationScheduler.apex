System.debug('schedule-LoqateMobileValidationScheduler.apex');
 
String cronExp = Label.Loqate_Mobile_Validation_Cron_Expression;
String ClassName='LoqateMobileValidationScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new LoqateMobileValidationScheduler());
}
 
System.debug('Complete');