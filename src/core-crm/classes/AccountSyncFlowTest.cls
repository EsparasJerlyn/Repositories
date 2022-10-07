/**
 * @description Test Class for Account Sync flow
 *
 * @see ../flows/Account Sync Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | kathy.cornejo	          | June 12, 2022         | DEPP-2991    | Created file                                |
      |                           |                       |              |                                             |
*/
@isTest
public class AccountSyncFlowTest {
	private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTeX).iterator().next();
    
    @isTest
    public static void updateSyncTest(){
        List<Account> accounts = new List<Account>();

        System.runAs(currentUser){
            accounts = TestDataFactory.createTestAccountRecords(100);

            for(Account a : accounts){
                a.Sync_To_MC__c = true;
                a.Do_Not_Sync_To_MC_Override__c = true;
            }

            insert accounts;
            
        Test.startTest();
       	List<Account> accountsToUpdate = new List<Account>([Select Id FROM Account]);
        	for(Account a: accountsToUpdate){
                a.Sync_To_MC__c = false;
                a.Do_Not_Sync_To_MC_Override__c = false;
        	}
        update(accountsToUpdate);
        Test.stopTest();       
    	}
        system.assert(![SELECT Id FROM Account Where Sync_To_MC__c = false].isEmpty(), 'Sync to MC must be false');
        system.assert(![SELECT Id FROM Account Where Do_Not_Sync_To_MC_Override__c = false].isEmpty(), 'Do Not Sync to MC must be false');
    }
}