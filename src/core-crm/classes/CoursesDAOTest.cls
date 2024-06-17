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
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(CoursesDAO.newInstance() != null, 'CoursesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new CoursesDAO().getSObjectType() == hed__Course__c.SObjectType,
                'SObject is not hed__Course__c'
            );
        }
        Test.stopTest();
    }
} 