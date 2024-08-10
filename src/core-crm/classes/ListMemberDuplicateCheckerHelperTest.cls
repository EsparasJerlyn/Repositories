/**
 * @description Test Class for ListMemberDuplicateCheckerHelper
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                        |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------------------------|
 *    | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | Created file                                                                         |
 *    | roy.nino.s.regala              | Feb 26, 2024          | DEPP-7882              | Fix mismatch of parameter, updated run as for ownership of contact record            |
 *    | ryan.j.a.dela.cruz             | April 30, 2024        | N/A - ST FIX           | Added accessLevel param for getListRecords                                           |
 */
@isTest
public with sharing class ListMemberDuplicateCheckerHelperTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserAlumniEngagementManager();
        Test.stopTest();
        
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

            List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(
                1,
                newListRecords[0].id,
                newContacts[0].id
            );
            ListMembersDAO.newInstance()
                .insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    static void detectDuplicateListMembersTest() {
        Contact con = ContactsDAO.getPersonContactsWithLimit(1).iterator().next();
        List__c listRec = ListsDAO.newInstance()
            .getListRecords(1, AccessLevel.USER_MODE)
            .iterator()
            .next();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(
                10,
                listRec.Id,
                con.Id
            );
            Test.startTest();
            Database.SaveResult[] srList = ListMembersDAO.newInstance()
                .insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void detectDuplicateListMembersTestonUpdate() {
        Contact con = ContactsDAO.getPersonContactsWithLimit(1).iterator().next();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            List__c listRec = ListsDAO.newInstance()
                .getListRecords(1, AccessLevel.USER_MODE)
                .iterator()
                .next();
            Test.startTest();
            List<List__c> newListBatchRecords = TestDataFactory.createListRecords(10);
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
            ListsDAO.newInstance().insertRecords(newListBatchRecords, false, AccessLevel.USER_MODE);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberBatchRecords(
                10,
                newListBatchRecords,
                newContacts[0].id
            );
            ListMembersDAO.newInstance()
                .insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
            List<List_Member__c> listMembersToUpdate = new List<List_Member__c>();
            for (List_Member__c listMember : newListMemberRecords) {
                listMembersToUpdate.add(
                    new List_Member__c(
                        Id = listMember.Id,
                        List__c = listRec.Id,
                        List_Member__c = con.Id
                    )
                );
            }

            Database.SaveResult[] srList = ListMembersDAO.newInstance()
                .updateRecords(listMembersToUpdate, false, AccessLevel.USER_MODE);

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
            Test.stopTest();
        }
    }
}
