/**
 * @description Test Class for Account Update Triggered Flow
 *
 * @see ../flows/Account_Update_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | November 2, 2021      | DEPP-732     | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest
private class Account_Update_Triggered_FlowTest {

    private static final String STR_QUTEX = 'QUTeX';
    
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers();
    }

    @isTest
    private static void updateAbnTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            List<Account> accList = TestDataFactory.createTestAccountRecords(100);
            for(Account acc : accList){
                acc.AccountABNEntity_Validation__c = 'Valid';
                acc.Entity_Name__c = 'Test';
            }
        	insert(accList);
            
            Test.startTest();
            for(Account acc : accList){
                acc.ABN__c = '1234';
            }
            update(accList);
            Test.stopTest();
            
            List<Account> updatedAccList = [SELECT Entity_Name__c,AccountABNEntity_Validation__c FROM Account LIMIT 100];
            for(Account acc : updatedAccList){
                System.assert(String.isBlank(acc.Entity_Name__c),'Entity Name is not blank as expected'); 
                System.assert(acc.AccountABNEntity_Validation__c == 'None', 'Validation Status not None as expected');
            }   
        }
    }
}