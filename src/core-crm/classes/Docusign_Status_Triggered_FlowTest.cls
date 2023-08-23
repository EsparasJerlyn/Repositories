/**
 * @description Tests the Docusign_Status_Triggered_Flow
 *
 * @see Docusign_Status_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | roy.nino.s.regala         | November 03, 2021     | DEPP-736 | Created file                    | 
      | rhea.b.torres             | June 05, 2023         |          | Fix All Test Class pipeline     |
      |                           |                       |          | error to run as proper persona  |
      | carl.alvin.cabiles        | August 16,2023        |          | Fix test class error            |
*/

@isTest
private class Docusign_Status_Triggered_FlowTest {

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
    private static void docuSignStatusTest(){
        Test.startTest();
        List<Opportunity> oppRecs = [Select Id FROM Opportunity];
        List<dfsle__EnvelopeStatus__c> docuSignStatuses = TestDataFactory.createTestEnvelopeStatusRecords(oppRecs,'Sent');
        
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            insert(docuSignStatuses);
            system.assert(![SELECT Id FROM Opportunity Where Status__c = 'Under Client Review'].isEmpty(), 'Status should be updated');

            for(Integer i=0;i<docuSignStatuses.size();i++){
                docuSignStatuses[i].dfsle__Status__c = 'Declined';
            }
            update(docuSignStatuses);
            system.assert(![SELECT Id FROM Opportunity Where Status__c = 'Client Rejects Proposal'].isEmpty(), 'Status should be updated');

            for(Integer i=0;i<docuSignStatuses.size();i++){
                docuSignStatuses[i].dfsle__Status__c = 'Completed';
            }
            update(docuSignStatuses);
            system.assert(![SELECT Id FROM Opportunity Where Status__c = 'Client Approved'].isEmpty(), 'Status should be updated');

        }
        
        Test.stopTest();
    } 
}