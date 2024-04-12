/**
 * @description DAO Test Class for Task Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                                          |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new test method getCompletedTasksByTargetIdTest |
 */

@isTest
public with sharing class TasksDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
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

    @isTest
    static void getCompletedTasksByTargetIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<task> taskList = TasksDAO.newInstance()
                .getCompletedTasksByTargetId(
                    new Set<String>(),
                    new Set<String>()
                );
            System.assert(taskList.isEmpty(), 'taskList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCompletedSMSTasksByActionCadenceStepTrackerIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<task> taskList = TasksDAO.newInstance()
                .getCompletedSMSTasksByActionCadenceStepTrackerId(
                    new Set<String>()
                );
            System.assert(taskList.isEmpty(), 'taskList should not be empty.');
        }
        Test.stopTest();
    }
}
