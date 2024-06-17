/**
 * @description Tests Class for Update Opp CloseDate Flow
 * @see Update_Opp_CloseDate_FlowTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.dayrit@qut.edu.au      | November 10, 2022     | DEPP-4653              | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest
public class Update_Opp_CloseDate_FlowTest {
    
    @TestSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
    }

    @isTest
    private static void updateOppCloseDateTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Account acct = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acct;
    
            Contact cont = TestDataFactory.createTestContactRecords(1).iterator().next();
            insert cont;
    
            List<Opportunity> createOpp = TestDataFactory.createTestOpportunityRecords(100,acct?.Id,cont?.Id);
            for(Opportunity oppty : createOpp){
                oppty.StageName = 'New';
            }
            insert createOpp;
               

            Test.startTest();
            List<Opportunity> oppRec = new List<Opportunity>([SELECT Id, StageName, Status__c  FROM Opportunity LIMIT 100]);

            for(Opportunity opp : oppRec){
                opp.StageName = 'Closed Won';
                opp.Status__c = 'Contract Signed';
            }
            update oppRec;
        }
        Test.stopTest();
        List<Opportunity> updatedOppList = [SELECT CloseDate FROM Opportunity LIMIT 100];
        for(Opportunity checkOpp : updatedOppList){
            System.assertEquals(date.today(), checkOpp.CloseDate, 'The Date did not match');
        }
    }
}
