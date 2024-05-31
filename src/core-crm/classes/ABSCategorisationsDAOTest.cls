/**
 * @description test class for ABSCategorisationsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 29, 2024          | DEPP-8954              | Created file                 |
 */
@isTest
public with sharing class ABSCategorisationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{'QUT_ESB'});
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(ABSCategorisationsDAO.newInstance() != null, 'ABSCategorisationsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                new ABSCategorisationsDAO().getSObjectType() == ABS_Categorisation__c.SObjectType,
                'SObject is not ABS_Categorisation__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getLatestActiveABSCategorisations() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance()
                .getLatestActiveABSCategorisations(
                    true,
                    'USER_MODE'
                );
            System.assert(absCategorisationList.isEmpty(), 'absCategorisationList is not empty');
        }
        Test.stopTest();
    }
}