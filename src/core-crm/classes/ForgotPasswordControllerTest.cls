/**
 * An apex page controller that exposes the site forgot password functionality
 */
@isTest 
public with sharing class ForgotPasswordControllerTest {
  	 @isTest
	 public static void testForgotPasswordController() {
		TestDataFactory.generateTestUsers(new List<String>{'QUT_Sys_Admin'});
    	// Instantiate a new controller with all parameters in the page
		System.runAs(TestDataFactory.getPortalSysAdminUser()){
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null, 'Must be null.'); 
		}
    }
}