/**
 * @description Test class for RelationshipManagersDAO. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 01, 2023       | DEPP-6141              | Created file                 |                                                     |
 */
@isTest
public with sharing class RelationshipManagersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            System.assert(RelationshipManagersDAO.newInstance() != null, 'RelationshipManagerDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            System.assert(
                new RelationshipManagersDAO().getSObjectType() == Relationship_Manager__c.SObjectType,
                'SObject is not Relationship_Manager__c'
            );
        }
        Test.stopTest();
    }
}
