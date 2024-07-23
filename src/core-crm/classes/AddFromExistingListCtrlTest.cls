/**
 * @description Test class for AddFromExistingListCtrl
 *
 * @see AddFromExistingListCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
 *    | neil.s.h.lesidan               | December 31, 2023     | DEPP-7004              | Created file                                      |
 *    | ryan.j.a.dela.cruz             | April 30, 2024        | N/A - ST FIX           | Added accessLevel param for getListRecords        |
 */
@isTest
public with sharing class AddFromExistingListCtrlTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
        List<List__c> newListRecords = TestDataFactory.createListRecords(1);
        ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
    }

    @isTest
    static void getSearchedListsTest() {
        List__c listRecord = ListsDAO.newInstance()
            .getListRecords(1, AccessLevel.USER_MODE)
            .iterator()
            .next();

        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();

            List<List__c> record = AddFromExistingListCtrl.getSearchedLists(listRecord.Id, '');
            System.assert(record.isEmpty(), 'List Record found');

            Test.stopTest();
        }
    }
}
