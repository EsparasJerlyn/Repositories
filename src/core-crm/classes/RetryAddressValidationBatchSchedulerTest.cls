/**
 * @description Test class for RetryAddressValidationBatchScheduler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | gabriel.p.ventayen             | June 11, 2024          | DEPP-8953             | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class RetryAddressValidationBatchSchedulerTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }
    
    @isTest
    static void schedulerTest(){
		System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            String cronExpression = '0 0 2 ? * *';
            
            Test.startTest();
                RetryAddressValidationBatchScheduler scheduler = new RetryAddressValidationBatchScheduler();
                System.schedule('Test Retry Address Validation Scheduler', cronExpression, scheduler);
            Test.stopTest();
            
            List<AsyncApexJob> jobsScheduled = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
            System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
            System.assertEquals('RetryAddressValidationBatchScheduler', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
            
            List<AsyncApexJob> jobsApexBatch = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex'];
            System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
            System.assertEquals('RetryAddressValidationBatch', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');
        }
	}
}