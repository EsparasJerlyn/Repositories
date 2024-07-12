/**
 * @description Test class for Related Child Products Controller
 *
 * @see RelatedChildProductsCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                |
      |---------------------------|-----------------------|--------------|-----------------------------------------------|
      | angelika.j.s.galang       | May 4, 2022           | DEPP-2342    | Created file                                  |
      |                           |                       |              |                                               |
*/
@isTest
private class RelatedChildProductsCtrlTest {

    private static final String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final String PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static final Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();

    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
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
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequest;

        List<Product_Request__c> prodRequest;
        prodRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequest[0].RecordTypeId = opeActProdReqId;
        insert prodRequest;

        List<Related_Product_Request__c> relatedProductRequests;
        relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodRequest,prodRequestOPEProgramRequest);
        insert relatedProductRequests;
    }

    @isTest
    private static void getRelatedChildProductsTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Id productRequestId = [SELECT Id FROM Product_Request__c WHERE RecordType.Name = :PR_PROGRAM]?.Id;
            Test.startTest();
            List<Related_Product_Request__c> relatedPRList = RelatedChildProductsCtrl.getRelatedChildProducts(productRequestId);
            Test.stopTest();
            System.assertEquals(1, relatedPRList.size(), 'Related Product Request not retrieved as expected');
        }
    }
}
