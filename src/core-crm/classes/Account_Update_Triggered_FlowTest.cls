/**
 * @description Test Class for Account Update Triggered Flow
 * 
 * @see ../flows/Account_Update_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                            |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------|
      | angelika.j.s.galang       | November 2, 2021      | DEPP-732     | Created file                                              | 
      | kenneth.f.alsay           | Aug 4, 2023           | DEPP-6304    | Added accountShare for testUser to access account records |      
      |                           |                       |              |                                             | 
*/
@isTest
private class Account_Update_Triggered_FlowTest {
    @testSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        List<Account> accList = TestDataFactory.createTestAccountRecords(100);
        for(Account acc : accList){
                acc.AccountABNEntity_Validation__c = 'Valid';
                acc.Entity_Name__c = 'Test';
        }
        AccountsDAO.newInstance().insertRecords(accList, false, AccessLevel.USER_MODE);
        List<AccountShare> accShare = TestDataFactory.createAccountShareRecords(accList, TestDataFactoryUser.selectUserQUTeXProgramAdministrator.Id, 'Edit');
        insert accShare;
    }

    @isTest
    private static void updateAbnTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){           
            Test.startTest();
            List<Account> accList = [Select Id, ABN__c FROM Account];
            for(Account acc : accList){
                acc.ABN__c = '1234';
            }
            update(accList);
            Test.stopTest();
            
            List<Account> updatedAccList = [SELECT Entity_Name__c, AccountABNEntity_Validation__c FROM Account];
            for(Account acc : updatedAccList){
                System.assert(String.isBlank(acc.Entity_Name__c),'Entity Name is not blank as expected'); 
                System.assert(acc.AccountABNEntity_Validation__c == 'None', 'Validation Status not None as expected');
            }   
        }
    }
}