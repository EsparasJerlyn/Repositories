@isTest
public with sharing class EmailTriggerVirtualSchedulerTest {
    
    public static testMethod void EmailTriggerVirtualSchedulerTest() {
		Test.StartTest();
		EmailTriggerVirtualScheduler emailScheduler = new EmailTriggerVirtualScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, emailScheduler );
		Test.stopTest();
	}
}