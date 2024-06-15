/**
 * An apex page controller that exposes the site forgot password functionality
 */
@isTest 
public with sharing class ForgotPasswordControllerTest {
	@testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }
  	 @isTest
	 public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
		System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null, 'Must be null.'); 
		}
    }
}