/**
 * @description Test class for ProgramOfferingsDAO. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | Created file                 |                                                     |
 */
@isTest
public with sharing class ProgramOfferingsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(CourseOfferingsDAO.newInstance() != null, 'ProgramOfferingsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ProgramOfferingsDAO().getSObjectType() == Program_Offering__c.SObjectType,
                'SObject is not Program_Offering__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProgramOfferingByRecordIdsEmptyTest() { 
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Program_Offering__c> programOfferingList = ProgramOfferingsDAO.newInstance()
                .getProgramOfferingByRecordIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(programOfferingList.isEmpty(), 'programOfferingList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getProgramOfferingByRecordIdsNotEmptyTest() { 
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builder = new MockIdGenerator(hed__Course_Offering__c.sObjectType);
            List<Program_Offering__c> programOfferingList = ProgramOfferingsDAO.newInstance()
                .getProgramOfferingByRecordIds(
                    new Set<Id>{builder.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(programOfferingList.isEmpty(), 'programOfferingList should be empty');
        }
        Test.stopTest();
    }
} 