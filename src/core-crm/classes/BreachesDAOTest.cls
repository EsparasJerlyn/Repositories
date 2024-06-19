/**
 * @description Test Class for BreachesDAO
 *
 * @author Accenture
 *
 * @history
 *
*    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | arsenio.jr.dayrit              | May 9, 2024           | DEPP-8487              | created file                               |
 */
@isTest
public with sharing class BreachesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(BreachesDAO.newInstance() != null, 'BreachesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new BreachesDAO().getSObjectType() == Breach__c.SObjectType,
                'SObject is not Breach__c'
            );
        }
        Test.stopTest();
    }

} 