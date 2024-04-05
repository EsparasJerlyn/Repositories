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
 *    | neil.s.h.lesidan               | Sep 20, 2023        | DEPP-6478              | Added getPersonContactsByEmailOrNameTest  |
 *    | arsenio.jr.dayrit              | Sept 22,2023        | DEPP-6720              | added getContactByCaseMobile              |
 *    | julie.jane.alegre              | Nov 07, 2023        | DEPP-7152              | Added method getExistingMCPersonaContactsBySetIds|
 *    | sebastianne.k.trias            | Feb 19, 2024        | DEPP-7750              | added getPersonContactsByNameUsingSOSLTest|
 */
@isTest
private class ContactsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUTeX_Program_Administrator', 'QUT_IE_Partnership_Manager', 'Future_Student_Agent_Domestic' }
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
    static void getPersonContactsByEmailOrNameTest() {
        Test.startTest();
        List<Contact> conList = TestDataFactory.createTestContactRecords(1);
        conList[0].FirstName = 'firstname';
        conList[0].LastName = 'lastname';
        conList[0].Email = 'firstlast@mail.test';
        conList[0].MobilePhone = '1234567';
        ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);

        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            ContactsDAO.QueryParamWrapperEmailOrName contactQueryParam = new ContactsDAO.QueryParamWrapperEmailOrName(
                conList[0].Email, conList[0].FirstName, conList[0].LastName , conList[0].MobilePhone
            );

            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsByEmailOrName(
                    contactQueryParam,
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contact should not be empty');
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
    static void getPersonContactsBySetIdsTestWithId() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            MockIdGenerator contactMock = new MockIdGenerator(Contact.sObjectType);
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsBySetIds(
                    new Set<Id>{contactMock.getMockId()},
                    AccessLevel.USER_MODE
                );
            System.assert(contactList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactByCaseMobileTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactByCaseMobile(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    static void getContactsForQTACAddressUpdate() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance().
                getContactsForQTACAddressUpdate(new Set<Id>(), AccessLevel.SYSTEM_MODE);
            System.assert(contactList.isEmpty(), 'contactList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactMobilePhoneByRecordIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactMobilePhoneByRecordIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }
  
    @isTest
    static void queryLocatorGetContactsByIdsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                ContactsDAO.newInstance().queryLocatorGetContactsByIds(
                    new Set<Id>()
                ) != null,
                'contactList should not be empty.'
            );
            Test.stopTest();
        }
    }
    
    @isTest
    static void getExistingMCPersonaContactsBySetIds() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getExistingMCPersonaContactsBySetIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsByParentPersonLeadIdsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Lead.SObjectType);
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsByParentPersonLeadIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
    }

    @isTest
    static void getContactsByParentPersonLeadIdsEmptyTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsByParentPersonLeadIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
    }

    @isTest
    static void getContactsNoParentPersonContactByIdsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsNoParentPersonContactByIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    @isTest
    static void getContactsNoParentPersonContactByIdsEmptyTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsNoParentPersonContactByIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    @isTest
    static void getContactsWithParentPersonContactByIdsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithParentPersonContactByIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    @isTest
    static void getContactsWithParentPersonContactByIdsEmptyTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithParentPersonContactByIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    static void getMCPersonaContactsByParentPersonContactIds() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getMCPersonaContactsByParentPersonContactIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getMCPersonaContactsByParentPersonLeadIds() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getMCPersonaContactsByParentPersonLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsByNameUsingSOSLTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsByNameUsingSOSL(
                    'test'
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }
}