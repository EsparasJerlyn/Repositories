/**
 * @description Tests the Program_Plan_Start_Date_to_Today Flow
 *
 * @see Program_Plan_Start_Date_to_Today
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                                  |
      |---------------------------|-----------------------|-----------|-------------------------------------------------|
      | roy.nino.s.regala         | February 16, 2023     | DEPP-5164 | Created file                                    |
*/
@isTest
public with sharing class Program_Plan_Start_Date_to_TodayTest {


    @isTest
    static void programplanStartDateTodayTest() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(100);
            insert programPlans;
        }
        system.assert(![SELECT Id FROM hed__Program_Plan__c WHERE hed__Start_Date__c = TODAY LIMIT 100].isEmpty(), 'program plans start dates are not today');
    }
}

