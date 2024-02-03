/**
 * @description Tests the CourseOfferingEndDateBatchScheduler
 *
 * @see CourseOfferingEndDateBatchScheduler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | sebastianne.k.trias       | January 25, 2024      | DEPP-7481    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest
public class CourseOfferingEndDateBatchSchedulerTest {
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();

    @isTest
    static void testCourseOfferingEndDateScheduler(){
        
        System.runAs(currentUser){              
            String cronExpression = Label.Course_Offering_End_Date_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test CourseOfferingEndDateTest daily at 12AM', cronExpression, new CourseOfferingEndDateBatchScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }

}