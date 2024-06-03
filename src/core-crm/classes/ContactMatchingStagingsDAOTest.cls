/**
 * @description test class for ContactMatchingStagingsDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | May 09, 2024        | DEPP-8676              | Created file                              |
 */
@isTest
private class ContactMatchingStagingsDAOTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetContactMarketingStagingsByBatchProcessTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                ContactMatchingStagingsDAO.newInstance()
                    .queryLocatorGetContactMarketingStagingsByBatchProcess(
                        new Set<String>(),
                        AccessLevel.SYSTEM_MODE
                    ) != null,
                'conMatchingStagings is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getContactMarketingStagingsByBatchProcessEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact_Matching_Staging__c> conMatchingStagings = ContactMatchingStagingsDAO.newInstance()
                .getContactMarketingStagingsByBatchProcess(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(conMatchingStagings.isEmpty(), 'conMatchingStagings is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactMarketingStagingsByBatchProcessTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact_Matching_Staging__c> conMatchingStagings = ContactMatchingStagingsDAO.newInstance()
                .getContactMarketingStagingsByBatchProcess(
                    new Set<String>{ 'Insert' },
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(conMatchingStagings.isEmpty(), 'conMatchingStagings is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                ContactMatchingStagingsDAO.newInstance() != null,
                'ContactMatchingStagingsDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                new ContactMatchingStagingsDAO().getSObjectType() ==
                Contact_Matching_Staging__c.SObjectType,
                'SObject is not ContactMatchingStagingsDAO'
            );
        }
        Test.stopTest();
    }
}
