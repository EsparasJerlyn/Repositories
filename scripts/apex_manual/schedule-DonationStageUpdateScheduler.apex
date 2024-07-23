System.debug(LoggingLevel.DEBUG, 'schedule-DonationStageUpdateScheduler.apex');//NOPMD
 
String cronExp = Label.Donation_Cron_Expression;
String ClassName='DonationStageUpdateScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new DonationStageUpdateScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD