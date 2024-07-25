/**
 * @description Test Class for OtherAddressChangeEventHandler
 * @see OtherAddressChangeEventHandler
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | July 18, 2024         | DEPP-9942              | Created file                 |
 */
@isTest
public with sharing class OtherAddressChangeEventHandlerTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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
            AddressesDAO.newInstance().insertRecords(addresses, true, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    static void testHandle() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Id addressId = [SELECT Id FROM hed__Address__c LIMIT 1].Id;
            List<Address_Change_Event__e> eventList = new List<Address_Change_Event__e>();
            Address_Change_Event__e insertEvent = new Address_Change_Event__e(
                Address_Id__c = addressId,  
                Address_Type__c = 'Other',
                Change_Type__c = 'Insert'
            );
            eventList.add(insertEvent);
    
            Test.startTest();
            OtherAddressChangeEventHandler eventHandler = new OtherAddressChangeEventHandler(eventList);
            eventHandler.handle();
            Test.stopTest();
    
            String batchName = 'AddressesValidationBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.areEqual(batchName, job.ApexClass.Name, 'AddressesValidationBatch should be executed.');
        }
        
    }

    @isTest
    static void testHandleForUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Id addressId = [SELECT Id FROM hed__Address__c LIMIT 1].Id;
            List<Address_Change_Event__e> eventList = new List<Address_Change_Event__e>();
            Address_Change_Event__e updateEvent = new Address_Change_Event__e(
                Address_Id__c = addressId,  
                Address_Type__c = 'Other',
                Change_Type__c = 'Update'
            );
            eventList.add(updateEvent);
    
            Test.startTest();
            OtherAddressChangeEventHandler eventHandler = new OtherAddressChangeEventHandler(eventList);
            eventHandler.handle();
            Test.stopTest();
    
            String batchName = 'AddressesValidationBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.areEqual(batchName, job.ApexClass.Name, 'AddressesValidationBatch should be executed.');
        } 
    }

}