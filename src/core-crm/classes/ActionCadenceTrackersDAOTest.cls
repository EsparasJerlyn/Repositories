/**
 * @description Test Class for ActionCadenceTrackersDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
 *    | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | Created file                                    |
 *    | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added test method for getCompletedACTrackerById |
 */
@isTest
public with sharing class ActionCadenceTrackersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
    }

    @isTest
    static void getRunningACTrackerByTargetIdAndCadenceNameTest() {//NOPMD
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<ActionCadenceTracker> actionCadenceTrackerList = ActionCadenceTrackersDAO.newInstance()
                .getRunningACTrackerByTargetIdAndCadenceName(new Set<Id>(), new Set<String>(),'SYSTEM_MODE');
            System.assert(actionCadenceTrackerList.isEmpty(), 'actionCadenceTrackerList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new ActionCadenceTrackersDAO().getSObjectType() == ActionCadenceTracker.SObjectType,
                'SObject is not ActionCadenceTracker'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCompletedACTrackerByIdTest() {//NOPMD
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<ActionCadenceTracker> actionCadenceTrackerList = ActionCadenceTrackersDAO.newInstance()
                .getCompletedACTrackerById(new Set<String>(),'SYSTEM_MODE');
            System.assert(actionCadenceTrackerList.isEmpty(), 'actionCadenceTrackerList is not empty');
        }
        Test.stopTest();
    }
}
