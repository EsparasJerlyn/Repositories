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
      | eugene.andrew.abuan            | August 03, 2024       | DEPP-9691              | Added getTaskByCompeltedCadenceTest                   |

 */

@isTest
public with sharing class TasksDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserFutureStudentSuperTeamLeaderDomestic();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(TasksDAO.newInstance() != null, 'TasksDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<task> taskList = TasksDAO.newInstance()
                .getCompletedSMSTasksByActionCadenceStepTrackerId(
                    new Set<String>()
                );
            System.assert(taskList.isEmpty(), 'taskList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getTaskByCompeltedCadenceTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentSuperTeamLeaderDomestic) {
            List<Task> taskList = TasksDAO.newInstance()
            .getTaskByCompeltedCadence(
                new Set<Id>(),
                AccessLevel.SYSTEM_MODE
            );
            System.assert(taskList.isEmpty(), 'taskList should not be empty.');        
        }
        Test.stopTest();
    }
}
