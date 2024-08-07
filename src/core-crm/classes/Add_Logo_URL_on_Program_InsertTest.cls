/**
 * @description Test Class for Add Logo URL on Program Insert flow
 *
 * @see ../flows/Add_Logo_URL_on_Program_Insert
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | kathy.cornejo	          | July 8, 2022          | DEPP-1770    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest
private class Add_Logo_URL_on_Program_InsertTest {
    
    private static final String QUTEX = System.Label.QUTeX;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    
    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProductAdministrator();
    }

    @isTest
    private static void addLogoUrlOnProgramInsertTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
            insert acc;
            Product_Request__c pr = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
            insert pr;
            hed__Program_Plan__c prog = TestDataFactory.createTestProgramPlanRecords(1).iterator().next();
            
            Test.startTest();
            insert prog;
            Test.stopTest();

            System.assert(
                [
                    SELECT 
                    LogoUrl__c
                    FROM hed__Program_Plan__c 
                    WHERE Id =: prog.Id
                ].LogoUrl__c != null,
                'Logo URL was not populated as expected'
            );
        }
    }
}