/**
 * @description Test Class for CaseTriggerHandler
 *
 * @see CaseTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | Sept 12, 2023         | DEPP-6421              | Created file                                     |
 */
@isTest
private class CaseTriggerHandlerTest {
    
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
                    Status = 'New', 
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
}