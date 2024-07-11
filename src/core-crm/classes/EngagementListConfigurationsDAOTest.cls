/**
 * @description Test Class for EngagementListConfigurationsDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 16, 2024         | DEPP-8484              | Created file                 |
 */
@isTest
public with sharing class EngagementListConfigurationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(EngagementListConfigurationsDAO.newInstance() != null, 'EngagementListConfigurationsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new EngagementListConfigurationsDAO().getSObjectType() == Engagement_List_Configuration__c.SObjectType,
                'SObject is not Engagement_List_Configuration__c'
            );
        }
        Test.stopTest();
    }
}