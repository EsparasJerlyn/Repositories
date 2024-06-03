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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator','QUT_ESB' });
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
            System.assert(addressList.isEmpty(), 'addressList is not empty');
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
            System.assert(addressList.isEmpty(), 'addressList is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testEmptyContactIdAndType() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            List<hed__Address__c> addressList = AddressesDAO.newInstance()
                .getAddressesByContactIdsAndAddressType(
                    new Set<Id>(),
                    new Set<String>(),
                    'USER_MODE'
                );
            System.assert(addressList.isEmpty(), 'addressList is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testEmptyAddressesByContactIdsAndAddressType() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            List<hed__Address__c> addressList = AddressesDAO.newInstance()
                .getAddressesByContactIdsAndAddressType(
                    new Set<Id>{ mockIdGen.getMockId() },
                    new Set<String>(),
                    'USER_MODE'
                );
            System.assert(addressList.isEmpty(), 'addressList is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAddressesByContactIdsAndAddressType() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = AddressesDAO.FIRST_ADMITTED_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                addresses.add(add);
            }
            
            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.USER_MODE);
            
            List<hed__Address__c> addressList = AddressesDAO.newInstance()
                .getAddressesByContactIdsAndAddressType(
                    new Map<Id,Contact>(contactList).keySet(),
                    new Set<String>{AddressesDAO.FIRST_ADMITTED_ADDRESS},
                    'USER_MODE'
                );
            
            System.Assert.areEqual(
                contactList.size(), 
                addressList.size(), 
			   'The addressList did not return the expected number of contact per address'
            );

            
            for(hed__Address__c address: addressList){
                System.Assert.areEqual(AddressesDAO.FIRST_ADMITTED_ADDRESS, address.hed__Address_Type__c , 'The address type is not equal to "First Admitted Adress"');
            }
        }
        Test.stopTest();
    }
}