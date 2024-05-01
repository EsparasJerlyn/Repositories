/**
 * @description test class for DonationStageUpdateScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Created file                 | 
 */
@isTest
private class DonationStageUpdateSchedulerTest {
    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Sys_Admin'});
        Test.stopTest();
    }
    @isTest
    static void schedulerTest(){
        System.runAs(TestDataFactory.getPortalSysAdminUser()){
            String cronExpression = Label.Donation_Cron_Expression;
            Test.startTest();
            String jobId = System.Schedule('Test DonationStageUpdateScheduler daily at 6AM', cronExpression, new DonationStageUpdateScheduler());
            Test.stopTest();
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime, CronExpression FROM CronTrigger WHERE ID =: jobId ];
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}