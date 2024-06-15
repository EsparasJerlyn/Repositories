/**
 * @description An apex page controller that controls the Email trigger for Virtual
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
public with sharing class EmailTriggerVirtualSchedulerTest {
    
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
			EmailTriggerVirtualScheduler emailScheduler = new EmailTriggerVirtualScheduler();
			String sch = '0 0 23 * * ?';
			system.schedule('Test status Check', sch, emailScheduler );
			System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'EmailTriggerVirtualScheduler'].isEmpty() , 'EmailTriggerVirtualScheduler Job was not executed');
			Test.stopTest();
		}
	}
}