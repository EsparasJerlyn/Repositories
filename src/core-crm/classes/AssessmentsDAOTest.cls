/**
 * @description Test Class for AssessmentsDAO 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | May 08, 2024          | DEPP-8487              | Created file                 |
 */
@isTest
public with sharing class AssessmentsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {
            System.assert(AssessmentsDAO.newInstance() != null, 'AssessmentsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {
            System.assert(
                new AssessmentsDAO().getSObjectType() == Assessment__c.SObjectType,
                'SObject is not Assessment__c'
            );
        }
        Test.stopTest();
    }
}