/**
 * @description Test Class for CaseTriggerHelper
 *
 * @see CaseTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | mark.j.mahilum                 | Sept 12, 2023         | DEPP-6421              | Created file                                          |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added test method for updating case using WhatsApp    |
      | johanna.a.gibas                | Nov 24, 2023          | DEPP-7143              | Removed references to Priority on International Tier  |
      | eccarius.munoz                 | February 16, 2024     | DEPP-7714	            | Added test method of case prio with sub category      | 
      | eccarius.munoz                 | February 19, 2024     | DEPP-7867	            | Added test method of case prio with lead src category | 
 */
@isTest
private class CaseTriggerHelperTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB'});
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()){
            List<International_Tier__c> tierList = TestDataFactory.createInternationalTierRecords(new List<String>{'Wales','Australia'}, 'Tier 1',true);
            International_Tier__c internationalTiersWithSubCateg = TestDataFactory.createInternationalTierRecords(new List<String>{ 'Yemen' }, 'Untiered',  true)[0];
            internationalTiersWithSubCateg.Tier_Subcategory__c = 'Restricted';
            tierList.add(internationalTiersWithSubCateg);
            
            InternationalTiersDAO.newInstance().insertRecords(tierList,false,AccessLevel.USER_MODE);
            List<Case_Priority_Configuration__c> casePrioConfig = TestDataFactory.createCasePrioConfigRecords();
            CasePriorityConfigurationsDAO.newInstance().insertRecords(casePrioConfig,false,AccessLevel.USER_MODE);
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void testCaseEmailMatchToContactEmail() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Email = '1testmail@mail.test';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Subject = 'Test Case',
                    SuppliedEmail = '1testmail@mail.test',
                    Description = 'Test Case Description',
                    Origin = 'Email'
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = [SELECT Id, ContactId FROM Case WHERE SuppliedEmail= '1testmail@mail.test' WITH USER_MODE LIMIT 1];
            System.assert(caseRecordList[0].ContactId !=null, 'case is not link to existing contact.');
        }
    }
    
    @isTest
    private static void testCaseEmailMatchToLeadEmail() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(0,1);
            leadList[0].Email = '1testmail@mail.test';
            LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Subject = 'Test Case',
                    SuppliedEmail = '1testmail@mail.test',
                    Description = 'Test Case Description',
                    Origin = 'Email'
                )
            );
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = [SELECT Id, ContactId,Lead__c FROM Case WHERE SuppliedEmail= '1testmail@mail.test' WITH USER_MODE LIMIT 1];
            System.assert(caseRecordList[0].Lead__c !=null, 'case is not link to existing lead.');
        }
    }
    
    @isTest
    private static void testCaseEmailNoMatchToExistingContactEmail() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Email = '1testmail@mail.test';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Subject = 'Test Case',
                    SuppliedEmail = '133testmail@mail.test',
                    Description = 'Test Case Description',
                    Origin = 'Email'
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = [SELECT Id, ContactId FROM Case WHERE SuppliedEmail= '133testmail@mail.test' WITH USER_MODE LIMIT 1];
            System.assert(caseRecordList[0].ContactId == null, 'case contactId is not null.');
        }
    }

    @isTest
    private static void testCaseRecordByContactMobileMatching() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].MobilePhone = '090909';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    SuppliedPhone = '090909',
                    Origin = CasesDAO.ORIGIN_WHATSAPP
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = CasesDAO.newInstance().getCasesBySuppliedPhone(new Set<String>{cases[0].SuppliedPhone}, AccessLevel.USER_MODE);
            System.assert(caseRecordList[0].ContactId != null, 'case contactId is not null.');
        }
    }

    @isTest
    private static void testCaseRecordByLeadMobileMatching() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(0,1);
            leadList[0].MobilePhone = '090909';
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    SuppliedPhone = '090909',
                    Origin = CasesDAO.ORIGIN_WHATSAPP
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = CasesDAO.newInstance().getCasesBySuppliedPhone(new Set<String>{cases[0].SuppliedPhone}, AccessLevel.USER_MODE);
            System.assert(caseRecordList[0].Lead__c !=null, 'case is not link to existing lead.');
        }
    }

    @isTest
    private static void testHandleAutoPriorityAssignedCase(){
        
        System.runAs(TestDataFactory.getESBIntegrationUser()){
            
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Auto_Priority_Assignment__c = true,
                    SuppliedPhone = '090909',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    RecordTypeId = CasesDAO.INTERNATIONALFS_RECTYPE_ID
                )
            );

            Test.startTest();
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            System.assert(cases[0].Id != null, 'case insert was not successful');
            Test.stopTest();
        }

        
    }

    @isTest
    private static void testHandleAutoPriorityAssignedCaseWithSubCateg(){
        
        System.runAs(TestDataFactory.getESBIntegrationUser()){

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Citizenship_Country__c = 'Yemen';
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);
            
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(
                    Status = 'Created',
                    Auto_Priority_Assignment__c = true,
                    Category__c = 'Student life',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    Priority = 'Low',
                    ContactId = contactList[0].Id,
                    RecordTypeId = CasesDAO.INTERNATIONALFS_RECTYPE_ID
                )
            );

            Test.startTest();
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            List<Case> caseList = CasesDAO.newInstance().getCasesByIds(new Set<Id>{cases[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals('High', caseList[0].Priority, 'Case priority should be set to high.');
        }
    }

    @isTest
    private static void testHandleAutoPriorityAssignedCaseWithLeadSourceCategory(){
        
        System.runAs(TestDataFactory.getESBIntegrationUser()){

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].Lead_Source_Category__c = 'Partner Sourced';
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);
            
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(
                    Status = 'Created',
                    Auto_Priority_Assignment__c = true,
                    Category__c = 'Student life',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    Priority = 'Low',
                    ContactId = contactList[0].Id,
                    RecordTypeId = CasesDAO.INTERNATIONALFS_RECTYPE_ID
                )
            );

            Test.startTest();
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            List<Case> caseList = CasesDAO.newInstance().getCasesByIds(new Set<Id>{cases[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals('High', caseList[0].Priority, 'Case priority should be set to high.');
        }
    }
}