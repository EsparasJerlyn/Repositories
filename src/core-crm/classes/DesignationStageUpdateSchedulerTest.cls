/**
 * @description test class for DesignationStageUpdateScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		    | March. 15, 2022       | DEPP-8210              | Created file                 | 
 */
@isTest
private class DesignationStageUpdateSchedulerTest{
     @testSetup
     static void setupMethod() {
         Test.startTest();
         TestDataFactory.generateTestUsers(new List<String>{'QUT_Sys_Admin'});
         Test.stopTest();
     }
     @isTest
     static void schedulerTest(){
         System.runAs(TestDataFactory.getPortalSysAdminUser()){
             String cronExpression = Label.Designation_Cron_Expression;
             Test.startTest();
             String jobId = System.Schedule('Test DesignationStageUpdateScheduler daily at 6AM', cronExpression, new DesignationStageUpdateScheduler());
             Test.stopTest();
             List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime, CronExpression FROM CronTrigger WHERE ID =: jobId ];
             System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
             System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
         }
     }
}