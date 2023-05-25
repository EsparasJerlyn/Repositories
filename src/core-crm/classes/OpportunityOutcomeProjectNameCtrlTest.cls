/**
 * @description Test class for OpportunityOutcomeProjectNameCtrl.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 15, 2023          | DEPP-5594              | created file
 */
@isTest
public with sharing class OpportunityOutcomeProjectNameCtrlTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
        insert new Opportunity(
            Name = 'XXX: Sample', 
            StageName = 'Qualify', 
            CloseDate = System.today() + 50, 
            OwnerId = TestDataFactory.getProgramAdminUser().Id
        );
        Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
        oppOutcomeCodeAutoNum.Research_Partnership_Project__c = 1;
        oppOutcomeCodeAutoNum.IPU_Project__c = 1;
        oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c = 1;
        oppOutcomeCodeAutoNum.Start_Up__c = 1;
        insert oppOutcomeCodeAutoNum;
    }
    
    @isTest
    private static void createRPPRecord() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Opportunity_Outcome__c opptyOutcome = createSampleOpptyOutcome(OpportunityOutcomesDAO.RT_OPPTYOC_RPP_ID);
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Opportunity_Outcome__c opptyOutcome = createSampleOpptyOutcome(OpportunityOutcomesDAO.RT_OPPTYOC_INP_ID);
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Opportunity_Outcome__c opptyOutcome = createSampleOpptyOutcome(OpportunityOutcomesDAO.RT_OPPTYOC_RCP_ID);
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Opportunity_Outcome__c opptyOutcome = createSampleOpptyOutcome(OpportunityOutcomesDAO.RT_OPPTYOC_RCC_ID);
            Test.startTest();
            insert opptyOutcome;
            Opportunity_Outcome__c opptyOutcomeFinal = [SELECT Id, Project_Name__c FROM Opportunity_Outcome__c LIMIT 1];
            Test.stopTest();
            System.assert(!String.isBlank(opptyOutcomeFinal.Project_Name__c), 'Failed to auto generate project name.');
            System.assertEquals('RCC: Sample', opptyOutcomeFinal.Project_Name__c, 'Incorrect project name.');
        }
    }
    
    private static Opportunity_Outcome__c createSampleOpptyOutcome(Id recordTypeId) {
        Id opptyId = [SELECT Id FROM Opportunity WHERE Name = 'XXX: Sample' LIMIT 1].Id;
        return new Opportunity_Outcome__c(
            Company_Name__c = 'Sample Company',
            Opportunity__c = opptyId,
            RecordTypeId = recordTypeId
        );
    }
}