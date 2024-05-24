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

} 