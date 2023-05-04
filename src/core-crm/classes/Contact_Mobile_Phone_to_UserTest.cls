/**
 * @description Test Class for flow Contact_Mobile_Phone_to_User
 * @see ..flows/Contact_Mobile_Phone_to_User
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | February 2, 2023      | DEPP-5130              | Created Test Class           |
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | fixed duplicate email error  |
 */
@isTest
public with sharing class Contact_Mobile_Phone_to_UserTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
        Test.stopTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contacts = TestDataFactory.createTestContactRecords(5);
            for (Contact contact : contacts) {
                contact.MobilePhone = '6112345678';
                contact.Work_Email__c = contact.LastName + 'work@test.com';
                contact.email = contact.LastName + '@test.com';
                contact.hed__Preferred_Email__c = 'Alternate Email';
                contact.hed__AlternateEmail__c = contact.LastName + '@test.com';
                contact.Registered_Email__c = contact.email;
            }
            insert contacts;

            Profile profile;
            if (Schema.sObjectType.Profile.isAccessible()) {
                profile = [
                    SELECT Id, Name
                    FROM Profile
                    WHERE Name = 'Customer Community Plus Login User'
                    LIMIT 1
                ];
            }

            List<User> users = new List<User>();
            for (Contact contact : contacts) {
                User user = new User();
                user.IsActive = true;
                user.Email = contact.Work_Email__c;
                user.Username = contact.Work_Email__c + '.cce';
                user.LastName = contact.LastName;
                user.FirstName = contact.FirstName;
                user.ContactId = contact.Id;
                user.MobilePhone = contact.MobilePhone;
                user.alias = contact.FirstName.substring(0, 1) + contact.LastName.substring(0, 2);
                user.LanguageLocaleKey = 'en_US';
                user.localesidkey = 'en_AU';
                user.emailEncodingKey = 'UTF-8';
                user.timeZoneSidKey = 'Australia/Brisbane';
                user.profileId = profile.Id;
                users.add(user);
            }
            insert users;
        }
    }

    @isTest
    private static void updatePhoneNumberTest() {
        List<User> users = new List<User>();
        String updatedMobilePhone = '6111111112';

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            List<Contact> contacts = [
                SELECT Id, MobilePhone, RecordType.Name, Name
                FROM Contact
                WHERE FirstName LIKE '%Test%' AND LastName LIKE '%Contact%'
                WITH SECURITY_ENFORCED
            ];
            for (Contact contact : contacts) {
                contact.mobilePhone = updatedMobilePhone;
            }
            update contacts;

            if (Schema.sObjectType.User.isAccessible()) {
                users = [SELECT Id, Name, MobilePhone FROM User WHERE ContactId IN :(contacts)];
            }

            Test.stopTest();
        }

        for (User user : users) {
            System.assertEquals(
                updatedMobilePhone,
                user.MobilePhone,
                'Mobile Phone was not updated.'
            );
        }
    }
}
