/**
 * @description Test Class IndividualEmailResultsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | created file                                |
 */
@isTest
public with sharing class IndividualEmailResultsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'System_Administrator' });
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            System.assert(
                new IndividualEmailResultsDAO().getSObjectType() == et4ae5__IndividualEmailResult__c.SObjectType,
                'SObject is not et4ae5__IndividualEmailResult__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getIndivEmailResultsByContactOrLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            List<et4ae5__IndividualEmailResult__c> indivEmailList = IndividualEmailResultsDAO.newInstance()
                .getIndivEmailResultsByContactOrLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(indivEmailList.isEmpty(), 'Individual Email Results is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetIndivEmailResultsByContactOrLeadIdsTest() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            Test.startTest();
            System.assert(
                IndividualEmailResultsDAO.newInstance().queryLocatorGetIndivEmailResultsByContactOrLeadIds(
                    new Set<Id>()
                ) != null,
                'Individual Email Results should not be empty.'
            );
            Test.stopTest();
        }
    }
}