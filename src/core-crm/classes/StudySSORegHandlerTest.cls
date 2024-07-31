/**
 * @description Test Class for StudySSORegHandler
 * 
 * @see classes/StudySSORegHandler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                           |
      |--------------------------------|-----------------------|------------------------|------------------------------------------|
      | eugene.andrew.abuan            | May 30, 2022          | DEPP-870               | Created file                             |
      | kenneth.f.alsay                | June 21, 2024         | DEPP-9221              | Renamed OPE Catalogue to QUT Experience  |
      |                                |                       |                        |                                          |
 */
@isTest
public with sharing class StudySSORegHandlerTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserSystemAdministrator();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @IsTest
    static void checkEmailDetailTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            StudySSORegHandler handler = new StudySSORegHandler();
            Auth.UserData data = TestDataFactory.createCommunityUser('testdata@test.com', 'Data', 'Test', 'tUser');

            Test.startTest();
            Account testAccount = new Account();
            testAccount.Name = 'QUT Experience';
            insert testAccount;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0].QUT_Student_Username__c = 'tUser';
            insert contacts;

            User u = handler.createUser(null, data);
            System.assert(u !=null,'User must not be null');
            System.assertEquals(u.email, data.email,'Email address must be the same');
            System.assertEquals(u.lastName,data.LastName, 'First name must match');
            System.assertEquals(u.firstName,data.FirstName, 'Last name must match');
            Test.stopTest();
        }
    }

    @isTest
    static void updateUserTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            StudySSORegHandler handler = new StudySSORegHandler();
            Auth.UserData data = TestDataFactory.createCommunityUser('testdata@test.com', 'Data', 'Test', 'tUser');
            Id userId = TestDataFactoryUser.selectUserQUTeXProgramAdministrator.Id;
            handler.updateUser(userId, null, data);
            User updatedUser = [SELECT Id, LastName, FirstName FROM User WHERE LastName='Data' AND FirstName='Test' LIMIT 1];
            System.assert(updatedUser != null, 'User was not updated.');
        }
    }
}
