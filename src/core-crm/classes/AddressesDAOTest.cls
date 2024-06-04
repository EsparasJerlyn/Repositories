/**
 * @description test class for Addressesdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | sep 22, 2023          | DEPP-6652              | Created file
 */
@isTest
public with sharing class AddressesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(AddressesDAO.newInstance() != null, 'Addressesdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new AddressesDAO().getSObjectType() == hed__Address__c.SObjectType,
                'SObject is not hed__Address__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getAddressesByContactIdsSet() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Address__c> addressList = AddressesDAO.newInstance()
                .getAddressesByContactIdsSet(new Set<Id>(), AccessLevel.USER_MODE);
            System.assert(addressList.isEmpty(), 'actionlist is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getAddressesByContactIdsNotEmptySet() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            List<hed__Address__c> addressList = AddressesDAO.newInstance()
                .getAddressesByContactIdsSet(
                    new Set<Id>{ mockIdGen.getMockId() },
                    AccessLevel.USER_MODE
                );
            System.assert(addressList.isEmpty(), 'actionlist is not empty');
        }
        Test.stopTest();
    }
}
