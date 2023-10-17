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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
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
    
}