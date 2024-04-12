/**
 * @description Test Class for PackageComponentDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | arsenio.jr.dayrit              | August 15, 2023       |DEPP-6370               | Created File                        |
 *    | eccarius.munoz                 | August 21, 2023       |DEPP-6252               | Added test method for               |
 *    |                                |                       |                        | getPackageComponentsByAppPrefIdSet  |
 */
@isTest
public with sharing class PackageComponentDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(PackageComponentDAO.newInstance() != null, 'PackageComponentDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new PackageComponentDAO().getSObjectType() == Package_Component__c.SObjectType,
                'SObject is not Package_Component__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getPackageComponentsByAppPrefIdSetTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Package_Component__c> packageComponentList = PackageComponentDAO.newInstance()
                .getPackageComponentsByAppPrefIdSet(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(packageComponentList.isEmpty(), 'Package component list should not be empty.');
        }
        Test.stopTest();
    }

} 