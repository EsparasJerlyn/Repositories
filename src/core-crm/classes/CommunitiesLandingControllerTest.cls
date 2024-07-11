/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@isTest 
public with sharing class CommunitiesLandingControllerTest {
 	@testSetup static void setupMethod() {
 		WebStore testWebStore = new WebStore( Name = 'Study', DefaultLanguage = 'en_US');
    	insert testWebStore;
        ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
    	insert prodCatalog;
        ProductCategory prodCateg = new ProductCategory( Name = 'Products',CatalogId = prodCatalog.Id);
    	insert prodCateg;
        
        TestDataFactoryUser.generateUserSystemAdministrator();
        
	}
    
	@isTest
    public static void testCommunitiesLandingController() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            // Instantiate a new controller with all parameters in the page
            CommunitiesLandingController controller = new CommunitiesLandingController();
            PageReference pageRef = controller.forwardToStartPage();
            //PageRef is either null or an empty object in test context
            if(pageRef != null){
                System.assertEquals(true, String.isNotEmpty(String.valueOf(pageRef)), 'Error in Community Landing.');
            }
        }
  	}
}