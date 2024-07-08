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
        Test.startTest();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        TestDataFactoryUser.generateUserFutureStudentAgentInternational();
        Test.stopTest();
        
        List<Contact> relatedContacts = TestDataFactory.createTestContactRecords(1);
        insert relatedContacts;
        
        List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test International Case', numberOfRecords);
        for(Case caseRecord : internationalCases){
            caseRecord.Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL;
        }
        List<Case> domesticCases = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test Domestic Case', numberOfRecords);
        for(Case caseRecord : domesticCases){
            caseRecord.Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC;
        }
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

        User userInternational = TestDataFactoryUser.selectUserFutureStudentAgentInternational;
        User userDomestic = TestDataFactoryUser.selectUserFutureStudentAgentDomestic;
        List<CaseShare> caseShareList = new List<CaseShare>();
        for(Case c : caseList){
            CaseShare caseShare = new CaseShare();
            caseShare.caseId = c.Id;
            caseShare.UserOrGroupId = userInternational.Id;
            caseShare.CaseAccessLevel = 'Edit'; 
            caseShare.RowCause = Schema.CaseShare.RowCause.Manual;
            caseShareList.add(caseShare);
        }
        for(Case c : caseList){
            CaseShare caseShare = new CaseShare();
            caseShare.caseId = c.Id;
            caseShare.UserOrGroupId = userDomestic.Id;
            caseShare.CaseAccessLevel = 'Edit'; 
            caseShare.RowCause = Schema.CaseShare.RowCause.Manual;
            caseShareList.add(caseShare);
        }
        
        Database.insert(
            caseShareList,
            false,
            AccessLevel.USER_MODE
        );
    }
    
    @IsTest
    static void reopenClosedInternationalCaseTest(){
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
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
            
            List<Case> casesRetrieved = [SELECT Id, Status FROM Case WHERE Status = 'Responded' AND RecordTypeId =: CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID AND Case_Type__c =: CasesDAO.CASE_TYPE_INTERNATIONAL];
            
            Assert.areEqual(numberOfRecords, casesRetrieved.size(), 'Closed cases should be Responded.');
        }
    }

    @IsTest
    static void reopenClosedDomesticCaseTest(){
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
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
            
            List<Case> casesRetrieved = [SELECT Id, Status FROM Case WHERE Status = 'Responded' AND RecordTypeId =: CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID AND Case_Type__c =: CasesDAO.CASE_TYPE_DOMESTIC];
            
            Assert.areEqual(numberOfRecords, casesRetrieved.size(), 'Closed cases should be Responded.');
        }
    }
    
}