/**
 * @description Test class for Update Product End Date
 *
 * @see ../flows/Update_Product_End_Date
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
private class Update_Product_End_DateTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id RT_ACTIVITY_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
    private static final string RT_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final Id RT_PROGRAM_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PROGRAM).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final string C_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id C_ACTIVITY_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_ACTIVITY).getRecordTypeId();
    private static string PP_PROGRAM = System.Label.RT_ProgramPlan_Program;
    private static Id opeProgPlanId = Schema.SObjectType.hed__Program_Plan__c.getRecordTypeInfosByDeveloperName().get(PP_PROGRAM).getRecordTypeId();
    private static Date CurrentDate = date.today();
    @IsTest
    static void updateCourseToNotProceedingStatusTest(){
         System.runAs(currentUser){
            
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                 acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                 acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                 productRequest.RecordTypeId = RT_ACTIVITY_ID;
            }
            insert productRequests;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
            courses[0].RecordTypeId = C_ACTIVITY_ID;
            insert courses;

            Test.startTest();
            List<Product_Request__c> pr = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 1];
            pr[0].Product_Request_Status__c = 'Not Proceeding';
            update pr;
            Test.stopTest();

            List<Product2> checkProd = [SELECT Id, End_Date__c FROM Product2 LIMIT 1];
            System.debug('checkProd size: ' + checkProd.size());
            System.assertEquals(CurrentDate, checkProd[0].End_Date__c, 'End Date Should be equal to Not Proceeding Date');
            
         }
    }
    @IsTest
    static void updateProgramToNotProceedingStatusTest(){
         System.runAs(currentUser){
            
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                 acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                 acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                 productRequest.RecordTypeId = RT_PROGRAM_ID;
            }
            insert productRequests;

            List<hed__Program_Plan__c> programs = TestDataFactory.createTestProgramPlanRecords(1);
            programs[0].RecordTypeId = opeProgPlanId;
            programs[0].Product_Request__c = productRequests[0].Id;
            insert programs;
            system.debug('program plan Id :'+ opeProgPlanId);

            Test.startTest();
            List<Product_Request__c> pr = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 1];
            pr[0].Product_Request_Status__c = 'Not Proceeding';
            update pr;
            Test.stopTest();

            List<Product2> checkProd = [SELECT Id, End_Date__c FROM Product2 LIMIT 1];
            System.debug('checkProd size: ' + checkProd.size());
            System.assertEquals(CurrentDate, checkProd[0].End_Date__c, 'End Date Should be equal to Not Proceeding Date');
            
         }
    }

    @IsTest
    static void updateCourseToDecommissionedTest(){
         System.runAs(currentUser){

          List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
          for(Account acc : accounts){
               acc.RecordTypeId = ACCT_UNIV_DEP_ID;
               acc.Organization_Unit_Level__c = '2';
          }
          insert accounts;

          List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
          for(Product_Request__c productRequest : productRequests){
               productRequest.RecordTypeId = RT_ACTIVITY_ID;
          }
          insert productRequests;

          List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
          courses[0].RecordTypeId = C_ACTIVITY_ID;
          insert courses;

          Test.startTest();
          List<Product2> prod = [SELECT Id, Decommission_Product__c, Decommission_Reason__c, Publishing_End_date__c, Publishing_Start_date__c, 
                                 QA_Review_Completed__c, Ready_for_publishing__c, Available_on_Cart__c, IsActive, LastModifiedDate FROM Product2 LIMIT 1];
          prod[0].QA_Review_Completed__c = 'Yes';
          prod[0].Publishing_Start_date__c = date.today();
          prod[0].Available_on_Cart__c = True;
          prod[0].Ready_for_publishing__c = 'Yes';
          prod[0].IsActive = True;
          prod[0].Decommission_Product__c = True;
          prod[0].Decommission_Reason__c = 'Test';
          prod[0].Publishing_End_date__c = date.today();

          update prod;
          Test.stopTest();

          List<Product2> checkProd = [SELECT Id, End_Date__c FROM Product2 LIMIT 1];
          System.debug('checkProd size: ' + checkProd.size());
          System.assertEquals(CurrentDate, checkProd[0].End_Date__c, 'End Date Should be equal to Decommission Date');
          
        }

     }

     @isTest
     static void updateProgramToDecommissionedTest(){
          System.runAs(currentUser){
 
           List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
           for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
           }
           insert accounts;
 
           List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
           for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = RT_PROGRAM_ID;
           }
           insert productRequests;
 
           List<hed__Program_Plan__c> programs = TestDataFactory.createTestProgramPlanRecords(1);
           programs[0].RecordTypeId = opeProgPlanId;
           programs[0].Product_Request__c = productRequests[0].id;
           insert programs;
 
           Test.startTest();
           List<Product2> prod = [SELECT Id, Decommission_Product__c, Decommission_Reason__c, Publishing_End_date__c, Publishing_Start_date__c, 
                                  QA_Review_Completed__c, Ready_for_publishing__c, Available_on_Cart__c, IsActive, LastModifiedDate FROM Product2 LIMIT 1];
           prod[0].QA_Review_Completed__c = 'Yes';
           prod[0].Publishing_Start_date__c = date.today();
           prod[0].Available_on_Cart__c = True;
           prod[0].Ready_for_publishing__c = 'Yes';
           prod[0].IsActive = True;
           prod[0].Decommission_Product__c = True;
           prod[0].Decommission_Reason__c = 'Test';
           prod[0].Publishing_End_date__c = date.today();
 
           update prod;
           Test.stopTest();
 
           List<Product2> checkProd = [SELECT Id, End_Date__c FROM Product2 LIMIT 1];
           System.debug('checkProd size: ' + checkProd.size());
           System.assertEquals(CurrentDate, checkProd[0].End_Date__c, 'End Date Should be equal to Decommission Date');
           
         }
 
      }
}
