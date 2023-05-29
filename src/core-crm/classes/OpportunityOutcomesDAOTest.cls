/**
 * @description test class for Opportunities Outcomes DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | created file
 */
@isTest
private class OpportunityOutcomesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                OpportunityOutcomesDAO.newInstance() != null,
                'OpportunityOutcomesDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new OpportunityOutcomesDAO().getSObjectType() == Opportunity_Outcome__c.SObjectType,
                'SObject is not Opportunity Outcome'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsSortByCodeAscTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsSortByCodeAsc();
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsWithLikeCodeSortAscTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithLikeCodeSortAsc('');
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getRecordsWithEqualEndDate() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithEqualEndDate(System.today());
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getRecordsWithNotEqualEndDate() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithNotEqualEndDate(System.today());
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
}
