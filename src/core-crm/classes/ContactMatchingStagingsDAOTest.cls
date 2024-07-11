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
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetContactMatchingStagingsByBatchProcessTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                ContactMatchingStagingsDAO.newInstance()
                    .queryLocatorGetContactMatchingStagingsByBatchProcess(
                        new Set<String>(),
                        AccessLevel.SYSTEM_MODE
                    ) != null,
                'conMatchingStagings is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getContactMatchingStagingsByBatchProcessEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact_Matching_Staging__c> conMatchingStagings = ContactMatchingStagingsDAO.newInstance()
                .getContactMatchingStagingsByBatchProcess(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(conMatchingStagings.isEmpty(), 'conMatchingStagings is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactMatchingStagingsByBatchProcessTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact_Matching_Staging__c> conMatchingStagings = ContactMatchingStagingsDAO.newInstance()
                .getContactMatchingStagingsByBatchProcess(
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new ContactMatchingStagingsDAO().getSObjectType() ==
                Contact_Matching_Staging__c.SObjectType,
                'SObject is not ContactMatchingStagingsDAO'
            );
        }
        Test.stopTest();
    }
}
