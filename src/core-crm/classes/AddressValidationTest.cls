/**
 * @description Test class for AddressValidation
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 29, 2024          | DEPP-8954              | Created file                 |
 */
@isTest
private class AddressValidationTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_ESB'});
        Test.stopTest();
    }

    @isTest
    static void processValidAddressesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            String mockResponseBody = '{"statisticalArea1":"Test Area","meshBlockId":"12345","socioEconomicPercentile":80,"remotenessClass":"Urban","isValid":true}';
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Success', mockResponseBody));
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
            Map<Id, hed__address__c> contactAddressMap = processAddressValidation.validateAddresses();           
            Test.stopTest();

            System.Assert.areEqual(
                contactList.size(), 
                contactAddressMap.size(), 
			   'The contactAddressMap did not return the expected number of contact'
            );

            
            for(hed__Address__c address: contactAddressMap.values()){
                System.Assert.areEqual(AddressesDAO.VALID_ADDRESS, address.Validated__c , 'The address Validated field is not equal to "Valid"');
                System.Assert.areEqual('Test Area', address.Statistical_Area_1_Id__c , 'The address Statistical_Area_1_Id__c field is not the expected value');
                System.Assert.areEqual('12345', address.Meshblock_Id__c , 'The address Meshblock_Id__c field is not the expected value');                
                System.Assert.areEqual(80, address.Socio_Economic_Percentile__c , 'The address Socio_Economic_Percentile__c field is not the expected value');
				System.Assert.areEqual('Urban', address.Remoteness_Class__c , 'The address Remoteness_Class__c field is not the expected value');
            }


        }
    }
    
    @isTest
    static void processNotValidAddressesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            String mockResponseBody = '{"statisticalArea1":"Test Area","meshBlockId":"12345","socioEconomicPercentile":80,"remotenessClass":"Urban","isValid":false}';
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Success', mockResponseBody));
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
            Map<Id, hed__address__c> contactAddressMap = processAddressValidation.validateAddresses();           
            Test.stopTest();

            System.Assert.areEqual(
                contactList.size(), 
                contactAddressMap.size(), 
			   'The contactAddressMap did not return the expected number of contact'
            );
            
            for(hed__Address__c address: contactAddressMap.values()){
                System.Assert.areEqual(AddressesDAO.NOT_VALID_ADDRESS, address.Validated__c , 'The address Validated field is not equal to "Not Valid"');
                System.Assert.areEqual(null, address.Statistical_Area_1_Id__c , 'The address Statistical_Area_1_Id__c field is not null');
                System.Assert.areEqual(null, address.Meshblock_Id__c , 'The address Meshblock_Id__c field is not null');                
                System.Assert.areEqual(null, address.Socio_Economic_Percentile__c , 'The address Socio_Economic_Percentile__c field is not null');
				System.Assert.areEqual(null, address.Remoteness_Class__c , 'The address Remoteness_Class__c field is not null');
            }
        }
    }
    
    @isTest
    static void processThrowExceptionAddressesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            String mockResponseBody = '{"statisticalArea1":"Test Area","meshBlockId":"12345","socioEconomicPercentile":80,"remotenessClass":"Urban","isValid":false}';
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(201, 'Fail', mockResponseBody));
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
            Map<Id, hed__address__c> contactAddressMap = processAddressValidation.validateAddresses();           
            Test.stopTest();

            System.Assert.areEqual(
                contactList.size(), 
                contactAddressMap.size(), 
			   'The contactAddressMap did not return the expected number of contact'
            );
			
            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance().getLogEntriesByMessage(
                new Set<String>{'Exception caught in method loqateAddressValidation in Apex class AddressValidation.'},
                AccessLevel.USER_MODE
            );
            
            System.assert(!logEntries.isEmpty(),'there should be log entries');
            
            for(LogEntry__c logEntry: logEntries){
                System.assertEquals(
                    'Exception caught in method loqateAddressValidation in Apex class AddressValidation.',
                    logEntry.Message__c,
                    'Error message should be Exception caught in method loqateAddressValidation in Apex class AddressValidation'
                );                             
            }
                        
            for(hed__Address__c address: contactAddressMap.values()){
                System.Assert.areEqual(AddressesDAO.NOT_VALID_ADDRESS, address.Validated__c , 'The address Validated field is not equal to "Not Valid"');
                System.Assert.areEqual(null, address.Statistical_Area_1_Id__c , 'The address Statistical_Area_1_Id__c field is not null');
                System.Assert.areEqual(null, address.Meshblock_Id__c , 'The address Meshblock_Id__c field is not null');                
                System.Assert.areEqual(null, address.Socio_Economic_Percentile__c , 'The address Socio_Economic_Percentile__c field is not null');
				System.Assert.areEqual(null, address.Remoteness_Class__c , 'The address Remoteness_Class__c field is not null');
            }
        }
    }
}