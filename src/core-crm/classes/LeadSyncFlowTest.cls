/**
 * @description Test Class for Lead Sync flow
 *
 * @see ../flows/Lead Sync Flow
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
public class LeadSyncFlowTest {
	private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTeX).iterator().next();
    
    @isTest
    public static void updateSyncTest(){
        List<Lead> leads = new List<Lead>();
        List<Account> accs = new List<Account>();

        System.runAs(currentUser){
            leads = TestDataFactory.createTestLeadRecords(100);
            accs = TestDataFactory.createTestAccountRecords(1);
            
            insert accs;

            for(Lead l : leads){
                l.Sync_To_MC__c = true;
                l.Do_Not_Sync_To_MC_Override__c = true;
            }

            insert leads;
            
        Test.startTest();
       	List<Lead> leadsToUpdate = new List<Lead>([Select Id FROM Lead]);
        	for(Lead l: leadsToUpdate){
                l.Sync_To_MC__c = false;
                l.Do_Not_Sync_To_MC_Override__c = false;
        	}
        update(leadsToUpdate);
        Test.stopTest();       
    	}
        system.assert(![SELECT Id FROM Lead Where Sync_To_MC__c = false].isEmpty(), 'Sync to MC must be false');
        system.assert(![SELECT Id FROM Lead Where Do_Not_Sync_To_MC_Override__c = false].isEmpty(), 'Do Not Sync to MC must be false');
    }
}