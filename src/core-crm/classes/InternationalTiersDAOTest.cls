/**
 * @description Test class for InternationtiersDAOTest 
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
public with sharing class InternationalTiersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new InternationalTiersDAO().getSObjectType() == International_Tier__c.SObjectType,
                'SObject is not International_Tier__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveInternationalTiersTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            System.assert(
                InternationalTiersDAO.newInstance().getActiveInternationalTiers(AccessLevel.USER_MODE) != null,
                'InternationalTiers retrieved is null'
            );
            Test.stopTest();
        }
    }
}