/**
 * @description test class for SyncOperatingHoursToAWSBatchScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.aldric.s.seril   	       | Jul. 29, 2024         | DEPP-9834              | Created file                 | 
 */
@isTest
public with sharing class SyncOperatingHrsToAWSBatchSchedulerTest {
    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }


    @isTest
    static void schedulerTest(){
        
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){              
            String cronExpression = Label.Sync_Operating_Hours_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test SyncOperatingHrsToAWSBatchSchedulerTest daily at 12AM', cronExpression, new SyncOperatingHoursToAWSBatchScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}