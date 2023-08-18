/**
 * @description test class for Opportunity_Create_Opportunity_Outcome flow
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary                                                                                  |
 *    |--------------------------------|-----------------------|----------------------|-------------------------------------------------------------------------------------------------|
 *    | kenneth.f.alsay                | June 14, 2023         | DEPP-5434, 5399      | Created file,added test methods                                                                 |
 *    | ryan.j.a.dela.cruz             | June 19, 2023         | DEPP-5748            | Added assert messages, pmd fix                                                                  |
 *    | ryan.j.a.dela.cruz             | July 03, 2023         | DEPP-5390            | Added pure project record creation                                                              |
 *    | kenneth.f.alsay                | August 15, 2023       | DEPP-6208-6275       | Removed Pure Project to reflect change in TestDataFactory.createTestOpportunityWithStageRecords | 
 *    | kenneth.f.alsay                | August 15, 2023       | DEPP-6300            | Removed IPU parts                                                                               |
 */
@isTest
public class Create_Opportunity_Outcome_FlowTest {
    // * Description: This method is used to create initial data for the test methods
    @TestSetup
    static void makeData() {
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

        List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_IE_Partnership_Manager', 'QUT_Operations_Manager' }
        );
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            // Create Opportunity records with RP record type
            List<Opportunity> rpOpportunityList = TestDataFactory.createTestOpportunityWithStageRecords(
                200,
                'Test RP Opportunity',
                OpportunitiesDAO.RESEARCHPARTNERSHIP_RECTYPE_ID,
                'Contract',
                accountList[0].Id,
                'Test Description'
            );
            OpportunitiesDAO.newInstance()
                .insertRecords(rpOpportunityList, false, AccessLevel.USER_MODE);
            
            // Create Contextual Role records related to above opportunities
            List<Contextual_Role__c> contextualRolesList = new List<Contextual_Role__c>();
            for (Opportunity opp : rpOpportunityList) {
                List<Contextual_Role__c> partnerContextualRolesList = TestDataFactory.createContextualRolesForOpportunity(
                    2,
                    ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                    opp.Id,
                    accountList[0].Id,
                    'Partners'
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
                contextualRolesList.addAll(contributorsContextualRolesList);
                contextualRolesList.addAll(researchCentreContextualRolesList);
            }
            ContextualRolesDAO.newInstance()
                .insertRecords(contextualRolesList, false, AccessLevel.USER_MODE);
        } 
    }

    @isTest
    public static void updateOpportunityStagetoExecuted() {
        Test.startTest(); 
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity> rpOpportunityList = OpportunitiesDAO.newInstance()
                .getRecordsLikeName('Test RP Opportunity', false, '%');
            for (Opportunity opportunity : rpOpportunityList) {
                opportunity.CLMS_Contract_ID__c = '1234';
                opportunity.CLMS_Contract_Status__c = 'Internally Approved';
                opportunity.StageName = 'Executed';
            }
            update rpOpportunityList;
            List<Id> opportunityIds = new List<Id>();
            for (Opportunity opp : rpOpportunityList) {
                opportunityIds.add(opp.Id);
            }
            //get created Opportunities
            List<Opportunity_Outcome__c> oppOutcomeList = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithOpportunity(opportunityIds);
            List<Id> opportunityOutcomeIds = new List<Id>();
            for (Opportunity_Outcome__c oppOutcome : oppOutcomeList) {
                opportunityOutcomeIds.add(oppOUtcome.Id);
            }
            System.assertEquals(
                200,
                [
                    SELECT COUNT()
                    FROM Opportunity_Outcome__c
                    WHERE Opportunity__c IN :opportunityIds
                ],
                'Incorrect count of Opportunity_Outcome__c records'
            );
            System.assertEquals(
                400,
                [
                    SELECT COUNT()
                    FROM Contextual_Role__c
                    WHERE
                        Opportunity_Outcome__c IN :opportunityOutcomeIds
                        AND Contextual_Role_Group__c = 'Partners'
                ],
                'Incorrect count of Contextual_Role__c records for Partners'
            );
            System.assertEquals(
                400,
                [
                    SELECT COUNT()
                    FROM Contextual_Role__c
                    WHERE
                        Opportunity_Outcome__c IN :opportunityOutcomeIds
                        AND Contextual_Role_Group__c = 'Contributors'
                ],
                'Incorrect count of Contextual_Role__c records for Contributors'
            );
                        System.assertEquals(
                400,
                [
                    SELECT COUNT()
                    FROM Contextual_Role__c
                    WHERE
                        Opportunity_Outcome__c IN :opportunityOutcomeIds
                        AND Contextual_Role_Group__c = 'Research Centre'
                ],
                'Incorrect count of Contextual_Role__c records for Research Centre'
            );
        }
        Test.stopTest(); 
    }
}