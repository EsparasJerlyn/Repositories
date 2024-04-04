/**
 * @description Test class for Adhoc Communication Batch Scheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan  	       | October 10, 2023      | DEPP-6612              | Created file                 | 
 */
@IsTest

public class AdhocCommunicationBatchSchedulerTest {

    @testSetup 
    static void setupMethod() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator'} );
    }

    @isTest
    static void adhocCommunicationSchedulerTest(){
        
        System.runAs(TestDataFactory.getProgramAdminUser()){              
            String cronExpression = Label.Adhoc_Communication_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test Adhoc Communication Schedule daily at 7AM', cronExpression, new AdhocCommunicationBatchScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}