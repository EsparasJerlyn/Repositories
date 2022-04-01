/**
 * @description Tests the PublishingEndDateScheduler
 *
 * @see PublishingEndDateScheduler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan       | March 02, 2022        | DEPP-1256    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData=false) 
public class PublishingEndDateBatchSchedulerTest {
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();

    @IsTest
    static void testPublishingEndDateScheduler(){
        
        System.runAs(currentUser){              
            String cronExpression = Label.Publishing_End_Date_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test PublishingEndDateTest daily at 12AM', cronExpression, new PublishingEndDateBatchScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}