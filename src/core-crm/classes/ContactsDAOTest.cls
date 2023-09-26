/**
 * @description test class for contactsdao.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023      | DEPP-5567              | Created file                              |
 *    | eugene.andrew.abuan            | June 08, 2023       | DEPP-5414              | Added checkWorkEmailFlowInputExist        |
 *    | mark.j.mahilum                 | June 26, 2023       | DEPP-5846              | Added test method for DEPP-5846           |
 *    | arsenio.jr.dayrit              | July 06, 2023       | DEPP-5847              | Added test method for DEPP-5847           |
 *    | roy.nino.s.regala              | Aug 09, 2023        | DEPP-5677              | Added test method for DEPP-5677           |
 *    | roy.nino.s.regala              | Sept 20, 2023       | DEPP-6714              | method getPersonContactsBySetIds          |
 *    | alexander.cadalin              | Sep 22, 2023        | DEPP-6652              | method getContactsForQTACAddressUpdate    |
 */
@isTest
private class ContactsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Program_Administrator', 'QUT_IE_Partnership_Manager', 'QUT_Domestic_Future_Student_Agent' }
        );
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

    @IsTest
    static void checkWorkEmailFlowInputExistTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .checkWorkEmailFlowInputExist('test');
            System.Assert(contactList.isEmpty(), 'Contact with same email not found');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsWithMatchingEmailsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithMatchingEmails(
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getContactsWithMatchingApplicationDetailsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithMatchingApplicationDetails(
                    new ContactsDAO.QueryParamWrapper(),
                    'SYSTEM_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsWithMatchingSamsApplicationsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithMatchingSamsApplications(
                    new ContactsDAO.QueryParamWrapper(),
                    'SYSTEM_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsByCalculatedCadencesTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsByCalculatedCadences(
                    new Set<String>()
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactCalculatedCadenceByIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactCalculatedCadenceByIds(
                    new Set<String>(),
                    'USER_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList should not be empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getContactsFromConvertedLeadTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsFromConvertedLead(
                    new Set<Id>(),
                    'USER_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsBySetIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsForQTACAddressUpdate() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance().
                getContactsForQTACAddressUpdate(new Set<Id>(), AccessLevel.SYSTEM_MODE);
            System.assert(contactList.isEmpty(), 'contactList should not be empty');
        }
        Test.stopTest();
    }
}
