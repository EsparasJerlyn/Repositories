/**
 * @description Test class for Update Product Name Flow
 *
 * @see ../flows/Update_Product_Name_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | arsenio.jr.dayrit         | March 29, 2022        | DEPP-2136 | Created file                    |
      |                           |                       |           |                                 |
*/
@isTest
private class UpdateProductNameFlowTest {
    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static string PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateProductNameTest(){
        
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
            prodRequestOPEProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
            prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
            insert prodRequestOPEProgramRequest;

            List<hed__Program_Plan__c> programPlanList;
            programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanList[0].Product_Request__c = prodRequestOPEProgramRequest[0].Id;
            insert programPlanList;

            Test.startTest();
            List<Product_Request__c> prodRequest;
            prodRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
            prodRequest[0].RecordTypeId = opeActProdReqId;
            insert prodRequest;


            List<hed__Course__c> courses;
            courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
            courses[0].Name = 'test';
            insert courses;
            Test.stopTest();

            List<Related_Product_Request__c> relatedProductRequests;
            relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodRequest,prodRequestOPEProgramRequest);

            insert relatedProductRequests;

            List<Related_Product_Request__c> rPr = [SELECT Id, Course__c, Product_Name__c FROM  Related_Product_Request__c LIMIT 100];
            for(Related_Product_Request__c checkProdName : rPr){
                System.assertEquals('test', checkProdName.Product_Name__c,'Name must be the same.');
            }

        }
    }
}
