/**
 * @description test class for Opportunities Outcomes DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | alexander.cadalin              | May 17, 2023          | DEPP-5594              | created file
 *    | carl.alvin.cabiles             | May 25, 2023          | DEPP-5410              | added methods
 *    | carl.alvin.cabiles             | June 13, 2023         | DEPP-5409              | added methods
 *    | kenneth.f.alsay                | February 1, 2024      | DEPP-6938              | Added getActiveCorporateOutcomes
 */
@isTest
private class OpportunityOutcomesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserCorporatePartnershipsManager();
        TestDataFactoryUser.generateUserIndustryOperationsManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
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
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
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
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsSortByCodeAsc();
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsWithLikeCodeSortAscTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithLikeCodeSortAsc('');
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getRecordsWithEqualEndDate() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithEqualEndDate(System.today());
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getRecordsWithNotEqualEndDate() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithNotEqualEndDate(System.today());
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getRecordsWithStartDate() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithStartDate(System.today());
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getRecordsWithFutureDateAsDecommissionedDate() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithFutureDateAsDecommissionedDate();
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getRecordsWithPastDateAsDecommissionedDate() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithPastDateAsDecommissionedDate();
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getActiveCorporateOutcomes() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager) {
            List<Opportunity_Outcome__c> opptyOutcomesList = OpportunityOutcomesDAO.newInstance()
                .getActiveCorporateOutcomes(AccessLevel.USER_MODE);
            System.assert(opptyOutcomesList.isEmpty(), 'opptyOutcomesList is not empty');
        }
        Test.stopTest();
    }
}