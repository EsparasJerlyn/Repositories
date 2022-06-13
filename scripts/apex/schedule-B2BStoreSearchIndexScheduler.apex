System.debug('schedule-B2BStoreSearchIndexScheduler.apex');
 
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
        System.Debug('Job already scheduled: '+aJob[0]);
    }
}else{
    scheduleJob = true;
}

if(scheduleJob){
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new B2BStoreSearchIndexScheduler());
}
 
System.debug('Complete');