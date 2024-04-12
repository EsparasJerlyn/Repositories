/**
 * @description Test Class for OpportunityContactRoleTriggerHandler
 *
 * @see OpportunityContactRoleTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | Aug 24, 2023          | DEPP-6367    | Created file                                |
*/
@isTest
private class OpportunityContactRoleTriggerHandlerTest {
    
    @testSetup static void setupMethod() {
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Program_Administrator'});
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            acc.Organization_Unit_Level__c = '3';
            insert acc;

            Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
            insert con;

            Contact conProgramLead = TestDataFactory.createTestContactRecords(1).iterator().next();
            conProgramLead.FirstName = 'Program Lead';
            insert conProgramLead;

            Contact conClientDecisionMaker = TestDataFactory.createTestContactRecords(1).iterator().next();
            conClientDecisionMaker.FirstName = 'Client Decision Maker';
            insert conClientDecisionMaker;

            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(50,acc?.Id,con?.Id);
            
            for(Integer i=0;i<oppList.size();i++){
                oppList[i].Lead_School__c = acc?.Id;
                oppList[i].Program_Name__c = 'Test Program Name' + i;
                oppList[i].Description = 'Test Description' + i;
                oppList[i].Amount = 123;
                oppList[i].Client_Budget__c = 123;
                oppList[i].Self_Evaluation__c = 'Yes';
                oppList[i].QUTeX_Capacity__c = 'Yes';
                oppList[i].Faculty_Capacity__c = 'Yes';
                oppList[i].Existing_Relationship__c = 'Yes';
            }
            Test.startTest();
            insert(oppList);

            List<OpportunityContactRole> programLeadRole = TestDataFactory.createTestOpportunityContactRolesRecords(conProgramLead?.Id,oppList);
            for(OpportunityContactRole role: programLeadRole){
                role.Role = 'Program Lead';
                role.IsPrimary = false;
            }
            insert(programLeadRole);

            List<OpportunityContactRole> clientDecisionMakerRole = TestDataFactory.createTestOpportunityContactRolesRecords(conClientDecisionMaker?.Id,oppList);
            for(OpportunityContactRole role: clientDecisionMakerRole){
                role.Role = 'Client Decision-Maker';
                role.IsPrimary = true;
            }
            insert(clientDecisionMakerRole);

            for(Integer i=0;i<oppList.size();i++){
                oppList[i].StageName = 'Proposal';
                oppList[i].Status__c = 'Drafting';
            }

            update(oppList);
            Test.stopTest();
        }
    }  
    
    @isTest
    private static void testOpportunityContactRoleWithContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            Test.startTest();
            List<OpportunityContactRole> clientDecisionMakerRole = [SELECT Id FROM OpportunityContactRole WHERE Role = 'Program Lead' limit 1];
            clientDecisionMakerRole[0].Role = 'Client Decision-Maker';
            
            Database.SaveResult[] srList = Database.update(clientDecisionMakerRole);
            Test.stopTest();
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }
    
    @isTest
    private static void testOpportunityContactRoleChangeRoleContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            Test.startTest();
            List<OpportunityContactRole> clientDecisionMakerRole = [SELECT Id FROM OpportunityContactRole WHERE Role = 'Client Decision-Maker' limit 1];
            clientDecisionMakerRole[0].Role = 'Program Lead';
            
            Database.SaveResult[] srList = Database.update(clientDecisionMakerRole);
            Test.stopTest();
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }  
}