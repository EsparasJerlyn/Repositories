/**
 * @description test class for Opportunities
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                                  |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------------------------|
 *    | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file                                                                                    |
 *    | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods                                                                                   |
 *    | kenneth.f.alsay                | June 20, 2023         | DEPP-5434, 5399        | added methods                                                                                   |
 *    | ryan.j.a.dela.cruz             | June 20, 2023         | DEPP-5434, 5399        | Added pure project record creation                                                              |
 *    | kenneth.f.alsay                | August 15, 2023       | DEPP-6208-6275         | Removed Pure Project to reflect change in TestDataFactory.createTestOpportunityWithStageRecords | 
 */
@isTest
private class OpportunitiesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
        List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

        // Create Pure Project records with Contract Negotiation status
        List<Pure_Project__c> pureProjectList = TestDataFactory.createTestPureProjectRecords(
            1,
            'Test Pure Project',
            'Contract Negotiation'
        );
        PureProjectsDAO.newInstance().insertRecords(pureProjectList, false, AccessLevel.USER_MODE);

        List<Opportunity> opportunityList = new List<Opportunity>();
        List<Opportunity> opptyListWildCardBefore = TestDataFactory.createTestOpportunityWithStageRecords(
            200,
            'Wildcard Opportunities',
            OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID,
            'Contract',
            accountList[0].Id,
            'Test Description'
        );
        List<Opportunity> opptyListWildCardAfter = TestDataFactory.createTestOpportunityWithStageRecords(
            200,
            'Opportunities wildcard',
            OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID,
            'Contract',
            accountList[0].Id,
            'Test Description'
        );
        opportunityList.addAll(opptyListWildCardBefore);
        opportunityList.addAll(opptyListWildCardAfter);
        OpportunitiesDAO.newInstance().insertRecords(opportunityList, false, AccessLevel.USER_MODE);
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance()
                .getRecordsSortByOpportunityCodeAsc();
            System.assert(!opportunitiesList.isEmpty(), 'opportunitiesList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsWithLikeOpportunityCodeSortAscTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance()
                .getRecordsWithLikeOpportunityCodeSortAsc('');
            System.assert(opportunitiesList.isEmpty(), 'opportunitiesList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsBySetName() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance()
                .getRecordsBySetName(new Set<String>{ '' });
            System.assert(opportunitiesList.isEmpty(), 'opportunitiesList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsLikeName() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Opportunity> opptyListWildCardAfter = OpportunitiesDAO.newInstance()
                .getRecordsLikeName('Opportunities', false, '%');
            System.assert(
                !opptyListWildCardAfter.isEmpty(),
                'opportunitiesList should not be empty'
            );
            List<Opportunity> opptyListWildCardBefore = OpportunitiesDAO.newInstance()
                .getRecordsLikeName('Opportunities', true, '%');
            System.assert(
                opptyListWildCardBefore.isEmpty(),
                'opportunitiesList record found'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsByStageName() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance()
                .getRecordsByStageName('');
            System.assert(opportunitiesList.isEmpty(), 'opportunitiesList should not be empty');
        }
    }

    @isTest
    static void getRecordsBySetIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance()
                .getRecordsBySetIds(new Set<Id>());
            System.assert(opportunitiesList.isEmpty(), 'opportunitiesList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getOpportunityByRecordTypeIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Opportunity> opportunitiesList = OpportunitiesDAO.newInstance()
                .getOpportunityByRecordTypeIds(new Set<Id>(),AccessLevel.SYSTEM_MODE);
            System.assert(opportunitiesList.isEmpty(), 'opportunitiesList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getOpportunityByRecordTypeIdsNotEmpty() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            MockIdGenerator recordTypeMock = new MockIdGenerator(Recordtype.getSObjectType());
            List<Opportunity> opportunityList = OpportunitiesDAO.newInstance()
                .getOpportunityByRecordTypeIds(
                    new Set<Id>{recordTypeMock.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(opportunityList.isEmpty(), 'OpportunityList should not be empty');
        }
        Test.stopTest();
    }
}
