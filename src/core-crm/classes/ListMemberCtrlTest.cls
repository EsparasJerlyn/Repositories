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
public class ListMemberCtrlTest {
@testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Alumni_Engagement_Manager' });
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(100,newListRecords[0].id,newContacts[0].id);
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
    }
    
    @isTest
    static void updateListMemberStatusTest(){
        System.runAs(TestDataFactory.getQUTAlumniEngagementManager()){
            List<List_Member__c> listMemberRecords = [SELECT Id, List_Member_Status__c FROM List_Member__c LIMIT 100];
            Test.startTest();
            ListMemberStatusModalCtrl.updateListMemberStatus(listMemberRecords, 'Qualified');
            List<List_Member__c> updatedListMemberRecords = [SELECT Id FROM List_Member__c WHERE List_Member_Status__c = 'Qualified'];
            System.assert(!updatedListMemberRecords.isEmpty(), 'No List Member found');
            Test.stopTest();
        }
    }

}