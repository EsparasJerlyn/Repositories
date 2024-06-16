/**
 * @description Test Class for Account Sync flow
 *
 * @see ../flows/Account Sync Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                            |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------|
      | kathy.cornejo	          | June 12, 2022         | DEPP-2991    | Created file                                              |
      | kenneth.f.alsay           | Aug 4, 2023           | DEPP-6304    | Added accountShare for testUser to access account records |
*/
@isTest
public class AccountSyncFlowTest {
    @testSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        
        for(Account a : accounts){
            a.Sync_To_MC__c = true;
            a.Do_Not_Sync_To_MC_Override__c = true;
        }
        
        AccountsDAO.newInstance().insertRecords(accounts, false, AccessLevel.USER_MODE);

        List<AccountShare> accShare = TestDataFactory.createAccountShareRecords(accounts, TestDataFactoryUser.selectUserQUTeXProgramAdministrator.Id, 'Edit');
        insert accShare;
    }
    
    @isTest
    public static void updateSyncTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        Test.startTest();
       	List<Account> accountsToUpdate = [Select Id, Sync_To_MC__c, Do_Not_Sync_To_MC_Override__c FROM Account];
        	for(Account a: accountsToUpdate){
                a.Sync_To_MC__c = false;
                a.Do_Not_Sync_To_MC_Override__c = false;
        	}
        update accountsToUpdate;
        Test.stopTest();       
    	
        System.assert(![SELECT Id FROM Account Where Sync_To_MC__c = false].isEmpty(), 'Sync to MC must be false');
        System.assert(![SELECT Id FROM Account Where Do_Not_Sync_To_MC_Override__c = false].isEmpty(), 'Do Not Sync to MC must be false');   

        }
    }
}