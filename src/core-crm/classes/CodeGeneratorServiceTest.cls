/**
 * @description Test class for CodeGeneratorService.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 22, 2023          | DEPP-5594              | created file
 */
@isTest
public class CodeGeneratorServiceTest {
	@testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
        Opportunity_Code_Auto_Number__c opptyCodeAutoNum = Opportunity_Code_Auto_Number__c.getOrgDefaults();
        opptyCodeAutoNum.Commercialisation__c = 1;
        opptyCodeAutoNum.International_Projects_Unit__c = 1;
        opptyCodeAutoNum.Research_Partnership__c = 1;
        OpportunityCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Opportunity_Code_Auto_Number__c>{opptyCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
        Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
        oppOutcomeCodeAutoNum.Research_Partnership_Project__c = 1;
        oppOutcomeCodeAutoNum.IPU_Project__c = 1;
        oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c = 1;
        oppOutcomeCodeAutoNum.Start_Up__c = 1;
        OpportunityOutcomeCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Opportunity_Outcome_Code_Auto_Number__c>{oppOutcomeCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
        Engagement_Code_Auto_Number__c engCodeAutoNum = Engagement_Code_Auto_Number__c.getOrgDefaults();
        engCodeAutoNum.Commercialisation__c = 1;
        engCodeAutoNum.Research_Partnership__c = 1;
        EngagementCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Engagement_Code_Auto_Number__c>{engCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
    }
    
    /** 
     * TEST START: CodeGeneratorService.generateOpportunityCodeForOpportunityRecords()
     * Various test cases of differing record types and record counts per transaction
     */
    @isTest
    private static void createOpptyRCORecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity> newItems = generateBatchOpportunityRecords(100, 'RCO', OpportunitiesDAO.RT_OPPTY_RCO_ID);
            Test.startTest();
            CodeGeneratorService.generateOpportunityCodeForOpportunityRecords(newItems);
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = Opportunity_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Opportunity newItem : newItems) {
                System.assertEquals(
                    'RCO:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Opportunity_Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, opptyCodeAutoNum.Commercialisation__c, 'Incorrect final auto-number value.');
        }
    }
    
    @isTest
    private static void createOpptyINPORecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity> newItems = generateBatchOpportunityRecords(100, 'RCO', OpportunitiesDAO.RT_OPPTY_INPO_ID);
            Test.startTest();
            CodeGeneratorService.generateOpportunityCodeForOpportunityRecords(newItems);
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = Opportunity_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Opportunity newItem : newItems) {
                System.assertEquals(
                    'INPO:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Opportunity_Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, opptyCodeAutoNum.International_Projects_Unit__c, 'Incorrect final auto-number value.');
        }
    }

