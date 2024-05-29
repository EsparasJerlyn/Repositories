/**
 * @description test class for Addressesdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | sep 22, 2023          | DEPP-6652              | Created file                 |
      | eccarius.munoz                 | May 29, 2024          | DEPP-8955              | added getQueryLocatorByIds   |
 */
@isTest
public with sharing class AddressesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB' });
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

    @isTest
    static void getQueryLocatorByIdsTest() {

        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            List<Contact> contact = TestDataFactory.createTestContactRecords(1);
            contact[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contact[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contact,true,AccessLevel.USER_MODE);
            
            List<hed__Address__c> addressList = new List<hed__Address__c>();
            hed__Address__c address = new hed__Address__c();
            address.hed__Address_Type__c = 'Other';
            address.hed__Parent_Contact__c = contact[0].Id;
            addressList.add(address);
            AddressesDAO.newInstance().insertRecords(addressList, true, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            Database.QueryLocator addressQueryLocator = AddressesDAO.newInstance().getQueryLocatorByIds(new Set<Id>{addressList[0].Id});
            String initialSoqlString = addressQueryLocator.getQuery();
            String soqlAddressIdReplaced = initialSoqlString.replace(': addressIdSet', ' (' + DynamicQueryService.formatStringSetForWhereClause(new Set<Id>{addressList[0].Id}) + ')');
            String finalSoqlString = soqlAddressIdReplaced.replace(': personRecordTypeId', DynamicQueryService.formatStringSetForWhereClause(new Set<Id>{ContactsDAO.PERSON_RECORDTYPE_ID}));
            List<hed__Address__c> retrievedAddressList = Database.query(finalSoqlString);
            Test.stopTest();

            System.assertEquals(1, retrievedAddressList.size(), 'Incorrect number of records retrieved.');
        }
    }
}
