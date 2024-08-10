/**
 * @description Test Class for List Contributor Task Due Date flow
 *
 * @see ../flows/List Contributor Task Due Date Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA          | Change Summary                                    |
 *    |---------------------------|-----------------------|---------------|---------------------------------------------------|
 *    | carl.alvin.cabiles        | December 12, 2023     | DEPP-7186     | created file                                      |
 *    | ryan.j.a.dela.cruz        | April 30, 2024        | N/A - ST FIX  | Added accessLevel param for getListRecords        |
 */
@isTest
public class List_Contributor_Task_Due_Date_FlowTest {
    @testSetup
    static void makeData() {
        Test.startTest();
        TestDataFactoryUser.generateUserCorporatePartnershipsManager();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager
) {
            List<List__c> listRecords = TestDataFactory.createListRecords(1);
            listRecords[0].Due_Date__c = System.today() + 30;
            ListsDAO.newInstance().insertRecords(listRecords, false, AccessLevel.USER_MODE);

            List<List_Contributor__c> listContributorRecords = TestDataFactory.createListContributorRecords(
                1,
                listRecords[0].id
            );
            ListContributorsDAO.newInstance()
                .insertRecords(listContributorRecords, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    public static void checkDueDate() {
        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager
        ) {
            Test.startTest();
            List<List__c> listRecords = ListsDAO.newInstance()
                .getListRecords(1, AccessLevel.USER_MODE);
            List<List_Contributor__c> listContributorRecord = ListContributorsDAO.newInstance()
                .getListContributorByListID(
                    new Set<Id>{ listRecords[0].id },
                    AccessLevel.USER_MODE
                );
            Test.stopTest();

            System.assertEquals(
                listRecords[0].Due_Date__c,
                listContributorRecord[0].Task_Due_Date__c,
                'List Due Date and List Contributor Task Due Date must be the same'
            );
        }
    }
}
