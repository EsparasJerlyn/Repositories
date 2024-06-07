/**
 * @description Test class for AddressesValidationBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 31, 2024          | DEPP-8955              | Created file                 |
 */
@isTest
public with sharing class AddressesValidationBatchTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_ESB'});
        Test.stopTest();
    }

    @isTest
    static void testAddressesValidationBatch() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            ImplementationSelector.DAO.setMock(new ABSCategorisationsDAOMock());
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new AddressesDAOMock());

            String mockResponseBody = '{"statisticalArea1":"Test Area","meshBlockId":"12345","socioEconomicPercentile":80,"remotenessClass":"Urban","isValid":true}';
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Success', mockResponseBody));
            
            List<ABS_Categorisation__c> absCategorisationList = new List<ABS_Categorisation__c>();
            absCategorisationList.add(new ABS_Categorisation__c(
                Low_SES_Lower_Boundary__c = 70,
                Low_SES_Upper_Boundary__c = 100,
                Is_Active__c = true
            ));
            ABSCategorisationsDAO.newInstance().insertRecords(absCategorisationList, true, AccessLevel.USER_MODE);

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
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

            Test.startTest();
            AddressesValidationBatch batch = new AddressesValidationBatch(addresses, new Map<Id,Contact>(contactList));
            Database.executeBatch(batch);
            Test.stopTest();

            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            List<Contact> contactsUpdated = ContactsDAO.newInstance().getPersonContactsBySetIds(contactMap.keySet(), AccessLevel.SYSTEM_MODE);            
            for(Contact contact: contactsUpdated){
                System.Assert.areEqual(ContactsDAO.LOW_SOCIO_ECONOMIC_STATUS_YES, contact.Low_Socio_Economic_Status__c , 'Incorrect value for Low_Socio_Economic_Status__c.');
            }

            List<hed__Address__c> addressesUpdated = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactMap.keySet(), new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'USER_MODE');
            for(hed__Address__c address: addressesUpdated){
                System.Assert.areEqual(absCategorisationList[0].Id, address.ABS_Categorisation__c , 'Incorrect value for ABS_Categorisation__c.');
            }

        }
    }
    
    @isTest
    static void testAddressesValidationBatchLowSocioEcoStatusNo() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            ImplementationSelector.DAO.setMock(new ABSCategorisationsDAOMock());
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new AddressesDAOMock());

            String mockResponseBody = '{"statisticalArea1":"Test Area","meshBlockId":"12345","socioEconomicPercentile":80,"remotenessClass":"Urban","isValid":true}';
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Success', mockResponseBody));
            
            List<ABS_Categorisation__c> absCategorisationList = new List<ABS_Categorisation__c>();
            absCategorisationList.add(new ABS_Categorisation__c(
                Low_SES_Lower_Boundary__c = 90,
                Low_SES_Upper_Boundary__c = 100,
                Is_Active__c = true
            ));
            ABSCategorisationsDAO.newInstance().insertRecords(absCategorisationList, true, AccessLevel.USER_MODE);

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
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
            
            Test.startTest();
            AddressesValidationBatch batch = new AddressesValidationBatch(addresses, new Map<Id,Contact>(contactList));
            Database.executeBatch(batch);
            Test.stopTest();

            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            List<Contact> contactsUpdated = ContactsDAO.newInstance().getPersonContactsBySetIds(contactMap.keySet(), AccessLevel.SYSTEM_MODE);            
            for(Contact contact: contactsUpdated){
                System.Assert.areEqual(ContactsDAO.LOW_SOCIO_ECONOMIC_STATUS_NO, contact.Low_Socio_Economic_Status__c , 'Incorrect value for Low_Socio_Economic_Status__c.');
            }

            List<hed__Address__c> addressesUpdated = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactMap.keySet(), new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'USER_MODE');
            for(hed__Address__c address: addressesUpdated){
                System.Assert.areEqual(absCategorisationList[0].Id, address.ABS_Categorisation__c , 'Incorrect value for ABS_Categorisation__c.');
            }

        }
    }
}