/**
 * @description test class for RisksDAOTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | ryan.j.a.dela.cruz             | August 08, 2023       | DEPP-6335              | Created file
 */
@isTest
public with sharing class ListContributorsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Alumni_Engagement_Manager' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAlumniEngagementManager()) {
            System.assert(ListContributorsDAO.newInstance() != null, 'ListContributorsDAO instance is null');
        }
        Test.stopTest(); 
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAlumniEngagementManager()) {
            System.assert(
                new ListContributorsDAO().getSObjectType() == List_Contributor__c.SObjectType,
                'SObject is not List_Contributor__c'
            );
        }
        Test.stopTest();
    }
    @isTest
    static void getListContributorByListID() {
        Test.startTest();
            List<List_Contributor__c> listContributors = ListContributorsDAO.newInstance()
                .getListContributorByListID(new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(listContributors.isEmpty(), 'listContributors is not empty');
        Test.stopTest();
    }
}