	@isTest
    private static void createOpptyRPORecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity> newItems = generateBatchOpportunityRecords(100, 'RCO', OpportunitiesDAO.RT_OPPTY_RPO_ID);
            Test.startTest();
            CodeGeneratorService.generateOpportunityCodeForOpportunityRecords(newItems);
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = Opportunity_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Opportunity newItem : newItems) {
                System.assertEquals(
                    'RPO:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Opportunity_Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, opptyCodeAutoNum.Research_Partnership__c, 'Incorrect final auto-number value.');
        }
    }
    /**
     * TEST STOP: CodeGeneratorService.generateOpportunityCodeForOpportunityRecords()
     */

    /** 
     * TEST START: CodeGeneratorService.generateCodeForOpportunityOutcomeRecords()
     * Various test cases of differing record types and record counts per transaction
     */
    @isTest
    private static void createOpptyOutcRPPORecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity_Outcome__c> newItems = generateBatchOpportunityOutcomeRecords(100, 'RPP', OpportunityOutcomesDAO.RT_OPPTYOC_RPP_ID);
            Test.startTest();
            CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(newItems);
            Opportunity_Outcome_Code_Auto_Number__c opptyOutcCodeAutoNum = Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Opportunity_Outcome__c newItem : newItems) {
                System.assertEquals(
                    'RPP:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, opptyOutcCodeAutoNum.Research_Partnership_Project__c, 'Incorrect final auto-number value.');
        }
    }

    @isTest
    private static void createOpptyOutcINPRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity_Outcome__c> newItems = generateBatchOpportunityOutcomeRecords(100, 'INP', OpportunityOutcomesDAO.RT_OPPTYOC_INP_ID);
            Test.startTest();
            CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(newItems);
            Opportunity_Outcome_Code_Auto_Number__c opptyOutcCodeAutoNum = Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Opportunity_Outcome__c newItem : newItems) {
                System.assertEquals(
                    'INP:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, opptyOutcCodeAutoNum.IPU_Project__c, 'Incorrect final auto-number value.');
        }
    }

    @isTest
    private static void createOpptyOutcRCPRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity_Outcome__c> newItems = generateBatchOpportunityOutcomeRecords(100, 'RCP', OpportunityOutcomesDAO.RT_OPPTYOC_RCP_ID);
            Test.startTest();
            CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(newItems);
            Opportunity_Outcome_Code_Auto_Number__c opptyOutcCodeAutoNum = Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Opportunity_Outcome__c newItem : newItems) {
                System.assertEquals(
                    'RCP:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, opptyOutcCodeAutoNum.Research_Commercialisation_Project__c, 'Incorrect final auto-number value.');
        }
    }

    @isTest
    private static void createOpptyOutcRCCRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity_Outcome__c> newItems = generateBatchOpportunityOutcomeRecords(100, 'RCC', OpportunityOutcomesDAO.RT_OPPTYOC_RCC_ID);
            Test.startTest();
            CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(newItems);
            Opportunity_Outcome_Code_Auto_Number__c opptyOutcCodeAutoNum = Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Opportunity_Outcome__c newItem : newItems) {
                System.assertEquals(
                    'RCC:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, opptyOutcCodeAutoNum.Start_Up__c, 'Incorrect final auto-number value.');
        }
    }
    /**
     * TEST STOP: CodeGeneratorService.generateCodeForOpportunityOutcomeRecords()
     */
    /** 
     * TEST START: CodeGeneratorService.generateEngagementCodeForEngagementRecords()
     * Various test cases of differing record types and record counts per transaction
     */
    @isTest
    private static void createEngagementRCERecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Engagement__c> newItems = generateBatchEngagementRecords(100, 'RCE', EngagementsDAO.RT_ENG_RCE_ID);
            Test.startTest();
            CodeGeneratorService.generateEngagementCodeForEngagementRecords(newItems);
            Engagement_Code_Auto_Number__c engCodeAutoNum = Engagement_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Engagement__c newItem : newItems) {
                System.assertEquals(
                    'RCE:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Engagement_Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, engCodeAutoNum.Commercialisation__c, 'Incorrect final auto-number value.');
        }
    }

    @isTest
    private static void createEngagementRPERecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Engagement__c> newItems = generateBatchEngagementRecords(100, 'RPE', EngagementsDAO.RT_ENG_RPE_ID);
            Test.startTest();
            CodeGeneratorService.generateEngagementCodeForEngagementRecords(newItems);
            Engagement_Code_Auto_Number__c engCodeAutoNum = Engagement_Code_Auto_Number__c.getOrgDefaults();
            Test.stopTest();
            Integer count = 1;
            for(Engagement__c newItem : newItems) {
                System.assertEquals(
                    'RPE:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Engagement_Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, engCodeAutoNum.Research_Partnership__c, 'Incorrect final auto-number value.');
        }
    }
    /**
     * TEST STOP: CodeGeneratorService.generateCodeForOpportunityOutcomeRecords()
     */

    /**
     * Generate a list of opportunity records based on the amount of records needed, the general name to be used, and the record type.
     */
    private static List<Opportunity> generateBatchOpportunityRecords(Integer size, String name, Id recordTypeId) {
        List<Opportunity> oppties = new List<Opportunity>();
        for(Integer i = 1; i <= size; i++) {
            oppties.add(
                new Opportunity(
                    Name = name + ' ' + String.valueOf(i), 
                    StageName = 'Qualify', 
                    CloseDate = System.today() + 50, 
                    RecordTypeId = recordTypeId
                )
            );
        }
        return oppties;
    }

    /**
     * Generate a list of opportunity outcome records based on the amount of records needed, the general name to be used, and record type
     */
    private static List<Opportunity_Outcome__c> generateBatchOpportunityOutcomeRecords(Integer size, String name, Id recordTypeId) {
        List<Opportunity> oppty = new List<Opportunity>();
        oppty.add(new Opportunity(
            Name = 'Sample Opportunity ' + System.now(),
            StageName = 'Qualify',
            CloseDate = System.today() + 50
        ));
        OpportunitiesDAO.newInstance().insertRecords(oppty, false, AccessLevel.USER_MODE);
        List<Opportunity_Outcome__c> oppOutcomes = new List<Opportunity_Outcome__c>();
        for(Integer i = 1; i <= size; i++) {
            oppOutcomes.add(
                new Opportunity_Outcome__c(
                    Company_Name__c = 'Sample Company', 
                    Opportunity__c = oppty[0].Id, 
                    Project_Name__c = oppty[0].Name,
                    RecordTypeId = recordTypeId
                )
            );
        }
        return oppOutcomes;
    }

    /**
     * Generate a list of engagement records based on the amount of records needed, summary, and record type
     */
    private static List<Engagement__c> generateBatchEngagementRecords(Integer size, String summary, Id recordTypeId) {
        List<Engagement__c> engs = new List<Engagement__c>();
        for(Integer i = 1; i <= size; i++) {
            engs.add(
                new Engagement__c(Engagement_Summary__c = summary + i, RecordTypeId = recordTypeId)
            );
        }
        return engs;
    }
}