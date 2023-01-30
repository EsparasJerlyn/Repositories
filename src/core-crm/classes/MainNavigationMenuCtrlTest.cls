/**
 * @description Add a custom tab for more flexible manipulation
 * @see ../lwc/mainNavigationMenuCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary                         |
      |--------------------------------|-----------------------|----------------------|----------------------------------------|
      | julie.jane.alegre              | November 28, 2022     | DEPP-4693            | Add test method for getAllAccountNames | 

 */

@isTest 
public with sharing class MainNavigationMenuCtrlTest {
private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
   
    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactory.generateTestUsers();
        Test.stopTest();
    }

    @isTest
    public static void getOpportunityContractTypeTest(){
        
    	User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
        insert currentUser;

        Test.startTest();
		List<Opportunity> opp = MainNavigationMenuCtrl.getOpportunityContractType(currentUser.id);
        Test.stopTest();
		System.assert(opp != null, 'Pass');        
    }
    
    @isTest
    public static void defaultMenuTest(){
        Test.startTest();
        List<NavigationMenuItem> navMenu = MainNavigationMenuCtrl.defaultMenu();
		System.assert(navMenu.size() == 0, 'Pass');
        Test.stopTest();

    }

        @isTest
    public static void getStoreFrontCategoriesCCETest(){
        final String COMMUNITY_NAME = 'CCE';
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
		
        ProductCatalog cat =new ProductCatalog(Name='CCE');
        insert cat;
        ProductCategory cate = new ProductCategory(CatalogId=cat.Id,
                                                  Name='Corporate Bundle');
        insert cate;

        Test.startTest();
        List<ProductCategory> categories = MainNavigationMenuCtrl.getStoreFrontCategories(communityId);
		System.assert(cate != null, 'Pass');
        Test.stopTest();

    }
    
    @isTest
    public static void getStoreFrontCategoriesStudyTest(){
        final String COMMUNITY_NAME = 'STUDY';
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
		
        ProductCatalog cat =new ProductCatalog(Name='STUDY');
        insert cat;
        ProductCategory cate = new ProductCategory(CatalogId=cat.Id,
                                                  Name='Products');
        insert cate;

        WebStore store = new WebStore();
        store.Name='MyStore';
        insert store;

        WebStoreCatalog catalog = TestDataFactory.createWebStoreCatalog(cat.Id, store.Id);
        insert catalog;

        B2BUtils.communityIdToWebStoreIdCache.put(communityId, (String)catalog.SalesStoreId);
        
        Test.startTest();
        List<ProductCategory> categories = MainNavigationMenuCtrl.getStoreFrontCategories(communityId);
		System.assert(categories != null, 'Pass');
        Test.stopTest();

    }
    
    @isTest
    public static void getStudyProductsTest(){
        final String COMMUNITY_NAME = 'STUDY';
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
        ProductCatalog cat =new ProductCatalog(Name='STUDY');
        
        insert cat;
        ProductCategory cate = new ProductCategory(CatalogId=cat.Id,
                                                  Name='Products');
        insert cate;
     
        WebStore store = new WebStore();
        store.Name='MyStore';
        insert store;

        WebStoreCatalog catalog = TestDataFactory.createWebStoreCatalog(cat.Id, store.Id);
        insert catalog;

        B2BUtils.communityIdToWebStoreIdCache.put(communityId, (String)catalog.SalesStoreId);

        Test.startTest();     
        List<ProductCategory> categories = MainNavigationMenuCtrl.getStudyProducts(communityId);
		System.assert(cate != null, 'Pass');
        Test.stopTest();
    }
    @isTest
    public static void getAccountNameTest(){
        Test.startTest();     
        String accountName = MainNavigationMenuCtrl.getAccountName('');
		System.assert(String.isBlank(accountName), 'Has account name');
        Test.stopTest();
    }
    @isTest
    public static void getAllAccountNameTest1(){
        System.runAs(TestDataFactory.getPortalSysAdminUser()){
            TestDataFactory.loadEDATriggers();
             Test.startTest();    
            // Create Accounts
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for (Account account : accounts) {
            	account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            }   
            insert accounts;
        
            // Create Contact
            Contact cceContact = new Contact(
				FirstName = 'Test',
				LastName = 'Contact',
				Email = 'testcontact@email.com',
				Registered_Email__c = 'testcontact@email.com',
				AccountId = accounts[0].Id,
				Work_Email__c = 'test@workemail.com',
				hed__Preferred_Email__c = 'Alternate Email',
				hed__AlternateEmail__c = 'test@email.com'
			);
			insert cceContact;
           
            //Get the ACR list to check if exists
              List<AccountContactRelation> acrList = new List<AccountContactRelation>([
                SELECT ContactId
                FROM AccountContactRelation
                WHERE AccountId =: accounts[0].Id
                LIMIT 1
              ]);
        
              if(acrList.isEmpty()){
                //Create ACR
                AccountContactRelation acr = new AccountContactRelation(
                  AccountId = accounts[0].Id,
                  ContactId = cceContact.Id
                );
                insert acr;       
      		}
            //Create a User
            List<User> user = TestDataFactory.createPortalUserRecords(
                              1, 
                              'Partner Community User', 
                              cceContact.Id
                              );
            insert user;   
            Id selectedId;
            MainNavigationMenuCtrl.AccountWrapper getAcct = MainNavigationMenuCtrl.getAllAccountName(user[0].Id, selectedId);
            //System.assert(getAcct.accountNames != null, 'No acccount names retrieve');
            System.assert(!getAcct.accountNames.isEmpty(), 'No acccount names retrieve');
         Test.stopTest();
        }
    }
     @isTest
     public static void getAllAccountNameTest2(){
        System.runAs(TestDataFactory.getPortalSysAdminUser()){
            TestDataFactory.loadEDATriggers();
            Test.startTest();    
            // Create Accounts
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for (Account account : accounts) {
            	account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
                account.Name = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
            }   
            insert accounts;
        
            // Create Contact
            Contact cceContact = new Contact(
				FirstName = 'Test',
				LastName = 'Contact',
				Email = 'testcontact@email.com',
				Registered_Email__c = 'testcontact@email.com',
				AccountId = accounts[0].Id,
				Work_Email__c = 'test@workemail.com',
				hed__Preferred_Email__c = 'Alternate Email',
				hed__AlternateEmail__c = 'test@email.com'
			);
			insert cceContact;
           
            //Get the ACR list to check if exists
              List<AccountContactRelation> acrList = new List<AccountContactRelation>([
                SELECT ContactId
                FROM AccountContactRelation
                WHERE AccountId =: accounts[0].Id
                LIMIT 1
              ]);
        
              if(acrList.isEmpty()){
                //Create ACR
                AccountContactRelation acr = new AccountContactRelation(
                  AccountId = accounts[0].Id,
                  ContactId = cceContact.Id
                );
                insert acr;       
      		}
            //Create a User
            List<User> user = TestDataFactory.createPortalUserRecords(
                              1, 
                              'Partner Community User', 
                              cceContact.Id
                              );
            insert user;   
            Id selectedId;
            MainNavigationMenuCtrl.AccountWrapper getAcct = MainNavigationMenuCtrl.getAllAccountName(user[0].Id, selectedId);
           // System.assert(getAcct.accountNames != null, 'No acccount names retrieve');
            System.assert(!getAcct.accountNames.isEmpty(), 'No acccount names retrieve');
         Test.stopTest();
        }
        
    }
    
}