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
    static void testValidateAddress() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<hed__Address__c> addressList = new List<hed__Address__c>();    
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            hed__Address__c addressWithContact = new hed__Address__c(
                hed__Parent_Contact__c = mockIdGen.getMockId(),  
                hed__Address_Type__c = 'Other'  
            );
            addressList.add(addressWithContact);
            
            hed__Address__c addressWithoutContact = new hed__Address__c(
                hed__Address_Type__c = 'Other'  
            );
            addressList.add(addressWithoutContact);
            
            Test.startTest();
            AddressTriggerHelper.validateAddress(addressList);
            Test.stopTest();
    
            List<EventBusSubscriber> eventBusSubscriberList = [SELECT Position, Status FROM EventBusSubscriber WHERE Topic = 'Address_Change_Event__e' AND Type = 'ApexTrigger'];
            for(EventBusSubscriber eventBusSubscriber : eventBusSubscriberList){
                System.Assert.isTrue(eventBusSubscriber.Position == 1 && eventBusSubscriber.Status == 'Running', 'There should be one published event.');
            }
        }
    }

    @isTest
    static void testProcessValidateAddress() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            List<hed__Address__c> addressList = new List<hed__Address__c>();
            addressList.add(
                new hed__Address__c(
                    hed__Parent_Contact__c = contactList[0].Id,
                    hed__Address_Type__c = 'Other', 
                    hed__MailingStreet__c = 'Test',
                    hed__MailingCity__c = 'Test',
                    hed__MailingPostalCode__c = '12345',
                    hed__MailingState__c = 'IL',
                    hed__MailingCountry__c = 'Australia'
                )
            );

            AddressesDAO.newInstance().updateRecords(addressList, false, AccessLevel.SYSTEM_MODE);
    
            Map<Id, hed__Address__c> oldItems = new Map<Id, hed__Address__c>();
            oldItems.put(addressList[0].Id, new hed__Address__c(
                hed__Parent_Contact__c = contactList[0].Id,
                hed__Address_Type__c = 'Other',
                hed__MailingStreet__c = 'Test 2',
                hed__MailingCity__c = 'Oakland',
                hed__MailingPostalCode__c = '54321',
                hed__MailingState__c = 'Test 2',
                hed__MailingCountry__c = 'Australia'
            ));
    
            Test.startTest();
            AddressTriggerHelper.processValidateAddress(addressList, oldItems);
            Test.stopTest();
    
            List<EventBusSubscriber> eventBusSubscriberList = [SELECT Position, Status FROM EventBusSubscriber WHERE Topic = 'Address_Change_Event__e' AND Type = 'ApexTrigger'];
            for(EventBusSubscriber eventBusSubscriber : eventBusSubscriberList){
                System.Assert.isTrue(eventBusSubscriber.Position == 1 && eventBusSubscriber.Status == 'Running', 'There should be one published event.');
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

}