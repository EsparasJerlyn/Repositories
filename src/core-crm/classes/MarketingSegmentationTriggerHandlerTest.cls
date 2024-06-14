/**
 * @description Test Class for Lead Scoring
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary               |
      |--------------------------|-----------------------|------------------------|------------------------------|
      | w.li                     | June 15, 2022         | DEPP-1058              | Created file                 |
      | alexander.cadalin        | February 20, 2023     | PMD                    | ApexUnitTestClassShouldHaveAsserts
 */
@isTest
public without sharing class MarketingSegmentationTriggerHandlerTest {
    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTMarketingCloud();
    }
    @isTest
    public static void testInsertMarketingSegmentation() {
        System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud) {
            Test.startTest();
            Marketing_Segmentation__c marketingSegmentation = new Marketing_Segmentation__c();
            Database.SaveResult saveResult = Database.insert(marketingSegmentation);
            Test.stopTest();
            System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
        }
    }
    @isTest
    public static void testUpdateMarketingSegmentation() {
        System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud) {
            Marketing_Segmentation__c marketingSegmentation = new Marketing_Segmentation__c();
            insert marketingSegmentation;
            Test.startTest();
            List<Marketing_Segmentation__c> marketingSegmentationToBeUpdated = [SELECT Id FROM Marketing_Segmentation__c LIMIT 1];
            Database.SaveResult[] saveResultList = Database.update(marketingSegmentationToBeUpdated);
            Test.stopTest();
            for(Database.SaveResult saveResult : saveResultList) {
                System.assert(saveResult.isSuccess(), 'A record was not successfully updated.');
            }
        }
    }
 }