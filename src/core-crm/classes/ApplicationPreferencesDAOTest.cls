/**
 * @description Test Class for ApplicationPreferencesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 11, 2023       |DEPP-6252               | Created File                        |
 */
@isTest
public with sharing class ApplicationPreferencesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(ApplicationPreferencesDAO.newInstance() != null, 'ApplicationPreferencesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                new ApplicationPreferencesDAO().getSObjectType() == Application_Preference__c.SObjectType,
                'SObject is not Application_Preference__c'
            );
        }
        Test.stopTest();
    }
    @isTest
    static void getApplicationPreferenceByAppSetIdsQTAC() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Application_Preference__c> applicationPreferenceList = ApplicationPreferencesDAO.newInstance()
                .getApplicationPreferenceByAppSetIdsQTAC(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(applicationPreferenceList.isEmpty(), 'applicationPreferenceList should not be empty.');
        }
        Test.stopTest();
    }
    @isTest
    static void getApplicationPreferenceByAppSetIdsStudyLink() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Application_Preference__c> applicationPreferenceList = ApplicationPreferencesDAO.newInstance()
                .getApplicationPreferenceByAppSetIdsStudyLink(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(applicationPreferenceList.isEmpty(), 'applicationPreferenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCurrentApplicationPreferenceByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Application_Preference__c> applicationPreferenceList = ApplicationPreferencesDAO.newInstance()
                .getCurrentApplicationPreferenceById(
                    new Set<Id>(),
                    'USER_MODE'
                );
            System.assert(applicationPreferenceList.isEmpty(), 'applicationPreferenceList should not be empty.');
        }
        Test.stopTest();
    }

}