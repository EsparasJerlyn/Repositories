/**
 * @description Test class for Update Course or Program  Start Date
 *
 * @see ../flows/Update_Course_or_Program_Start_Date
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | arsenio.jr.dayrit         | June 08, 2022         | DEPP-2523 | Created file                    |
      |                           |                       |           |                                 |
*/
@isTest(SeeAllData=false)
private class Update_Course_or_Program_Start_DateTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id RT_ACTIVITY_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
    private static final string RT_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final Id RT_PROGRAM_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PROGRAM).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @IsTest
    static void updateCourseStartDateTest(){
         System.runAs(currentUser){
            
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                 acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                 acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            Test.startTest();
            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                 productRequest.RecordTypeId = RT_ACTIVITY_ID;
            }
            insert productRequests;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
            insert courses;
            Test.stopTest();

            List<hed__Course__c> courseRec = [SELECT Id, Start_Date__c FROM hed__Course__c LIMIT 1];
            System.assertEquals(productRequests[0].CreatedDate,courseRec[0].Start_Date__c,'Start Date should be equal to created Date');
         }
    }

    @IsTest
    static void updateProgramStartDateTest(){
         System.runAs(currentUser){

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                 acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                 acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            Test.startTest();
            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                 productRequest.RecordTypeId = RT_PROGRAM_ID;

            }
            insert productRequests;

            
            List<hed__Program_Plan__c> programs = TestDataFactory.createTestProgramPlanRecords(1);
            for(hed__Program_Plan__c program : programs){
                    program.Product_Request__c = productRequests[0].Id;
            }
            insert programs;
           
            Test.stopTest();
            List<hed__Program_Plan__c> programRec = [SELECT Id, hed__Start_Date__c FROM hed__Program_Plan__c LIMIT 1];
            System.assertEquals(productRequests[0].CreatedDate, programRec[0].hed__Start_Date__c,'Start Date should be equal to created Date');
         }
    }

}
