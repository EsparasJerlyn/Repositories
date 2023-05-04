/**
 * @description test class for contactsdao.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
private class ContactsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getExistingPersonContactsWithMatchingEmailsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getExistingPersonContactsWithMatchingEmails(
                    new Set<String>(),
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsWithLimitTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ContactsDAO().getSObjectType() == Contact.SObjectType,
                'SObject is not Contact'
            );
        }
        Test.stopTest();
    }
}
