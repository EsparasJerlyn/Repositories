/**
 * @description ProgramOfferingTriggerHandler Test Class
 * @see ProgramOfferingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 26, 2022        | DEPP-1687              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class ProgramOfferingTriggerHandlerTest {
    private static User currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();

    @IsTest
    private static void insertProgramOfferingTest() {
        System.runAs(currentUser) {
            Test.startTest();

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(25);
            insert programPlans;
            List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(25,programPlans);
            insert programOfferings;

            Test.stopTest();
            System.assert(![SELECT Id FROM Program_Offering__c].isEmpty(),'No Program offering created');
        }
    }
}
