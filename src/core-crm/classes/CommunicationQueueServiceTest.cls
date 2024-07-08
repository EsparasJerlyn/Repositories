/**
 * @description Test Class for CommunicationQueueService
 *
 * @see CommunicationQueueService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
 *    | gabriel.p.ventayen             | May 21,2024           | DEPP-8833	            | Created File                                          |
 */
@isTest
private class CommunicationQueueServiceTest {

    private static final String TEST_TEMPLATE = 'Test Email Template';

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    private static void enqueueEmailQualtricSurveyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            newContacts[0].AccountId = acc.Id;
            newContacts[0].Registered_Email__c ='work0testmail@mail.test';
            newContacts[0].QUT_Learner_Email__c = 'TestEmail@unique.com';
            ContactsDAO.newInstance().insertRecords(newContacts, true, AccessLevel.USER_MODE);

            List<EmailTemplate> emailTemplateList = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                TEST_TEMPLATE => 'Test Email Subject1'
            });
            insert emailTemplateList;

            Engagement_List_Configuration__c engagementListConfig = new Engagement_List_Configuration__c();
            engagementListConfig.Email_Template__c = emailTemplateList[0].Name;
            engagementListConfig.Communication_Channel__c = 'Email';
            insert engagementListConfig;

            Qualtrics_Survey__c qualtricsSurvey = new Qualtrics_Survey__c();
            qualtricsSurvey.In_Progress_Survey_URL__c = 'Test.com';
            insert qualtricsSurvey;
            List<Qualtrics_Survey__c> qualtricsSurveyList = new List<Qualtrics_Survey__c>();
            qualtricsSurveyList.add(qualtricsSurvey);

            List<Case> caseList = TestDataFactory.createTestCaseRecords(1, new List<Lead>(), newContacts);
            caseList[0].Origin = 'Email';
            caseList[0].Engagement_List_Configuration__c = engagementListConfig.Id;
            caseList[0].Qualtrics_Survey__c = qualtricsSurvey.Id;
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.USER_MODE);

            Test.startTest();
                List<Communication_Queue__c> retCommunicationQueueList = CommunicationQueueService.enqueueEmail(qualtricsSurveyList, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(retCommunicationQueueList.Size() > 0, 'Communication Queue Not Inserted.');
            System.assert(retCommunicationQueueList[0].Type__c ==  CommunicationQueuesDAO.TYPE_EMAIL, 'Communication Queue Type not matched.');
            System.assert(retCommunicationQueueList[0].Due_Date__c == System.today(), 'Communication Queue Due Date not matched.');
            System.assert(retCommunicationQueueList[0].Business_Process__c == 'Outreach Initial Email', 'Communication Queue Business Process not matched.');
            System.assert(retCommunicationQueueList[0].WhoId__c == newContacts[0].Id, 'Communication Queue Contact not matched.');
            System.assert(retCommunicationQueueList[0].WhatId__c == caseList[0].Id, 'Communication Queue Case not matched.');
            System.assert(retCommunicationQueueList[0].Template_Id__c == emailTemplateList[0].Id, 'Communication Queue Email Template not matched.');
            System.assert(retCommunicationQueueList[0].Sender__c == [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Student Success']?.Id, 'Communication Queue Sender not matched.');
            System.assert(retCommunicationQueueList[0].Status__c ==  CommunicationQueuesDAO.STATUS_SCHEDULED, 'Communication Queue Status not matched.');
            System.assert(retCommunicationQueueList[0].Communication_Endpoint__c == CommunicationQueuesDAO.END_POINT_CONTACT_LEARNER_EMAIL, 'Communication Queue End Point not matched.');
            System.assert([SELECT Initial_Communication_Status__c FROM Case WHERE Id = :caseList[0].Id].Initial_Communication_Status__c == 'Pending', 'Communication Queue Initial_Communication_Status__c not matched.');
            
        }  
    }

    @isTest
    private static void enqueueEmailCaseTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            newContacts[0].AccountId = acc.Id;
            newContacts[0].Registered_Email__c ='work0testmail@mail.test';
            newContacts[0].QUT_Learner_Email__c = 'TestEmail@unique.com';
            ContactsDAO.newInstance().insertRecords(newContacts, true, AccessLevel.USER_MODE);

            List<EmailTemplate> emailTemplateList = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                TEST_TEMPLATE => 'Test Email Subject1'
            });
            insert emailTemplateList;

            Engagement_List_Configuration__c engagementListConfig = new Engagement_List_Configuration__c();
            engagementListConfig.Email_Template__c = emailTemplateList[0].Name;
            engagementListConfig.Communication_Channel__c = 'Email';
            insert engagementListConfig;

            Qualtrics_Survey__c qualtricsSurvey = new Qualtrics_Survey__c();
            qualtricsSurvey.In_Progress_Survey_URL__c = 'Test.com';
            insert qualtricsSurvey;
            List<Qualtrics_Survey__c> qualtricsSurveyList = new List<Qualtrics_Survey__c>();
            qualtricsSurveyList.add(qualtricsSurvey);

            List<Case> caseList = TestDataFactory.createTestCaseRecords(1, new List<Lead>(), newContacts);
            caseList[0].Origin = 'Email';
            caseList[0].Engagement_List_Configuration__c = engagementListConfig.Id;
            caseList[0].Qualtrics_Survey__c = qualtricsSurvey.Id;
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.USER_MODE);

            Test.startTest();
                List<Communication_Queue__c> retCommunicationQueueList = CommunicationQueueService.enqueueEmail(caseList, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(retCommunicationQueueList.Size() > 0, 'Communication Queue Not Inserted.');
            System.assert(retCommunicationQueueList[0].Type__c ==  CommunicationQueuesDAO.TYPE_EMAIL, 'Communication Queue Type not matched.');
            System.assert(retCommunicationQueueList[0].Due_Date__c == System.today(), 'Communication Queue Due Date not matched.');
            System.assert(retCommunicationQueueList[0].Business_Process__c == 'Outreach Initial Email', 'Communication Queue Business Process not matched.');
            System.assert(retCommunicationQueueList[0].WhoId__c == newContacts[0].Id, 'Communication Queue Contact not matched.');
            System.assert(retCommunicationQueueList[0].WhatId__c == caseList[0].Id, 'Communication Queue Case not matched.');
            System.assert(retCommunicationQueueList[0].Template_Id__c == emailTemplateList[0].Id, 'Communication Queue Email Template not matched.');
            System.assert(retCommunicationQueueList[0].Sender__c == [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Student Success']?.Id, 'Communication Queue Sender not matched.');
            System.assert(retCommunicationQueueList[0].Status__c ==  CommunicationQueuesDAO.STATUS_SCHEDULED, 'Communication Queue Status not matched.');
            System.assert(retCommunicationQueueList[0].Communication_Endpoint__c == CommunicationQueuesDAO.END_POINT_CONTACT_LEARNER_EMAIL, 'Communication Queue End Point not matched.');
            System.assert([SELECT Initial_Communication_Status__c FROM Case WHERE Id = :caseList[0].Id].Initial_Communication_Status__c == 'Pending', 'Communication Queue Initial_Communication_Status__c not matched.');
            
        }  
    }
}
