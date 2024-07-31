/**
 * @description Test class for ActionCadenceStepTrackersDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 4, 2023     | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class ActionCadenceStepTrackersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new ActionCadenceStepTrackersDAO().getSObjectType() == ActionCadenceStepTracker.SObjectType,
                'SObject is not ActionCadenceStepTracker'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getUsersByNameSetTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            System.assert(
                ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(new List<String>(), AccessLevel.SYSTEM_MODE) != null,
                'ActionCadenceStepTracker retrieved is not empty'
            );
            Test.stopTest();
        }
    }
   
    @isTest
    static void getCadenceStepTrackersByTargetIdTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            System.assert(
                ActionCadenceStepTrackersDAO.newInstance().getCadenceStepTrackersByTargetId(new Set<String>(), AccessLevel.SYSTEM_MODE) != null,
                'ActionCadenceStepTracker is not empty.'
            );
            Test.stopTest();
        }
    }
}