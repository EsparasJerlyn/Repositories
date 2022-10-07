/**
 * @description Tests Controller Class for AccountCtrl
 * @see AccountCtrlTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | September 27, 2021    | DEP1-158, DEP1-623     | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest
public class AccountCtrlTest {

    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers();
    }

    @isTest
    static void getAccountName(){
         String result;
         System.runAs(TestDataFactory.getProgramAdminUser()) {
           	Test.startTest();
            String acctId = TestDataFactory.getAccountId();
            result = AccountCtrl.getAccountName(acctId);
            Test.stopTest();
        }
        System.assertEquals(result, 'TestAccount1', 'Not equal to TestAccount1.');
        
    }


}