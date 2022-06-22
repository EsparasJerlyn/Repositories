@isTest
public with sharing class EmailTriggerPreSessionSchedulerTest {
    
    public static testMethod void EmailTriggerPreSessionSchedulerTest() {
		Test.StartTest();
		EmailTriggerPreSessionScheduler emailScheduler = new EmailTriggerPreSessionScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, emailScheduler );
		Test.stopTest();
	}
}