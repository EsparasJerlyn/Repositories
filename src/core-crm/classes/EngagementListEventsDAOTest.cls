/**
 * @description Test Class for EngagementListEventsDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 14, 2024         | DEPP-8484              | Created file                 |
 */
@isTest
public with sharing class EngagementListEventsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{  'QUT_ESB' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(EngagementListEventsDAO.newInstance() != null, 'EngagementListEventsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                new EngagementListEventsDAO().getSObjectType() == Engagement_List_Event__c.SObjectType,
                'SObject is not Engagement_List_Event__c'
            );
        }
        Test.stopTest();
    }
}