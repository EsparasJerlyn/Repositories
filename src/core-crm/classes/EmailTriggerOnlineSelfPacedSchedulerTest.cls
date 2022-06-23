@isTest
public with sharing class EmailTriggerOnlineSelfPacedSchedulerTest {
    
    public static testMethod void EmailTriggerOnlineSelfPacedSchedulerTest() {
		Test.StartTest();
		EmailTriggerOnlineSelfPacedScheduler emailScheduler = new EmailTriggerOnlineSelfPacedScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, emailScheduler );
		Test.stopTest();
	}
}