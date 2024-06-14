/**
 * @description test class for for ProductLedgerEndedBatchScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		       | Aug  25, 2022	       | DEPP-3482              | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest 
public class ProductLedgerEndedBatchSchedulerTest {

    @isTest
    static void testProductLedgerScheduler(){

        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){              
            String cronExpression = Label.Product_Ledger_Ended_Cron_Expression;
            
            String jobId = System.Schedule('Test Product Ledger daily at 12AM', cronExpression, new ProductLedgerEndedBatchScheduler());
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}