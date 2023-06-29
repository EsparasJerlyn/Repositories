/**
 * @description test class for dmlbasemock
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        |DEPP-5567               | Created File                 | 
 */
@IsTest
public class DmlBaseMockTest {
    private class TestMock extends DmlBaseMock {
        public TestMock(Map<Id, SObject> records) {
            super(records, Account.SObjectType);
        }

        public Schema.SObjectType getSObjectType() {
            return Account.SObjectType;
        }
    }

    @IsTest
    // prettier-ignore
    static void testInsertRecords() {//NOPMD class is mocked no need for running user
        TestMock mock = new TestMock(new Map<Id, Account>());
        Account testAccount = new Account(Name = 'Test Account');
        List<Database.SaveResult> saveResults = mock.insertRecords(
            new List<Account>{ testAccount },
            true,
            AccessLevel.USER_MODE
        );
        System.assert(saveResults[0].isSuccess(), 'dml was unsuccessful');
    }

    @IsTest
    // prettier-ignore
    static void testUpdateRecords() {//NOPMD class is mocked no need for running user
        TestMock mock = new TestMock(new Map<Id, Account>());
        Account testAccount = new Account(Name = 'Test Account');
        mock.insertRecords(new List<Account>{ testAccount }, true, AccessLevel.USER_MODE);
        testAccount.Name = 'Updated Test Account';
        List<Database.SaveResult> updateResults = mock.updateRecords(
            new List<Account>{ testAccount },
            true,
            AccessLevel.USER_MODE
        );
        System.assert(updateResults[0].isSuccess(), 'dml was unsuccessful');
    }

    @IsTest
    // prettier-ignore
    static void testUpsertRecords() {//NOPMD class is mocked no need for running user
        TestMock mock = new TestMock(new Map<Id, Account>());
        Account testAccount = new Account(Name = 'Test Account');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        mock.insertRecords(new List<Account>{ testAccount2 }, true, AccessLevel.USER_MODE);
        List<Database.UpsertResult> upsertResults = mock.upsertRecords(
            new List<Account>{ testAccount, testAccount2 },
            true,
            AccessLevel.USER_MODE
        );
        System.assert(upsertResults[0].isSuccess(), 'dml was unsuccessful');
    }

    @IsTest
    // prettier-ignore
    static void testDeleteRecords() {//NOPMD class is mocked no need for running user
        TestMock mock = new TestMock(new Map<Id, Account>());
        Account testAccount = new Account(Name = 'Test Account');
        mock.insertRecords(new List<Account>{ testAccount }, true, AccessLevel.USER_MODE);
        List<Database.DeleteResult> deleteResults = mock.deleteRecords(
            new List<Account>{ testAccount },
            true,
            AccessLevel.USER_MODE
        );
        System.assert(deleteResults[0].isSuccess(), 'dml was unsuccessful');
    }

    @IsTest
    // prettier-ignore
    static void testDeleteRecordIds() {//NOPMD class is mocked no need for running user
        TestMock mock = new TestMock(new Map<Id, Account>());
        Account testAccount = new Account(Name = 'Test Account');
        mock.insertRecords(new List<Account>{ testAccount }, true, AccessLevel.USER_MODE);
        List<Database.DeleteResult> deleteResults = mock.deleteRecords(
            new List<Id>{ testAccount.Id },
            true,
            AccessLevel.USER_MODE
        );
        System.assert(deleteResults[0].isSuccess(), 'dml was unsuccessful');
    }

    @isTest
    // prettier-ignore
    static void testSObjectType() {//NOPMD class is mocked no need for running user
        TestMock mock = new TestMock(new Map<Id, Account>());
        Schema.SObjectType objectType = mock.sObjectType();
        System.assert(Account.sObjectType == objectType, 'sObjectType did not match');
    }

    @IsTest
    // prettier-ignore
    static void testGetRecords() {//NOPMD class is mocked no need for running user
        TestMock mock = new TestMock(new Map<Id, Account>());
        Account testAccount = new Account(Name = 'Test Account');
        List<Database.SaveResult> saveResults = mock.insertRecords(
            new List<Account>{ testAccount },
            true,
            AccessLevel.USER_MODE
        );
        System.assert(saveResults[0].isSuccess(), 'dml was unsuccessful');
        System.assert(!mock.getRecords().isEmpty(), 'no mock records found');
    }
}
