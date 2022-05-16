@IsTest(SeeAllData=false) 
public class MainNavigationMenuCtrlTest {

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
    public static void getStoreFrontCategoriesTest(){
        final String COMMUNITY_NAME = 'CCE';
        B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
		
        ProductCatalog cat =new ProductCatalog(Name='CCE');
        insert cat;
        ProductCategory cate = new ProductCategory(CatalogId=cat.Id,
                                                  Name='Corporate Bundle');
        insert cate;
        
        Test.startTest();
		System.assert(cate != null, 'Pass');
        Test.stopTest();

    }

}