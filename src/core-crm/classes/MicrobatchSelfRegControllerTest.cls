@isTest
 public with sharing class MicrobatchSelfRegControllerTest {
      @isTest
     public static void testMicrobatchSelfRegController() {
      TestDataFactory.generateTestUsers(new List<String>{ 'System_Administrator' });
        System.runAs(TestDataFactory.getSystemAdminUser()){
         MicrobatchSelfRegController controller = new MicrobatchSelfRegController();
         controller.firstName = 'FirstName';
         controller.lastName = 'LastName';
         controller.email = 'test@force.com';
         controller.communityNickname = 'test';

         // registerUser will always return null when the page isn't accessed as a guest user
         System.assert(controller.registerUser() == null, 'Must be null.');
        }
     }
 }