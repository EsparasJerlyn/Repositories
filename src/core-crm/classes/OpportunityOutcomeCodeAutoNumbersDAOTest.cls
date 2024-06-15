/**
 * @description test class for Opportunities Outcome Code Auto Numbers DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | created file
 */
@isTest
private class OpportunityOutcomeCodeAutoNumbersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                OpportunityOutcomeCodeAutoNumbersDAO.newInstance() != null,
                'OpportunityOutcomeCodeAutoNumbersDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new OpportunityOutcomeCodeAutoNumbersDAO().getSObjectType() == Opportunity_Outcome_Code_Auto_Number__c.SObjectType,
                'SObject is not Opportunity_Outcome_Code_Auto_Number__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getOrganizationalDefaults() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults() == new Opportunity_Outcome_Code_Auto_Number__c(),
                'Org defaults is not a new instance of the setting'
            );
        }
    }
}
