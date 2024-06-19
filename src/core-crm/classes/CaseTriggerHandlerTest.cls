/**
 * @description Test Class for CaseTriggerHandler
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
      | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method testCaseMobileMatchToContactMobile   |
 */
@isTest
private class CaseTriggerHandlerTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }
    
    @isTest
    private static void testCaseEmailMatchToContactEmail() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
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
                    Case_type__c = 'Domestic Future Student Enquiry',
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
    private static void testCaseMobileMatchToContactMobile() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].MobilePhone = '090909';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    SuppliedPhone = '090909',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = CasesDAO.newInstance().getCasesBySuppliedPhone(new Set<String>{cases[0].SuppliedPhone}, AccessLevel.USER_MODE);
            System.assert(caseRecordList[0].ContactId !=null, 'case is not link to existing contact.');
        }
    }
}