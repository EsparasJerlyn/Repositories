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
    
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers();
        
        List<Contact> relatedContacts = TestDataFactory.createTestContactRecords(1);
        insert relatedContacts;
        
        Id internationalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('International_Future_Student_Enquiry').getRecordTypeId();
        
        List<Case> internationalCases = TestDataFactory.createTestCaseRecords(internationalRecordTypeId, 'Test International Case', 100);
        
        for(Case c : internationalCases){
            c.ContactId = relatedContacts[0].Id;
            c.Origin = 'Email';
            c.Priority = 'Low';
            c.Category__c = 'Student life';
            c.Status = 'Closed';
            c.Closure_Code__c = 'Response Given';
            c.Closure_Details__c = 'Test Closure Details.';
        }
        
        insert internationalCases;   
    }
    
    @IsTest
    static void reopenClosedCaseTest(){
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
        
        List<Case> casesRetrieved = [SELECT Id, Status FROM Case WHERE Status = 'Responded'];
        
        Assert.areEqual(100, casesRetrieved.size(), 'Closed cases should be Responded.');
    }
    
}