/**
 * @description test class for ContactMatchingConfigurationsDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | April 18, 2024      | DEPP-7986              | Created file                              |
 */
@isTest
private class ContactMatchingConfigurationsDAOTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void getContactMatchingConfigurationRecordsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact_Matching_Configuration__c> conMatchingConfig = ContactMatchingConfigurationsDAO.newInstance()
                .getContactMatchingConfigurationRecords(AccessLevel.SYSTEM_MODE);
            System.assert(conMatchingConfig.isEmpty(), 'contactMatchingConfig is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                ContactMatchingConfigurationsDAO.newInstance() != null,
                'ContactMatchingConfigurationsDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new ContactMatchingConfigurationsDAO().getSObjectType() ==
                Contact_Matching_Configuration__c.SObjectType,
                'SObject is not ContactMatchingConfigurationsDAO'
            );
        }
        Test.stopTest();
    }
}
