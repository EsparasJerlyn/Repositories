/**
 * @description An apex page controller that exposes the site login functionality
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | August 8, 2022        | DEPP-1386              | Removed SeeAllData           |
      | marygrace.li                   | January 3, 2023       | N/A                    | Fix PMD issue                |
 */
@isTest
public with sharing class CommunitiesLoginControllerTest {

    @isTest
    public static void testCommunitiesLoginController () {
            Test.startTest();
            TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
            Test.stopTest();

            System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            CommunitiesLoginController controller = new CommunitiesLoginController();
            System.assertEquals(null, controller.forwardToAuthPage(),'Forward to AuthPage is not null.');       
        }    
    }
}
