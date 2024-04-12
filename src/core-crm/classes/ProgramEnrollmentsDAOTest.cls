/**
 * @description Test Class for ProgramEnrollmentsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 08, 2023       |DEPP-5760               | Created File                        |
 */
@isTest
public with sharing class ProgramEnrollmentsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }

    @isTest
    static void getProgramEnrollmentsByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .getProgramEnrollmentsById(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(programEnrollmentList.isEmpty(), 'Program Enrollment list should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ProgramEnrollmentsDAO().getSObjectType() == hed__Program_Enrollment__c.SObjectType,
                'SObject is not hed__Program_Enrollment__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProgramEnrollmentsByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .getProgramEnrollmentsByContactIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(programEnrollmentList.isEmpty(), 'Program Enrollment list should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getProgramEnrollmentsByContactIdAndStatusTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .getProgramEnrollmentsByContactIdAndStatus(
                    new Set<Id>(),
                    '',
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(programEnrollmentList.isEmpty(), 'Program Enrollment list should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getAllProgramEnrollmentsByContactIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .getAllProgramEnrollmentsByContactId(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(programEnrollmentList.isEmpty(), 'Program Enrollment list should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetAllProgramEnrollmentsByContactIdTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                ProgramEnrollmentsDAO.newInstance().queryLocatorGetAllProgramEnrollmentsByContactId(
                    new Set<Id>()
                ) != null,
                'Program Enrollment list should not be empty.'
            );
            Test.stopTest();
        }
    }
    
}