/**
 * @description scheduler for SendWelcomeEmailBatchScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala   	       | July 30, 2022         | DEPP-3557              | Created file                 | 
 */
@isTest 
public class SendWelcomeEmailBatchSchedulerTest {
    @testSetup 
    static void setupMethod() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }


    @isTest
    static void testSendWelcomeEmailBatch(){
        
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){              
            String cronExpression = Label.Send_Welcome_Email_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test SendWelcomeEmailBatchSchedulerTest daily at 12AM', cronExpression, new SendWelcomeEmailBatchScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}