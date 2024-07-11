/**
 * @description Tests the ProductManagementCtrl Test Class
 *
 * @see ProductManagementCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | roy.nino.s.regala         | March 10, 2022        | DEPP1747  | Created file                    |
      | alexander.cadalin         | July 26, 2022         | DEPP-2500 | Added test for checkParentIsSOA |
*/
@isTest
private class ProductManagementCtrlTest {
    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static string PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();

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
        prodRequestOPEProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        prodRequestOPEProgramRequest[0].OPE_Program_Plan_Type__c = 'Flexible Program';
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
    static void testCheckParentProgramTypeTrue() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Boolean hasNoPrescribedProgramAsParent;
            hasNoPrescribedProgramAsParent = ProductManagementCtrl.checkParentProgramType([SELECT Id FROM Product_Request__c WHERE RecordTypeId =: opeActProdReqId LIMIT 1][0].Id);
            system.assert( hasNoPrescribedProgramAsParent, 'Parent product request should not be a prescribed program');
        }

        Test.stopTest();
    }

    @isTest
    static void testCheckParentProgramTypeFalse() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Boolean hasNoPrescribedProgramAsParent;
            update(new Product_Request__c(Id = [SELECT Id FROM Product_Request__c WHERE RecordTypeId =: opeProgProdReqId LIMIT 1][0].Id, OPE_Program_Plan_Type__c ='Prescribed Program'));
            hasNoPrescribedProgramAsParent = ProductManagementCtrl.checkParentProgramType([SELECT Id FROM Product_Request__c WHERE RecordTypeId =: opeActProdReqId LIMIT 1][0].Id);
            system.assert( !hasNoPrescribedProgramAsParent, 'Parent product request should be a prescribed program');
        }

        Test.stopTest();
    }

    @isTest
    static void testCheckAvailableOnCart() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Boolean isAvailableOnCart;
            isAvailableOnCart = ProductManagementCtrl.checkAvailableOnCart([SELECT Id FROM Product_Request__c WHERE RecordTypeId =: opeActProdReqId LIMIT 1][0].Id);
            system.assert( !isAvailableOnCart, 'is AvailableOnCart');
        }

        Test.stopTest();
    }

    @isTest
    static void testCheckParentIsSOA() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Boolean parentIsSOA;
            parentIsSOA = ProductManagementCtrl.checkParentIsSOA([SELECT Id FROM Product_Request__c LIMIT 1].Id);
            system.assert( !parentIsSOA, 'is ParentSOA');
        }
        Test.stopTest();
    }
}