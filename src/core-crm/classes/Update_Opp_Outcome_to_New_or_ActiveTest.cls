/**
 * @description Test class to test coverage of Update_Opp_Outcome_to_New_or_Active_Flow
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | ryan.j.a.dela.cruz             | July 06, 2023         | DEPP-5995              | Created file
 */
@isTest
public class Update_Opp_Outcome_to_New_or_ActiveTest {
    private static string companyName = 'TestCompany';
    private static string projectName = 'project';
    private static string code = '0';
    private static Id recordTypeId = OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID;
    private static Integer numOfOppOutcome = 5;
    private static Date currentDate = System.today();

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Partnership_Manager' });

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

        List<Opportunity> opportunities = TestDataFactory.createOpportunityRecords(
            1,
            'OpportunityTest',
            OpportunitiesDAO.IDENTIFY_STAGE
        );
        OpportunitiesDAO.newInstance().insertRecords(opportunities, false, AccessLevel.USER_MODE);

        List<Opportunity_Outcome__c> opportunityList = TestDataFactory.createOpportunityOutcome(
            numOfOppOutcome,
            recordTypeId,
            opportunities[0].Id
        );
        OpportunityOutcomesDAO.newInstance()
            .insertRecords(opportunityList, false, AccessLevel.USER_MODE);
    }

    @isTest
    private static void updateOpportunityOutcomeStartDateToCurrentTest() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity_Outcome__c> opportunityOutcomeListToUpdate = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithStartDate(currentDate + 10); // from future date

            Test.startTest();
            updateStartDate(opportunityOutcomeListToUpdate, 0); // update to current date
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithStartDate(currentDate - 10); // compare with current date

            for (Opportunity_Outcome__c oppOutcome : oppOutcomes) {
                System.assertEquals(
                    OpportunityOutcomesDAO.ACTIVE_STAGE,
                    oppOutcome.Stage_Name__c,
                    'Stage should be Active.'
                );
            }
        }
    }

    @isTest
    private static void updateOpportunityOutcomeStartDateToFutureTest() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity_Outcome__c> opportunityOutcomeListToUpdate = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithStartDate(currentDate + 10); // from future date

            Test.startTest();
            updateStartDate(opportunityOutcomeListToUpdate, 10); // add 10 more days (Still future)
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithStartDate(currentDate + 10); // compare with current date

            for (Opportunity_Outcome__c oppOutcome : oppOutcomes) {
                System.assertEquals(
                    OpportunityOutcomesDAO.NEW_STAGE,
                    oppOutcome.Stage_Name__c,
                    'Stage should be New.'
                );
            }
        }
    }

    @isTest
    private static void updateOpportunityOutcomeStartDateToPreviousTest() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity_Outcome__c> opportunityOutcomeListToUpdate = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithStartDate(currentDate + 10); // from future date

            Test.startTest();
            updateStartDate(opportunityOutcomeListToUpdate, -10); // decrease 10 more days (previous date)
            Test.stopTest();

            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance()
                .getRecordsWithStartDate(currentDate - 10); // compare with current date

            for (Opportunity_Outcome__c oppOutcome : oppOutcomes) {
                System.assertEquals(
                    OpportunityOutcomesDAO.ACTIVE_STAGE,
                    oppOutcome.Stage_Name__c,
                    'Stage should be Active.'
                );
            }
        }
    }

    private static void updateStartDate(
        List<Opportunity_Outcome__c> opportunityOutcomes,
        Integer increment
    ) {
        for (Opportunity_Outcome__c opp_outcome : opportunityOutcomes) {
            opp_outcome.Start_Date__c = currentDate + increment;
        }
        update opportunityOutcomes;
    }
}
