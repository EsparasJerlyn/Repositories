/**
 * @description Test Class CasesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Created File                                     |
 */
@isTest
public with sharing class CasesDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CasesDAO().getSObjectType() == Case.SObjectType,
                'SObject is not Case'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByContactIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByContactOrLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByContactOrLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }
}