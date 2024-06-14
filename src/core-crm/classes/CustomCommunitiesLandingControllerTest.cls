/**
 * @description An apex page controller that takes the user to the right start page based on credentials or lack thereof
 * @see ../
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | August 23, 2022       | DEPP-3676            | Created file                 |
      |                           |                       |                      |                              | 
 */
@isTest 
public with sharing class CustomCommunitiesLandingControllerTest {
    @testSetup static void setupMethod() {
     TestDataFactoryUser.generateUserSystemAdministrator();
 		WebStore testWebStore = new WebStore( Name = 'CCE', DefaultLanguage = 'en_US');
    	     insert testWebStore; 
	}
    
	@isTest
    public static void testCustomCommunitiesLandingController() {
     final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
     Test.startTest();
     System.runAs(PORTAL_SYS_ADMIN){
          // Instantiate a new controller with all parameters in the page
          CustomCommunitiesLandingController controller = new CustomCommunitiesLandingController();
          PageReference pageRef = controller.forwardToCustomStartPage();
          //PageRef is either null or an empty object in test context
          if(pageRef != null){
              System.assertEquals(true, String.isNotEmpty(String.valueOf(pageRef)),'null');
          }
     }
     Test.stopTest();
  	}
}