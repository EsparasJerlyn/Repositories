/**
 * An apex page controller that exposes the change password functionality
 */
@isTest public with sharing class ChangePasswordControllerTest {
    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactory.generateTestUsers();
        Test.stopTest();
    }

    @isTest
    public static void testChangePasswordController() {
        final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
        System.runAs(PORTAL_SYS_ADMIN) {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null, 'Must be null.');      
    }    
  }
}