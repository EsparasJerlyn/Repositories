/**
 * @description Test class for CustomHeaderDatatableCtrl
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
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Alumni_Engagement_Manager' });
        System.runAs(TestDataFactory.getQUTAlumniEngagementManager()) {
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    static void getContactByIdTest(){
        Contact con = ContactsDAO.getPersonContactsWithLimit(1).iterator().next();

        System.runAs(TestDataFactory.getQUTAlumniEngagementManager()) {
            Test.startTest();
            String ids = (String) con.Id;
            List<Contact> contactsList = ListMemberImportModalCtrl.getContactById(ids);
            System.assert(!contactsList.isEmpty(), 'No Contact found');

            Test.stopTest();
        }
    }

    @isTest
    static void bulkSaveListMemberTest(){
        Contact con = ContactsDAO.getPersonContactsWithLimit(1).iterator().next();
        List__c listRec = ListsDAO.newInstance().getListRecords(1).iterator().next();
        System.runAs(TestDataFactory.getQUTAlumniEngagementManager()) {
            Test.startTest();
            String record = '[{ "List_Member__c": "' + con.Id  + '", "Activity_Status__c": "Accepted" }]';
            Boolean isBulkSave = ListMemberImportModalCtrl.bulkSaveListMember((String) listRec.Id, record);
            System.assert(isBulkSave, 'Error upon saving');

            Test.stopTest();
        }
    }
}