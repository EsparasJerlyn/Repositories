/**
 * @description Test Class for Add Logo URL on Course Insert flow
 *
 * @see ../flows/Add_Logo_URL_on_Course_Insert
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | April 21, 2022        | DEPP-1481    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest
private class Add_Logo_URL_on_Course_InsertTest {
    
    private static final String QUTEX = System.Label.QUTeX;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();  

    @testSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void addLogoUrlOnCourseInsertTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
            insert acc;
            Product_Request__c pr = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
            insert pr;
            hed__Course__c course = TestDataFactory.createTestCourseRecords(1,acc?.Id,pr?.Id).iterator().next();
            
            Test.startTest();
            insert course;
            Test.stopTest();

            System.assert(
                [
                    SELECT
                    LogoUrl__c
                    FROM hed__Course__c
                    WHERE Id =: course.Id
                ].LogoUrl__c != null,
                'Logo URL was not populated as expected'
            );
        }
    }
}
