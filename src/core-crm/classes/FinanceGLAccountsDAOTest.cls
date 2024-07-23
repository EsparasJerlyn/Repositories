/**
 * @description test class for FinanceGLAccountsDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                           |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------------------------------------------|
      | neil.s.h.lesidan               | April 11, 2024        | DEPP-8392              | Created file                                                                             |
*/
@isTest
public with sharing class FinanceGLAccountsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Advancement_Manager' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAdvancementManager()) {
            System.assert(FinanceGLAccountsDAO.newInstance() != null, 'FinanceGLAccountsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAdvancementManager()) {
            System.assert(
                new FinanceGLAccountsDAO().getSObjectType() == Finance_GL_Account__c.SObjectType,
                'SObject is not Finance_GL_Account__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getFinanceGLAccountBySetNamesWithLimitTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAdvancementManager()) {
            List<Finance_GL_Account__c> financeGlAccountList = FinanceGLAccountsDAO.newInstance()
                .getFinanceGLAccountBySetNamesWithLimit(new Set<String>(), 1);
            System.assert(financeGlAccountList.isEmpty(), 'financeGlAccountList is not empty');
        }
        Test.stopTest();
    }
}