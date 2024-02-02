/**
 * @description Test class for CourseOfferingsDAO. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                         |
      |--------------------------------|-----------------------|------------------------|----------------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                           |
      | sebastianne.k.trias            | January 25, 2024      | DEPP-7481              | added queryLocatorGetPastActiveRecords |      
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