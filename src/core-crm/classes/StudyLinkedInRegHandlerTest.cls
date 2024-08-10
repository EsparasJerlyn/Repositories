/**
 * @description Tests Class for LinkedInHandler
 * @see LinkedInHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | November 24, 2021     | DEPP-771               | Created file                 | 
      |                                |                       |                        |                              | 
 */

@isTest
public without sharing class StudyLinkedInRegHandlerTest {

    @testSetup
    static void makeData(){
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void createUserTest(){
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        StudyLinkedInRegHandler handler = new StudyLinkedInRegHandler();
        Auth.UserData data = TestDataFactory.createCommunityUser('testdata@test.com', 'Data', 'Test', 'tUser');

        system.runAs(PORTAL_SYS_ADMIN) { 

            Test.startTest();
            Account testAccount = new Account();
            testAccount.Name = 'QUT Experience';
            insert testAccount;

            User u = handler.createUser(null, data);

            System.assert(u !=null,'User must not be null');
            System.assertEquals(u.email, data.email,'Email address must be the same');
            System.assertEquals(u.lastName,data.LastName, 'First name must match');
            System.assertEquals(u.firstName,data.FirstName, 'Last name must match');
            Test.stopTest();
        }
    }    
}
