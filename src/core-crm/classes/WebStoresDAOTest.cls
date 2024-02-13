/**
 * @description test class for WebStoresDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 */
@isTest
public with sharing class WebStoresDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(WebStoresDAO.newInstance() != null, 'WebStoresdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new WebStoresDAO().getSObjectType() == WebStore.SObjectType,
                'SObject is not WebStore'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCCEWebStoreIdTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                WebStoresDAO.newInstance().getCCEWebStoreId() == null, 
                'webStores is not empty.'
            );
            Test.stopTest();
        }
    }
}
