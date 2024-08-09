/**
 * @description Test class for ListMemberAddModalController
 *
 * @see ListMemberAddModalController
 *
 * @author Accenture
 *
 * @history
 *    | Developer                           | Date                  | JIRA                 | Change Summary                                         |
      |-------------------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | nicole.genon@accenture.com          | February 1, 2024      | DEPP-7003            | Created file                                           |
*/
@isTest
public with sharing class ListMemberAddModalControllerTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserAlumniEngagementManager();
        Test.stopTest();
    }

    @isTest
    static void getDefaultListContributorTest(){
        ImplementationSelector.DAO.setMock(new ListContributorsDAOMock());

        User alumniUser = TestDataFactoryUser.selectUserAlumniEngagementManager;
        System.runAs(alumniUser){
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
    
            List<List_Contributor__c> newListContributorRecords = TestDataFactory.createListContributorRecords(1,newListRecords[0].Id);
            for(List_Contributor__c record : newListContributorRecords){
                record.List_Contributor__c = alumniUser.Id;
            }
            ListContributorsDAO.newInstance().insertRecords(newListContributorRecords, false, AccessLevel.SYSTEM_MODE);
    
            Test.startTest();
            List<List_Contributor__c> listContributorRecord = ListMemberAddModalController.getDefaultListContributor(newListRecords[0].Id, alumniUser.Id);
            System.assert(!listContributorRecord.isEmpty(), 'No Default List Contributor found.');
            Test.stopTest();
        }
    }

    @isTest
    static void checkIfExistingContactTest(){
        ImplementationSelector.DAO.setMock(new ListMembersDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);        
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        List<List_Member__c> newListMembers = TestDataFactory.createListMemberRecords(1,newListRecords[0].Id,newContacts[0].Id);
        ListMembersDAO.newInstance().insertRecords(newListMembers, false, AccessLevel.USER_MODE);

        Test.startTest();
        Boolean isContactExisting = ListMemberAddModalController.checkIfExistingContact(newListRecords[0].Id,newContacts[0].Id);
        System.assert(isContactExisting, 'Contact is already added to the List.');

        Test.stopTest();
    }

    @isTest
    static void getRelatedListContributorTest(){
        ImplementationSelector.DAO.setMock(new ListContributorsDAOMock());

        User alumniUser = TestDataFactoryUser.selectUserAlumniEngagementManager;
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);

        List<List_Contributor__c> newListContributorRecords = TestDataFactory.createListContributorRecords(5,newListRecords[0].Id);
        for(List_Contributor__c record : newListContributorRecords){
            record.List_Contributor__c = alumniUser.Id;
        }
        ListContributorsDAO.newInstance().insertRecords(newListContributorRecords, false, AccessLevel.SYSTEM_MODE);

        Test.startTest();
        List<List_Contributor__c> listContributorRecords = ListMemberAddModalController.getRelatedListContributor(newListRecords[0].Id);
        System.assert(listContributorRecords != null, 'No Related List Contributor found.');
        for(List_Contributor__c rec : listContributorRecords){
            System.assert(rec.List__c == newListRecords[0].Id, 'No Related List Contributor found.');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsWithMatchingEmailsPositionTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 15);        
        ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

        Test.startTest();
        String toSearch = 'Test';
        Integer recordLimit = 15;
        List<Contact> getContacts = ListMemberAddModalController.getContactsWithMatchingEmailsPosition(toSearch,recordLimit);
        System.assert(!getContacts.isEmpty(), 'Contact is not empty.');

        Test.stopTest();
    }
}