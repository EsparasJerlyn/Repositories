/**
 * @description test class for ActionsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created File                 | 
 */
@isTest
public with sharing class ActionsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getActionsByProductRequestAndRecordTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Action__c> actionList = ActionsDAO.newInstance()
                .getActionsByProductRequestAndRecordType(new Set<Id>(), null);
            System.assert(actionList.isEmpty(), 'actionlist is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ActionsDAO().getSObjectType() == Action__c.SObjectType,
                'SObject is not Action__c'
            );
        }
        Test.stopTest();
    }
}
