/**
 * @description Tests Class for Opportunity_Create_Opportunity_Contact_Role
 * @see Opp_Create_Opportunity_Contact_RoleTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.dayrit@qut.edu.au      | November 04, 2021     | DEPP-746               | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest
public class Opp_Create_Opportunity_Contact_RoleTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void createOpptyContactRole(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Account acct = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acct;
    
            Contact cont = TestDataFactory.createTestContactRecords(1).iterator().next();
            insert cont;
    
            List<Opportunity> createOpp = TestDataFactory.createTestOpportunityRecords(100,acct?.Id,cont?.Id);    
            insert createOpp;
    
        }
        Test.stopTest();
        List<OpportunityContactRole> createdOppConRoleList = [SELECT OpportunityId, IsPrimary, Role FROM OpportunityContactRole LIMIT 100];
        for(OpportunityContactRole checkOppConRole : createdOppConRoleList){

            System.assertEquals(100,createdOppConRoleList.size(),'the size did not match');
            System.assertEquals(True, checkOppConRole.IsPrimary,'the primary field did not match');
            System.assertEquals('Client Decision-Maker', checkOppConRole.Role,'the Role did not match');
        }

    }
        
        
    }
