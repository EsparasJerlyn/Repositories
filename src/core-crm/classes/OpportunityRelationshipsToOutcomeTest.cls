/**
 * @description test class for OpportunityRelationshipsToOutcome
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary                                        |
 *    |--------------------------------|-----------------------|----------------------|-------------------------------------------------------|
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468  | Created file                                          |
 *    | kenneth.f.alsay                | August 14, 2023       | DEPP-6208-6275       | Removed Pure_Project_ID__c field creation and copying |
 */
@isTest
public with sharing class OpportunityRelationshipsToOutcomeTest {
    @TestSetup
    static void setup() {
        Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        opptyCodeAutoNum.Commercialisation__c = 1;
        opptyCodeAutoNum.International_Projects_Unit__c = 1;
        opptyCodeAutoNum.Research_Partnership__c = 1;
        OpportunityCodeAutoNumbersDAO.newInstance()
            .upsertRecords(
                new List<Opportunity_Code_Auto_Number__c>{ opptyCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
        Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        oppOutcomeCodeAutoNum.Research_Partnership_Project__c = 1;
        oppOutcomeCodeAutoNum.IPU_Project__c = 1;
        oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c = 1;
        oppOutcomeCodeAutoNum.Start_Up__c = 1;
        OpportunityOutcomeCodeAutoNumbersDAO.newInstance()
            .upsertRecords(
                new List<Opportunity_Outcome_Code_Auto_Number__c>{ oppOutcomeCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
        Test.startTest();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        TestDataFactoryUser.generateUserIndustryOperationsManager();
        Test.stopTest();

        List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            // Create Opportunity records with IPU record type
            List<Opportunity> comOpportunityList = TestDataFactory.createTestOpportunityWithStageRecords(
                1,
                'Test Com Opportunity',
                OpportunitiesDAO.COMMERCIALIZATION_RECTYPE_ID,
                'Executed',
                accountList[0].Id,
                'Test Description'
            );
            OpportunitiesDAO.newInstance()
                .insertRecords(comOpportunityList, false, AccessLevel.USER_MODE);
    
            // Create Financial Split records related to above opportunities
            List<Financial_Split__c> financialSplitList = new List<Financial_Split__c>();
            for (Opportunity opp : comOpportunityList) {
                List<Financial_Split__c> tempList = TestDataFactory.createTestFinancialSplitRecordsForOpportunity(
                    2,
                    opp.Id,
                    accountList[0].Id
                );
                financialSplitList.addAll(tempList);
            }
            FinancialSplitsDAO.newInstance()
                .insertRecords(financialSplitList, false, AccessLevel.USER_MODE);

            // Create IP Management records
            List<IP_Management__c> ipManagement = TestDataFactory.createIPManagement(
                1,
                IPManagementsDAO.PATENT_RECTYPE_ID
            );
            IPManagementsDAO.newInstance()
                .insertRecords(ipManagement, false, AccessLevel.USER_MODE);

            // Create IP Management Relationship records related to above opportunities
            List<IP_Management_Relationship__c> ipManagementRelationships = new List<IP_Management_Relationship__c>();
            for (Opportunity opp : comOpportunityList) {
                List<IP_Management_Relationship__c> tempList = TestDataFactory.createIPManagementRelationships(
                    2,
                    opp.Id,
                    ipManagement[0].Id,
                    IPManagementRelationshipsDAO.IP_OPPORTUNITY_OUTCOME_RELATIONSHIP_RECTYPE_ID
                );
                ipManagementRelationships.addAll(tempList);
            }
            IPManagementRelationshipsDAO.newInstance()
                .insertRecords(ipManagementRelationships, false, AccessLevel.USER_MODE);
            // Create Contextual Role records related to above opportunities
            List<Contextual_Role__c> contextualRolesList = new List<Contextual_Role__c>();
            for (Opportunity opp : comOpportunityList) {
                List<Contextual_Role__c> partnerContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'Partners'
                );
                List<Contextual_Role__c> academicsContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'Academic Team'
                );
                List<Contextual_Role__c> trainingContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'Training Team'
                );
                contextualRolesList.addAll(partnerContextualRolesList);
                contextualRolesList.addAll(academicsContextualRolesList);
                contextualRolesList.addAll(trainingContextualRolesList);
            }
            ContextualRolesDAO.newInstance()
                .insertRecords(contextualRolesList, false, AccessLevel.USER_MODE);
        }

        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            // Create Opportunity records with Commercialisation record type
            List<Opportunity> comOpportunityList = TestDataFactory.createTestOpportunityWithStageRecords(
                1,
                'Test Com Opportunity',
                OpportunitiesDAO.COMMERCIALIZATION_RECTYPE_ID,
                'Contract',
                accountList[0].Id,
                'Test Description'
            );
            OpportunitiesDAO.newInstance()
                .insertRecords(comOpportunityList, false, AccessLevel.USER_MODE);

            // Create Financial Split records related to above opportunities
            List<Financial_Split__c> financialSplitList = new List<Financial_Split__c>();
            for (Opportunity opp : comOpportunityList) {
                List<Financial_Split__c> tempList = TestDataFactory.createTestFinancialSplitRecordsForOpportunity(
                    2,
                    opp.Id,
                    accountList[0].Id
                );
                financialSplitList.addAll(tempList);
            }
            FinancialSplitsDAO.newInstance()
                .insertRecords(financialSplitList, false, AccessLevel.USER_MODE);

            // Create IP Management records
            List<IP_Management__c> ipManagement = TestDataFactory.createIPManagement(
                1,
                IPManagementsDAO.PATENT_RECTYPE_ID
            );
            IPManagementsDAO.newInstance()
                .insertRecords(ipManagement, false, AccessLevel.USER_MODE);

            // Create IP Management Relationship records related to above opportunities
            List<IP_Management_Relationship__c> ipManagementRelationships = new List<IP_Management_Relationship__c>();
            for (Opportunity opp : comOpportunityList) {
                List<IP_Management_Relationship__c> tempList = TestDataFactory.createIPManagementRelationships(
                    2,
                    opp.Id,
                    ipManagement[0].Id,
                    IPManagementRelationshipsDAO.IP_OPPORTUNITY_OUTCOME_RELATIONSHIP_RECTYPE_ID
                );
                ipManagementRelationships.addAll(tempList);
            }
            IPManagementRelationshipsDAO.newInstance()
                .insertRecords(ipManagementRelationships, false, AccessLevel.USER_MODE);

            // Create Contextual Role records related to above opportunities
            List<Contextual_Role__c> contextualRolesList = new List<Contextual_Role__c>();
            for (Opportunity opp : comOpportunityList) {
                List<Contextual_Role__c> partnerContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'Partners'
                );
                List<Contextual_Role__c> schoolContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'School'
                );
                List<Contextual_Role__c> facultyContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'Faculty'
                );
                List<Contextual_Role__c> contributorsContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'Contributors'
                );
                List<Contextual_Role__c> researchCentreContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'Research Centre'
                );
                contextualRolesList.addAll(partnerContextualRolesList);
                contextualRolesList.addAll(schoolContextualRolesList);
                contextualRolesList.addAll(facultyContextualRolesList);
                contextualRolesList.addAll(contributorsContextualRolesList);
                contextualRolesList.addAll(researchCentreContextualRolesList);
            }
            ContextualRolesDAO.newInstance()
                .insertRecords(contextualRolesList, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void createCommercialisationOutcomeRecord() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            Test.startTest();
            List<Opportunity> comOpportunityList = OpportunitiesDAO.newInstance()
                .getRecordsLikeName('Test Com Opportunity', false, '%');
            List<Opportunity_Outcome__c> opportunityOutcomeList = TestDataFactory.createOpportunityOutcome(
                1,
                OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID,
                comOpportunityList[0].Id
            );
            OpportunityOutcomesDAO.newInstance()
                .insertRecords(opportunityOutcomeList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            // Assert that records were inserted
            List<Opportunity_Outcome__c> insertedRecords = OpportunityOutcomesDAO.getRecordsSortByCodeAsc();
            System.assertEquals(1, insertedRecords.size(), 'Expected 1 Opportunity_Outcome__c record to be inserted.');
        }
    }
    
    @isTest
    private static void createStartupOutcomeRecord() {
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            Test.startTest();
            List<Opportunity> comOpportunityList = OpportunitiesDAO.newInstance()
            .getRecordsLikeName('Test Com Opportunity', false, '%');

            List<Opportunity_Outcome__c> opportunityList = TestDataFactory.createOpportunityOutcome(
                1,
                OpportunityOutcomesDAO.STARTUP_RECTYPE_ID,
                comOpportunityList[0].Id
            );
            OpportunityOutcomesDAO.newInstance()
                .insertRecords(opportunityList, false, AccessLevel.USER_MODE);
            Test.stopTest();
    
            // Assert that records were inserted
            List<Opportunity_Outcome__c> insertedRecords = OpportunityOutcomesDAO.getRecordsSortByCodeAsc();
            System.assertEquals(1, insertedRecords.size(), 'Expected 1 Opportunity_Outcome__c record to be inserted.');
        }
    }

    @isTest
    static void testUpdateOpportunityOutcome() {

        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
        List<Opportunity> comOpportunityList = OpportunitiesDAO.newInstance()
            .getRecordsLikeName('Test Com Opportunity', false, '%');
        List<Opportunity_Outcome__c> testOpportunityOutcomes = TestDataFactory.createOpportunityOutcome(
            1,
            OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID,
            comOpportunityList[0].Id
        );
        OpportunityOutcomesDAO.newInstance()
            .insertRecords(testOpportunityOutcomes, false, AccessLevel.USER_MODE);
        
        Test.startTest();
        OpportunityRelationshipsToOutcome.updateOpportunityOutcome(testOpportunityOutcomes);
        Test.stopTest();

        // Verify that the Opportunity_Outcome__c records are updated
        List<Opportunity_Outcome__c> updatedOpportunityOutcomes = OpportunityOutcomesDAO.getRecordsSortByCodeAsc();
		System.assertEquals(1, updatedOpportunityOutcomes.size(), 'Expected 1 Opportunity_Outcome__c record to be updated.');
        }
    }
}