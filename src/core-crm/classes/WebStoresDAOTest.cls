/**
 * @description test class for WebStoresDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 */
@isTest
public with sharing class WebStoresDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(WebStoresDAO.newInstance() != null, 'WebStoresdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new WebStoresDAO().getSObjectType() == WebStore.SObjectType,
                'SObject is not WebStore'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCCEWebStoreIdTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                WebStoresDAO.newInstance().getCCEWebStoreId() == null, 
                'webStores is not empty.'
            );
            Test.stopTest();
        }
    }
}
