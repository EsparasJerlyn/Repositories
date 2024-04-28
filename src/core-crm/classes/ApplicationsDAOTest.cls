/**
 * @description Test Class ApplicationsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                        |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | Created File                                                          |
 *    | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Added method getApplicationsByLeadIds                                 |
 *    | mark.j.mahilum                 | July 14, 2023         | DEPP-5799              | Added method getApplicationsByContactIdTest                           |
 *    | mark.j.mahilum                 | Aug 31, 2023          | DEPP-6455              | Added method getApplicationsActiveApplicantsTest                      |
 *    | sebastianne.k.trias            | March 28, 2024        | DEPP-8382              | Added method queryApplicationsByPastIntakeDateAndActiveApplicantsTest |
 */
@isTest
public with sharing class ApplicationsDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getApplicationsBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getApplicationsBySetIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new ApplicationsDAO().getSObjectType() == hed__Application__c.SObjectType,
                'SObject is not hed__Application__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getApplicationsByLeadIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getApplicationsByLeadIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getApplicationsByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getApplicationsByContactIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQtacApplicationsWithQtacApplicantIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getQtacApplicationsWithQtacApplicantId(
                    new List<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getApplicationsActiveApplicantsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getApplicationsActiveApplicants(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getApplicationsByLeadOrContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getApplicationsByLeadOrContactIds(
                    new Set<String>(),
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getAppsWithLatestCalculatedIntakeDateByApplicantIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getAppsWithLatestCalculatedIntakeDateByApplicantIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getApplicationsByLeadIdOrContactIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getApplicationsByLeadIdOrContactId(
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }
    
    static void queryApplicationsByPastIntakeDateAndActiveApplicantsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                ApplicationsDAO.newInstance().queryApplicationsByPastIntakeDateAndActiveApplicants('SYSTEM_MODE') != null,
                'Applications retrieved is null'
            );
            Test.stopTest();
        }
    }
}