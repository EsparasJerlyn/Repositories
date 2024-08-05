/**
 * @description testclass for dmlbase
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
private class DmlBaseTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    private class TestDmlBase extends DmlBase {
        public Schema.SObjectType getSObjectType() {
            return Account.sObjectType;
        }
    }

    @IsTest
    // prettier-ignore
    static void testInsertRecords() {//NOPMD no specific user to run as for test dml base
        Account testAccount = new Account(Name='Test Account');
        TestDmlBase dml = new TestDmlBase();
        List<Database.SaveResult> saveResults = dml.insertRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        System.assert(saveResults[0].isSuccess(),'dml was unsuccessful');
    }

    @IsTest
    // prettier-ignore
    static void testFailedInsertRecords() {//NOPMD no specific user to run as for test dml base
        Account testAccount = new Account();
        TestDmlBase dml = new TestDmlBase();
        List<Database.SaveResult> saveResults = dml.insertRecords(new List<Account>{testAccount}, false, AccessLevel.USER_MODE);
        System.assert(!saveResults[0].isSuccess(),'dml was successful');
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is abstract no specific user to test
    // prettier-ignore
    static void testEmptyInsertRecords() {
        TestDmlBase dml = new TestDmlBase();
        List<Database.SaveResult> saveResults = dml.insertRecords(new List<Account>(), false, AccessLevel.USER_MODE);
        System.assert(saveResults.isEmpty(),'dml was not skipped');
    }

    @IsTest
    // prettier-ignore
    static void testUpdateRecords() { //NOPMD no specific user to run as for test dml base
        TestDmlBase dml = new TestDmlBase();
        Account testAccount = new Account(Name='Test Account');
        dml.insertRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        testAccount.Name = 'Updated Test Account';
        List<Database.SaveResult> updateResults = dml.updateRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        System.assert(updateResults[0].isSuccess(),'dml was unsuccessful');
    }
    @IsTest
    // prettier-ignore
    static void testFailedUpdateRecords() { //NOPMD no specific user to run as for test dml base
        TestDmlBase dml = new TestDmlBase();
        Account testAccount = new Account(Name='Test Account');
        dml.insertRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        testAccount.Name = '';
        List<Database.SaveResult> updateResults = dml.updateRecords(new List<Account>{testAccount}, false, AccessLevel.USER_MODE);
        System.assert(!updateResults[0].isSuccess(),'dml was successful');
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is abstract no specific user to test
    // prettier-ignore
    static void testEmptyUpdateRecords() {
        TestDmlBase dml = new TestDmlBase();
        List<Database.SaveResult> saveResults = dml.updateRecords(new List<Account>(), false, AccessLevel.USER_MODE);
        System.assert(saveResults.isEmpty(),'dml was not skipped');
    }

    @IsTest
    // prettier-ignore
    static void testUpsertRecords() { //NOPMD no specific user to run as for test dml base
        TestDmlBase dml = new TestDmlBase();
        Account testAccount = new Account(Name='Test Account');
        List<Database.UpsertResult> upsertResults = dml.upsertRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        System.assert(upsertResults[0].isSuccess(),'dml was unsuccessful');
    }

    @IsTest
    // prettier-ignore
    static void testFailedUpsertRecords() { //NOPMD no specific user to run as for test dml base
        TestDmlBase dml = new TestDmlBase();
        Account testAccount = new Account();
        List<Database.UpsertResult> upsertResults = dml.upsertRecords(new List<Account>{testAccount}, false, AccessLevel.USER_MODE);
        System.assert(!upsertResults[0].isSuccess(),'dml was successful');
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is abstract no specific user to test
    // prettier-ignore
    static void testEmptyUpsertRecords() {
        TestDmlBase dml = new TestDmlBase();
        List<Database.UpsertResult> upsertResults = dml.upsertRecords(new List<Account>(), false, AccessLevel.USER_MODE);
        System.assert(upsertResults.isEmpty(),'dml was not skipped');
    }

    @IsTest
    // prettier-ignore
    static void testDeleteRecords() { //NOPMD no specific user to run as for test dml base
        TestDmlBase dml = new TestDmlBase();
        Account testAccount = new Account(Name='Test Account');
        dml.insertRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        List<Database.DeleteResult> deleteResults = dml.deleteRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        System.assert(deleteResults[0].isSuccess(),'dml was unsuccessful');
    }

    @IsTest
    static void testFailedDeleteRecords() {
        TestDmlBase dml = new TestDmlBase();
        Account testAccount = new Account(Name = 'Test Account');
        dml.insertRecords(new List<Account>{ testAccount }, true, AccessLevel.USER_MODE);
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            //program admin should not have delete access
            List<Database.DeleteResult> deleteResults = dml.deleteRecords(
                new List<Account>{ testAccount },
                false,
                AccessLevel.USER_MODE
            );
            System.assert(!deleteResults[0].isSuccess(), 'dml was unsuccessful');
        }
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is abstract no specific user to test
    // prettier-ignore
    static void testEmptyDeleteRecords() {
        TestDmlBase dml = new TestDmlBase();
        List<Database.DeleteResult> deleteResults = dml.deleteRecords(new List<Account>(), false, AccessLevel.USER_MODE);
        System.assert(deleteResults.isEmpty(),'dml was not skipped');
    }

    @IsTest
    // prettier-ignore
    static void testDeleteRecordIds() { //NOPMD no specific user to run as for test dml base
        TestDmlBase dml = new TestDmlBase();
		Account testAccount = new Account(Name='Test Account');
        dml.insertRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        List<Database.DeleteResult> deleteResults = dml.deleteRecords(new List<Id>{testAccount.Id}, true, AccessLevel.USER_MODE);
        System.assert(deleteResults[0].isSuccess(),'dml was unsuccessful');
    }

    @IsTest
    // prettier-ignore
    static void testFailedDeleteRecordIds() { //NOPMD no specific user to run as for test dml base
        TestDmlBase dml = new TestDmlBase();
		Account testAccount = new Account(Name='Test Account');
        dml.insertRecords(new List<Account>{testAccount}, true, AccessLevel.USER_MODE);
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){//program admin should not have delete access
            List<Database.DeleteResult> deleteResults = dml.deleteRecords(new List<Id>{testAccount.Id}, false, AccessLevel.USER_MODE);
            System.assert(!deleteResults[0].isSuccess(),'dml was successful');
        }
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is abstract no specific user to test
    // prettier-ignore
    static void testEmptyDeleteRecordIds() {
        TestDmlBase dml = new TestDmlBase();
        List<Database.DeleteResult> deleteResults = dml.deleteRecords(new List<Id>(), false, AccessLevel.USER_MODE);
        System.assert(deleteResults.isEmpty(),'dml was not skipped');
    }

    @isTest
    // prettier-ignore
    static void testSObjectType() { //NOPMD no specific user to run as for test dml base
        TestDmlBase dml = new TestDmlBase();
        Schema.SObjectType objectType = dml.sObjectType();
        System.assert(Account.sObjectType == objectType, 'sObjectType did not match');
    }
}