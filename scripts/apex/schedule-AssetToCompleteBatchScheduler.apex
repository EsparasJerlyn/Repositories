System.debug('schedule-AssetToCompleteBatchScheduler.apex');
 
String cronExp = Label.Asset_Cron_Expression;
String ClassName='AssetToCompleteBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new AssetToCompleteBatchScheduler());
}
 
System.debug('Complete');