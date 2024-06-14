/**
 * @description test class for ExpensesDAOTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | carl.alvin.cabiles             | August 22, 2023       | DEPP-6410              | Created file
 */
@isTest
public with sharing class ExpensesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserIndustryOperationsManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            System.assert(ExpensesDAO.newInstance() != null, 'ExpensesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            System.assert(
                new ExpensesDAO().getSObjectType() == Expense__c.SObjectType,
                'SObject is not Expense__c'
            );
        }
        Test.stopTest();
    }
}