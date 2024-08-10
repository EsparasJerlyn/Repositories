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
 *    | carl.alvin.cabiles             | February 12, 2024     | DEPP-7134              | Add getEngagementOpportunitiesBySetNames            |

 */
@isTest
public with sharing class EngagementOpportunitiesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserAlumniEngagementManager();
    }
 
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(EngagementOpportunitiesDAO.newInstance() != null, 'EngagementOpportunitiesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Engagement_Opportunity__c> engagementOpportunityList = EngagementOpportunitiesDAO.newInstance()
                .getEngagementOpportunitiesBySetIds(new Set<Id>(), AccessLevel.SYSTEM_MODE);
            System.assert(engagementOpportunityList.isEmpty(), 'EngagementOpportunityList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getEngagementOpportunitiesBySetNames() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            List<Engagement_Opportunity__c> engagementOpportunitiesList = EngagementOpportunitiesDAO.newInstance().getEngagementOpportunitiesBySetNames(new Set<String>{''}, AccessLevel.USER_MODE);
            System.assert(engagementOpportunitiesList.isEmpty(), 'engagementOpportunitiesList is not empty');
        }
        Test.stopTest();
    }
}