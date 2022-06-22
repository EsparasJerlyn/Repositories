@isTest
public with sharing class EmailTriggerPostCourseSchedulerTest {
   
    public static testMethod void EmailTriggerPostCourseSchedulerTest() {
		Test.StartTest();
		EmailTriggerPostCourseScheduler emailScheduler = new EmailTriggerPostCourseScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, emailScheduler );
		Test.stopTest();
	}
}