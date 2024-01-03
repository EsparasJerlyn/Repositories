/**
 * @description Test class for CourseOfferingsDAO. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                 |
      | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | added getCourseOfferingByRecordIdsTest|                                                      |
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

} 