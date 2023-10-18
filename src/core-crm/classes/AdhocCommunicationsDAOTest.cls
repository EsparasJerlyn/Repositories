/**
 * @description test class for adhocCommunicationsdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Oct 10, 2023          | DEPP-6614              | Created file
 */
@isTest
public with sharing class AdhocCommunicationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(AdhocCommunicationsDAO.newInstance() != null, 'adhocCommunicationsdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new AdhocCommunicationsDAO().getSObjectType() == Adhoc_Communication__c.SObjectType,
                'SObject is not Adhoc_Communication__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getAdhocCommunicationsByOfferingFieldAndProductOfferingIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Adhoc_Communication__c> adhocCommunicationList = AdhocCommunicationsDAO.newInstance()
                .getAdhocCommunicationsByOfferingFieldAndProductOfferingId(
                    '',
                    'Program_Offering__c',
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(adhocCommunicationList.isEmpty(), 'adhocCommunicationList should be empty.');
        }
        Test.stopTest();
    }
    @isTest
    static void getAdhocCommunicationsByDateTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                AdhocCommunicationsDAO.newInstance().getAdhocCommunicationsByDate(null) != null,
                'Adhoc Communication retrieved is null'
            );
            Test.stopTest();
        }
    }
}