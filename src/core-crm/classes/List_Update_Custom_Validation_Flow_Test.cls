/**
 * @description Test Class for List Custom Validation flow
 *
 * @see ../flows/List Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA          | Change Summary                                    |
 *    |---------------------------|-----------------------|---------------|---------------------------------------------------|
 *    | jerlyn.esparas            | March 12,2024         | DEPP-7944     | created file                                      |
 *    | ryan.j.a.dela.cruz        | April 30, 2024        | N/A - ST FIX  | Added accessLevel param for getListRecords        |
 */
@isTest
public class List_Update_Custom_Validation_Flow_Test {

    @testSetup
    static void makeData() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<List__c> listRecords = TestDataFactory.createListRecords(1);
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            ListsDAO.newInstance().insertRecords(listRecords, false, AccessLevel.USER_MODE);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

            List<List_Member__c> newListMemberRec = new List<List_Member__c>();
            List<List_Member__c> listMemberRecords = TestDataFactory.createListMemberRecords(
                1,
                listRecords[0].id,
                newContacts[0].Id
            );

            for (List_Member__c listMem : listMemberRecords) {
                listMem.List_Member_Status__c = 'Qualified';
                newListMemberRec.add(listMem);
            }
            ListMembersDAO.newInstance().insertRecords(newListMemberRec, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    public static void checkListMemberStatusOnHold() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<List__c> listRecords = ListsDAO.newInstance().getListRecords(1, AccessLevel.USER_MODE);
            List<List_Member__c> newListMemberRecToUpdate = new List<List_Member__c>();
            List<List_Member__c> newListMemberRec = ListMembersDAO.newInstance()
                .getListMembersByListIdAndStatus(
                    new Set<Id>{ listRecords[0].Id },
                    'Qualified',
                    AccessLevel.USER_MODE
                );

            Test.startTest();
            for (List_Member__c listMemRec : newListMemberRec) {
                listMemRec.List_Member_Status__c = 'On Hold';
                newListMemberRecToUpdate.add(listMemRec);
            }
            ListMembersDAO.newInstance().updateRecords(newListMemberRecToUpdate, false, AccessLevel.USER_MODE);

            listRecords[0].Stage__c = 'Distribute';
            Database.SaveResult[] srList = ListsDAO.newInstance()
                .updateRecords(listRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest
    public static void checkListMemberStatusQualified() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<List__c> listRecords = ListsDAO.newInstance().getListRecords(1, AccessLevel.USER_MODE);
            List<List_Member__c> newListMemberRec = ListMembersDAO.newInstance()
                .getListMembersByListIdAndStatus(
                    new Set<Id>{ listRecords[0].Id },
                    'Qualified',
                    AccessLevel.USER_MODE
                );

            Test.startTest();
            listRecords[0].Stage__c = 'Distribute';
            Database.SaveResult[] srList = ListsDAO.newInstance().updateRecords(listRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved successfully.');
            }
        }
    }
}