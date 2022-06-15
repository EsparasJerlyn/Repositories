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

@IsTest(SeeAllData=false)
public without sharing class MarketingSegmentationTriggerHandlerTest {

    @IsTest
    public static void testInsertMarketingSegmentation() {
        Test.startTest();
        Marketing_Segmentation__c marketingSegmentation = new Marketing_Segmentation__c();
        insert marketingSegmentation;
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateMarketingSegmentation() {
        Marketing_Segmentation__c marketingSegmentation = new Marketing_Segmentation__c();
        insert marketingSegmentation;

        Test.startTest();
        List<Marketing_Segmentation__c> marketingSegmentationToBeUpdated = [SELECT Id FROM Marketing_Segmentation__c LIMIT 1];
        update marketingSegmentationToBeUpdated;
        Test.stopTest();
    }

 }