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
 */
@isTest
public with sharing class CommunitiesLoginControllerTest {

    @isTest
    public static void testCommunitiesLoginController () {
     	CommunitiesLoginController controller = new CommunitiesLoginController();
     	System.assertEquals(null, controller.forwardToAuthPage());       
    }    
}
