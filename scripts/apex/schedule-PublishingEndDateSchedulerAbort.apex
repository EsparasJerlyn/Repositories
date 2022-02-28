System.debug('schedule-PublishingEndDateSchedulerAbort.apex');
 
List<CronTrigger> jobIdList = new List<CronTrigger>();
jobIdList = [select Id from CronTrigger where CronJobDetail.Name = 'PublishingEndDateScheduler'];
for(CronTrigger job:jobIdList )
{
   System.abortJob(job.id);
}

System.debug('Complete');