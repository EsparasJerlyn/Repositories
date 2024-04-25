System.debug(LoggingLevel.DEBUG, 'schedule-CourseOfferingEndDateBatchScheduler.apex');//NOPMD
 
String cronExp = Label.Course_Offering_End_Date_Cron_Expression;
String ClassName='CourseOfferingEndDateBatchScheduler';
 
list<AsyncApexJob> aJob= [
    SELECT Id, Status, ApexClassID
    FROM AsyncApexJob
    WHERE ApexClass.Name = :ClassName AND Status = 'Queued'
];
 
if(aJob.size()>0){
    System.Debug(LoggingLevel.DEBUG, 'Job already scheduled: '+aJob[0]);//NOPMD
}else{
    System.Debug(LoggingLevel.DEBUG, 'Schedule Job: '+ClassName);//NOPMD
    System.schedule(ClassName, cronExp, new CourseOfferingEndDateBatchScheduler());
}
 
System.debug(LoggingLevel.DEBUG, 'Complete');//NOPMD