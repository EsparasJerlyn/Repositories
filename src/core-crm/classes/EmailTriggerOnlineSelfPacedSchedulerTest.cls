/**
 * @description An apex page controller that controls the Email trigger for Online Self-Paced
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
public with sharing class EmailTriggerOnlineSelfPacedSchedulerTest {
    
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
			EmailTriggerOnlineSelfPacedScheduler emailScheduler = new EmailTriggerOnlineSelfPacedScheduler();
			String sch = '0 0 23 * * ?';
			system.schedule('Test status Check', sch, emailScheduler );
			System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'EmailTriggerOnlineSelfPacedScheduler'].isEmpty() , 'EmailTriggerOnlineSelfPacedScheduler Job was not executed');
			Test.stopTest();
		}
	}
}