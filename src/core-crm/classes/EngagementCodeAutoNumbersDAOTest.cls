/**
 * @description test class for Engagement Code Auto Numbers DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | created file
 */
@isTest
private class EngagementCodeAutoNumbersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                EngagementCodeAutoNumbersDAO.newInstance() != null,
                'EngagementCodeAutoNumbersDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new EngagementCodeAutoNumbersDAO().getSObjectType() == Engagement_Code_Auto_Number__c.SObjectType,
                'SObject is not Engagement_Code_Auto_Number__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getOrganizationalDefaults() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults() == new Engagement_Code_Auto_Number__c(),
                'Org defaults is not a new instance of the setting'
            );
        }
        Test.stopTest();
    }
}
