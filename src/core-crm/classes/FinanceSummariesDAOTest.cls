/**
 * @description test class for FinanceSummariesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 12, 2023         | DEPP-5473              | Created file
 */
@isTest
public with sharing class FinanceSummariesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Operations_Manager' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getOperationsManager()) {
            System.assert(FinanceSummariesDAO.newInstance() != null, 'FinanceSummariesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getOperationsManager()) {
            System.assert(
                new FinanceSummariesDAO().getSObjectType() == Finance_Summary__c.SObjectType,
                'SObject is not Finance_Summary__c'
            );
        }
        Test.stopTest();
    }
}
