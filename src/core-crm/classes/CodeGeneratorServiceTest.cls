/**
 * @description Test class for CodeGeneratorService.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 22, 2023          | DEPP-5594              | created file                 |
      | eugene.andrew.abuan            | March 20, 2024        | DEPP-8200              | Added Donation Cause         |
      | eugene.andrew.abuan            | April 05, 2024        | DEPP-8390              | Added Designation Cause      |
      | eugene.andrew.abuan            | April 17, 2024        | DEPP-8340              | Added Designation Endowment  |

 */
@isTest
public class CodeGeneratorServiceTest {
	@testSetup
    static void setup() {
        TestDataFactoryUser.generateUserAdvancementManager();
        TestDataFactoryUser.generateUserDonorEngagementManager();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        opptyCodeAutoNum.Commercialisation__c = 1;
        opptyCodeAutoNum.International_Projects_Unit__c = 1;
        opptyCodeAutoNum.Research_Partnership__c = 1;
        OpportunityCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Opportunity_Code_Auto_Number__c>{opptyCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
        Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        oppOutcomeCodeAutoNum.Research_Partnership_Project__c = 1;
        oppOutcomeCodeAutoNum.IPU_Project__c = 1;
        oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c = 1;
        oppOutcomeCodeAutoNum.Start_Up__c = 1;
        OpportunityOutcomeCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Opportunity_Outcome_Code_Auto_Number__c>{oppOutcomeCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
        Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        engCodeAutoNum.Commercialisation__c = 1;
        engCodeAutoNum.Research_Partnership__c = 1;
        EngagementCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Engagement_Code_Auto_Number__c>{engCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );

        Donation_Cause_Code_Auto_Number__c donationCauseCodeAutoNum = DonationCauseCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        donationCauseCodeAutoNum.Donation_Cause__c = 1;
        DonationCauseCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Donation_Cause_Code_Auto_Number__c>{donationCauseCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
        
        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Giving_To_Cause__c = 1;
        designationCodeAutoNum.Endowment__c = 1;
        DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Opportunity> newItems = TestDataFactory.createTestOpportunityRecords(100, 'RCO', OpportunitiesDAO.COMMERCIALIZATION_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateOpportunityCodeForOpportunityRecords(newItems);
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Opportunity> newItems = TestDataFactory.createTestOpportunityRecords(100, 'RCO', OpportunitiesDAO.INTERNATIONALPROJECTSUNIT_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateOpportunityCodeForOpportunityRecords(newItems);
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Opportunity> newItems = TestDataFactory.createTestOpportunityRecords(100, 'RCO', OpportunitiesDAO.RESEARCHPARTNERSHIP_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateOpportunityCodeForOpportunityRecords(newItems);
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Opportunity_Outcome__c> newItems = TestDataFactory.createTestOpportunityOutcomeRecords(100, 'RPP', OpportunityOutcomesDAO.RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(newItems);
            Opportunity_Outcome_Code_Auto_Number__c opptyOutcCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Opportunity_Outcome__c> newItems = TestDataFactory.createTestOpportunityOutcomeRecords(100, 'INP', OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(newItems);
            Opportunity_Outcome_Code_Auto_Number__c opptyOutcCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Opportunity_Outcome__c> newItems = TestDataFactory.createTestOpportunityOutcomeRecords(100, 'RCP', OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(newItems);
            Opportunity_Outcome_Code_Auto_Number__c opptyOutcCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Opportunity_Outcome__c> newItems = TestDataFactory.createTestOpportunityOutcomeRecords(100, 'RCC', OpportunityOutcomesDAO.STARTUP_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(newItems);
            Opportunity_Outcome_Code_Auto_Number__c opptyOutcCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Engagement__c> newItems = TestDataFactory.createTestEngagementRecords(100, 'RCE', EngagementsDAO.COMMERCIALISATION_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateEngagementCodeForEngagementRecords(newItems);
            Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Engagement__c> newItems = TestDataFactory.createTestEngagementRecords(100, 'RPE', EngagementsDAO.RESEARCHPARTNERSHIP_RECTYPE_ID);
            Test.startTest();
            CodeGeneratorService.generateEngagementCodeForEngagementRecords(newItems);
            Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
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
     * TEST START: CodeGeneratorService.generateCodeForDonationCauseRecords()
     */
    @isTest
    private static void createDonationCauseRecords() {

        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Donation_Cause__c> newItems = TestDataFactory.createDonationCauseRecords(100);
            Test.startTest();
                CodeGeneratorService.generateCodeForDonationCauseRecords(newItems);
                Donation_Cause_Code_Auto_Number__c dcCodeAutoNum = DonationCauseCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();

            Integer count = 1;
            for(Donation_Cause__c newItem : newItems) {
                System.assertEquals(
                    'ADVDC:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Donation_Cause_Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, dcCodeAutoNum.Donation_Cause__c, 'Incorrect final auto-number value.');
        }
    }

    /**
     * TEST STOP: CodeGeneratorService.generateCodeForDonationCauseRecords()
     */

    /** 
     * TEST START: CodeGeneratorService.generateCodeForDesignationGivingToCauseRecords()
     */
    @isTest
    private static void createDesignationGivingToCauseRecords() {

        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> newItems = TestDataFactory.createDesignationRecords(100, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            Test.startTest();
                CodeGeneratorService.generateCodeForDesignationGivingToCauseRecords(newItems);
                Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();

            Integer count = 1;
            for(Designation__c newItem : newItems) {
                System.assertEquals(
                    'ADVGC:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Designation_Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, designationCodeAutoNum.Giving_To_Cause__c, 'Incorrect final auto-number value.');
        }
    }

    /**
     * TEST STOP: CodeGeneratorService.generateCodeForDesignationGivingToCauseRecords()
     */
        /** 
     * TEST START: CodeGeneratorService.generateCodeForDesignationEndowmentRecords()
     */
    @isTest
    private static void createDesignationEndowmentRecords() {

        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> newItems = TestDataFactory.createDesignationRecords(100, DesignationsDAO.ENDOWNMENT_RECTYPE_ID);
            for(Designation__c d : newItems){
                d.Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
            }
            Test.startTest();
                CodeGeneratorService.generateCodeForDesignationEndowmentRecords(newItems);
                Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();

            Integer count = 1;
            for(Designation__c newItem : newItems) {
                System.assertEquals(
                    'ADVEDW:' + String.valueOf(count).leftPad(5, '0'),
                    newItem.Designation_Code__c,
                    'Incorrect code.');
                count++;
            }
            System.assertEquals(101, designationCodeAutoNum.Endowment__c, 'Incorrect final auto-number value.');
        }
    }

    /**
     * TEST STOP: CodeGeneratorService.generateCodeForDesignationEndowmentRecords()
     */
}