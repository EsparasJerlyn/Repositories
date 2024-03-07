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
     | neil.s.h.lesidan                    | December 20, 2023     | DEPP-6963            | Created file                                           |
     | kenneth.f.alsay                     | January 15, 2024      | DEPP-6964            | Added method - updateListMemberStatusTest              |
     | kenneth.f.alsay                     | January 29, 2024      | DEPP-6964            | Utilized DAOMock                                       |
     | neil.s.h.lesidan                    | Feb 2, 2024           | DEPP-7005            | Add method getListIdEngOppTest                         |
     | kenneth.f.alsay                     | February 12, 2024     | DEPP-6953            | Added method getListMembersByListIdAndStatus           |
     | kenneth.f.alsay                     | Ferbruary 15, 2024    | DEPP-8040            | Added method getAllListContributors                    |
*/
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
public with sharing class CustomHeaderContainerCtrlTest {
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

        List<List_Member__c> listMemberRecord = CustomHeaderContainerCtrl.getListMembers(newListRecords[0].Id);
        System.assert(!listMemberRecord.isEmpty(), 'No List Member found');

        Test.stopTest();
    }

    @isTest
    static void getListIdEngOppTest(){
        ImplementationSelector.DAO.setMock(new ListMembersDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(1,newListRecords[0].id,newContacts[0].id);
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);

        List<Engagement_Opportunity__c> newEngagementOpportunity = TestDataFactory.createTestEngagementOpportunityRecords(1);
        EngagementOpportunitiesDAO.newInstance().insertRecords(newEngagementOpportunity, false, AccessLevel.USER_MODE);

        List<List__c> listToUpdate = new List<List__c>();
        listToUpdate.add(
            new List__c(
                Id = newListRecords[0].id,
                Engagement_Opportunity__c = newEngagementOpportunity[0].id
            )
        );

        Test.startTest();
        List<List__c> listMemberRecord = CustomHeaderContainerCtrl.getListIdEngOpp(newEngagementOpportunity[0].id);
        System.assert(!listMemberRecord.isEmpty(), 'No Engagement Opportunityt record found');
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

        for(List_Member__c listMember : newListMemberRecords){
            listMember.List_Member_Status__c = 'Qualified';
        }

        Test.startTest();
        CustomHeaderContainerCtrl.updateListMemberStatus(newListMemberRecords);
        List<List_Member__c> updatedListMemberRecords = ListMembersDAO.newInstance().getListMembersByStatus(100, AccessLevel.SYSTEM_MODE, 'Qualified');
        System.assert(!updatedListMemberRecords.isEmpty(), 'No List Member found');
        Test.stopTest();
    }

    @isTest
    static void getUserHasListContributorTest(){
        ImplementationSelector.DAO.setMock(new ListsDAOMock());
        ImplementationSelector.DAO.setMock(new ListContributorsDAOMock());
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        MockIdGenerator mockUser = new MockIdGenerator(User.SObjectType);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);

        List<List_Contributor__c> newListContributor = TestDataFactory.createListContributorRecords(1, newListRecords[0].Id);
		newListContributor[0].List_Contributor__c = mockUser.getMockId();
        ListContributorsDAO.newInstance().insertRecords(newListContributor, false, AccessLevel.USER_MODE);

        Test.startTest();
        List<List_Contributor__c> listContributorRecord = CustomHeaderContainerCtrl.getUserHasListContributor(newListRecords[0].Id, newListContributor[0].List_Contributor__c);
        System.assert(!listContributorRecord.isEmpty(), 'No List Contributor found');
        Test.stopTest();
    }
    
    @isTest
    static void getListMembersByListIdAndStatus(){
        ImplementationSelector.DAO.setMock(new ListMembersDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(10,newListRecords[0].id,newContacts[0].id);
        for(List_Member__c listMember : newListMemberRecords){
            listMember.List_Member_Status__c = 'Qualified';
        }
        ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
        
        Test.startTest();
        List<List_Member__c> listMemberRecord = CustomHeaderContainerCtrl.getListMembersByListIdAndStatus(newListMemberRecords[0].Id, 'Qualified');
        System.assert(!listMemberRecord.isEmpty(), 'No List Member found');
        Test.stopTest();     
    }
    
    @isTest
    static void getAllListContributors(){
        ImplementationSelector.DAO.setMock(new ListContributorsDAOMock());
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        List<List_Contributor__c> newListContributors = TestDataFactory.createListContributorRecords(5, newListRecords[0].Id);
        ListContributorsDAO.newInstance().insertRecords(newListContributors, false, AccessLevel.USER_MODE);
        Test.startTest();
        List<List_Contributor__c> getListContributors = CustomHeaderContainerCtrl.getAllListContributors(newListRecords[0].Id);
        System.assert(!getListContributors.isEmpty(), 'No List Contributors found');
        Test.stopTest();         
    }
}