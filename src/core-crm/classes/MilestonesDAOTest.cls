/**
 * @description test class for Milestonesdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 6, 2023          | DEPP-5567              | Created file
 */
@isTest
public with sharing class MilestonesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserIndustryOperationsManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            System.assert(MilestonesDAO.newInstance() != null, 'Milestonesdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            System.assert(
                new MilestonesDAO().getSObjectType() == Milestone__c.SObjectType,
                'SObject is not Milestone__c'
            );
        }
        Test.stopTest();
    }
}
