@IsTest(SeeAllData=false) 
public class MainNavigationMenuCtrlTest {

    @isTest
    public static void getOpportunityContractTypeTest(){
        
    	User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
        insert currentUser;
		System.debug(currentUser);        

       Test.startTest();
		List<Opportunity> opp = MainNavigationMenuCtrl.getOpportunityContractType(currentUser.id);
        Test.stopTest();
		System.assert(opp != null, 'Pass');        
    }
    
    @isTest
    public static void defaultMenuTest(){
        System.debug('1111');
        Test.startTest();
        List<NavigationMenuItem> navMenu = MainNavigationMenuCtrl.defaultMenu();
        System.debug('2342'+navMenu);
		System.assert(navMenu.size() == 0, 'Pass');
        Test.stopTest();

    }

        @isTest
    public static void getStoreFrontCategoriesCCETest(){
        String COMMUNITY_NAME = 'CCE';
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
		
        ProductCatalog cat =new ProductCatalog(Name='CCE');
        insert cat;
        ProductCategory cate = new ProductCategory(CatalogId=cat.Id,
                                                  Name='Corporate Bundle');
        insert cate;
        
        Test.startTest();
        List<ProductCategory> Categories = MainNavigationMenuCtrl.getStoreFrontCategories(communityId);
		System.assert(cate != null, 'Pass');
        Test.stopTest();

    }
    
    @isTest
    public static void getStoreFrontCategoriesStudyTest(){
        String COMMUNITY_NAME = 'STUDY';
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
		
        ProductCatalog cat =new ProductCatalog(Name='STUDY');
        insert cat;
        ProductCategory cate = new ProductCategory(CatalogId=cat.Id,
                                                  Name='Products');
        insert cate;
        
        Test.startTest();
        List<ProductCategory> Categories = MainNavigationMenuCtrl.getStoreFrontCategories(communityId);
		System.assert(cate != null, 'Pass');
        Test.stopTest();

    }
    
    @isTest
    public static void getStudyProductsTest(){
        String COMMUNITY_NAME = 'STUDY';
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
        ProductCatalog cat =new ProductCatalog(Name='STUDY');
        
        insert cat;
        ProductCategory cate = new ProductCategory(CatalogId=cat.Id,
                                                  Name='Products');
        insert cate;
     
        Test.startTest();     
        List<ProductCategory> Categories = MainNavigationMenuCtrl.getStudyProducts(communityId);
		System.assert(cate != null, 'Pass');
        Test.stopTest();
    }
}