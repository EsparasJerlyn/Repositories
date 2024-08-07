/**
 * @description Test Class for Update Product Code Flow
 *
 * @see ../flows/Update_Product_Code_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | arsenio.jr.dayrit         | April 07, 2022        | DEPP-2057    | Created file                                |
      |                           |                       |              |                                             |
      |                           |                       |              |                                             |
*/
@isTest
private class UpdateProductCodeFlowTest{
    private static Integer numberOfRecords = 10;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateProductCodeTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            List<Account> accounts;
            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Contact> contacts;
            contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;

            List<Opportunity> opps;
            opps = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,contacts[0].Id);
            insert opps;

            List<Product_Specification__c> productSpecs = TestDataFactory.retrieveCCEProductSpecifications();

            List<Product_Request__c> prodRequestOPEProgramRequest;
            prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
            insert prodRequestOPEProgramRequest;

            List<hed__Program_Plan__c> programPlanList;
            programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
            insert programPlanList;

            List<Product_Request__c> prodRequest;
            prodRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
            insert prodRequest;


            List<hed__Course__c> courses;
            courses = TestDataFactory.createTestCourseRecords(numberOfRecords,accounts[0].Id,prodRequest[0].Id);
            insert courses;


           List<Product2> products = TestDataFactory.createTestProductRecords(numberOfRecords, courses);
           for(Integer i = 0 ; i > products.size() ; i++){
                products[i].Course__c = courses[i].id;
                products[i].ProductCode = 'Test'+i;
           }

           Test.startTest();
           insert products;
           Test.stopTest();

           List<Product2> prodRec = [SELECT Id, Name, Product_Code__c, ProductCode FROM Product2 LIMIT 100];
           for(Product2 checkProd : prodRec){
           System.assertEquals(checkProd.Product_Code__c, checkProd.ProductCode, 'custom product code must be the same with standard product code');
           }


        }
    }
}