/**
 * @description Tests the Add Product Request Controller Test Class
 *
 * @see AddProductRequestCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | roy.nino.s.regala         | October 01, 2021      | DEPP40,42 | Created file                    |
      | adrian.c.habasa           | January 20, 2022      | DEPP-1471 | Added Test Class Method         |
*/
@isTest
private class AddProductRequestCtrlTest {

    private static final String PRODUCT_REQ_API_NAME = Product_Request__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(ACTIVITY).getRecordTypeId();
    private static final string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static final String PRODUCT_SPEC_RT = System.Label.RT_ProductSpecification_OPEProgramSpecification;
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(PRODUCT_SPEC_RT).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final String QUTEX = System.Label.QUTeX;
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
  
    @testSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();

        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;
        List<Contact> conList;
        conList = TestDataFactory.createTestContactRecords(1);
        insert conList;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(1,accounts[0].Id,conList.iterator().next()?.Id);
        insert oppList;
        List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList);
            for(Integer i = 0 ; i < prodSpecList.size() ; i++){
                prodSpecList[i].RecordTypeId = opeProdSpecId;
                prodSpecList[i].Stage__c = 'Idea';
                prodSpecList[i].Status__c = 'Idea Sent';
                prodSpecList[i].Requestor_Name__c = conList[i].Id;
        }
        insert prodSpecList;

        List<Product_Request__c> prodRequestOPEProgramRequest;
        prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
        prodRequestOPEProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequest;

        List<hed__Program_Plan__c> programPlanList;
        programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanList[0].Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        insert programPlanList;


        List<Product_Request__c> prodRequest;
        prodRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
        prodRequest[0].RecordTypeId = ACTIVITY_ID;
        insert prodRequest;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        insert courses;
    }

    @isTest
    private static void testGetQUTeXAccountId(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
           List<Account> acc= TestDataFactory.createTestAccountRecords(1);
           Account a = new Account(Name = 'QUTeX Products');
           acc.add(a);
           insert acc;
           String accId=AddProductRequestCtrl.getAccountId();
           system.assert(!String.isBlank(accId),'No QUTeX Products Account Found');
        }
        Test.stopTest();
    }

    @isTest
    private static void getUsers(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='QUTeX']; 
        User u = new User();
            u.LastName = 'Test 2';
            u.UserName = 'TestPr1'+'@mailinator.com';
            u.Email = 'testuser1@mailinator.com';
            u.ProfileId = p.id;
            String alias = 'test';
            u.alias = alias;
            u.LanguageLocaleKey = 'en_US';
            u.localesidkey = UserInfo.getLocale();
            u.emailEncodingKey = 'UTF-8';
            u.timeZoneSidKey = 'Australia/Brisbane';
           insert u;
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
           List<Map<String,String>> us =AddProductRequestCtrl.getSearchedUsers('Test 2');
           Test.stopTest();
           System.assert(!us.isEmpty(), 'user did not match as expected');
        }
        
    
    }

    @isTest
    private static void testGetRecordTypes(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<Map<String,String>> recordTypeMap = AddProductRequestCtrl.getRecordTypes(PRODUCT_REQ_API_NAME);
            Test.stopTest();
            System.assertEquals(ACTIVITY, recordTypeMap[0].get('label'), 'Record type did not match as expected');
        }
    }

    @isTest
    private static void testGetSearchedCourseProductRequests(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            AddProductRequestCtrl.SearchProductRequestParameters searchParameters = new AddProductRequestCtrl.SearchProductRequestParameters();
            searchParameters.filterPRList = new List<Product_Request__c>();
            searchParameters.filterString = 'Course';
            searchParameters.prodSpecRecordType = PRODUCT_SPEC_RT;
            searchParameters.isSOA = false;
            List<Product_Request__c> searchProduct = AddProductRequestCtrl.getSearchedProductRequests(searchParameters);
            Test.stopTest();
            System.assert(!searchProduct.isEmpty(),'Could not find search product');
        }
    }

    @isTest
    private static void testGetSearchedCourseProductRequestsSOA(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            AddProductRequestCtrl.SearchProductRequestParameters searchParameters = new AddProductRequestCtrl.SearchProductRequestParameters();
            searchParameters.filterPRList = new List<Product_Request__c>();
            searchParameters.filterString = 'Course';
            searchParameters.prodSpecRecordType = PRODUCT_SPEC_RT;
            searchParameters.isSOA = true;
            List<Product_Request__c> searchProduct = AddProductRequestCtrl.getSearchedProductRequests(searchParameters);
            Test.stopTest();
            System.assert(!searchProduct.isEmpty(),'Could not find search product');
        }
    }

    @isTest
    private static void testCreateBuyerGroupAndEntitlement(){

        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        insert acc;
        WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
        insert testWebStore;

        Id productRequestId = null;
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            Test.startTest();
            productRequestId = [SELECT Id FROM Product_Request__c LIMIT 1]?.Id;
            AddProductRequestCtrl.BuyerGroupAndEntDetails details = new AddProductRequestCtrl.BuyerGroupAndEntDetails();
            details.productRequestId = productRequestId;
            details.accountId = acc.Id;
            details.accountName = acc.Name;
            details.isCorporateBundle = true;
            details.isSoa = false;
            AddProductRequestCtrl.createBuyerGroupAndEntitlement(details);
            Test.stopTest();
        }

        List<BuyerGroup> buyerGroups = [SELECT Id FROM BuyerGroup WHERE Product_Request__c=:productRequestId];
        System.assert(buyerGroups != null, 'BuyerGroup should be created.');
    }
}