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
    }
    
    @isTest
    private static void createRPPRecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                TestDataFactory.createTestOpportunityOutcomeRecords(1, 'Research Partnership Project Sample', OpportunityOutcomesDAO.RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID),
                false,
                AccessLevel.USER_MODE
                );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            Opportunity_Outcome__c oppOutcomeFinal = OpportunityOutcomesDAO.getRecordsSortByCodeAsc()[0];
            System.assert(String.isNotBlank(oppOutcomeFinal.Code__c), 'Blank RPP code on record.');
            System.assertEquals('RPP:00001', oppOutcomeFinal.Code__c, 'Incorrect RPP code on record.');
            System.assertEquals(2.0, oppOutcomeCodeAutoNum.Research_Partnership_Project__c, 'Incorrect latest RPP code auto-number value.');
        }
    }
    
    @isTest
    private static void createRPPRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                TestDataFactory.createTestOpportunityOutcomeRecords(100, 'Research Partnership Project Sample', OpportunityOutcomesDAO.RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID),
                false,
                AccessLevel.USER_MODE
                );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomesFinal = OpportunityOutcomesDAO.getRecordsSortByCodeAsc();
            Integer counter = 1;
            for(Opportunity_Outcome__c oppOutcomeFinal : oppOutcomesFinal) {
                System.assert(String.isNotBlank(oppOutcomeFinal.Code__c), 'Blank RPP code on record #' + counter + '.');
            	System.assertEquals('RPP:' + String.valueOf(counter).leftPad(5, '0'), oppOutcomeFinal.Code__c, 'Incorrect RPP code on record #' + counter + '.');
                counter++;
            }
            System.assertEquals(101.0, oppOutcomeCodeAutoNum.Research_Partnership_Project__c, 'Incorrect latest RPP code auto-number value.');
        }
    }
    
    @isTest
    private static void createINPRecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                TestDataFactory.createTestOpportunityOutcomeRecords(1, 'IPU Project Sample', OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID),
                false,
                AccessLevel.USER_MODE
                );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            Opportunity_Outcome__c oppOutcomeFinal = OpportunityOutcomesDAO.getRecordsSortByCodeAsc()[0];
            System.assert(String.isNotBlank(oppOutcomeFinal.Code__c), 'Blank INP code on record.');
            System.assertEquals('INP:00001', oppOutcomeFinal.Code__c, 'Incorrect INP code on record.');
            System.assertEquals(2.0, oppOutcomeCodeAutoNum.IPU_Project__c, 'Incorrect latest INP code auto-number value.');
        }
    }
    
    @isTest
    private static void createINPRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                TestDataFactory.createTestOpportunityOutcomeRecords(100, 'IPU Project Sample', OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID),
                false,
                AccessLevel.USER_MODE
                );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomesFinal = OpportunityOutcomesDAO.getRecordsSortByCodeAsc();
            Integer counter = 1;
            for(Opportunity_Outcome__c oppOutcomeFinal : oppOutcomesFinal) {
                System.assert(String.isNotBlank(oppOutcomeFinal.Code__c), 'Blank INP code on record #' + counter + '.');
            	System.assertEquals('INP:' + String.valueOf(counter).leftPad(5, '0'), oppOutcomeFinal.Code__c, 'Incorrect INP code on record #' + counter + '.');
                counter++;
            }
            System.assertEquals(101.0, oppOutcomeCodeAutoNum.IPU_Project__c, 'Incorrect latest INP code auto-number value.');
        }
    }
    
    @isTest
    private static void createRCPRecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                TestDataFactory.createTestOpportunityOutcomeRecords(1, 'Research Commercialisation Project Sample', OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID),
                false,
                AccessLevel.USER_MODE
                );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            Opportunity_Outcome__c oppOutcomeFinal = OpportunityOutcomesDAO.getRecordsSortByCodeAsc()[0];
            System.assert(String.isNotBlank(oppOutcomeFinal.Code__c), 'Blank RCP code on record.');
            System.assertEquals('RCP:00001', oppOutcomeFinal.Code__c, 'Incorrect RCP code on record.');
            System.assertEquals(2.0, oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c, 'Incorrect latest RCP code auto-number value.');
        }
    }
    
    @isTest
    private static void createRCPRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                TestDataFactory.createTestOpportunityOutcomeRecords(100, 'Research Commercialisation Project Sample', OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID),
                false,
                AccessLevel.USER_MODE
                );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomesFinal = OpportunityOutcomesDAO.getRecordsSortByCodeAsc();
            Integer counter = 1;
            for(Opportunity_Outcome__c oppOutcomeFinal : oppOutcomesFinal) {
                System.assert(String.isNotBlank(oppOutcomeFinal.Code__c), 'Blank RCP code on record #' + counter + '.');
            	System.assertEquals('RCP:' + String.valueOf(counter).leftPad(5, '0'), oppOutcomeFinal.Code__c, 'Incorrect RCP code on record #' + counter + '.');
                counter++;
            }
            System.assertEquals(101.0, oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c, 'Incorrect latest RCP code auto-number value.');
        }
    }
    
    @isTest
    private static void createRCCRecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                TestDataFactory.createTestOpportunityOutcomeRecords(1, 'Start-Up Sample', OpportunityOutcomesDAO.STARTUP_RECTYPE_ID),
                false,
                AccessLevel.USER_MODE
                );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            Opportunity_Outcome__c oppOutcomeFinal = OpportunityOutcomesDAO.getRecordsSortByCodeAsc()[0];
            System.assert(String.isNotBlank(oppOutcomeFinal.Code__c), 'Blank RCC code on record.');
            System.assertEquals('RCC:00001', oppOutcomeFinal.Code__c, 'Incorrect RCC code on record.');
            System.assertEquals(2.0, oppOutcomeCodeAutoNum.Start_Up__c, 'Incorrect latest RCC code auto-number value.');
        }
    }
    
    @isTest
    private static void createRCCRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(
                TestDataFactory.createTestOpportunityOutcomeRecords(100, 'Start-Up Sample', OpportunityOutcomesDAO.STARTUP_RECTYPE_ID),
                false,
                AccessLevel.USER_MODE
                );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomesFinal = OpportunityOutcomesDAO.getRecordsSortByCodeAsc();
            Integer counter = 1;
            for(Opportunity_Outcome__c oppOutcomeFinal : oppOutcomesFinal) {
                System.assert(String.isNotBlank(oppOutcomeFinal.Code__c), 'Blank RCC code on record #' + counter + '.');
            	System.assertEquals('RCC:' + String.valueOf(counter).leftPad(5, '0'), oppOutcomeFinal.Code__c, 'Incorrect RCC code on record #' + counter + '.');
                counter++;
            }
            System.assertEquals(101.0, oppOutcomeCodeAutoNum.Start_Up__c, 'Incorrect latest RCC code auto-number value.');
        }
    }

	@isTest
    private static void createComboRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity_Outcome__c> oppOutcomes = new List<Opportunity_Outcome__c>();
            oppOutcomes.addAll(TestDataFactory.createTestOpportunityOutcomeRecords(10, 'RPP', OpportunityOutcomesDAO.RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID));
            oppOutcomes.addAll(TestDataFactory.createTestOpportunityOutcomeRecords(15, 'INP', OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID));
            oppOutcomes.addAll(TestDataFactory.createTestOpportunityOutcomeRecords(20, 'RCP', OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID));
            oppOutcomes.addAll(TestDataFactory.createTestOpportunityOutcomeRecords(25, 'RCC', OpportunityOutcomesDAO.STARTUP_RECTYPE_ID));
            Test.startTest();
            OpportunityOutcomesDAO.newInstance().insertRecords(oppOutcomes, false, AccessLevel.USER_MODE);
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            System.assertEquals(11, oppOutcomeCodeAutoNum.Research_Partnership_Project__c, 'Incorrect latest RPP code auto-number value.');
            System.assertEquals(16, oppOutcomeCodeAutoNum.IPU_Project__c, 'Incorrect latest INP code auto-number value.');
            System.assertEquals(21, oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c, 'Incorrect latest RCP code auto-number value.');
            System.assertEquals(26, oppOutcomeCodeAutoNum.Start_Up__c, 'Incorrect latest RCC code auto-number value.');
        }
    }
}