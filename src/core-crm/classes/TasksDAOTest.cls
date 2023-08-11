/**
 * @description DAO Test Class for Task Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                                 |
 */

@isTest
public with sharing class TasksDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(TasksDAO.newInstance() != null, 'TasksDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new TasksDAO().getSObjectType() == Task.SObjectType,
                'SObject is not Tasks'
            );
        }
        Test.stopTest();
    }
}
