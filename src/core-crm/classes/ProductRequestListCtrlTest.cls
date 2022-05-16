/**
 * @description Tests the Product Request Controller Test Class
 *
 * @see ProductRequestListCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | roy.nino.s.regala         | October 01, 2021      | DEPP40,42 | Created file                    |
      | eccarius.munoz            | March 24, 2022        | DEPP-1888 | Added test method for record    |
      |                           |                       |           | update to Not Proceeding        |
      |                           |                       |           |                                 |
*/
@isTest(SeeAllData=false)
private class ProductRequestListCtrlTest {
    private static final String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final String PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;

    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setupMethod() {
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
        opps = TestDataFactory.createTestOpportunityRecords(1,accounts[0].Id,contacts[0].Id);
        insert opps;

        List<Product_Specification__c> productSpecs;
        productSpecs = TestDataFactory.createTestProductSpecsRecords(1,contacts,opps);
        insert productSpecs;

        List<Product_Request__c> prodRequestOPEProgramRequest;
        prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequestOPEProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequest;

        List<hed__Program_Plan__c> programPlanList;
        programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanList[0].Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        insert programPlanList;

        List<Product_Request__c> prodRequest;

        prodRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequest[0].RecordTypeId = opeActProdReqId;
        insert prodRequest;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        List<Related_Product_Request__c> relatedProductRequests;
        relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodRequest,prodRequestOPEProgramRequest);
        insert relatedProductRequests;

    }

    @isTest
    static void testGetProductRequests() {
        Test.startTest();
        System.runAs(currentUser){
            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id FROM Product_Specification__c Limit 1].Id));
            system.assert( !getProdReqs.parentList.isEmpty(), 'unable to get parent product requests');
            system.assert( !getProdReqs.parentChildMap.isEmpty(), 'unable to get parent child map product requests');
        }

        Test.stopTest();
    }

    @isTest
    static void testUpdateProdReqToNotProceeding() {
        Test.startTest();
        System.runAs(currentUser){
            Id productRequestId = [SELECT Id, Name, Product_Request_Status__c FROM Product_Request__c LIMIT 1].Id;
            String response = ProductRequestListCtrl.updateProdReqToNotProceeding(productRequestId, PR_PROGRAM, 'notProceedingComment', false);
            System.assertEquals('Success', response, 'Failed to update record.');
        }
        Test.stopTest();
    }

}