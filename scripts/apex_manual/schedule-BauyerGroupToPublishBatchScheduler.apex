System.debug(LoggingLevel.DEBUG, 'schedule-BuyerGroupToPublishBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Buyer_Group_Cron_Expression;
String ClassName='BuyerGroupToPublishBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new BuyerGroupToPublishBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD