/**
 * @description Test Class for List Custom Validation flow
 *
 * @see ../flows/List Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                            |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------|
      | jerlyn.esparas            | March 12,2024         | DEPP-7944    | created file                                              |
*/
@isTest
public class List_Custom_Validation_Flow_Test {
	
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager'});
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<List__c> listRecords = TestDataFactory.createListRecords(1);
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            ListsDAO.newInstance().insertRecords(listRecords, false, AccessLevel.USER_MODE);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            List<List_Member__c> newListMemberRec = new List<List_Member__c>();
            List<List_Member__c> listMemberRecords = TestDataFactory.createListMemberRecords(1,listRecords[0].id,newContacts[0].Id);

            for(List_Member__c listMem : listMemberRecords){
                listMem.List_Member_Status__c = 'Qualified';
                newListMemberRec.add(listMem);
            }
            ListMembersDAO.newInstance().insertRecords(newListMemberRec, false, AccessLevel.USER_MODE);                        
        }
    }

    @isTest
    public static void checkListMemberStatusOnHold(){
        System.runAs(TestDataFactory.getAdvancementManager()){

            List<List__c> listRecords = ListsDAO.newInstance().getListRecords(1);
            List<List_Member__c> newListMemberRec = ListMembersDAO.newInstance().getListMembersByListIdAndStatus(new Set<Id>{listRecords[0].Id},'Qualified', AccessLevel.USER_MODE);
            
            Test.startTest();
            for(List_Member__c listMemRec : newListMemberRec){
                listMemRec.List_Member_Status__c = 'On Hold';
            }
            ListMembersDAO.newInstance().updateRecords(newListMemberRec, false, AccessLevel.USER_MODE);
            Test.stopTest();
            listRecords[0].Stage__c = 'Distribute';
            Database.SaveResult[] srList = ListsDAO.newInstance().updateRecords(listRecords, false, AccessLevel.USER_MODE);
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was saved.'); 
            }
        }
    }
}