/**
 * @description Test class for OutreachCommunicationProcessedHandler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 21, 2024          | DEPP-8823              | Created file                 |
 */
@isTest
public class OutreachCommunicationProcessedHandTest {
    
	private static final String EMAIL = 'testmail@mail.test';
    
    @testSetup
    static void setupTestData() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
    }

    @isTest
    static void testAfterInsertCaseCommunicationStatusSent() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            // Create test Cases
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Integer i = 0; i < contactList.size(); i++){
                contactList[i].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contactList[i].Email = 'work' + i + EMAIL;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);          
            List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{'Test Email Temp'}, AccessLevel.USER_MODE);
            List<Case> caseList = TestDataFactory.createTestCaseRecords(contactList.size(),null,contactList);
            for(Case caseRec: caseList) {
                caseRec.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
                caseRec.Origin = CommunicationQueuesDAO.TYPE_EMAIL;
                caseRec.Priority = 'Low';
                caseRec.Category__c = 'Student life';
                caseRec.Status = 'Created';
                caseRec.SuppliedEmail = 'test333111CaseRec@mailinator.com';
                caseRec.recordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
            }
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);  
            
            // Create test outeach Communication_Processed__e events
            List<Communication_Processed__e> testEvents = new List<Communication_Processed__e>();
            for (Case c : caseList) {
                testEvents.add(new Communication_Processed__e(
                    What_Id__c = c.Id,
                    Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_OUTREACH,
                    Type__c = CommunicationQueuesDAO.TYPE_EMAIL,
                    Success__c = true
                ));
            }
            
            // Publish the platform events
            Test.startTest();
            EventBus.publish(testEvents);
            Test.stopTest();
            
            // Retrieve the test Cases to use their Ids
            List<Case> testCases = [SELECT Id, Initial_Communication_Status__c FROM Case WHERE RecordTypeId =: CasesDAO.OUTREACH_RECTYPE_ID];
            for (Case c : testCases) {
                System.assertEquals(CasesDAO.INITIAL_COMMUNICATION_STATUS_SENT, c.Initial_Communication_Status__c, 'Initial Communication Status should be "Sent"');
            }
        }
    }
    
    @isTest
    static void testAfterInsertCaseCommunicationStatusFailed() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            // Create test Cases
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Integer i = 0; i < contactList.size(); i++){
                contactList[i].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contactList[i].Email = 'work' + i + EMAIL;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);          
            List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{'Test Email Temp'}, AccessLevel.USER_MODE);
            List<Case> caseList = TestDataFactory.createTestCaseRecords(contactList.size(),null,contactList);
            for(Case caseRec: caseList) {
                caseRec.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
                caseRec.Origin = CommunicationQueuesDAO.TYPE_EMAIL;
                caseRec.Priority = 'Low';
                caseRec.Category__c = 'Student life';
                caseRec.Status = 'Created';
                caseRec.Initial_Communication_Status__c = CasesDAO.INITIAL_COMMUNICATION_STATUS_PENDING;
                caseRec.SuppliedEmail = 'test333111CaseRec@mailinator.com';
                caseRec.recordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
            }
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);  
            
            // Create test Communication_Processed__e events
            List<Communication_Processed__e> testEvents = new List<Communication_Processed__e>();
            for (Case c : caseList) {
                testEvents.add(new Communication_Processed__e(
                    What_Id__c = c.Id,
                    Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_OUTREACH,
                    Type__c = CommunicationQueuesDAO.TYPE_EMAIL,
                    Success__c = false
                ));
            }
            
            // Publish the platform events
            Test.startTest();
            EventBus.publish(testEvents);
            Test.stopTest();
            
            // Retrieve the test Cases to use their Ids
            List<Case> testCases = [SELECT Id, Initial_Communication_Status__c FROM Case WHERE RecordTypeId =: CasesDAO.OUTREACH_RECTYPE_ID];
            for (Case c : testCases) {
                System.assertEquals(CasesDAO.INITIAL_COMMUNICATION_STATUS_PENDING, c.Initial_Communication_Status__c, 'Initial Communication Status should be "Pending"');
            }
        }
    }
}