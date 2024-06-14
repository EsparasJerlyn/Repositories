/**
 * @description test class for BuyerGroupToPublishBatchScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala   	       | August 8, 2022        | DEPP-2498              | Created file                 | 
 */
@isTest
public class BuyerGroupToPublishBatchSchedulerTest {
    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }


    @isTest
    static void schedulerTest(){
        
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){              
            String cronExpression = Label.Buyer_Group_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test BuyerGroupToPublishBatchScheduler daily at 12AM', cronExpression, new BuyerGroupToPublishBatchScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}