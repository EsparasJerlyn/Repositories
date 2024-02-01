/**
* @description Test class for CustomHeaderDatatableCtrl
*
* @see CustomHeaderDatatableCtrl
*
* @author Accenture
*
* @history
*    | Developer                           | Date                  | JIRA                 | Change Summary                                         |
     |-------------------------------------|-----------------------|----------------------|--------------------------------------------------------|
     | neil.s.h.lesidan@accenture.com      | December 20, 2023     | DEPP-6963            | Created file                                           |
     | kenneth.f.alsay                     | January 15, 2024      | DEPP-6964            | Added method - updateListMemberStatusTest              |
     | kenneth.f.alsay                     | January 29, 2024      | DEPP-6964            | Utilized DAOMock                                       |
*/
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
public with sharing class CustomHeaderDatatableCtrlTest {
    @isTest
    static void getListMembersTest(){
        ImplementationSelector.DAO.setMock(new ListMembersDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
        
        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(10,newListRecords[0].id,newContacts[0].id);
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
        Test.startTest();
        
        Database.SaveResult[] srList = ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
        
        List<List_Member__c> listMemberRecord = CustomHeaderDatatableCtrl.getListMembers(newListRecords[0].Id);
        System.assert(!listMemberRecord.isEmpty(), 'No List Member found');
        
        Test.stopTest();
    }
    
    @isTest
    static void updateListMemberStatusTest(){
        ImplementationSelector.DAO.setMock(new ListMembersDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
        
        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(1,newListRecords[0].id,newContacts[0].id);
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
        
        List<List_Member__c> listMemberRecords = ListMembersDAO.newInstance().getListMembersByStatus(100, AccessLevel.SYSTEM_MODE, '');
        
        for(List_Member__c listMember : newListMemberRecords){
            listMember.List_Member_Status__c = 'Qualified';
        }
        
        Test.startTest();
        CustomHeaderDatatableCtrl.updateListMemberStatus(newListMemberRecords);
        List<List_Member__c> updatedListMemberRecords = ListMembersDAO.newInstance().getListMembersByStatus(100, AccessLevel.SYSTEM_MODE, 'Qualified');
        System.assert(!updatedListMemberRecords.isEmpty(), 'No List Member found');
        Test.stopTest();
    }
}