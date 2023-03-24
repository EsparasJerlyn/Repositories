/**
 * @description Test Class for Lead Scoring
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------|------------------------------|
      | w.li                     | June 15, 2022         | DEPP-1058              | Created file                 |
      | alexander.cadalin        | February 20, 2023     | PMD                    | ApexUnitTestClassShouldHaveAsserts
 */

@isTest
public without sharing class MarketingInteractionTriggerHandlerTest {
    @testSetup static void setupMethod() {
        TestDataFactory.generateTestUsers();
    }

    @isTest
    public static void testInsertMarketingInteraction() {
        System.runAs(TestDataFactory.getMarketingCloudUser()) {
            Test.startTest();
            Marketing_Interaction__c marketingInteraction = new Marketing_Interaction__c();
            Database.SaveResult saveResult = Database.insert(marketingInteraction);
            Test.stopTest();
            System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
        }
    }

    @isTest
    public static void testUpdateMarketingInteraction() {
        System.runAs(TestDataFactory.getMarketingCloudUser()) {
            Marketing_Interaction__c marketingInteraction = new Marketing_Interaction__c();
            insert marketingInteraction;

            Test.startTest();
            List<Marketing_Interaction__c> marketingInteractionToBeUpdated = [SELECT Id FROM Marketing_Interaction__c LIMIT 1];
            Database.SaveResult[] saveResultList = Database.update(marketingInteractionToBeUpdated);
            Test.stopTest();
            for(Database.SaveResult saveResult : saveResultList) {
                System.assert(saveResult.isSuccess(), 'A record was not successfully updated.');
            }
        }
    }
}