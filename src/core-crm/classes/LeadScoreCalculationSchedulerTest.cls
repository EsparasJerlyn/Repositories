/**
 * @description Test class for LeadScoreCalculationScheduler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 18, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class LeadScoreCalculationSchedulerTest {
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
            LeadScoreCalculationScheduler emailScheduler = new LeadScoreCalculationScheduler();
            String sch = '0 0 10 * * ?';
            system.schedule('Test status Check', sch, emailScheduler );
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'LeadScoreCalculationScheduler'].isEmpty() , 'LeadScoreCalculationScheduler Job was not executed');
            Test.stopTest();
		}
	}
}