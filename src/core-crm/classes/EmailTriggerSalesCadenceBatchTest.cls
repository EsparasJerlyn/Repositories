/**
 * @description Test class for EmailTriggerSalesCadenceBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                      |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------------|
      | eccarius.munoz                 | August 31, 2023       | DEPP-6138              | Created file                                                        |
	  | mark.j.mahilum                 | March 07, 2024        | DEPP-8243              | Updated test class to cover the communication queue status          |
      |                                |                       |                        | the actual status once Email or SMS is sent to the contact or lead  |
 */
@isTest
public with sharing class EmailTriggerSalesCadenceBatchTest {
    
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
    private static void sendEmailWithSentStatusTest() {
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
            EmailTriggerSalesCadenceBatch batchable = new EmailTriggerSalesCadenceBatch();
            Id batchableId = Database.executeBatch(batchable);      
            Test.stopTest();
            
            System.Assert.isTrue(
                batchableId != null,
                'The batch job failed to execute.'
            );

            
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
    private static void sendSMSWithSentStatusTest() {
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
                comsqueue.Mobile__c = '9999999999';
                comsqueue.Message__c = 'SMS Sending Test';
                comsqueue.Type__c = 'SMS';
                comsqueue.Business_Process__c = 'Domestic Automated Cadence SMS';
                comsqueue.Status__c = CommunicationQueuesDAO.STATUS_SCHEDULED;
                commsQueueList.add(comsqueue);
            }
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            EmailTriggerSalesCadenceBatch batchable = new EmailTriggerSalesCadenceBatch();
            Id batchableId = Database.executeBatch(batchable);      
            Test.stopTest();
            
            System.Assert.isTrue(
                batchableId != null,
                'The batch job failed to execute.'
            );
            
            
            List<Communication_Queue__c> resultCommsQueueList = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
                new Set<String>{CommunicationQueuesDAO.STATUS_RETRY},
                AccessLevel.USER_MODE
            );
            System.Assert.isTrue(!resultCommsQueueList.isEmpty(), 'Communication Queue List should not be empty.');            
            
            System.Assert.areEqual(
                contactList.size(),
                resultCommsQueueList.size(),
                'Expected to get the same contact size of communication queue that is Retry'
            );
            
            for(Communication_Queue__c comsQueue: resultCommsQueueList){
                System.Assert.areEqual(
                    CommunicationQueuesDAO.STATUS_RETRY,
                    comsQueue.Status__c,
                    'We expected the status to be Retry'
                );
            }       
        }
    }
    
    @isTest
    private static void sendNurturingEmailWithSentStatusTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Integer i = 0; i < contactList.size(); i ++){
                contactList[i].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contactList[i].Email = 'work' + i + EMAIL;
                contactList[i].QUT_Applicant__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);          
            List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{'Test Email Temp'}, AccessLevel.USER_MODE);
            
            List<Communication_Queue__c> commsQueueList = new List<Communication_Queue__c>();
            
            for(Contact con: contactList){
                Communication_Queue__c comsqueue = new Communication_Queue__c();              
                comsqueue.WhoId__c = con.Id;
                comsqueue.Template_Id__c = emailTemplates[0].Id;
                comsqueue.Type__c = 'Email';
                comsqueue.Business_Process__c = 'Domestic Automated Cadence Email';
                comsqueue.Status__c = CommunicationQueuesDAO.STATUS_SCHEDULED;
                comsqueue.Communication_Endpoint__c = 'Contact.Email';
                comsqueue.Due_Date__c = Date.today();
                comsqueue.Sender__c = orgwideId;
                commsQueueList.add(comsqueue);
            }
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            EmailTriggerSalesCadenceBatch batchable = new EmailTriggerSalesCadenceBatch();
            Id batchableId = Database.executeBatch(batchable);      
            Test.stopTest();
            
            System.Assert.isTrue(
                batchableId != null,
                'The batch job failed to execute.'
            );

            
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
}