/**
 * @description Test class for AddressValidation
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 29, 2024          | DEPP-8954              | Created file                 |
      | eccarius.munoz                 | June 11, 2024         | DEPP-8954              | Used DAOMock and added method|
      |                                |                       |                        | for failed integ status.     |
 */
@isTest
private class AddressValidationTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void processValidAddressesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new AddressesDAOMock());

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
            AddressValidation processAddressValidation = new AddressValidation(addresses);
            Map<Id, hed__address__c> addressMap = processAddressValidation.validateAddresses();           
            Test.stopTest();

            System.Assert.areEqual(
                contactList.size(), 
                addressMap.size(), 
			   'The addressMap did not return the expected number of contact'
            );

            
            for(hed__Address__c address: addressMap.values()){
                System.Assert.areEqual(AddressesDAO.INTEGRATION_STATUS_SENT, address.Address_Integration_Status__c , 'The address Address_Integration_Status__c field is not equal to "Sent"');
            }
        }
    }
    
    @isTest
    static void processNotValidAddressesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new AddressesDAOMock());

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            
            //US Address
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.hed__MailingCountry__c = 'US';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                addresses.add(add);
            }
            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            AddressValidation processAddressValidation = new AddressValidation(addresses);
            Map<Id, hed__address__c> addressMap = processAddressValidation.validateAddresses();           
            Test.stopTest();
            
            //Integration Status should not be updated, since Address is Non AU
            for(hed__Address__c address: addressMap.values()){
                System.Assert.areEqual(null, address.Address_Integration_Status__c , 'The address Address_Integration_Status__c field is not equal to "NULL"');
            }
        }
    }
    
    @isTest
    static void processThrowExceptionAddressesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new AddressesDAOMock());

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(201, 'Fail', ''));

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
            AddressValidation processAddressValidation = new AddressValidation(addresses);
            Map<Id, hed__address__c> addressMap = processAddressValidation.validateAddresses();           
            Test.stopTest();

            System.Assert.areEqual(
                contactList.size(), 
                addressMap.size(), 
			   'The addressMap did not return the expected number of contact'
            );
			
            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance().getLogEntriesByMessage(
                new Set<String>{'Callout Exception caught in method addressValidationRequest in Apex class AddressValidation.'},
                AccessLevel.USER_MODE
            );
            
            System.assert(!logEntries.isEmpty(), 'There should be log entries');
            
            for(LogEntry__c logEntry: logEntries){
                System.assertEquals(
                    'Callout Exception caught in method addressValidationRequest in Apex class AddressValidation.',
                    logEntry.Message__c,
                    'Error message should be Callout Exception caught in method addressValidationRequest in Apex class AddressValidation.'
                );                             
            }
                        
            for(hed__Address__c address: addressMap.values()){
                System.Assert.areEqual(AddressesDAO.INTEGRATION_STATUS_RETRY, address.Address_Integration_Status__c , 'The address Address_Integration_Status__c field is not equal to "Retry"');
            }
        }
    }

    @isTest
    static void processFailedAddressesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new AddressesDAOMock());

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(201, 'Fail', ''));

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
            AddressValidation processAddressValidation = new AddressValidation(addresses);
            Map<Id, hed__address__c> addressMap = processAddressValidation.validateAddresses();           
            Test.stopTest();
                        
            for(hed__Address__c address: addressMap.values()){
                System.Assert.areEqual(AddressesDAO.INTEGRATION_STATUS_FAILED, address.Address_Integration_Status__c , 'The address Address_Integration_Status__c field is not equal to "Retry"');
            }
        }
    }
}