/**
 * @description Test Class CourseConnectionDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Created File                                      |
      | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | added method named                                |
      |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds         |
      | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | added method named                                |
      |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds         |
      | kenneth.f.alsay                | Sep 25, 2023          | DEPP-6629              | added method named                                |
      |                                |                       |                        | getCourseConnectionByStatusTest                   |
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseConnectionByCartItemTest|
      |                                |                       |                        | getCourseConnectionByCartItemNotEmptyTest         |
 */
@isTest
public with sharing class CourseConnectionsDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CourseConnectionsDAO().getSObjectType() == hed__Course_Enrollment__c.SObjectType,
                'SObject is not hed__Course_Enrollment__c'
            );
        }
        Test.stopTest();
    }


    @isTest
    static void getCourseConnectionByPEContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByPEContactIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseConnectionByProgramEnrollmentIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByProgramEnrollmentIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveCourseConnectionsBySetContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getActiveCourseConnectionsBySetContactIds(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getRegisteredLearnersEmailByCourseOfferingTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getRegisteredLearnersEmailByCourseOffering(
                    new Set<Id>(),
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseConnectionByStatusTest(){
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByStatus(
                    'Active',
                    'Sent'
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseConnectionByCartItemTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByCartItem(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseConnectionByCartItemNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builderForCartItem = new MockIdGenerator(CartItem.sObjectType);
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByCartItem(
                    new Set<Id>{builderForCartItem.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

}