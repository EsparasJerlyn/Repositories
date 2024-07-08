/**
 * @description Tests the LoqateMobileValidationScheduler
 *
 * @see LoqateMobileValidationScheduler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | May 31, 2022          | DEPP-2105    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest 
public class LoqateMobileValidationSchedulerTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void testLoqateScheduler(){
        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){              
            String cronExpression = Label.Loqate_Mobile_Validation_Cron_Expression;
            
            Test.startTest();
            
            String jobId = System.Schedule('Test LoqateMobileValidationBatch daily at 12AM', cronExpression, new LoqateMobileValidationScheduler());
            
            Test.stopTest();
            
            List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime,CronExpression FROM CronTrigger WHERE ID =: jobId ];
            
            System.assertEquals(cronExpression, cts[0].CronExpression,'Cron Expression Time is different');
            System.assertEquals(0, cts[0].TimesTriggered,'Times Triggered is not equal to zero');
        }
    }
}