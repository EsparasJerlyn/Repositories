/**
 * @description Tests Controller Class for AccountCtrl
 * @see AccountCtrlTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | marygrace.li@qut.edu.au        | September 27, 2021    | DEP1-158, DEP1-623     | Created file                   |
 *    | roy.nino.s.regala              | April 23, 2023        | DEPP-5567              | Update to adapt dao framework  |
 *    | ryan.j.a.dela.cruz             | June 5, 2023          | DEPP-5385              | Added tests for checkABNExists |
 */
@isTest
public class AccountCtrlTest {
    @isTest
	// prettier-ignore
    private static void getAccountNameTest() {//NOPMD - test class is mocked
        String accountName = '';
        Test.startTest();
        ImplementationSelector.DAO.setMock(new AccountsDAOMock());
        List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
        accountName = AccountCtrl.getAccountName(accountList.iterator().next()?.Id);
        Test.stopTest();
        System.AssertEquals('TestAccount0', accountName, 'Should get account name');
    }

    @isTest
	// prettier-ignore
    private static void getAccountNameErrorTest() {// NOPMD - test class is mocked
        Test.startTest();
        try {
            ImplementationSelector.DAO.setMock(new AccountsDAOMock());
            AccountCtrl.getAccountName('errorstring');
        } catch (Exception e) {
            System.assert(e != null, 'no error');
        }
        Test.stopTest();
    }

    @isTest
	// prettier-ignore
    private static void checkABNExistsTest() {//NOPMD - test class is mocked
        Test.startTest();
        ImplementationSelector.DAO.setMock(new AccountsDAOMock());
        List<Account> accountList = TestDataFactory.createTestAccountWithABNRecords(1);
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
        Boolean abnExists = AccountCtrl.checkABNExists(accountList.iterator().next()?.ABN__c);
        Test.stopTest();
        System.assertEquals(true, abnExists, 'ABN Should Exist');
    }

    @isTest
	// prettier-ignore
    private static void checkABNExistsErrorTest() {// NOPMD - test class is mocked
        Test.startTest();
        try {
            ImplementationSelector.DAO.setMock(new AccountsDAOMock());
            AccountCtrl.checkABNExists('errorstring');
        } catch (Exception e) {
            System.assert(e != null, 'no error');
        }
        Test.stopTest();
    }
}
