/**
 * @description test class for DAO Class for Asset Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created                      | 
 */
@isTest
public with sharing class AssetsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void queryLocatorProductRequestsOfAssetToCompleteTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                AssetsDAO.newInstance().queryLocatorProductRequestsOfAssetToComplete() != null,
                'assets retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new AssetsDAO().getSObjectType() == Asset.SObjectType,
                'SObject is not Asset'
            );
        }
        Test.stopTest();
    }
}
