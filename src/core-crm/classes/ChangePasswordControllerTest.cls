/**
 * An apex page controller that exposes the change password functionality
 */
@isTest public with sharing class ChangePasswordControllerTest {
   	@isTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null, 'Must be null.');                           
    }    
}