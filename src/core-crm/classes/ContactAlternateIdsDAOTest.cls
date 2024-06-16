/**
 * @description test class for ContactAlternateIdsDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | April 18, 2024      | DEPP-7986              | Created file                              |
 */
@isTest
private class ContactAlternateIdsDAOTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB'});
        Test.stopTest();
    }

    @isTest
    static void getContactAlternateIdsBySystemKeyIdSetTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact_Alternate_ID__c> contactAlternateIdsList = ContactAlternateIdsDAO.newInstance()
                .getContactAlternateIdsBySystemKeyIdSet(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactAlternateIdsList.isEmpty(), 'contactAlternateIdsList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactAlternateIdsByContactIdSetTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact_Alternate_ID__c> contactAlternateIdsList = ContactAlternateIdsDAO.newInstance()
                .getContactAlternateIdsByContactIdSet(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactAlternateIdsList.isEmpty(), 'contactAlternateIdsList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactAlternateIdsBySystemKeyIdSetNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact_Alternate_ID__c> contactAlternateIdsList = ContactAlternateIdsDAO.newInstance()
                .getContactAlternateIdsBySystemKeyIdSet(
                    new Set<String>{'123'},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactAlternateIdsList.isEmpty(), 'contactAlternateIdsList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactAlternateIdsByContactIdSetNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            MockIdGenerator contactMock = new MockIdGenerator(Contact.sObjectType); 
            List<Contact_Alternate_ID__c> contactAlternateIdsList = ContactAlternateIdsDAO.newInstance()
                .getContactAlternateIdsByContactIdSet(
                    new Set<Id>{contactMock.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactAlternateIdsList.isEmpty(), 'contactAlternateIdsList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveAndSupersededStudentAlternateIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            MockIdGenerator contactMock = new MockIdGenerator(Contact.sObjectType); 
            List<Contact_Alternate_ID__c> contactAlternateIdsList = ContactAlternateIdsDAO.newInstance()
                .getActiveAndSupersededStudentAlternateIds(
                    new Set<String>{'test'},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactAlternateIdsList.isEmpty(), 'contactAlternateIdsList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveAndSupersededStudentAlternateIdsTestEmpty() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            MockIdGenerator contactMock = new MockIdGenerator(Contact.sObjectType); 
            List<Contact_Alternate_ID__c> contactAlternateIdsList = ContactAlternateIdsDAO.newInstance()
                .getActiveAndSupersededStudentAlternateIds(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactAlternateIdsList.isEmpty(), 'contactAlternateIdsList is not empty');
        }
        Test.stopTest();
    }
   
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(ContactAlternateIdsDAO.newInstance() != null, 'ContactAlternateIdsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                new ContactAlternateIdsDAO().getSObjectType() == Contact_Alternate_ID__c.SObjectType,
                'SObject is not ContactAlternateIdsDAO'
            );
        }
        Test.stopTest();
    }

}