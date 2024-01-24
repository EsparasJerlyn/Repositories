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
*/
@isTest
public with sharing class CustomHeaderDatatableCtrlTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(1,newListRecords[0].id,newContacts[0].id);
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
    }

    @isTest
    static void getListMembersTest(){
        Contact con = ContactsDAO.getPersonContactsWithLimit(1).iterator().next();
        List__c listRec = ListsDAO.newInstance().getListRecords(1).iterator().next();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(10,con.Id,listRec.Id);
            Test.startTest();

            Database.SaveResult[] srList = ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);

            List<List_Member__c> listMemberRecord = CustomHeaderDatatableCtrl.getListMembers(listRec.Id);
            System.assert(!listMemberRecord.isEmpty(), 'No List Member found');

            Test.stopTest();
        }
    }
}