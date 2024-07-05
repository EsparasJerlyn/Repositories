/**
 * @description Test class for AddressTriggerHelper
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 31, 2024          | DEPP-8955              | Created file                 |
 */
@isTest
public with sharing class AddressTriggerHelperTest {
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<ABS_Categorisation__c> absCategorisationList = new List<ABS_Categorisation__c>();
            absCategorisationList.add(
                new ABS_Categorisation__c(
                    Name = 'Categorisation 1',
                    Is_Active__c = true,
                    Low_SES_Lower_Boundary__c = 70,
                    Low_SES_Upper_Boundary__c = 100,
                    Remoteness_Inner_Regional__c = true,
                    Remoteness_Outer_Regional__c = true,
                    Remoteness_Remote__c = true,
                    Remoteness_Very_Remote__c = true
                )
            );
            ABSCategorisationsDAO.newInstance().insertRecords(absCategorisationList, true, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    static void testAddressValidation() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance().getLatestUpdatedActiveCategorisationRecord('SYSTEM_MODE');
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.Socio_Economic_Percentile__c = 80;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                addresses.add(add);
            }

            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            String batchName = 'AddressesValidationBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.areEqual(batchName, job.ApexClass.Name, 'AddressesValidationBatch should be executed.');

            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            List<Contact> contactsUpdated = ContactsDAO.newInstance().getPersonContactsBySetIds(contactMap.keySet(), AccessLevel.SYSTEM_MODE);            
            for(Contact contact: contactsUpdated){
                System.Assert.areEqual(ContactsDAO.LOW_SOCIO_ECONOMIC_STATUS_YES, contact.Low_Socio_Economic_Status__c , 'Incorrect value for Low_Socio_Economic_Status__c.');
            }

            List<hed__Address__c> addressesUpdated = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactMap.keySet(), new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'SYSTEM_MODE');
            for(hed__Address__c address: addressesUpdated){
                System.Assert.areEqual(absCategorisationList[0].Id, address.ABS_Categorisation__c , 'Incorrect value for ABS_Categorisation__c.');
                System.Assert.areEqual(AddressesDAO.INTEGRATION_STATUS_SENT, address.Address_Integration_Status__c , 'Incorrect value for Address_Integration_Status__c.');
            }

        }
    }

    @isTest
    static void testNotForValidationAddress() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = 'Mailing';
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                addresses.add(add);
            }
            
            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            String batchName = 'AddressesValidationBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.isTrue(job == null, 'AddressesValidationBatch should not be executed.');

            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            List<Contact> contactsUpdated = ContactsDAO.newInstance().getPersonContactsBySetIds(contactMap.keySet(), AccessLevel.SYSTEM_MODE);            
            for(Contact contact: contactsUpdated){
                System.Assert.areEqual(ContactsDAO.LOW_SOCIO_ECONOMIC_STATUS_UNKNOWN, contact.Low_Socio_Economic_Status__c, 'Low_Socio_Economic_Status__c should be unknown.');
            }

            List<hed__Address__c> addressesUpdated = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactMap.keySet(), new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'SYSTEM_MODE');
            for(hed__Address__c address: addressesUpdated){
                System.Assert.isNull(address.ABS_Categorisation__c , 'ABS_Categorisation__c should not be set.');
            }

        }
    }

    @isTest
    static void testUpdateOtherAddressValidation() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance().getLatestUpdatedActiveCategorisationRecord('SYSTEM_MODE');
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;                
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.Is_First_Admission_Address__c = true;            
                addresses.add(add);
            }
            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.SYSTEM_MODE);
            Test.startTest();
            
            List<hed__Address__c> addressesToUpdate = new List<hed__Address__c>();
            for(hed__Address__c add : addresses){
                hed__Address__c adddress = new hed__Address__c();
                adddress.Id = add.Id;
                adddress.Validated__c = AddressesDAO.VALID_ADDRESS;
                adddress.Socio_Economic_Percentile__c = 80;
                adddress.Remoteness_Class__c = AddressesDAO.REMOTE;
                adddress.Address_Integration_Status__c = AddressesDAO.INTEGRATION_STATUS_SUCCESS;
                addressesToUpdate.add(adddress);
            }
            AddressesDAO.newInstance().updateRecords(addressesToUpdate, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            String batchName = 'AddressesValidationBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.areEqual(batchName, job.ApexClass.Name, 'AddressesValidationBatch should be executed.');

            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            List<Contact> contactsUpdated = ContactsDAO.newInstance().getPersonContactsBySetIds(contactMap.keySet(), AccessLevel.SYSTEM_MODE);            
            for(Contact contact: contactsUpdated){
                System.Assert.areEqual(ContactsDAO.LOW_SOCIO_ECONOMIC_STATUS_YES, contact.Low_Socio_Economic_Status__c , 'Incorrect value for Low_Socio_Economic_Status__c.');
                System.Assert.areEqual(ContactsDAO.REGIONAL_REMOTE_YES, contact.Regional_Remote__c , 'Incorrect value for Regional_Remote__c.');
            }

            List<hed__Address__c> otherAddressesUpdated = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactMap.keySet(), new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'SYSTEM_MODE');
            for(hed__Address__c address: otherAddressesUpdated){
                System.Assert.areEqual(absCategorisationList[0].Id, address.ABS_Categorisation__c , 'Incorrect value for ABS_Categorisation__c.');
            }

            List<hed__Address__c> firstAdmittedAddressList = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactMap.keySet(), new Set<String>{AddressesDAO.FIRST_ADMITTED_ADDRESS}, 'SYSTEM_MODE');
            for(hed__Address__c address: firstAdmittedAddressList){
                System.Assert.areEqual(absCategorisationList[0].Id, address.ABS_Categorisation__c , 'Incorrect value for ABS_Categorisation__c.');
                System.Assert.isFalse(address.Is_First_Admission_Address__c , 'Incorrect value for Is_First_Admission_Address__c.');
            }
        }
    }

    @isTest
    static void testUpdateFirstAdmittedAddressValidation() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;                
                add.hed__Address_Type__c = AddressesDAO.FIRST_ADMITTED_ADDRESS;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.Is_First_Admission_Address__c = true;            
                addresses.add(add);
            }
            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.SYSTEM_MODE);
            Test.startTest();
            
            List<hed__Address__c> addressesToUpdate = new List<hed__Address__c>();
            for(hed__Address__c add : addresses){
                hed__Address__c adddress = new hed__Address__c();
                adddress.Id = add.Id;
                adddress.Validated__c = AddressesDAO.VALID_ADDRESS;
                adddress.Socio_Economic_Percentile__c = 80;
                adddress.Remoteness_Class__c = AddressesDAO.REMOTE;
                adddress.Address_Integration_Status__c = AddressesDAO.INTEGRATION_STATUS_SUCCESS;
                addressesToUpdate.add(adddress);
            }
            AddressesDAO.newInstance().updateRecords(addressesToUpdate, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            String batchName = 'AddressesValidationBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.areEqual(batchName, job.ApexClass.Name, 'AddressesValidationBatch should be executed.');

            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            List<Contact> contactsUpdated = ContactsDAO.newInstance().getPersonContactsBySetIds(contactMap.keySet(), AccessLevel.SYSTEM_MODE);            
            for(Contact contact: contactsUpdated){
                System.Assert.areEqual(ContactsDAO.REGIONAL_REMOTE_YES, contact.Regional_Remote__c , 'Incorrect value for Regional_Remote__c.');
            }
        }
    }

    @isTest
    static void testUpdateAddressMailingField() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;                
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.Is_First_Admission_Address__c = true;            
                add.Socio_Economic_Percentile__c = 80;
                add.Remoteness_Class__c = AddressesDAO.REMOTE;
                addresses.add(add);
            }
            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.SYSTEM_MODE);
            Test.startTest();
            
            List<hed__Address__c> addressesToUpdate = new List<hed__Address__c>();
            for(hed__Address__c add : addresses){
                hed__Address__c adddress = new hed__Address__c();
                adddress.Id = add.Id;
                adddress.hed__MailingStreet__c = 'Test';
                addressesToUpdate.add(adddress);
            }
            AddressesDAO.newInstance().updateRecords(addressesToUpdate, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            String batchName = 'AddressesValidationBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.areEqual(batchName, job.ApexClass.Name, 'AddressesValidationBatch should be executed.');

            List<hed__Address__c> otherAddressesUpdated = AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Map<Id, Contact>(contactList).keySet(), new Set<String>{AddressesDAO.OTHER_ADDRESS}, 'SYSTEM_MODE');
            for(hed__Address__c address: otherAddressesUpdated){
                System.Assert.isNull(address.Socio_Economic_Percentile__c , 'Socio_Economic_Percentile__c must be null.');
                System.Assert.isNull(address.Remoteness_Class__c , 'Remoteness_Class__c must be null.');
            }

        }
    }

}