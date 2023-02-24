System.debug(LoggingLevel.DEBUG, 'schedule-B2BStoreSearchIndexScheduler.apex');//NOPMD
 
String cronExp = Label.Build_Search_Index_Cron_Expression;
String ClassName='B2BStoreSearchIndexScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
    ORDER BY CreatedDate DESC
];

Boolean scheduleJob = false;
if(aJob.size()>0){
    if(aJob[0].Status!='Queued'){
        scheduleJob = true;
    }else{
        System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
    }
}else{
    scheduleJob = true;
}

if(scheduleJob){
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new B2BStoreSearchIndexScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD