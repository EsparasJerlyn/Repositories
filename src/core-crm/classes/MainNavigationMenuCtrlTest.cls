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
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }

    @isTest
    public static void getOpportunityContractTypeTest(){
        
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {

            User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
            insert currentUser;
            Test.startTest();
            List<Opportunity> opp = MainNavigationMenuCtrl.getOpportunityContractType(currentUser.id);
            Test.stopTest();
            System.assert(opp != null, 'Pass');
        }     
    }
    
    @isTest
    public static void defaultMenuTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            List<NavigationMenuItem> navMenu = MainNavigationMenuCtrl.defaultMenu();
            System.assert(navMenu.size() == 0, 'Pass');
            Test.stopTest();
        }

    }

        @isTest
    public static void getStoreFrontCategoriesCCETest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            final String COMMUNITY_NAME = 'CCE';
            String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
            
            ProductCatalog cat =new ProductCatalog(Name='CCE');
            insert cat;
            ProductCategory cate = new ProductCategory(CatalogId=cat.Id,
                                                    Name='Corporate Bundle');
            insert cate;

            Test.startTest();
            List<ProductCategory> categories = MainNavigationMenuCtrl.getStoreFrontCategories(communityId);
            System.assert(categories != null, 'Pass');
            Test.stopTest();
        }

    }
    
    @isTest
    public static void getStoreFrontCategoriesStudyTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
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

    }
    
    @isTest
    public static void getStudyProductsTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
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
            System.assert(categories != null, 'Pass');
            Test.stopTest();
        }
        
    }
    @isTest
    public static void getAccountNameTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();     
            String accountName = MainNavigationMenuCtrl.getAccountName('');
            System.assert(String.isBlank(accountName), 'Has account name');
            Test.stopTest();
        }
    }    
    
}