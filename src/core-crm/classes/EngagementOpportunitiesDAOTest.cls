/**
 * @description Test Class for ServiceAppointmentsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                                      |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------------------|
 *    | nicole.genon                   | December 18, 2023     |DEPP-6949               | Created File                                        |
 */
@isTest
public with sharing class EngagementOpportunitiesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
 
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(EngagementOpportunitiesDAO.newInstance() != null, 'EngagementOpportunitiesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new EngagementOpportunitiesDAO().getSObjectType() == Engagement_Opportunity__c.SObjectType,
                'SObject is not Engagement_Opportunity__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getServiceAppointmentsBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Engagement_Opportunity__c> engagementOpportunityList = EngagementOpportunitiesDAO.newInstance()
                .getEngagementOpportunitiesBySetIds(new Set<Id>(), AccessLevel.SYSTEM_MODE);
            System.assert(engagementOpportunityList.isEmpty(), 'EngagementOpportunityList is not empty');
        }
        Test.stopTest();
    }
}