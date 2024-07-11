/**
 * @description Tests the Opportunity to Product Specification flow
 *
 * @see Opportunity_to_Program_Specs_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | adrian.c.habasa           | November 04, 2021     | DEPP-743 | Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest
public with sharing class Opp_to_Product_Specification_flowTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void closedWonOppTest()
    {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
            Test.startTest();
                List<Account> acc = new List<Account>();
                List<Contact> con = new List<Contact>();
                List<Opportunity> opp = new List<Opportunity>();
                List<OpportunityContactRole> progLeadRole = new List<OpportunityContactRole>();

                acc = TestDataFactory.createTestAccountRecords(1);
                insert acc;
            
                con = TestDataFactory.createTestContactRecords(1);
                insert con;

                opp= TestDataFactory.createTestOpportunityRecords(100,acc[0].Id,con[0].Id);
                for(Integer i=0;i<opp.size();i++){
                    
                    opp[i].Program_Name__c = 'Test Program Name' + i;
                    opp[i].StageName = 'Closed Won';
                }
                insert(opp);
                
                Contact conProgramLead = TestDataFactory.createTestContactRecords(1).iterator().next();
                conProgramLead.FirstName = 'Program Lead';
                insert conProgramLead;

                progLeadRole = TestDataFactory.createTestOpportunityContactRolesRecords(conProgramLead?.Id,opp);
                for(OpportunityContactRole programRole: progLeadRole)
                {
                    programRole.Role= 'Program Lead';
                    programRole.IsPrimary = true;
                }
                insert progLeadRole;

                List<Opportunity> opps = [SELECT id FROM Opportunity LIMIT 100];
                for(Opportunity newOpp: opps)
                {
                    newOpp.Amount = 123;
                }
                update(opps);
    
            Test.stopTest();
            System.assert(![SELECT Id FROM Product_Specification__c WHERE Opportunity_Name__c IN :opp].isEmpty(),'No Product Specification Record Created');
        }
    }

   
}
