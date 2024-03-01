/**
 * @description test class for PlanActivitiesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file
 */
@isTest
public with sharing class PlanActivitiesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Advancement_Manager' });
    }
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAdvancementManager()) {
            System.assert(PlanActivitiesDAO.newInstance() != null, 'PlanActivitiesDAO instance is null');
        }
        Test.stopTest();
    }
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAdvancementManager()) {
            System.assert(
                new PlanActivitiesDAO().getSObjectType() == Plan_Activity__c.SObjectType,
                'SObject is not Plan_Activity__c'
            );
        }
        Test.stopTest();
    }
}