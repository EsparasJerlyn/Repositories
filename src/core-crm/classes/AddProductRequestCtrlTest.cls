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
@isTest(SeeAllData=false)
private class AddProductRequestCtrlTest {

    private static final String PRODUCT_REQ_API_NAME = Product_Request__c.SObjectType.getDescribe().getLocalName();
    private static final String ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(ACTIVITY).getRecordTypeId();
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static final String PRODUCT_SPEC_RT = System.Label.RT_ProductSpecification_OPEProgramSpecification;
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(PRODUCT_SPEC_RT).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    static testMethod void testGetFieldLayoutSettings() {
        Test.startTest();
        System.runAs(currentUser){
            AddProductRequestCtrl.MetadataDetails getMetadata = new AddProductRequestCtrl.MetadataDetails();
            getMetadata = AddProductRequestCtrl.getFieldLayoutSettings('Product_Request__c',false);
            system.assert( !getMetadata.fieldLayoutMap.isEmpty(), 'unable to get recordtype and layout metadata');
        }
        Test.stopTest();
    }

    static testMethod void testGetFieldLayoutSettingsError() {
        Test.startTest();
        try{
            System.runAs(currentUser){
                AddProductRequestCtrl.MetadataDetails getMetadata = new AddProductRequestCtrl.MetadataDetails();
                getMetadata = AddProductRequestCtrl.getFieldLayoutSettings(null,null);
            }
        }catch(Exception e){
            system.assertEquals('Error while getting record type and layout mapping.',e.getMessage(),'Exception should have been thrown');
        }
        Test.stopTest();
    }

    @isTest
    private static void testGetQUTeXAccountId(){
        Test.startTest();
        System.runAs(currentUser){
           List<Account> acc= TestDataFactory.createTestAccountRecords(1);
           Account a = new Account(Name = 'QUTeX');
           acc.add(a);
           insert acc;
           String accId=AddProductRequestCtrl.getAccountId();
           system.assert(!String.isBlank(accId),'No QUTeX Account Found');
        }
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordTypes(){
        System.runAs(currentUser){
            Test.startTest();
            List<Map<String,String>> recordTypeMap = AddProductRequestCtrl.getRecordTypes(PRODUCT_REQ_API_NAME);
            Test.stopTest();
            System.assertEquals(ACTIVITY, recordTypeMap[0].get('label'), 'Record type did not match as expected');
        }
    }

    @isTest
    private static void testGetSearchedCourseProductRequests(){
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

        System.runAs(currentUser){
            Test.startTest();
            List<Product_Request__c> searchProduct = AddProductRequestCtrl.getSearchedCourseProductRequests('Course',new List<Product_Request__c>(),PRODUCT_SPEC_RT);
            Test.stopTest();
            System.assert(!searchProduct.isEmpty(),'Could not find search product');
        }
    }
}