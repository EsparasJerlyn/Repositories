/**
 * @description test class for DistributionMgtStatusUpdateScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay      	       | April 11, 2024        | DEPP-8453              | Created file                 |
 */
@isTest
public class DistributionMgtStatusUpdateSchedulerTest {
    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Sys_Admin'});
        Test.stopTest();
    }
    
    @isTest
    static void schedulerTest(){
        System.runAs(TestDataFactory.getPortalSysAdminUser()){
            String cronExpression = Label.Distribution_Management_Cron_Expression;
            Test.startTest();
            String jobId = System.Schedule('Test DistributionMgtStatusUpdateScheduler daily at 6AM', cronExpression, new DistributionMgtStatusUpdateScheduler());
            Test.stopTest();
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime, CronExpression FROM CronTrigger WHERE ID =: jobId ];
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}