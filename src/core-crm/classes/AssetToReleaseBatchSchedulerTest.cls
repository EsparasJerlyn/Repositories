/**
 * @description test class for AssetToReleaseBatchScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | August 11, 2023       | DEPP-6240              | Created file                 |
 */
@isTest
public class AssetToReleaseBatchSchedulerTest {
    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }

    @isTest
    static void schedulerTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){              
            String cronExpression = Label.Asset_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test AssetToReleaseBatchScheduler daily at 12AM', cronExpression, new AssetToReleaseBatchScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}