/**
 * @description BuyerGroupTriggerHandler Test Class
 * @see BuyerGroupTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | eccarius.munoz                 | November 22, 2022     | DEPP-4014              | Created File                               |
 */
@isTest
public with sharing class BuyerGroupPublishingHelperTest {
    private static final Id SOA_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Standing_Offer_Arrangement').getRecordTypeId();
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
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();

        ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
        insert prodCatalog;

        ProductCategory prodCateg = new ProductCategory(
            Name = 'Products',
            CatalogId = prodCatalog.Id
        );
        insert prodCateg;

        CommerceEntitlementPolicy commEntPolicy = new CommerceEntitlementPolicy(
            Name = 'OPE Entitlement'
        );
        insert commEntPolicy;

        List<Account> accountList = setupBusinessAccounts();
        insert accountList;

        List<Account> accounts = setupUnivDeptAccounts();        
        insert accounts;

        List<Contact> conList;
        conList = TestDataFactory.createTestContactRecords(1);
        insert conList;

        List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,conList.iterator().next()?.Id);
        insert oppList;

        List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();


        List<Product_Request__c> soaRequest = TestDataFactory.createTestProductRequestRecords(100,prodSpecList[0].Id);

        for(Product_Request__c pr : soaRequest){
            pr.RecordTypeId = SOA_ID;        
        }
        insert soaRequest;

        List<BuyerGroup> bgToInsertList = new List<BuyerGroup>();

        for(Integer i = 0; i < soaRequest.size(); i++){
            bgToInsertList.add(new BuyerGroup(
            Name = soaRequest[i].Product_Request_Name__c, 
            Product_Request__c = soaRequest[i].Id
            ));
        }
        
        insert bgToInsertList;
    }

    @isTest
    private static void publishToDecomissionTest() {
        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        List<BuyerGroup> bgList = new List<BuyerGroup>([
            SELECT Id, Ready_for_publishing__c
            FROM BuyerGroup
        ]);
    
        for(BuyerGroup bg: bgList){
            bg.Ready_for_publishing__c = 'Yes';
            bg.Publishing_End_Date__c = Date.Today() + 5;
            bg.Publishing_Start_Date__c = Date.Today();
        }

        Test.startTest();
        update bgList;
        for(BuyerGroup bg: bgList){
            bg.Decommission__c = true;
            bg.Decommission_Reason__c = 'reason';
            bg.End_Date__c = Date.Today();
        }
        update bgList;
        Test.stopTest();
    
        system.assert(![SELECT Id FROM BuyerGroup WHERE Ready_for_publishing__c = 'Yes' And Publishing_End_Date__c = TODAY].isEmpty(),'No buyergroup published');
        }
    }

    private static List<Account> setupBusinessAccounts(){
        List<Account> accountList = TestDataFactory.createTestAccountRecords(2);
        for(Account acc: accountList){
            acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        }
        return accountList;
    }

    private static List<Account> setupUnivDeptAccounts(){
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        return accounts;
    }
}
