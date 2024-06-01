/**
 * @description Test class for AddressValidation
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 31, 2024          | DEPP-8956              | Created file                 |
 */
@isTest
private class AddressValidationManagerTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_ESB'});
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<ABS_Categorisation__c> absCategorisation = new List<ABS_Categorisation__c>();
            absCategorisation.add(
                new ABS_Categorisation__c(
                    Name = 'Categorisation 1',
                    Is_Active__c = true,
                    Low_SES_Lower_Boundary__c = 0,
                    Low_SES_Upper_Boundary__c = 80,
                    Remoteness_Inner_Regional__c = true,
                    Remoteness_Outer_Regional__c = true,
                    Remoteness_Remote__c = true,
                    Remoteness_Very_Remote__c = true
                )
            );
            
            ABSCategorisationsDAO.newInstance().insertRecords(absCategorisation, false, AccessLevel.USER_MODE);
        }
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
            AddressValidationManager addressValidation = new AddressValidationManager(addresses);
            addressValidation.executeAddressValidation();           
            Test.stopTest();

            for(hed__Address__c address: AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Map<Id,Contact>(contactList).keySet(),new Set<String>{AddressesDAO.OTHER_ADDRESS},'USER_MODE')){
                System.Assert.areEqual(AddressesDAO.VALID_ADDRESS, address.Validated__c , 'The address Validated field is not equal to "Valid"');
                System.Assert.areEqual('Test Area', address.Statistical_Area_1_Id__c , 'The address Statistical_Area_1_Id__c field is not the expected value');
                System.Assert.areEqual('12345', address.Meshblock_Id__c , 'The address Meshblock_Id__c field is not the expected value');                
                System.Assert.areEqual(80, address.Socio_Economic_Percentile__c , 'The address Socio_Economic_Percentile__c field is not the expected value');
                System.Assert.areEqual('Urban', address.Remoteness_Class__c , 'The address Remoteness_Class__c field is not the expected value');
            }
        }
    }
    
    @isTest
    static void testValidAddressWithProgramEnrollmentWithoutExistingFirstAdmitted() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            String mockResponseBody = '{"statisticalArea1":"Test Area","meshBlockId":"12345","socioEconomicPercentile":80,"remotenessClass":"Urban","isValid":true}';
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Success', mockResponseBody));
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<hed__Program_Enrollment__c> programEnListWithContact = TestDataFactory.createTestProgramEnrollmentRecords(2); 
            for(hed__Program_Enrollment__c prog: programEnListWithContact){                           
                prog.hed__Contact__c = contactList[0].Id;
                prog.Enrollment_Status__c = 'Admitted';
            }
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnListWithContact, true, AccessLevel.SYSTEM_MODE);
            
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
            AddressValidationManager addressValidation = new AddressValidationManager(addresses);
            addressValidation.executeAddressValidation();           
            Test.stopTest();

            for(hed__Address__c address: AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Map<Id,Contact>(contactList).keySet(),new Set<String>{AddressesDAO.OTHER_ADDRESS},'USER_MODE')){
                System.Assert.areEqual(AddressesDAO.VALID_ADDRESS, address.Validated__c , 'The address Validated field is not equal to "Valid"');
                System.Assert.areEqual('Test Area', address.Statistical_Area_1_Id__c , 'The address Statistical_Area_1_Id__c field is not the expected value');
                System.Assert.areEqual('12345', address.Meshblock_Id__c , 'The address Meshblock_Id__c field is not the expected value');                
                System.Assert.areEqual(80, address.Socio_Economic_Percentile__c , 'The address Socio_Economic_Percentile__c field is not the expected value');
                System.Assert.areEqual('Urban', address.Remoteness_Class__c , 'The address Remoteness_Class__c field is not the expected value');
            }
            
            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance().getLogEntriesByRelatedRecordId(
                new Map<Id,Contact>(contactList).keySet(),
                AccessLevel.USER_MODE
            );
            
            System.assert(!logEntries.isEmpty(),'there should be log entries');
            
            for(LogEntry__c logEntry: logEntries){
                System.assertEquals(
                    'First Admitted Address not found for the following contact',
                    logEntry.Message__c,
                    'Error message should be First Admitted Address not found for the following contact'
                );                             
            }
        }
    }

    @isTest
    static void processNotValidAddressWithExistingFirstAdmittedAddress() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            String mockResponseBody = '{"statisticalArea1":"Test Area","meshBlockId":"12345","socioEconomicPercentile":80,"remotenessClass":"Urban","isValid":true}';
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Success', mockResponseBody));
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<hed__Program_Enrollment__c> programEnListWithContact = TestDataFactory.createTestProgramEnrollmentRecords(2); 
            for(hed__Program_Enrollment__c prog: programEnListWithContact){                           
                prog.hed__Contact__c = contactList[0].Id;
                prog.Enrollment_Status__c = 'Passed';
            }
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnListWithContact, true, AccessLevel.SYSTEM_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            List<hed__Address__c> otherAddresses = new List<hed__Address__c>();
            
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
                otherAddresses.add(add);
            }
            addresses.addAll(otherAddresses);
            
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
            
            Test.startTest();
            AddressValidationManager addressValidation = new AddressValidationManager(otherAddresses);
            addressValidation.executeAddressValidation();           
            Test.stopTest();

            for(hed__Address__c address: AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Map<Id,Contact>(contactList).keySet(),new Set<String>{AddressesDAO.OTHER_ADDRESS},'USER_MODE')){
                System.Assert.areEqual(AddressesDAO.VALID_ADDRESS, address.Validated__c , 'The address Validated field is not equal to "Valid"');
                System.Assert.areEqual('Test Area', address.Statistical_Area_1_Id__c , 'The address Statistical_Area_1_Id__c field is not the expected value');
                System.Assert.areEqual('12345', address.Meshblock_Id__c , 'The address Meshblock_Id__c field is not the expected value');                
                System.Assert.areEqual(80, address.Socio_Economic_Percentile__c , 'The address Socio_Economic_Percentile__c field is not the expected value');
                System.Assert.areEqual('Urban', address.Remoteness_Class__c , 'The address Remoteness_Class__c field is not the expected value');
            }
        }
    }
}