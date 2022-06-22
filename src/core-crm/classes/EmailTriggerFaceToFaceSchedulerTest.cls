@isTest
public with sharing class EmailTriggerFaceToFaceSchedulerTest {

    public static testMethod void EmailTriggerFaceToFaceSchedulerTest() {
		Test.StartTest();
		EmailTriggerFaceToFaceScheduler emailScheduler = new EmailTriggerFaceToFaceScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, emailScheduler );
		Test.stopTest();
	}
}
