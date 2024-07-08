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
        TestDataFactoryUser.generateUserQUTESB();
        List<Account> accountList = TestDataFactory.createTestAccountRecordsWithRecordType(100, AccountsDAO.ACCT_BUSINESS_ORG_ID);
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
    }   
    
    @isTest
    public static void updateOpportunityStagetoExecuted(){
        User esbIntegrationUser = [SELECT Id FROM USER WHERE FirstName = 'ESB' AND LastName = 'Integration User' LIMIT 1];
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            Set<String> accountName = new Set<String>();
            for(Integer i=0; i<100 ; i++){
                accountName.add('TestAccount' + i);
            }
            List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetNames(accountName);
                System.assertEquals(
                100,
                [SELECT COUNT()
                FROM Account
                WHERE OwnerId = :esbIntegrationUser.Id
                AND Id IN :accountList],
                'Incorrect number of Accounts'
                );
        }
    }
}