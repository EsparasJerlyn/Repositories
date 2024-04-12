/**
 * @description Test class for CoursesDAO. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                 |                                                     |
 */
@isTest
public with sharing class CoursesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(CoursesDAO.newInstance() != null, 'CoursesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CoursesDAO().getSObjectType() == hed__Course__c.SObjectType,
                'SObject is not hed__Course__c'
            );
        }
        Test.stopTest();
    }
} 