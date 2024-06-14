/**
 * @description AssetTriggerHelper Test Class
 * @see AssetTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | alexander.cadalin              | August 15, 2022       | DEPP-3481              | Created file                               |
      | eccarius.karl.munoz  	       | November 17, 2022     | DEPP-4014              | Added validateExistingPublishedAssetTest   |
 */
@isTest
public with sharing class AssetTriggerHelperTest {
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
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
        System.runAs(PROGRAM_ADMIN){
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
            
            List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,conList.iterator().next()?.Id);
            insert oppList;
            
            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();
        
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
        
    }

    @isTest
    private static void validatePublishingTestPositive() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Asset[] assetList = [SELECT Id, Ready_for_publishing__c FROM Asset LIMIT 1];
            assetList[0].Ready_for_publishing__c = 'Yes';
            Test.startTest();
            Database.SaveResult[] sr = Database.update(assetList, false);
            Test.stopTest();
            
            System.assert(sr[0].isSuccess(), 'Not saved.');
        }
        
    }

    @isTest
    private static void publishParentTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
    }

    @isTest
    private static void completeParentTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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

    @isTest
    private static void validateExistingPublishedAssetTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Asset> assetList = [SELECT Id, Ready_for_publishing__c, Product_Request__c, AccountId, ContactId FROM Asset LIMIT 1];
            assetList[0].Ready_for_publishing__c = 'Yes';
            
            List<Product_Request__c> prodReqs = [SELECT Id FROM Product_Request__c WHERE Id =: assetList[0].Product_Request__c LIMIT 1];
            for(Product_Request__c p : prodReqs){
                p.Product_Request_Status__c = 'Published';
            }
            update prodReqs;

            List<Asset> publishedAssets = new List<Asset>();
            for(Asset a : assetList){
                publishedAssets.add(
                    new Asset(
                        Name = 'Published Asset', 
                        AccountId = a.AccountId, 
                        ContactId = a.ContactId, 
                        Ready_for_Publishing__c = 'Yes', 
                        Product_Request__c = prodReqs[0].Id
                    )
                );
            }
            insert publishedAssets;

            Test.startTest();
            Database.SaveResult[] sr = Database.update(assetList, false);
            Test.stopTest();
            
            System.assert(!sr[0].isSuccess(), 'There should not be more than 1 active Corporate Bundle per Product Specification');
        }
    }
}