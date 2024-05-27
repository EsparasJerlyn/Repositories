/**
 * @description Test Class for EngagementListCriteriasDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | vincent.ferrer                 |  May 1, 2024          | DEPP-8492              | Created file
 */
@isTest
public with sharing class EngagementListCriteriasDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{  'QUT_ESB' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(EngagementListCriteriasDAO.newInstance() != null, 'EngagementListCriteriasDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                new EngagementListCriteriasDAO().getSObjectType() == Engagement_List_Criteria__c.SObjectType,
                'SObject is not Engagement_List_Criteria__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void findActiveEntryCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Engagement_List_Criteria__c> engagementListCriteriaList = EngagementListCriteriasDAO.newInstance()
                .findActiveEngagementListCriteriasByRecordtype(
                    EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA,
                    system.today(),
                    AccessLevel.USER_MODE
                );
            System.assert(engagementListCriteriaList.isEmpty(), 'Engagement List Criteria list should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void findActiveEntryCriteriaEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Engagement_List_Criteria__c> engagementListCriteriaList = EngagementListCriteriasDAO.newInstance()
                .findActiveEngagementListCriteriasByRecordtype(
                    null,
                    null,
                    AccessLevel.USER_MODE
                );
            System.assert(engagementListCriteriaList.isEmpty(), 'Engagement List Criteria list should not be empty.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getEntryCriteriaByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c(
                Engagement_List_Criteria_Title__c = 'Test',
                Citizenship_Status__c = 'International',
                Engagement_List_Configuration__c = configs[0].Id
            );

            EngagementListConfigurationsDAO.newInstance().insertRecords(new List<Engagement_List_Criteria__c>{elc},true,AccessLevel.USER_MODE);
            Engagement_List_Criteria__c elCrit = EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(
                    elc.Id,
                    AccessLevel.USER_MODE
                );
            System.assert(elCrit != null, 'The criteria should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getEntryCriteriaByIdEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Engagement_List_Criteria__c elCrit = EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(
                    null,
                    AccessLevel.USER_MODE
                );
            System.assert(elCrit == null, 'The criteria should be empty.');
        }
        Test.stopTest();
    }
} 