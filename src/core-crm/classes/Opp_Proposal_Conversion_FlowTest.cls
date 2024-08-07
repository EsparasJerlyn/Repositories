/**
 * @description Tests the Opportunity Proposal Conversion Triggered Flow  
 *
 * @see Opportunity_Proposal_Conversion_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | adrian.c.habasa           | November 03, 2021     | DEPP-742 | Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest 
private with sharing class Opp_Proposal_Conversion_FlowTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateOpportunityRecordTest()
    {
       System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
       {
        Test.startTest();
            List<Account> acc = new List<Account>();
            List<Contact> con = new List<Contact>();
            List<Opportunity> opp = new List<Opportunity>();
            List<Opportunity> oppNoRole = new List<Opportunity>();
            List<OpportunityContactRole> progLeadRole = new List<OpportunityContactRole>();
            List<OpportunityContactRole> clientDecRole = new List<OpportunityContactRole>();


            acc = TestDataFactory.createTestAccountRecords(1);
            insert acc;
        
            con = TestDataFactory.createTestContactRecords(1);
            insert con;

            opp= TestDataFactory.createTestOpportunityRecords(50,acc[0].Id,con[0].Id);
            insert opp;

            oppNoRole= TestDataFactory.createTestOpportunityRecords(50,acc[0].Id,con[0].Id);
            insert oppNoRole;

            Contact conProgramLead = TestDataFactory.createTestContactRecords(1).iterator().next();
            conProgramLead.FirstName = 'Program Lead';
            insert conProgramLead;

            Contact conClientDecisionMaker = TestDataFactory.createTestContactRecords(1).iterator().next();
            conClientDecisionMaker.FirstName = 'Client Decision Maker';
            insert conClientDecisionMaker;

            progLeadRole = TestDataFactory.createTestOpportunityContactRolesRecords(conProgramLead?.Id,opp);
            for(OpportunityContactRole programRole: progLeadRole)
            {
                programRole.Role= 'Program Lead';
                programRole.IsPrimary = false;
            }
            insert progLeadRole;

            clientDecRole = TestDataFactory.createTestOpportunityContactRolesRecords(conClientDecisionMaker?.Id,opp);
            for(OpportunityContactRole clientRole: clientDecRole)
            {
                clientRole.Role= 'Client Decision-Maker	';
                clientRole.IsPrimary = true;
            }
            insert clientDecRole;

            List<Opportunity> opps =[SELECT Id,Name FROM Opportunity LIMIT 100];
            for(Opportunity newOpp : opps)
            {
                newOpp.Faculty_Capacity__c = 'Yes';
            }
            update(opps);
        Test.stopTest();

        System.assert(![SELECT Has_Proposal_Opportunity_Role__c FROM Opportunity WHERE Has_Proposal_Opportunity_Role__c =true].isEmpty(),'No Opportunity Contact Role');
        System.assert(![SELECT Has_Proposal_Opportunity_Role__c FROM Opportunity WHERE Has_Proposal_Opportunity_Role__c =false].isEmpty(),'Has Program Lead and Client Decision-Maker Opportunity Contact Role');
       }
    }


}
