/**
 * @description AssetTriggerHandler Test Class
 * @see AssetTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | john.m.tambasen                | August 10, 2022       | DEPP-3480              | Created file                               |
      | alexander.cadalin              | August 15, 2022       | DEPP-3481              | Updated tests                              |
 */
@isTest
public with sharing class AssetTriggerHandlerTest {
    private static final Id CORPBUNDLE_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Corporate_Bundle').getRecordTypeId();
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    
    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactory.generateTestUsers();
        Test.stopTest();
        
        ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
        insert prodCatalog;
        
        ProductCategory prodCateg = new ProductCategory(
        Name = 'Products',
        CatalogId = prodCatalog.Id
        );
        insert prodCateg;
        
        CommerceEntitlementPolicy commentPolicy = new CommerceEntitlementPolicy(
        Name = 'OPE Entitlement'
        );
        insert commentPolicy;
        
        List<Account> accountList = TestDataFactory.createTestAccountRecords(2);
        
        for(Account acc: accountList){
            acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        }
        insert accountList;
        
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
            prodSpecList[i].RecordTypeId = cceProdSpecId;
        }
        insert prodSpecList;
        
        
        List<Product_Request__c> cbRequest = TestDataFactory.createTestProductRequestRecords(100,prodSpecList[0].Id);
        for(Product_Request__c pr : cbRequest){
            pr.RecordTypeId = CORPBUNDLE_ID;        
        }
        insert cbRequest;
        
        List<Asset> assetInsert = new List<Asset>();
        assetInsert.add(new Asset(
            Name='Corporate Bundle',
            AccountId = accountList[0].Id,
            Product_Request__c = cbRequest[0].Id
        ));
        insert assetInsert;
        
        List<BuyerGroup> bgToInsertList = new List<BuyerGroup>();
        bgToInsertList.add(new BuyerGroup(
            Name = 'Corporate Bundle - ' + accountList[0].Name,
            Product_Request__c = cbRequest[0].Id
        ));
        insert bgToInsertList;
    }
    
    @isTest 
    private static void validateAssetTestPositive() {
        Asset[] assetList = [SELECT Id, Mark_Design_Stage_as_Complete__c FROM Asset LIMIT 1];
        assetList[0].Mark_Design_Stage_as_Complete__c = true;
        Test.startTest();
        Database.SaveResult[] sr = Database.update(assetList, false);
        Test.stopTest();
        
        System.assert(sr[0].isSuccess(), 'Not saved.');
    }

    @isTest
    private static void validateAssetTestNegative() {
        Asset[] assetList = [SELECT Id, Mark_Design_Stage_as_Complete__c, AccountId, Product_Request__c FROM Asset LIMIT 1];
        //assetList[0].Mark_Design_Stage_as_Complete__c = true;
        Id parentPRId = assetList[0].Product_Request__c;
        //update assetList[0];
        Product_Request__c[] parentPRList = [SELECT Id, Product_Request_Status__c FROM Product_Request__c WHERE Id = :parentPRId LIMIT 1];
        parentPRList[0].Product_Request_Status__c = 'Release';
        update parentPRList;
        
        Id assetPRId = assetList[0].Product_Request__c;
        Product_Request__c[] prList = [SELECT Id FROM Product_Request__c WHERE Id != :assetPRId LIMIT 1];

        Asset[] assetFailList = new List<Asset>();
        assetFailList.add(new Asset(
            Name='Corporate Bundle 2',
            AccountId = assetList[0].AccountId,
            Product_Request__c = prList[0].Id
        ));
        insert assetFailList[0];

        assetFailList[0].Mark_Design_Stage_as_Complete__c = true;

        Test.startTest();
        Database.SaveResult[] sr = Database.update(assetFailList, false);
        Test.stopTest();

        System.assert(!sr[0].isSuccess(), 'Saved.');
    }

    @isTest
    private static void validatePublishingTestPositive() {
        Asset[] assetList = [SELECT Id, Ready_for_publishing__c FROM Asset LIMIT 1];
        assetList[0].Ready_for_publishing__c = 'Yes';
        Test.startTest();
        Database.SaveResult[] sr = Database.update(assetList, false);
        Test.stopTest();
        
        System.assert(sr[0].isSuccess(), 'Not saved.');
    }
    
    @isTest
    private static void publishParentTest() {
        Asset[] assetList = [SELECT Id, Ready_for_publishing__c, Publishing_Start_Date__c, Product_Request__c FROM Asset LIMIT 1];
        assetList[0].Ready_for_publishing__c = 'Yes';
        assetList[0].Publishing_Start_Date__c = Date.today();
        Test.startTest();
        update assetList;
        Test.stopTest();

        Id assetParent = assetList[0].Product_Request__c;
        Product_Request__c[] prList = [SELECT Id, Product_Request_Status__c FROM Product_Request__c WHERE Id = :assetParent LIMIT 1];
        System.assert(prList[0].Product_Request_Status__c == 'Published', 'PR Status is not Published.');
    }

    @isTest
    private static void completeParentTest() {
        Asset[] assetList = [SELECT Id, Publishing_End_Date__c, Product_Request__c FROM Asset LIMIT 1];
        assetList[0].Ready_for_publishing__c = 'Yes';
        assetList[0].Publishing_Start_Date__c = Date.today();
        update assetList;
        assetList[0].Decommission__c = true;
        assetList[0].Decommission_Reason__c = 'decomission test';
        assetList[0].End_Date__c = Date.today();
        Test.startTest();
        update assetList;
        Test.stopTest();

        Id assetParent = assetList[0].Product_Request__c;
        Product_Request__c[] prList = [SELECT Id, Product_Request_Status__c FROM Product_Request__c WHERE Id = :assetParent LIMIT 1];
        System.assert(prList[0].Product_Request_Status__c == 'Completed', 'PR Status is not Completed.');
    }
}