/**
 * @description Test class for CompletedCadencesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                       |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | created file                                                         |
      | roy.nino.s.regala              | Aug 9, 2023           | DEPP-5677              | added test method                                                    |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Updated test method getCompletedCadenceByTargetIdsAndCadenceNameTest |
 */
@isTest
public with sharing class CompletedCadencesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator', 'QUT_Domestic_Future_Student_Agent' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CompletedCadencesDAO().getSObjectType() == Completed_Cadence__c.SObjectType,
                'SObject is not Completed_Cadence__c'
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void getCompletedCadenceByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByContactIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(completedCadenceList.isEmpty(), 'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getCompletedCadenceByLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByLeadIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(completedCadenceList.isEmpty(), 'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCompletedCadenceByTargetIdsAndCadenceNameTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByTargetIdsAndCadenceName(
                    new Set<String>(),
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(completedCadenceList.isEmpty(), 'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCompletedCadenceByTargetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByTargetIds(
                    new Set<Id>(),
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(completedCadenceList.isEmpty(), 'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }
       
}