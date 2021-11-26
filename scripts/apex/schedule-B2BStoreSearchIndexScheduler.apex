System.debug('schedule-B2BStoreSearchIndexScheduler.apex');
 
String cronExp = Label.Build_Search_Index_Cron_Expression;
String ClassName='B2BStoreSearchIndexScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName
];
 
if(aJob.size()>0){
    System.Debug('Job already scheduled: '+aJob[0]);
}else{
    System.Debug('Schedule Job: '+ClassName);
    System.schedule(ClassName, cronExp, new B2BStoreSearchIndexScheduler());
}
 
System.debug('Complete');