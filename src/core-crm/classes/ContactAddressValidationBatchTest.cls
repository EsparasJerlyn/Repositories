/**
 * @description Test class for ContactAddressValidationBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 31, 2024          | DEPP-8956              | Created file                 |
 */
@isTest
private class ContactAddressValidationBatchTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_ESB','QUT_Program_Administrator'});
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
    static void processEmptyAddressesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
			            
            Test.startTest();
            ContactAddressValidationBatch batch = new ContactAddressValidationBatch(new Set<Id>{});
            Id batchableId = Database.executeBatch(batch);
            Test.stopTest();
            
            System.Assert.isTrue(
                batchableId != null,
                'The batch job failed to execute.'
            );
        }
    }

    
    @isTest
    static void processNotValidatedAddressesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            Set<Id> addressIdSet = new Set<Id>();
            
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[0].Id;
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                addresses.add(add);
                addressIdSet.add(add.Id);
            }

            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            ContactAddressValidationBatch batch = new ContactAddressValidationBatch(addressIdSet);
            Id batchableId = Database.executeBatch(batch);
            Test.stopTest();
            
            System.Assert.isTrue(
                batchableId != null,
                'The batch job failed to execute.'
            );

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance().getLogEntriesByRelatedRecordId(
                new Map<Id,Contact>(contactList).keySet(),
                AccessLevel.USER_MODE
            );

            System.assert(logEntries.isEmpty(),'error log entries should be empty');
        }
    }
    
    @isTest
    static void processContactWithFirstAdmittedAddressesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            Set<Id> addressIdSet = new Set<Id>();
            
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = AddressesDAO.FIRST_ADMITTED_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                addresses.add(add);
                addressIdSet.add(add.Id);
            }

            AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            ContactAddressValidationBatch batch = new ContactAddressValidationBatch(addressIdSet);
            Id batchableId = Database.executeBatch(batch);
            Test.stopTest();
            
            System.Assert.isTrue(
                batchableId != null,
                'The batch job failed to execute.'
            );

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance().getLogEntriesByRelatedRecordId(
                new Map<Id,Contact>(contactList).keySet(),
                AccessLevel.USER_MODE
            );

            System.assert(logEntries.isEmpty(),'error log entries should be empty');
        }
    }
}