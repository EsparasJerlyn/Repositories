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
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(ApplicationPreferencesDAO.newInstance() != null, 'ApplicationPreferencesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Application_Preference__c> applicationPreferenceList = ApplicationPreferencesDAO.newInstance()
                .getApplicationPreferenceByAppSetIdsQTAC(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(applicationPreferenceList.isEmpty(), 'applicationPreferenceList should not be empty.');
        }
        Test.stopTest();
    }
    @isTest
    static void getApplicationPreferenceByAppSetIdsStudyLink() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Application_Preference__c> applicationPreferenceList = ApplicationPreferencesDAO.newInstance()
                .getApplicationPreferenceByAppSetIdsStudyLink(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(applicationPreferenceList.isEmpty(), 'applicationPreferenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCurrentApplicationPreferenceByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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