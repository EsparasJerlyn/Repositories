/**
 * @description Test class for CommunicationQueueEmailRequestCommand
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 20, 2024          | DEPP-8766              | Created file                 |
 */
@isTest
public with sharing class CommunicationQueueEmailRequestComTest {
	
    private static final String EMAIL = 'testmail@mail.test';
    private static Id orgwideId;
    
    @TestSetup
    static void setupData(){
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) { 
            List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
            EmailTemplate emailTemplate = new EmailTemplate();
            emailTemplate.Name = 'Test Email Temp';
            emailTemplate.Subject = 'Test Subject';
            emailTemplate.HtmlValue = '<html></html>';
            emailTemplate.TemplateType = 'custom';
            emailTemplate.UiType = 'SFX';
            emailTemplate.RelatedEntityType = 'Contact';
            emailTemplate.IsActive = true;
            emailTemplates.add(emailTemplate);
            EmailTemplatesDAO.newInstance().insertRecords(emailTemplates, false, AccessLevel.SYSTEM_MODE);
            
            MockIdGenerator mockIdGen = new MockIdGenerator(OrgWideEmailAddress.SObjectType);
            orgwideId = mockIdGen.getMockId();
        }
    }

    @isTest
    private static void sendEmailToContactWithSentStatusTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Integer i = 0; i < contactList.size(); i ++){
                contactList[i].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contactList[i].Email = 'work' + i + EMAIL;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);          
            List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{'Test Email Temp'}, AccessLevel.USER_MODE);
            
            List<Communication_Queue__c> commsQueueList = new List<Communication_Queue__c>();
            
            for(Contact con: contactList){
                Communication_Queue__c comsqueue = new Communication_Queue__c();              
                comsqueue.WhoId__c = con.Id;
                comsqueue.Template_Id__c = emailTemplates[0].Id;
                comsqueue.Type__c = CommunicationQueuesDAO.TYPE_EMAIL;
                comsqueue.Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_OUTREACH;
                comsqueue.Status__c = CommunicationQueuesDAO.STATUS_SCHEDULED;
                comsqueue.Communication_Endpoint__c = 'Contact.Email';
                comsqueue.Due_Date__c = Date.today();
                comsqueue.Sender__c = orgwideId;
                commsQueueList.add(comsqueue);
            }
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);

            Test.startTest();
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new CommunicationQueueEmailRequestCommand(commsQueueList));
            cmd.executeCommand();
            Test.stopTest();

            List<Communication_Queue__c> resultCommsQueueList = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
                new Set<String>{CommunicationQueuesDAO.STATUS_SENT},
                AccessLevel.USER_MODE
            );
            System.Assert.isTrue(!resultCommsQueueList.isEmpty(), 'Communication Queue List should not be empty.');            
            
            System.Assert.areEqual(
                contactList.size(),
                resultCommsQueueList.size(),
                'Expected to get the same contact size of communication queue that is sent'
            );

            for(Communication_Queue__c comsQueue: resultCommsQueueList){
                System.Assert.areEqual(
                    CommunicationQueuesDAO.STATUS_SENT,
                    comsQueue.Status__c,
                    'We expected the status to be Sent'
                );
            }            
        }
    }
    
    @isTest
    private static void sendEmailToLeadWithSentStatusTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            
            List<Lead> leadList = TestDataFactory.createLeadRecordsByLeadType(3,'Learner',false);              
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);
            
            List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{'Test Email Temp'}, AccessLevel.USER_MODE);
            
            List<Communication_Queue__c> commsQueueList = new List<Communication_Queue__c>();
            
            for(Lead lead: leadList){
                Communication_Queue__c comsqueue = new Communication_Queue__c();              
                comsqueue.WhoId__c = lead.Id;
                comsqueue.Template_Id__c = emailTemplates[0].Id;
                comsqueue.Type__c = CommunicationQueuesDAO.TYPE_EMAIL;
                comsqueue.Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_OUTREACH;
                comsqueue.Status__c = CommunicationQueuesDAO.STATUS_SCHEDULED;
                comsqueue.Communication_Endpoint__c = 'Lead.Email';
                comsqueue.Due_Date__c = Date.today();
                comsqueue.Sender__c = orgwideId;
                commsQueueList.add(comsqueue);
            }
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);

            Test.startTest();
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new CommunicationQueueEmailRequestCommand(commsQueueList));
            cmd.executeCommand();
            Test.stopTest();

            List<Communication_Queue__c> resultCommsQueueList = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
                new Set<String>{CommunicationQueuesDAO.STATUS_SENT},
                AccessLevel.USER_MODE
            );
            System.Assert.isTrue(!resultCommsQueueList.isEmpty(), 'Communication Queue List should not be empty.'); 
            System.Assert.areEqual(
                leadList.size(),
                resultCommsQueueList.size(),
                'Expected to get the same lead size of communication queue that is sent'
            );

            for(Communication_Queue__c comsQueue: resultCommsQueueList){
                System.Assert.areEqual(
                    CommunicationQueuesDAO.STATUS_SENT,
                    comsQueue.Status__c,
                    'We expected the status to be Sent'
                );
            }            
        }
    }
    
    @isTest
    private static void sendEmailWithWhatIdPopulatedTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {          
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Integer i = 0; i < contactList.size(); i ++){
                contactList[i].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contactList[i].Email = 'work' + i + EMAIL;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);          
            List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{'Test Email Temp'}, AccessLevel.USER_MODE);
            List<Case> caseList = TestDataFactory.createTestCaseRecords(contactList.size(),null,contactList);
            for(Case caseRec: caseList) {
                caseRec.Case_Type__c = 'Student Success - Retention';
                caseRec.Origin = 'Email';
                caseRec.Priority = 'Low';
                caseRec.Category__c = 'Student life';
                caseRec.Status = 'Created';
                caseRec.SuppliedEmail = 'test333111CaseRec@mailinator.com';
                caseRec.recordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
            }
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);  
            
            List<Communication_Queue__c> commsQueueList = new List<Communication_Queue__c>();
            
            for(Integer i = 0; i < contactList.size(); i ++){
                Communication_Queue__c comsqueue = new Communication_Queue__c();              
                comsqueue.WhoId__c = contactList[i].Id;
                comsqueue.Template_Id__c = emailTemplates[0].Id;
                comsqueue.Type__c = CommunicationQueuesDAO.TYPE_EMAIL;
                comsqueue.Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_OUTREACH;
                comsqueue.Status__c = CommunicationQueuesDAO.STATUS_SCHEDULED;
                comsqueue.Communication_Endpoint__c = 'Contact.Email';
                comsqueue.Due_Date__c = Date.today();
                comsqueue.Sender__c = orgwideId;
                comsqueue.WhatId__c = caseList[i].id;
                commsQueueList.add(comsqueue);
            }
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);

            Test.startTest();
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new CommunicationQueueEmailRequestCommand(commsQueueList));
            cmd.executeCommand();
            Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();

            List<Communication_Queue__c> resultCommsQueueList = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
                new Set<String>{CommunicationQueuesDAO.STATUS_SENT},
                AccessLevel.USER_MODE
            );
            System.Assert.isTrue(!resultCommsQueueList.isEmpty(), 'Communication Queue List should not be empty.');            
            
            System.Assert.areEqual(
                contactList.size(),
                resultCommsQueueList.size(),
                'Expected to get the same contact size of communication queue that is sent'
            );

            for(Communication_Queue__c comsQueue: resultCommsQueueList){
                System.Assert.areEqual(
                    CommunicationQueuesDAO.STATUS_SENT,
                    comsQueue.Status__c,
                    'We expected the status to be Sent'
                );
            }
			System.Assert.isTrue(![SELECT Id FROM Task WHERE WhatId IN:caseList].isEmpty(), ' Related Tasks List should not be empty.');
            System.Assert.areEqual(1, invocations,'The actual email is not sent');
        }
    }

}