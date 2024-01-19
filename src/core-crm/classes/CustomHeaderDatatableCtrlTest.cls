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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager','QUT_Alumni_Engagement_Manager' });

        List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);

        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(1,newListRecords[0].id,newContacts[0].id);
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);

        System.runAs(TestDataFactory.getQUTAlumniEngagementManager()) {
            List<Engagement_Opportunity__c> engagementOppList = TestDataFactory.createTestEngagementOpportunityRecords(1);
            for(Engagement_Opportunity__c enOpp : engagementOppList){
                enOpp.RecordTypeId = EngagementOpportunitiesDAO.ALUMNI_ENGAGEMENT_RECTYPE_ID;
            }
            EngagementOpportunitiesDAO.newInstance().insertRecords(engagementOppList, false, AccessLevel.USER_MODE);

            Engagement_Opportunity__c enOppRec = EngagementOpportunitiesDAO.newInstance().getEngagementOpportunityRecords(1,AccessLevel.USER_MODE).iterator().next();
            List<List__c> listRecords = TestDataFactory.createListRecords(1);
            for(List__c rec : listRecords){
                rec.Engagement_Opportunity__c = enOppRec.Id;
            }
            
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        }
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
    static void getEngagementOpportunityListIdTest(){
        Engagement_Opportunity__c enOppRec = EngagementOpportunitiesDAO.newInstance().getEngagementOpportunityRecords(1,AccessLevel.USER_MODE).iterator().next();
        System.runAs(TestDataFactory.getQUTAlumniEngagementManager()) {
            Test.startTest();

            Id listId = CustomHeaderDatatableCtrl.getEngagementOpportunityListId(enOppRec.Id);
            System.assert(listId != null, 'No List record found');

            Test.stopTest();
        }
    }
}