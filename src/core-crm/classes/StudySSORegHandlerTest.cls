/**
 * @description Test Class for StudySSORegHandler
 * 
 * @see classes/StudySSORegHandler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | May 30, 2022          | DEPP-870               | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest
public with sharing class StudySSORegHandlerTest {

    @isTest
    static void createUserTest(){
        StudySSORegHandler handler = new StudySSORegHandler();
        Auth.UserData data = TestDataFactory.createCommunityUser('testdata@test.com', 'Data', 'Test', 'tUser');
        
        User PORTAL_SYS_ADMIN = TestDataFactory.getPortalOwner();
        update PORTAL_SYS_ADMIN;

        system.runAs(PORTAL_SYS_ADMIN) { 

            Test.startTest();
            Account testAccount = new Account();
            testAccount.Name = 'OPE Catalogue';
            insert testAccount;
            
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0].QUT_Student_Username__c = 'tUser';
            insert contacts;
            
            User u = handler.createUser(null, data);
            System.debug(u);
            System.assert(u !=null,'User must not be null');
            System.assertEquals(u.email, data.email,'Email address must be the same');
            System.assertEquals(u.lastName,data.LastName, 'First name must match');
            System.assertEquals(u.firstName,data.FirstName, 'Last name must match');
            Test.stopTest();
        }    
    }
}
