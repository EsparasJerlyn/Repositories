/**
 * @description test class for MarketingCourseApplicationsDAOTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 02, 2024          | n/a                    | Created file
 */
@isTest
public with sharing class MarketingCourseApplicationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(MarketingCourseApplicationsDAO.newInstance() != null, 'marketingCourseApplicationsdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new MarketingCourseApplicationsDAO().getSObjectType() == Marketing_Course_Application__c.SObjectType,
                'SObject is not Marketing_Course_Application__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getMrktngCourseAppsByLeadIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Marketing_Course_Application__c.SObjectType);
            List<Marketing_Course_Application__c> mrktgCourseAppList = MarketingCourseApplicationsDAO.newInstance()
                .getMrktngCourseAppsByLeadIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            System.assert(mrktgCourseAppList.isEmpty(), 'mrktgCourseAppList is not empty.');
        }
    }

    @isTest
    static void getMrktngCourseAppsByLeadIdsEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Marketing_Course_Application__c> mrktgCourseAppList = MarketingCourseApplicationsDAO.newInstance()
                .getMrktngCourseAppsByLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            System.assert(mrktgCourseAppList.isEmpty(), 'mrktgCourseAppList is not empty.');
        }
    }
}
