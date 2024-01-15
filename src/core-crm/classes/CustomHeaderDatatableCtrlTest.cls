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
*/
@isTest
public with sharing class CustomHeaderDatatableCtrlTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager', 'QUT_Alumni_Engagement_Manager' });
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
    
    @isTest
    static void updateListMemberStatusTest(){
        System.runAs(TestDataFactory.getQUTAlumniEngagementManager()){
            List<List_Member__c> listMemberRecords = [SELECT Id, List_Member_Status__c FROM List_Member__c];
            for(List_Member__c listMember : listMemberRecords){
                listMember.List_Member_Status__c = 'Qualified';
            }
            Test.startTest();
            CustomHeaderDatatableCtrl.updateListMemberStatus(listMemberRecords);
            List<List_Member__c> updatedListMemberRecords = [SELECT Id FROM List_Member__c WHERE List_Member_Status__c = 'Qualified'];
            System.assert(!updatedListMemberRecords.isEmpty(), 'No List Member found');
            Test.stopTest();
        }
    }
}