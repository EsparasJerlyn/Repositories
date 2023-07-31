/**
 * @description Test class for CompletedCadencesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | created file                 |
 */
@isTest
public with sharing class CompletedCadencesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
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
}