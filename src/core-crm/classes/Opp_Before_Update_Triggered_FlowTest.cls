/**
 * @description Tests Class for Opportunity_Before_Update_Triggered_Flow
 * @see Opp_Before_Update_Triggered_FlowTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.dayrit@qut.edu.au      | November 03, 2021     | DEPP-745               | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest
public class Opp_Before_Update_Triggered_FlowTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateOpportunityStageToContract(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Account acct = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acct;
    
            Contact cont = TestDataFactory.createTestContactRecords(1).iterator().next();
            insert cont;
    
            List<Opportunity> createOpp = TestDataFactory.createTestOpportunityRecords(100,acct?.Id,cont?.Id);    
            insert createOpp;

            Test.startTest();
            List<Opportunity> getOpp = new List<Opportunity>();
            List<Opportunity> oppRec = new List<Opportunity>([SELECT Id, StageName, Status__c  FROM Opportunity LIMIT 100]);

            for(Opportunity opp : oppRec){
                opp.StageName = 'Contract';
                opp.Status__c = 'Contract Created';
                getOpp.add(opp);
            }
            update getOpp;
        }
        Test.stopTest();
        List<Opportunity> updatedOppList = [SELECT Status__c FROM Opportunity LIMIT 100];
        for(Opportunity checkOpp : updatedOppList){
            System.assertEquals('Pending Contract Creation', checkOpp.Status__c,'the status did not match');
        }

    }
        
        
    }
