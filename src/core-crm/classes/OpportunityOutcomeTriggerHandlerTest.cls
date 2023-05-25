/**
 * @description Test class for OpportunityTriggerHandler.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 22, 2023          | DEPP-5594              | created file
 */
@isTest
public with sharing class OpportunityOutcomeTriggerHandlerTest {

    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
        Opportunity_Outcome_Code_Auto_Number__c opportunityOutcomeCodeSetting = Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
        opportunityOutcomeCodeSetting.IPU_Project__c = 1;
        opportunityOutcomeCodeSetting.Research_Commercialisation_Project__c = 1;
        opportunityOutcomeCodeSetting.Research_Partnership_Project__c = 1;
        opportunityOutcomeCodeSetting.Start_Up__c = 1;
        OpportunityOutcomeCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Opportunity_Outcome_Code_Auto_Number__c>{opportunityOutcomeCodeSetting}, 
            false, 
            AccessLevel.USER_MODE
            );
    }

    @isTest
    private static void createIPUProjectRecord() {
        ImplementationSelector.DAO.setMock(new OpportunitiesDAOMock());
        List<Opportunity> opportunities = TestDataFactory.createTestOpportunityRecords(1, null, null);
        OpportunitiesDAO.newInstance().insertRecords(opportunities,false, AccessLevel.USER_MODE);
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                generateBatchOpportunityOutcomeRecords(
                    1, 
                    'IPU Project Sample', 
                    OpportunityOutcomesDAO.RT_OPPTYOC_INP_ID),
                false,
                AccessLevel.USER_MODE);
            //Opportunity_Outcome_Code_Auto_Number__c opportunityOutcomeCodeSetting = Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            // Opportunity_Outcome__c opportunityOutcomeRecord = OpportunityOutcomesDAO.newInstance().getRecordsSortByCodeAsc()[0];
            // System.assert(String.isNotBlank(opportunityOutcomeRecord.Code__c), 'Blank IPU Project Code__c on record.');
            // System.assertEquals('INP:00001', opportunityOutcomeRecord.Code__c, 'Incorrect IPU Project Code__c  on record.');
            // System.assertEquals(2.0, opportunityOutcomeCodeSetting.IPU_Project__c, 'Incorrect latest RCO code auto-number value.');
        }
    }

    /**
     * TEST STOP: CodeGeneratorService.generateOpportunityCodeForOpportunityRecords()
     */
    
    /**
     * Generate a list of opportunity records based on the amount of records needed, the general name to be used, and the record type.
     */
    private static List<Opportunity_Outcome__c> generateBatchOpportunityOutcomeRecords(Integer size, String name, Id recordTypeId) {
        List<Opportunity_Outcome__c> opportunityOutcomes = new List<Opportunity_Outcome__c>();
        for(Integer i = 1; i <= size; i++) {
            opportunityOutcomes.add(
                new Opportunity_Outcome__c(
                    Opportunity__c = OpportunitiesDAO.newInstance().getRecordsSortByOpportunityCodeAsc()[0].Id,
                    RecordTypeId = recordTypeId
                )
            );
        }
        return opportunityOutcomes;
    }
}