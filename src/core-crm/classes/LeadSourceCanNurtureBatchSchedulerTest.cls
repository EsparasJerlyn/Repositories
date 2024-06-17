/**
 * @description Test class for LeadSourceCanNurtureFlagBatchScheduler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | March 05, 2024        | DEPP-8069              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class LeadSourceCanNurtureBatchSchedulerTest {
    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }

    @isTest
    static void schedulerTest(){
		System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.StartTest();
            LeadSourceCanNurtureFlagBatchScheduler LeadScoreCanNurtureScheduler = new LeadSourceCanNurtureFlagBatchScheduler();
            String sch = '0 0 0 * * ?';
            system.schedule('Test status Check', sch, LeadScoreCanNurtureScheduler );
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'LeadSourceCanNurtureFlagBatchScheduler'].isEmpty() , 'LeadSourceCanNurtureFlagBatchScheduler Job was not executed');
            Test.stopTest();
		}
	}
}