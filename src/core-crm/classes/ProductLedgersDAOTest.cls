/**
 * @description test class for productLedgersdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 05, 2024          | n/a                    | Created file
 */
@isTest
public with sharing class ProductLedgersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(ProductLedgersDAO.newInstance() != null, 'productLedgersdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ProductLedgersDAO().getSObjectType() == Product_Ledger__c.SObjectType,
                'SObject is not Product_Ledger__c'
            );
        }
        Test.stopTest();
    }
}
