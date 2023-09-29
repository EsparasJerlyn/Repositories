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
 */
@isTest
private class CaseTriggerHelperTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
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
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.USER_MODE);
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
}