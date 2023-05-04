/**
 * @description Test class for LeadsDAOTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public with sharing class LeadsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getExistingUnconvertedLeadsByEmailTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getExistingUnconvertedLeadsByEmail(
                    new Set<String>(),
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(leadList.isEmpty(), 'leadList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadsWithLimitTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            System.assert(leadList.isEmpty(), 'leadList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new LeadsDAO().getSObjectType() == Lead.SObjectType,
                'SObject is not Lead'
            );
        }
        Test.stopTest();
    }
}
