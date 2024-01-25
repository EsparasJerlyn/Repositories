/**
 * @description Test class for CustomHeaderContainerCtrl
 *
 * @see CustomHeaderContainerCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                           | Date                  | JIRA                 | Change Summary                                         |
      |-------------------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | neil.s.h.lesidan@accenture.com      | December 20, 2023     | DEPP-7005            | Created file                                           |
*/
@isTest
public with sharing class CustomHeaderContainerCtrlTest {
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
            Test.startTest();

            List<List_Member__c> listMemberRecord = CustomHeaderContainerCtrl.getListMembers(listRec.Id);

            System.assert(!listMemberRecord.isEmpty(), 'No List Member found');
            Test.stopTest();
        }
    }

    @isTest
    static void getListIdEngOpp(){
        List__c listRec = ListsDAO.newInstance().getListRecords(1).iterator().next();
        List<Engagement_Opportunity__c> newEngagementOpportunity = TestDataFactory.createTestEngagementOpportunityRecords(1);
        EngagementOpportunitiesDAO.newInstance().insertRecords(newEngagementOpportunity, false, AccessLevel.USER_MODE);

		List<List__c> listToUpdate = new List<List__c>();
        listToUpdate.add(
            new List__c(
                Id = listRec.id,
                Engagement_Opportunity__c = newEngagementOpportunity[0].id
            )
        );

        ListsDAO.newInstance().updateRecords(listToUpdate, false, AccessLevel.USER_MODE);

        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            List<List__c> listMemberRecord = CustomHeaderContainerCtrl.getListIdEngOpp(newEngagementOpportunity[0].id);
            System.assert(!listMemberRecord.isEmpty(), 'No Engagement Opportunityt record found');
            Test.stopTest();
        }
    }
}