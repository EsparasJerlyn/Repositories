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
      | neil.s.h.lesidan@accenture.com      | August 7, 2024        | DEPP-10226           | Use new TestDataFactoryUser                            |
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
        User user = TestDataFactoryUser.selectUserAlumniEngagementManager;
        System.runAs(user){
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);

            List<List_Contributor__c> newListContributorRecords = TestDataFactory.createListContributorRecords(5,newListRecords[0].Id);
            for(List_Contributor__c record : newListContributorRecords){
                record.List_Contributor__c = user.Id;
                record.Is_Active__c = true;
            }
            ListContributorsDAO.newInstance().insertRecords(newListContributorRecords, false, AccessLevel.SYSTEM_MODE);
            Test.startTest();
                List<List_Contributor__c> listContributorRecord = ListMemberAddModalController.getDefaultListContributor(newListRecords[0].Id, user.Id);
            Test.stopTest();
            System.debug('listContributorRecord>>>>' + listContributorRecord);
            System.assert(!listContributorRecord.isEmpty(), 'No Default List Contributor found.');
        }
    }

    @isTest
    static void checkIfExistingContactTest(){
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager){
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

            List<List_Member__c> newListMembers = TestDataFactory.createListMemberRecords(1,newListRecords[0].Id,newContacts[0].Id);
            ListMembersDAO.newInstance().insertRecords(newListMembers, false, AccessLevel.USER_MODE);

            Test.startTest();
                Boolean isContactExisting = ListMemberAddModalController.checkIfExistingContact(newListRecords[0].Id,newContacts[0].Id);
            Test.stopTest();

            System.assert(isContactExisting, 'Contact is already added to the List.');
        }
    }

    @isTest
    static void getRelatedListContributorTest(){
        User user = TestDataFactoryUser.selectUserAlumniEngagementManager;
        System.runAs(user){
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);

            List<List_Contributor__c> newListContributorRecords = TestDataFactory.createListContributorRecords(5,newListRecords[0].Id);
            for(List_Contributor__c record : newListContributorRecords){
                record.List_Contributor__c = user.Id;
                record.Is_Active__c = true;
            }
            ListContributorsDAO.newInstance().insertRecords(newListContributorRecords, false, AccessLevel.SYSTEM_MODE);

            List<List_Contributor__c> listContributorRecords = new List<List_Contributor__c>();
            Test.startTest();
                listContributorRecords = ListMemberAddModalController.getRelatedListContributor(newListRecords[0].Id);
            Test.stopTest();
            System.assert(listContributorRecords != null, 'No Related List Contributor found.');
            for(List_Contributor__c rec : listContributorRecords){
                System.assert(rec.List__c == newListRecords[0].Id, 'No Related List Contributor found.');
            }
        }
    }

    @isTest
    static void getContactsWithMatchingEmailsPositionTest(){
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager){

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


    @isTest
    static void createListMemberTest(){
        User user = TestDataFactoryUser.selectUserAlumniEngagementManager;

        System.runAs(user){
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            List<List_Member__c> listMembers = new List<List_Member__c>();
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
            List<List_Contributor__c> newListContributorRecords = TestDataFactory.createListContributorRecords(1, newListRecords[0].Id);
            for(List_Contributor__c record : newListContributorRecords) {
                record.List_Contributor__c = user.Id;
                record.Is_Active__c = true;
            }

            ListContributorsDAO.newInstance().insertRecords(newListContributorRecords, false, AccessLevel.USER_MODE);

            listMembers.add(
                new List_Member__c(
                    List_Contributor__c = newListContributorRecords[0].id,
                    List_Member__c = newContacts[0].Id,
                    List__c = newListRecords[0].Id
                )
            );

            Test.startTest();
            Boolean isSuccess = ListMemberAddModalController.createListMember(listMembers);
            Test.stopTest();

            System.assert(isSuccess, 'Error creating record List Member');
        }
    }
}