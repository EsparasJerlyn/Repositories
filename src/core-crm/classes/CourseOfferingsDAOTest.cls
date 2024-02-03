/**
 * @description Test class for CourseOfferingsDAO. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                                              |
      | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | added getCourseOfferingByRecordIdsTest                    |
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseOfferingByProgramOfferingIdTest |
      |                                |                       |                        | getCourseOfferingByProgramOfferingIdNotEmptyTest          |
      | sebastianne.k.trias            | January 25, 2024      | DEPP-7481              | added queryLocatorGetPastActiveRecords                    |                                                   |
 */
@isTest
public with sharing class CourseOfferingsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(CourseOfferingsDAO.newInstance() != null, 'CoureOfferingsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseOfferingByProgramOfferingIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Offering__c> courseOfferingList = CourseOfferingsDAO.newInstance()
                .getCourseOfferingByProgramOfferingId(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseOfferingList.isEmpty(), 'courseOfferingList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseOfferingByProgramOfferingIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builderForProgramOffering = new MockIdGenerator(Program_Offering__c.sObjectType);
            List<hed__Course_Offering__c> courseOfferingList = CourseOfferingsDAO.newInstance()
                .getCourseOfferingByProgramOfferingId(
                    new Set<Id>{builderForProgramOffering.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseOfferingList.isEmpty(), 'courseOfferingList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CourseOfferingsDAO().getSObjectType() == hed__Course_Offering__c.SObjectType,
                'SObject is not hed__Course__Offering__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsLikeNameTest() { 
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String name = '%' + 'test' + '%';
            List<hed__Course_Offering__c> courseOfferingList = CourseOfferingsDAO.newInstance()
                .getRecordsLikeName(
                    name
                );
            System.assert(courseOfferingList.isEmpty(), 'courseOfferingList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseOfferingByRecordIdsEmptyTest() { 
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Offering__c> courseOfferingList = CourseOfferingsDAO.newInstance()
                .getCourseOfferingByRecordIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseOfferingList.isEmpty(), 'courseOfferingList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseOfferingByRecordIdsNotEmptyTest() { 
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builder = new MockIdGenerator(hed__Course_Offering__c.sObjectType);
            List<hed__Course_Offering__c> courseOfferingList = CourseOfferingsDAO.newInstance()
                .getCourseOfferingByRecordIds(
                    new Set<Id>{builder.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseOfferingList.isEmpty(), 'courseOfferingList should not be empty');
        }
        Test.stopTest();
    }

    static void getRecordsLikeName() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert( 
                CourseOfferingsDAO.newInstance().getRecordsLikeName('test') != null,
                'Course Offerings retrieved is null'
            );
        }
    }

    @isTest
    static void queryLocatorGetPastActiveRecordsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                CourseOfferingsDAO.newInstance().queryLocatorGetPastActiveRecords() != null,
                'Course Offerings retrieved is null'
            );
            Test.stopTest();
        }
    }
}
