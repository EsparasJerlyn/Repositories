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
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
@isTest
public with sharing class AssetsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void queryLocatorProductRequestsOfAssetToCompleteTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new AssetsDAO().getSObjectType() == Asset.SObjectType,
                'SObject is not Asset'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getAssetsByProductRequestIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            MockIdGenerator mockPR = new MockIdGenerator(Product_Request__c.SObjectType);
            List<Asset> assets = AssetsDAO.newInstance().getAssetsByProductRequestIds(
                new Set<Id>{mockPR.getMockId()},
                AccessLevel.SYSTEM_MODE
            );
            System.assert(assets.isEmpty(), 'assets is not empty');
            Test.stopTest();
        }
    }

    @isTest
    static void getAssetsByProductRequestIdsEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<Asset> assets = AssetsDAO.newInstance().getAssetsByProductRequestIds(
                new Set<Id>(),
                AccessLevel.SYSTEM_MODE
            );
            System.assert(assets.isEmpty(), 'assets is not empty');
            Test.stopTest();
        }
    }
}
