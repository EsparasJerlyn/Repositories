/**
* @description Test Class for Reopen Closed Case Flow
* @see ../flow/Reopen_Closed_Case
*
* @author Accenture
*
* @history
*
| Developer Email                | Date                  | JIRA                   | Change Summary                             |
|--------------------------------|-----------------------|------------------------|--------------------------------------------|
| wushi.li		                 | December 22, 2023     | DEPP-7479              | Created file                               |
*/

@isTest
public with sharing class Reopen_Closed_CaseTest {

    private static final Integer numberOfRecords = 100;
    
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_International_Future_Student_Agent', 'QUT_Domestic_Future_Student_Agent' });
        
        List<Contact> relatedContacts = TestDataFactory.createTestContactRecords(1);
        insert relatedContacts;
        
        List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INTERNATIONALFS_RECTYPE_ID, 'Test International Case', numberOfRecords);
        List<Case> domesticCases = TestDataFactory.createTestCaseRecords(CasesDAO.DOMESTICFS_RECTYPE_ID, 'Test Domestic Case', numberOfRecords);

        List<Case> caseList = new List<Case>();
        caseList.addAll(internationalCases);
        caseList.addAll(domesticCases);

        for(Case c : caseList){
            c.ContactId = relatedContacts[0].Id;
            c.Origin = 'Email';
            c.Priority = 'Low';
            c.Category__c = 'Student life';
            c.Status = 'Closed';
            c.Closure_Code__c = 'Response Given';
            c.Closure_Details__c = 'Test Closure Details.';
        }
        
        CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);
    }
    
    @IsTest
    static void reopenClosedInternationalCaseTest(){
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
            List<EmailMessage> EmailMessages = new List<EmailMessage>();
        
            Test.startTest();
    
            for(Case c : [SELECT Id FROM Case]){                
                EmailMessage emailMessage = new EmailMessage();
                emailMessage.relatedToId = c.Id; 
                emailMessage.fromAddress = 'test@test.com'; // from address
                emailMessage.fromName = 'Test'; // from name
                emailMessage.toAddress = 'test@test.com';
                emailMessage.Subject = 'Test Email Message Subject';
                emailMessage.incoming = true;
                emailMessage.HtmlBody = 'Test HtmlBody';
                emailMessages.add(emailMessage);
            }
            
            insert emailMessages;
            
            Test.stopTest();
            
            List<Case> casesRetrieved = [SELECT Id, Status FROM Case WHERE Status = 'Responded' AND RecordTypeId =: CasesDAO.INTERNATIONALFS_RECTYPE_ID];
            
            Assert.areEqual(numberOfRecords, casesRetrieved.size(), 'Closed cases should be Responded.');
        }
    }

    @IsTest
    static void reopenClosedDomesticCaseTest(){
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<EmailMessage> EmailMessages = new List<EmailMessage>();
        
            Test.startTest();
    
            for(Case c : [SELECT Id FROM Case]){                
                EmailMessage emailMessage = new EmailMessage();
                emailMessage.relatedToId = c.Id; 
                emailMessage.fromAddress = 'test@test.com'; // from address
                emailMessage.fromName = 'Test'; // from name
                emailMessage.toAddress = 'test@test.com';
                emailMessage.Subject = 'Test Email Message Subject';
                emailMessage.incoming = true;
                emailMessage.HtmlBody = 'Test HtmlBody';
                emailMessages.add(emailMessage);
            }
            
            insert emailMessages;
            
            Test.stopTest();
            
            List<Case> casesRetrieved = [SELECT Id, Status FROM Case WHERE Status = 'Responded' AND RecordTypeId =: CasesDAO.DOMESTICFS_RECTYPE_ID];
            
            Assert.areEqual(numberOfRecords, casesRetrieved.size(), 'Closed cases should be Responded.');
        }
    }
    
}