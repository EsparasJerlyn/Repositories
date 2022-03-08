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
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime FROM CronTrigger WHERE ID =: jobId ];
            
            DateTime midnight = Datetime.newInstance(date.today(), time.newInstance(0, 0, 0, 0));
            String dayToday = midnight.format('EEEE');
            
            if(dayToday == 'Friday'){
                System.assertEquals(midnight.addDays(3),cts[0].NextFireTime, 'Error, Next fire is Not Monday');
            }else if(dayToday =='Saturday'){
                System.assertEquals(midnight.addDays(2),cts[0].NextFireTime, 'Error, Next fire is Not Monday');
            }else if(dayToday == 'Sunday'){
                System.assertEquals(midnight.addDays(1),cts[0].NextFireTime, 'Error, Next fire is Not Monday');
            }
            else{
                System.assertEquals(midnight.addHours(24),cts[0].NextFireTime, 'Error Not Scheduled in Midnight');
            }
        }
    }
}