/**
 * @description test class for Opportunities
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file,
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods
 */
@isTest
private class OpportunitiesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                OpportunitiesDAO.newInstance() != null,
                'OpportunitiesDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new OpportunitiesDAO().getSObjectType() == Opportunity.SObjectType,
                'SObject is not Opportunity'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsSortByOpportunityCodeAscTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance().getRecordsSortByOpportunityCodeAsc();
            System.assert(opportunitiesList.isEmpty(), 'opportunitiesList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsWithLikeOpportunityCodeSortAscTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance().getRecordsWithLikeOpportunityCodeSortAsc('');
            System.assert(opportunitiesList.isEmpty(), 'opportunitiesList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsBySetName() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance().getRecordsBySetName(new Set<String>{''});
            System.assert(opportunitiesList.isEmpty(), 'opportunitiesList is not empty');
        }
        Test.stopTest();
    }
}