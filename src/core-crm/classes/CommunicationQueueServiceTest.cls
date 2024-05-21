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

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    private static void enqueueEmailTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            newContacts[0].AccountId = acc.Id;
            newContacts[0].Registered_Email__c ='work0testmail@mail.test';
            newContacts[0].QUT_Learner_Email__c = 'TestEmail@unique.com';
            ContactsDAO.newInstance().insertRecords(newContacts, true, AccessLevel.USER_MODE);

            Engagement_List_Configuration__c engagementListConfig = new Engagement_List_Configuration__c();
            engagementListConfig.Email_Template__c = 'Test Template';
            engagementListConfig.Communication_Channel__c = 'Email';
            insert engagementListConfig;

            Qualtrics_Survey__c qualtricsSurvey = new Qualtrics_Survey__c();
            qualtricsSurvey.In_Progress_Survey_URL__c = 'Test.com';
            insert qualtricsSurvey;

            List<Case> caseList = TestDataFactory.createTestCaseRecords(1, new List<Lead>(), newContacts);
            caseList[0].Origin = 'Email';
            caseList[0].Engagement_List_Configuration__c = engagementListConfig.Id;
            caseList[0].Qualtrics_Survey__c = qualtricsSurvey.Id;
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.USER_MODE);

            Test.startTest();
                Communication_Queue__c retCommunicationQueue = CommunicationQueueService.enqueueEmail(qualtricsSurvey, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(retCommunicationQueue.Id != null, 'Communication Queue Not Inserted.');
            System.assert(retCommunicationQueue.Type__c == 'Email', 'Communication Queue Type not matched.');
            System.assert(retCommunicationQueue.Due_Date__c == System.today(), 'Communication Queue Due Date not matched.');
            System.assert(retCommunicationQueue.Business_Process__c == 'Outreach Initial Email', 'Communication Queue Business Process not matched.');
            System.assert(retCommunicationQueue.WhoId__c == newContacts[0].Id, 'Communication Queue Contact not matched.');
            System.assert(retCommunicationQueue.WhatId__c == caseList[0].Id, 'Communication Queue Case not matched.');
            System.assert(retCommunicationQueue.Template_Id__c == engagementListConfig.Email_Template__c, 'Communication Queue Email Template not matched.');
            System.assert(retCommunicationQueue.Sender__c == [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='success@qut.edu.au']?.Id, 'Communication Queue Sender not matched.');
            System.assert(retCommunicationQueue.Status__c == 'Scheduled', 'Communication Queue Status not matched.');
            System.assert(retCommunicationQueue.Communication_Endpoint__c == newContacts[0].QUT_Learner_Email__c, 'Communication Queue End Point not matched.');
            System.assert([SELECT Initial_Communication_Status__c FROM Case WHERE Id = :caseList[0].Id].Initial_Communication_Status__c == 'Pending', 'Communication Queue Initial_Communication_Status__c not matched.');
            
        }  
    }
}
