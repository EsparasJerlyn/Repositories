/**
 * @description Test class for ListMemberImportModalCtrl
 *
 * @see ListMemberImportModalCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                           | Date                  | JIRA                 | Change Summary                                         |
      |-------------------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | neil.s.h.lesidan@accenture.com      | December 20, 2023     | DEPP-7005            | Created file                                           |
*/
@isTest
public with sharing class ListMemberImportModalCtrlTest {
    @isTest
    static void getContactByIdTest(){
        ImplementationSelector.DAO.setMock(new ListMembersDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        Test.startTest();
        String ids = (String) newContacts[0].Id;
        List<Contact> contactsList = ListMemberImportModalCtrl.getContactById(ids);
        System.assert(!contactsList.isEmpty(), 'No Contact found');
        Test.stopTest();
    }

    @isTest
    static void getListContributorByIdsTest(){
        ImplementationSelector.DAO.setMock(new ListsDAOMock());
        ImplementationSelector.DAO.setMock(new ListContributorsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);

        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        List<List_Contributor__c> newListContributors = TestDataFactory.createListContributorRecords(1, newListRecords[0].Id);
        ListContributorsDAO.newInstance().insertRecords(newListContributors, false, AccessLevel.USER_MODE);

        Test.startTest();
        List<List_Contributor__c> listContributorRecords = ListMemberImportModalCtrl.getListContributorByIds(newListRecords[0].Id, (String) newListContributors[0].Id);
        System.assert(!listContributorRecords.isEmpty(), 'No List Contributor Found');

        Test.stopTest();
    }

    @isTest
    static void bulkSaveListMemberTest(){
        ImplementationSelector.DAO.setMock(new ListsDAOMock());
        ImplementationSelector.DAO.setMock(new ListMembersDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(1,newListRecords[0].id, newContacts[0].id);
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);

        Test.startTest();
        Boolean isBulkSave = ListMemberImportModalCtrl.bulkSaveListMember(newListMemberRecords);
        System.assert(isBulkSave, 'Error saving record');

        Test.stopTest();
    }
}