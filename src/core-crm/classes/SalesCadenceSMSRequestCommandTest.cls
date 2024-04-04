/**
 * @description Test class for SalesCadenceSMSRequestCommand
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum      	       | October 25, 2023      | DEPP-6985              | Created file                 |
 */

@isTest
public with sharing class SalesCadenceSMSRequestCommandTest {

    @TestSetup
    static void setupData(){
        TestDataFactory.generateTestUsers(new List<String>{ 'System_Administrator' });
        System.runAs(TestDataFactory.getSystemAdminUser()) { 

            List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
            leadScoreParentConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Total Max Score DUG',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined'
                )
            );

            LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Marketing consent',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'Domestic',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 20,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Marketing consent',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'International',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 20,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
            leadScoreConfigChildList.addAll(TestDataFactory.createDomestcAndUndeterminedSubCategory(
                leadScoreConfigList[0].Id,
                new List<String>{
                    'Yes',
                    'is blank'
                },
                new List<Integer>{200,200}
            ));
            leadScoreConfigChildList.addAll(TestDataFactory.createIntlAndUndeterminedSubCategory(
                leadScoreConfigList[1].Id,
                new List<String>{
                    'Yes',
                    'is blank'
                },
                new List<Integer>{200,200}
            ));

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1,3);
            contactList[0].Calculated_Cadence__c = 'International Application Submission - Direct Applicant (Automated)';
            contactList[0].hed__Citizenship_Status__c = 'International';
            contactList[1].Calculated_Cadence__c = 'Domestic Offer Lapsed (Automated)';
            contactList[1].hed__Citizenship_Status__c = 'Domestic';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();

            List<Nurture_Track_Configuration__c> initialNurtureListInt = TestDataFactory.createNurtureTrackConfigRecords(1);
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListInt){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)',
                        Lead_Score_Threshold__c = 3,
                        Status__c = 'Active'
                    )
                );
            }

            List<Nurture_Track_Configuration__c> initialNurtureListDom = TestDataFactory.createNurtureTrackConfigRecords(1);
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListDom){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Offer Lapsed (Automated)',
                        Lead_Score_Threshold__c = 3,
                        Status__c = 'Active'
                    )
                );
            }

            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  

            List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
            EmailTemplate emailTemplate = new EmailTemplate();
            emailTemplate.Name = 'Test Email Temp';
            emailTemplate.Subject = 'Test Subject';
            emailTemplate.HtmlValue = '<html></html>';
            emailTemplate.TemplateType = 'custom';
            emailTemplate.UiType = 'SFX';
            emailTemplates.add(emailTemplate);
            EmailTemplatesDAO.newInstance().insertRecords(emailTemplates, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void sendEmailWithSentStatusTest() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(2);
            List<Communication_Queue__c> commsQueueList = new List<Communication_Queue__c>();
            
            commsQueueList.add(
                new Communication_Queue__c(
                    WhoId__c = contactList[0].Id,
                    Status__c = 'Scheduled',
                    Mobile__c = '999999999',
                    Message__c = 'SMS Text message',
                    Type__c = 'SMS'
                )
            );
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);

            Test.startTest();
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new SalesCadenceSMSRequestCommand(commsQueueList));
            cmd.executeCommand();     
            Test.stopTest();
        }

        List<Communication_Queue__c> commsQueue = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
            new Set<String>{CommunicationQueuesDAO.STATUS_RETRY},
            AccessLevel.USER_MODE
        );

        System.assert(!commsQueue.isEmpty(), 'List should not be empty.');
    } 
    
    @isTest
    private static void createTaskRecordForNoAnswerSMS() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            List<Contact> contacts = ContactsDAO.newInstance().getPersonContactsWithLimit(2);
            List<Communication_Queue__c> commQueues = new List<Communication_Queue__c>();
            commQueues.add(new Communication_Queue__c(
                Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_DOMESTIC_NO_ANSWER_SMS,
                WhoId__c = contacts[0].Id,
                Message__c = 'Sample message.',
                Type__c = 'SMS'
            ));
            CommunicationQueuesDAO.newInstance().insertRecords(commQueues, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new SalesCadenceSMSRequestCommand(commQueues));
            cmd.executeCommand();
            cmd.executeCommand();
            cmd.executeCommand();
            cmd.executeCommand();
            Test.stopTest();
            
            commQueues = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
            new Set<String>{CommunicationQueuesDAO.STATUS_FAILED},
            AccessLevel.USER_MODE
        	);

        	System.assert(!commQueues.isEmpty(), 'List should not be empty.');
        }
    }
    
    @isTest
    private static void createTaskRecordForNurtureTrackSMS() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            List<Contact> contacts = ContactsDAO.newInstance().getPersonContactsWithLimit(2);
            List<Communication_Queue__c> commQueues = new List<Communication_Queue__c>();
            commQueues.add(new Communication_Queue__c(
                WhoId__c = contacts[0].Id,
                Message__c = 'Sample message.',
                Type__c = 'SMS'
            ));
            CommunicationQueuesDAO.newInstance().insertRecords(commQueues, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new SalesCadenceSMSRequestCommand(commQueues));
            cmd.executeCommand();
            cmd.executeCommand();
            cmd.executeCommand();
            cmd.executeCommand();
            Test.stopTest();
            
            commQueues = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
            new Set<String>{CommunicationQueuesDAO.STATUS_FAILED},
            AccessLevel.USER_MODE
        	);

        	System.assert(!commQueues.isEmpty(), 'List should not be empty.');
        }
    }
}