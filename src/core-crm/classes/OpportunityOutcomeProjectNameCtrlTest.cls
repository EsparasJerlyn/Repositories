/**
 * @description Test class for OpportunityOutcomeProjectNameCtrl.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | alexander.cadalin              | May 15, 2023          | DEPP-5594              | created file                 |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Fixed test method failures   |
 * 	  | kenneth.f.alsay                | August 24, 2023       | DEPP-6250              | Updated Test Opportunity name|
 */
@isTest
public with sharing class OpportunityOutcomeProjectNameCtrlTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Operations_Manager' });

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

        insert new Opportunity(
            Name = 'RPO: Sample', 
            StageName = 'Qualify', 
            CloseDate = System.today() + 50, 
            OwnerId = TestDataFactory.getOperationsManager().Id
        );

        Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        oppOutcomeCodeAutoNum.Research_Partnership_Project__c = 1;
        oppOutcomeCodeAutoNum.IPU_Project__c = 1;
        oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c = 1;
        oppOutcomeCodeAutoNum.Start_Up__c = 1;
        insert oppOutcomeCodeAutoNum;
    }
    
    @isTest
    private static void createRPPRecord() {
        System.runAs(TestDataFactory.getOperationsManager()) {
            Opportunity_Outcome__c opptyOutcome = createSampleOpptyOutcome(OpportunityOutcomesDAO.RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID);
            Test.startTest();
            insert opptyOutcome;
            Opportunity_Outcome__c opptyOutcomeFinal = [SELECT Id, Project_Name__c FROM Opportunity_Outcome__c LIMIT 1];
            Test.stopTest();
            System.assert(!String.isBlank(opptyOutcomeFinal.Project_Name__c), 'Failed to auto generate project name.');
            System.assertEquals('RPP: Sample', opptyOutcomeFinal.Project_Name__c, 'Incorrect project name.');
        }
    }
    
    @isTest
    private static void createINPRecord() {
        System.runAs(TestDataFactory.getOperationsManager()) {
            Opportunity_Outcome__c opptyOutcome = createSampleOpptyOutcome(OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID);
            Test.startTest();
            insert opptyOutcome;
            Opportunity_Outcome__c opptyOutcomeFinal = [SELECT Id, Project_Name__c FROM Opportunity_Outcome__c LIMIT 1];
            Test.stopTest();
            System.assert(!String.isBlank(opptyOutcomeFinal.Project_Name__c), 'Failed to auto generate project name.');
            System.assertEquals('INP: Sample', opptyOutcomeFinal.Project_Name__c, 'Incorrect project name.');
        }
    }
    
    @isTest
    private static void createRCPRecord() {
        System.runAs(TestDataFactory.getOperationsManager()) {
            Opportunity_Outcome__c opptyOutcome = createSampleOpptyOutcome(OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID);
            Test.startTest();
            insert opptyOutcome;
            Opportunity_Outcome__c opptyOutcomeFinal = [SELECT Id, Project_Name__c FROM Opportunity_Outcome__c LIMIT 1];
            Test.stopTest();
            System.assert(!String.isBlank(opptyOutcomeFinal.Project_Name__c), 'Failed to auto generate project name.');
            System.assertEquals('RCP: Sample', opptyOutcomeFinal.Project_Name__c, 'Incorrect project name.');
        }
    }
    
    @isTest
    private static void createRCCRecord() {
        System.runAs(TestDataFactory.getOperationsManager()) {
            Opportunity_Outcome__c opptyOutcome = createSampleOpptyOutcome(OpportunityOutcomesDAO.STARTUP_RECTYPE_ID);
            Test.startTest();
            insert opptyOutcome;
            Opportunity_Outcome__c opptyOutcomeFinal = [SELECT Id, Project_Name__c FROM Opportunity_Outcome__c LIMIT 1];
            Test.stopTest();
            System.assert(!String.isBlank(opptyOutcomeFinal.Project_Name__c), 'Failed to auto generate project name.');
            System.assertEquals('RCC: Sample', opptyOutcomeFinal.Project_Name__c, 'Incorrect project name.');
        }
    }
    
    private static Opportunity_Outcome__c createSampleOpptyOutcome(Id recordTypeId) {
        Id opptyId = [SELECT Id FROM Opportunity WHERE Name = 'RPO: Sample' LIMIT 1].Id;
        return new Opportunity_Outcome__c(
            Company_Name__c = 'Sample Company',
            Opportunity__c = opptyId,
            RecordTypeId = recordTypeId
        );
    }
}