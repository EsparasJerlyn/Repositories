/**
 * @description Test Class for CaseService
 *
 * @see CaseService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | arsenio.jr.dayrit              | Sept 27,2023          | DEPP-6720              | Created file                                          |
 */
@isTest
private class CaseServiceTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    private static void testmapExistingContactMatchToCase() {
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
    private static void testmapExistingLeadMatchToCase() {
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