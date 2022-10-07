System.debug('schedule-BuyerGroupToPublishBatchScheduler.apex');
 
String cronExp = Label.Buyer_Group_Cron_Expression;
String ClassName='BuyerGroupToPublishBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new BuyerGroupToPublishBatchScheduler());
}
 
System.debug('Complete');