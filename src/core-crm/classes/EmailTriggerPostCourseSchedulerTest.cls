/**
 * @description An apex page controller that controls the Email trigger for Post Course
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
public with sharing class EmailTriggerPostCourseSchedulerTest {
   
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
			EmailTriggerPostCourseScheduler emailScheduler = new EmailTriggerPostCourseScheduler();
			String sch = '0 0 23 * * ?';
			system.schedule('Test status Check', sch, emailScheduler );
			System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'EmailTriggerPostCourseScheduler'].isEmpty() , 'EmailTriggerPostCourseScheduler Job was not executed');
			Test.stopTest();
		}
	}
}