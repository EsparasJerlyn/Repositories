/**
 * @description test class for ApplicantFlagBatchScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | March 28, 2024        | DEPP-8382              | Created file                 |
 */
@isTest
public class ApplicantFlagBatchSchedulerTest {
    @testSetup 
    static void setupMethod() {
        Test.startTest();
            TestDataFactory.generateTestUsers();
        Test.stopTest();
    }

    @isTest
    static void schedulerTest(){
        System.runAs(TestDataFactory.getPortalSysAdminUser()){              
            String cronExpression = Label.Applicant_Flag_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test ApplicantFlagBatchScheduler daily at 12AM', cronExpression, new ApplicantFlagBatchScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}