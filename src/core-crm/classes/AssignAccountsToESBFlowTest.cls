/**
* @description test class for Assign Accounts To ESB flow
* @author Accenture
*
* @history
*
*    | Developer Email                | Date                  | JIRA                 | Change Summary                      |
*    |--------------------------------|-----------------------|----------------------|-------------------------------------|
*    | kenneth.f.alsay                | July 31, 2023         | DEPP-6101            | Created file,added test methods     |
*/
@isTest
public class AssignAccountsToESBFlowTest {
    // * Description: This method is used to create initial data for the test methods
    @TestSetup
    static void makeData() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
        Test.startTest();
        List<Account> accountList = TestDataFactory.createTestAccountRecordsWithRecordType(200, AccountsDAO.ACCT_BUSINESS_ORG_ID);
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
        Test.stopTest();
    }   
    
    @isTest
    public static void updateOpportunityStagetoExecuted(){
        System.runAs(TestDataFactory.getESBIntegrationUser()){
            Set<String> accountName = new Set<String>();
            for(Integer i=0; i<200 ; i++){
                accountName.add('TestAccount' + i);
            }
            List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetNames(accountName);
                System.assertEquals(
                200,
                [SELECT COUNT()
                FROM Account
                WHERE OwnerId = :TestDataFactory.getESBIntegrationUser().Id
                AND Id IN :accountList],
                'Incorrect number of Accounts'
                );
        }
    }
}