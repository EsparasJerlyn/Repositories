/**
 * @description An apex page controller that exposes the site login functionality
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li                   | January 3, 2023       | N/A                    | Fix PMD issue                |
      |                                |                       |                        |                              |
 
 */
@isTest public with sharing class SiteLoginControllerTest {      

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
    }

    @isTest
    public static void testSiteLoginController () {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            // Instantiate a new controller with all parameters in the page
            SiteLoginController controller = new SiteLoginController ();
            controller.username = 'test@salesforce.com';
            controller.password = '123456'; 
                    
            System.assertEquals(controller.login(),null,'Login is not null.');                           
        }  
    }
}