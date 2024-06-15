/**
 * @description Test Class CasesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Created File                                     |
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Added getCaseBySuppliedEmailTest                 |
      | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method getCasesBySuppliedPhoneTest     |
      | gabriel.p.ventayen             | May 23, 2024          | DEPP-8833              | added getCasesByQualtricsSurveyIds               |
*/
@isTest
public with sharing class CasesDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Student_Success_Outreach_Manager' });
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new CasesDAO().getSObjectType() == Case.SObjectType,
                'SObject is not Case'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByContactIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByContactOrLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByContactOrLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCaseBySuppliedEmailTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCaseBySuppliedEmail(
                    '',
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesBySuppliedPhoneTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesBySuppliedPhone(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetCasesByContactOrLeadIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                CasesDAO.newInstance().queryLocatorGetCasesByContactOrLeadIds(
                    new Set<Id>()
                ) != null,
                'caseList should not be empty.'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getCasesByQualtricsSurveyIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                CasesDAO.newInstance().getCasesByQualtricsSurveyIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                ) != null,
                'caseList should not be empty.'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getOpenOutreachCasesByConfigAndContactIdsTest() {
        System.runAs(TestDataFactory.getStudentSuccessOutreachManager()) {

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            configs.add(new Engagement_List_Configuration__c(Name = 'Test Outreach Config'));
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            Id ownerId = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
            Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(configs[0], ownerId, contactList[0].Id);
            List<Case> caseList = new List<Case>();
            caseList.add(outreachCase);
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<Case> outreachCases = CasesDAO.newInstance()
                .getOpenOutreachCasesByConfigAndContactIds(
                    new Set<Id>{contactList[0].Id},
                    configs[0].Id,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();

            System.assert(!outreachCases.isEmpty(), 'Incorrect Subject of Case.');
            System.assertEquals(contactList[0].Id, outreachCases[0].ContactId , 'No Case retrieved for Contact ' + contactList[0].Id);
        }
    }

    @isTest
    static void getCasesByEngagementListConfigurationIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            configs.add(new Engagement_List_Configuration__c(Name = 'Test Outreach Config'));
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            Id ownerId = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
            Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(configs[0], ownerId, contactList[0].Id);
            List<Case> caseList = new List<Case>();
            caseList.add(outreachCase);
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

            List<Case> caseListRecord = CasesDAO.newInstance()
                .getCasesByEngagementListConfigurationIds(
                    (String)configs[0].Id,
                    AccessLevel.SYSTEM_MODE
                );
            System.assertEquals(configs[0].Id, caseListRecord[0].Engagement_List_Configuration__c , 'Engagement_List_Configuration__c should be the same as configs[0].Id');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByIdsImportedTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getStudentSuccessOutreachManager()) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            configs.add(new Engagement_List_Configuration__c(Name = 'Test Outreach Config'));
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            Id ownerId = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
            Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(configs[0], ownerId, contactList[0].Id);
            List<Case> caseList = new List<Case>();
            caseList.add(outreachCase);
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);
            List<Case> caseListRecord = CasesDAO.newInstance()
                .getCasesByIdsImported(
                    new Set<Id>{caseList[0].Id},
                    AccessLevel.SYSTEM_MODE
                );
            System.assertEquals(caseList[0].Id, caseListRecord[0].Id , 'caseList[0].Id should be the same as caseListRecord[0].Id');
        }
        Test.stopTest();
    }

}