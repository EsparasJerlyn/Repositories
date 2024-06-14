/**
 * @description DAO TestClass for Marketing_Interaction__c Object. Contains SOQL and Constants related to the Marketing_Interaction__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | September 18, 2023    |DEPP-6667               | Created File                        |
 */
@isTest
public with sharing class MarketingInteractionsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new MarketingInteractionsDAO().getSObjectType() == Marketing_Interaction__c.SObjectType,
                'SObject is not Marketing_Interaction__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingInteractionByApplicantIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Marketing_Interaction__c> marketingInteractionList = MarketingInteractionsDAO.newInstance()
                .getMarketingInteractionByApplicantIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingInteractionList.isEmpty(), 'marketingInteractionList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingInteractionsByContactOrLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Marketing_Interaction__c> marketingInteractionList = MarketingInteractionsDAO.newInstance()
                .getMarketingInteractionsByContactOrLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingInteractionList.isEmpty(), 'marketingInteractionList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetMarketingInteractionsByContactOrLeadIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                MarketingInteractionsDAO.newInstance().queryLocatorGetMarketingInteractionsByContactOrLeadIds(
                    new Set<Id>()
                ) != null,
                'marketingInteractionList should not be empty.'
            );
            Test.stopTest();
        }
    }
    
}
