/**
* @description Tests Controller Class for ListMemberCtrl
* @see ListMemberCtrl
*
* @author Accenture
*
* @history
*
*    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
*    |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
*    | kenneth.f.alsay                | January 12, 2024      | DEPP-6964              | Created file                                      |
*/
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
public class ListMemberCtrlTest {
    @isTest
    static void updateListMemberStatusTest(){
        ImplementationSelector.DAO.setMock(new ListMembersDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(100,newListRecords[0].id,newContacts[0].id);
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);             
        Test.startTest();
        ListMemberCtrl.updateListMemberStatus(newListMemberRecords, 'Qualified', false);
        List<List_Member__c> updatedListMemberRecordsFalse = ListMembersDAO.newInstance().getListMembersByStatus(100, AccessLevel.SYSTEM_MODE, 'Qualified');
        System.assert(!updatedListMemberRecordsFalse.isEmpty(), 'No List Member found');
        ListMemberCtrl.updateListMemberStatus(newListMemberRecords, 'Accepted', true);
        List<List_Member__c> updatedListMemberRecordsTrue = ListMembersDAO.newInstance().getListMembersByActivityStatus(100, 'Accepted', AccessLevel.USER_MODE);
        System.assert(!updatedListMemberRecordsFalse.isEmpty(), 'No List Member found');
        Test.stopTest();
    }
}