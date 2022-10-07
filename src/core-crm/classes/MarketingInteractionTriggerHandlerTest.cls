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
 */

@isTest
public without sharing class MarketingInteractionTriggerHandlerTest {

    @isTest
    public static void testInsertMarketingInteraction() {
        Test.startTest();
        Marketing_Interaction__c marketingInteraction = new Marketing_Interaction__c();
        insert marketingInteraction;
        Test.stopTest();
    }

    @isTest
    public static void testUpdateMarketingInteraction() {
        Marketing_Interaction__c marketingInteraction = new Marketing_Interaction__c();
        insert marketingInteraction;

        Test.startTest();
        List<Marketing_Interaction__c> marketingInteractionToBeUpdated = [SELECT Id FROM Marketing_Interaction__c LIMIT 1];
        update marketingInteractionToBeUpdated;
        Test.stopTest();
    }

 }