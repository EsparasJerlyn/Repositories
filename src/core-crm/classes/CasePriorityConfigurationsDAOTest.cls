/**
 * @description Test class for CasePriorityConfiguration 
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Octover 5, 2023       | DEPP-6426              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class CasePriorityConfigurationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new CasePriorityConfigurationsDAO().getSObjectType() == Case_Priority_Configuration__c.SObjectType,
                'SObject is not Case_Priority_Configuration__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveCasePriorityConfigurationsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            System.assert(
                CasePriorityConfigurationsDAO.newInstance().getActiveCasePriorityConfigurations(AccessLevel.USER_MODE) != null,
                'Case_Priority_Configuration__c retrieved is null'
            );
            Test.stopTest();
        }
    }
    
}