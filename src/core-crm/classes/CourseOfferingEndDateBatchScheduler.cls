/**
 * @description Scheduler for CourseOfferingEndDate
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | sebastianne.k.trias       | January 25, 2024      | DEPP-7481    | Created file                                |
      |                           |                       |              |                                             |
*/
public with sharing class CourseOfferingEndDateBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling Course Offering End Date batch job
    */
    public void execute (SchedulableContext context){
        CourseOfferingEndDateBatch batch = new CourseOfferingEndDateBatch();
		Database.executeBatch(batch);
    }
}