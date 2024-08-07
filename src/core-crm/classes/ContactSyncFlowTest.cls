/**
 * @description Test Class for Contact Sync flow
 *
 * @see ../flows/Contact Sync Flow
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
public class ContactSyncFlowTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }
    
    @isTest
    public static void updateSyncTest(){
        List<Contact> contacts = new List<Contact>();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            contacts = TestDataFactory.createTestContactRecords(100);

            for(Contact c : contacts){
                c.Sync_To_MC__c = true;
                c.Do_Not_Sync_To_MC_Override__c = true;
            }

            insert contacts;
            
        Test.startTest();
       	List<Contact> contactsToUpdate = new List<Contact>([Select Id FROM Contact]);
        	for(Contact c: contactsToUpdate){
                c.Sync_To_MC__c = false;
                c.Do_Not_Sync_To_MC_Override__c = false;
        	}
        update(contactsToUpdate);
        Test.stopTest();       
    	}
        system.assert(![SELECT Id FROM Contact Where Sync_To_MC__c = false].isEmpty(), 'Sync to MC must be false');
        system.assert(![SELECT Id FROM Contact Where Do_Not_Sync_To_MC_Override__c = false].isEmpty(), 'Do Not Sync to MC must be false');
    }
}