/**
 * @description Batch class publish to release Corporate Bundle product requests
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | August 11, 2023       | DEPP-6240              | Created file                 |
      | kenneth.f.alsay                | December 27, 2023     |                        | Removed unused variable      |
 */
@isTest
public with sharing class AssetToReleaseBatchTest {
    private static final String PR_RELEASE = System.Label.PL_ProductRequest_Release;
    private static final String PR_PUBLISHED = System.Label.PL_ProductRequest_Published;
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final Id CORPORATEBUNDLE_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Corporate_Bundle').getRecordTypeId();
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCT_UNIV_DEP)
      .getRecordTypeId();

    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }

    @isTest
    private static void runPublishToReleaseTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            // create business account
            List<Account> accountList = TestDataFactory.createTestAccountRecords(2);
            for(Account acc: accountList){
                acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            }
            insert accountList;

            // create account for that business account
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

            // create product request
            List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();

            List<Product_Request__c> cbRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c pr : cbRequest){
                pr.RecordTypeId = CORPORATEBUNDLE_ID; 
                pr.Product_Request_Status__c = PR_PUBLISHED;
            }
            insert cbRequest;

            // since product request is created, create a asset
            Asset aInsert = new Asset();
            aInsert.Name = accountList[0].Name + ' ' + String.valueofGmt(System.now());
            aInsert.AccountId = accountList[0].Id;
            aInsert.Product_Request__c = cbRequest[0].Id;
            aInsert.Ready_for_publishing__c = 'Yes';
            aInsert.Publishing_Start_Date__c = Date.Today().addDays(-1);
            aInsert.Publishing_End_Date__c = Date.Today();
            aInsert.End_Date__c = Date.Today().addDays(1);
            insert aInsert;

            BuyerGroup bgInsert = new BuyerGroup();
            bgInsert.Name = accountList[0].Name + ' ' + String.valueofGmt(System.now());
            bgInsert.Product_Request__c = cbRequest[0].Id;
            insert bgInsert;
            
            // create a child product request for corporate bundle
            List<Product_Request__c> courseRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c pr : courseRequest){
                pr.RecordTypeId = ACTIVITY_ID;        
            }
            insert courseRequest;

            List<hed__Course__c> courses;
            courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,courseRequest[0].Id);
            for(hed__Course__c c: courses){
                c.RecordTypeId = ACTIVITY_COURSE_ID;
            }
            insert courses;

            // update product list to published
            List<Product2> productsList = new List<Product2>([SELECT Id FROM Product2 WHERE Course__c IN: courses]);
            for(Product2 prod: productsList){
                prod.QA_Comments__c = 'test comment';
                prod.QA_Review_Completed__c = 'Yes';
                prod.Ready_for_publishing__c = 'Yes';
                prod.Publishing_Start_Date__c = Date.Today().addDays(-1);
                prod.Publishing_End_Date__c = Date.Today();
                prod.End_Date__c = Date.Today().addDays(1);
            }

            update productsList;

            Test.startTest();
                AssetToReleaseBatch batch = new AssetToReleaseBatch();
                Database.executeBatch(batch);
            Test.stopTest();
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'AssetToReleaseBatch'].isEmpty() , 'AssetToReleaseBatch Job was not executed');
        }
    }

}