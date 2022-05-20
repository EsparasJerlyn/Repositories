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
    
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();

    @isTest
    static void getAccountName(){
         String result;
         System.runAs(currentUser) {
           	Test.startTest();
            String acctId = TestDataFactory.getAccountId();
            result = AccountCtrl.getAccountName(acctId);
            Test.stopTest();
        }
        System.assertEquals(result, 'TestAccount1', 'Not equal to TestAccount1.');
        
    }


}