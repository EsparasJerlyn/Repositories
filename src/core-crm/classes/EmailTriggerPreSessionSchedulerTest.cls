/**
 * @description An apex page controller that controls the Email trigger for Pre-session
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li                   | January 3, 2023       | N/A                    | Fix PMD issue                |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class EmailTriggerPreSessionSchedulerTest {
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
			EmailTriggerPreSessionScheduler emailScheduler = new EmailTriggerPreSessionScheduler();
			String sch = '0 0 23 * * ?';
			system.schedule('Test status Check', sch, emailScheduler );
			System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'EmailTriggerPreSessionScheduler'].isEmpty() , 'EmailTriggerPreSessionScheduler Job was not executed');
			Test.stopTest();
		}
	}
}