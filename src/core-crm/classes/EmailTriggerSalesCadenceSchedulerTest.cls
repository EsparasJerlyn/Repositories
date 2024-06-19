/**
 * @description Test class for EmailTriggerSalesCadenceScheduler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 08, 2023    | DEPP-6138              | Created File                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class EmailTriggerSalesCadenceSchedulerTest {
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
            EmailTriggerSalesCadenceScheduler emailScheduler = new EmailTriggerSalesCadenceScheduler();
            String sch = '0 0 10 * * ?';
            system.schedule('Test status Check', sch, emailScheduler );
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'EmailTriggerSalesCadenceScheduler'].isEmpty() , 'EmailTriggerSalesCadenceScheduler Job was not executed');
            Test.stopTest();
		}
	}
}