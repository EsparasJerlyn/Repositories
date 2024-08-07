/**
 * @description Test class for RetryAddressValidationBatch
 * @see RetryAddressValidationBatch
 * 
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | June 10, 2024         | DEPP-9226              | Created file                 |
 */
@isTest
public with sharing class RetryAddressValidationBatchTest {
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void processRetryToFailAddressesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
            insert bypass;

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(500, 'Internal Server Error', ''));

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
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.Socio_Economic_Percentile__c = 80;
                add.Address_Integration_Status__c = AddressesDAO.INTEGRATION_STATUS_RETRY;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                addresses.add(add);
            }

            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            RetryAddressValidationBatch batchable = new RetryAddressValidationBatch();
            Database.executeBatch(batchable);    
            Test.stopTest();

            List<hed__Address__c> addressList = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Set<Id>{contactList[0].Id}, new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'USER_MODE');
            System.Assert.areEqual(AddressesDAO.INTEGRATION_STATUS_FAILED, addressList[0].Address_Integration_Status__c , 'Incorrect value for Address_Integration_Status__c.');
        }
    }

    @isTest
    static void processRetryToSentAddressesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
            insert bypass;

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

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
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.Socio_Economic_Percentile__c = 80;
                add.Address_Integration_Status__c = AddressesDAO.INTEGRATION_STATUS_RETRY;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                addresses.add(add);
            }

            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            RetryAddressValidationBatch batchable = new RetryAddressValidationBatch();
            Database.executeBatch(batchable);    
            Test.stopTest();

            List<hed__Address__c> addressList = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Set<Id>{contactList[0].Id}, new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'USER_MODE');
            System.Assert.areEqual(AddressesDAO.INTEGRATION_STATUS_SENT, addressList[0].Address_Integration_Status__c , 'Incorrect value for Address_Integration_Status__c.');
        }
    }

}