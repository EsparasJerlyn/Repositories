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
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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
    }
       
    @isTest
    static void executeAddressValidationFirstAdmittedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.Low_Socio_Economic_Status__c = 'Unknown';
                con.Regional_Remote__c = 'Unknown';
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
            AddressValidationManager addressValidation = new AddressValidationManager(addresses);
            addressValidation.executeAddressValidation();           
            Test.stopTest();

            for(hed__Address__c address: AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Map<Id,Contact>(contactList).keySet(),new Set<String>{AddressesDAO.FIRST_ADMITTED_ADDRESS},'USER_MODE')){
                System.assertEquals(AddressesDAO.INTEGRATION_STATUS_SENT, address.Address_Integration_Status__c, 'Address Integration Status must be Sent');
            }
        }
    }

    @isTest
    static void executeAddressValidationNotFirstAdmittedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(201, 'Fail', ''));
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.Low_Socio_Economic_Status__c = 'Unknown';
                con.Regional_Remote__c = 'Unknown';
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
    static void executeAddressValidationOtherAddressTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.Low_Socio_Economic_Status__c = 'Unknown';
                con.Regional_Remote__c = 'Unknown';
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<hed__Program_Enrollment__c> programEnListWithContact = TestDataFactory.createTestProgramEnrollmentRecords(1); 
            programEnListWithContact[0].hed__Contact__c = contactList[0].Id;
            programEnListWithContact[0].Enrollment_Status__c = 'Admitted';
            

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
                System.Assert.areEqual(true, address.Is_First_Admission_Address__c , 'First Admission must set be true');                
            }
        }
    }

    @isTest
    static void executeAddressValidationOtherAddressCloneTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.Low_Socio_Economic_Status__c = 'Unknown';
                con.Regional_Remote__c = 'Unknown';
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<hed__Program_Enrollment__c> programEnListWithContact = TestDataFactory.createTestProgramEnrollmentRecords(1); 
            programEnListWithContact[0].hed__Contact__c = contactList[0].Id;
            programEnListWithContact[0].Enrollment_Status__c = 'Admitted';
            

            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnListWithContact, true, AccessLevel.SYSTEM_MODE);
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.hed__MailingCountry__c = 'Philippines';
                add.hed__MailingState__c = 'PH';
                add.hed__MailingCity__c = 'MNL';
                add.hed__MailingPostalCode__c = '06125';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                addresses.add(add);
            }
			AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.USER_MODE);
            Test.startTest();
            AddressValidationManager addressValidation = new AddressValidationManager(addresses);
            addressValidation.executeAddressValidation();           
            Test.stopTest();
            
            for(hed__Address__c address: AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Map<Id,Contact>(contactList).keySet(),new Set<String>{AddressesDAO.FIRST_ADMITTED_ADDRESS},'USER_MODE')){
                System.assertEquals(false, address.Is_First_Admission_Address__c , 'Cloned Address First Admission must set be false');
                System.assertEquals('Philippines', address.hed__MailingCountry__c , 'Cloned Address Mailing Country should be the same as the test data setup');                
                System.assertEquals(AddressesDAO.FIRST_ADMITTED_ADDRESS, address.hed__Address_Type__c , 'Cloned Address Type should be set as First Admitted');                
                System.assertEquals('PH', address.hed__MailingState__c , 'Cloned Address Mailing State should be the same as the test data setup');                
                System.assertEquals('06125', address.hed__MailingPostalCode__c , 'Cloned Address Mailing Postal Code should be the same as the test data setup');                
                System.assertEquals(contactList[0].Id, address.hed__Parent_Contact__c , 'Cloned Address Parent Contact should be the same as the test data setup');                
    
            }
        }
    }

    @isTest
    static void processValidateAddressOthersTest() {
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
                adddress.Socio_Economic_Percentile__c = 100;
                adddress.Remoteness_Class__c = AddressesDAO.REMOTE;
                adddress.Address_Integration_Status__c = AddressesDAO.INTEGRATION_STATUS_SUCCESS;
                addressesToUpdate.add(adddress);
            }
            AddressesDAO.newInstance().updateRecords(addressesToUpdate, false, AccessLevel.SYSTEM_MODE);


            AddressValidationManager addressValidation = new AddressValidationManager(addresses);
            addressValidation.processValidateAddress();       
            Test.stopTest();


            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            List<Contact> contactsUpdated = ContactsDAO.newInstance().getPersonContactsBySetIds(contactMap.keySet(), AccessLevel.SYSTEM_MODE);            
            for(Contact contact: contactsUpdated){
                System.Assert.areEqual(ContactsDAO.LOW_SOCIO_ECONOMIC_STATUS_NO, contact.Low_Socio_Economic_Status__c , 'Incorrect value for Low_Socio_Economic_Status__c.');
                System.Assert.areEqual(ContactsDAO.REGIONAL_REMOTE_NO, contact.Regional_Remote__c , 'Incorrect value for Regional_Remote__c.');
            }
        }
    }
    @isTest
    static void processValidateAddressOthersTestNotQUTStudent() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance().getLatestUpdatedActiveCategorisationRecord('SYSTEM_MODE');
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = false;
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
            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            Test.startTest();
        
            AddressValidationManager addressValidation = new AddressValidationManager(addresses , contactMap, false);
            addressValidation.processValidateAddress();       
            Test.stopTest();


            for(hed__address__c address : AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactMap.keySet(),new Set<String>{AddressesDAO.OTHER_ADDRESS},'USER_MODE')){
                System.Assert.areEqual(null, address.Address_Integration_Status__c , 'Integration Status should not be populated during insert');
            }
        }
    }
}
