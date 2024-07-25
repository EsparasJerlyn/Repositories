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
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserSysAdminIntegration();
        
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(AddressesDAO.newInstance() != null, 'Addressesdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Address__c> addressList = AddressesDAO.newInstance()
                .getAddressesByContactIdsSet(new Set<Id>(), AccessLevel.USER_MODE);
            System.assert(addressList.isEmpty(), 'actionlist is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getAddressesByContactIdsNotEmptySet() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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

    @isTest
    static void getAddressesByContactIdsAndAddressTypeTest() {
        Test.startTest();
        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Address__c> addressList = AddressesDAO.newInstance()
                .getAddressesByContactIdsAndAddressType(new Set<Id>{ mockIdGen.getMockId() }, new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'SYSTEM_MODE');
            System.assert(addressList.isEmpty(), 'actionlist is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryLocatorByIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            System.assert(
                AddressesDAO.newInstance().getQueryLocatorByIds(new Set<Id>{ mockIdGen.getMockId() }) != null,
                'Address queues retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getQueryLocatorByIntegrationStatusTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                AddressesDAO.newInstance().getQueryLocatorByIntegrationStatus(new Set<String>{AddressesDAO.INTEGRATION_STATUS_SENT, AddressesDAO.INTEGRATION_STATUS_FAILED, AddressesDAO.INTEGRATION_STATUS_RETRY}) != null,
                'Address queues retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getAddressesByIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSysAdminIntegration) {
            MockIdGenerator mockIdGen = new MockIdGenerator(hed__Address__c.SObjectType);
            List<hed__Address__c> addressList = AddressesDAO.newInstance()
                .getAddressesByIds(new Set<Id>{mockIdGen.getMockId()}, AccessLevel.USER_MODE);
            System.assert(addressList.isEmpty(), 'addressList is not empty');
        }
        Test.stopTest();
    }
}