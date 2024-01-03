/**
 * @description Test class for CourseOfferingsDAO. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                                              |
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseOfferingByProgramOfferingIdTest |
      |                                |                       |                        | getCourseOfferingByProgramOfferingIdNotEmptyTest          |                                                          
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
} 