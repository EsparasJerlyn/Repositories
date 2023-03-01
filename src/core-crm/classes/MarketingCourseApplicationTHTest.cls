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
public without sharing class MarketingCourseApplicationTHTest {

    @isTest
    public static void testInsertMarketingCourseApplication() {
        Test.startTest();
        Marketing_Course_Application__c marketingCourseApplication = new Marketing_Course_Application__c();
        Database.SaveResult saveResult = Database.insert(marketingCourseApplication);
        Test.stopTest();
        System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
    }

    @isTest
    public static void testUpdateMarketingCourseApplication() {
        Marketing_Course_Application__c marketingCourseApplication = new Marketing_Course_Application__c();
        insert marketingCourseApplication;

        Test.startTest();
        List<Marketing_Course_Application__c> marketingCourseApplicationToBeUpdated = [SELECT Id FROM Marketing_Course_Application__c LIMIT 1];
        Database.SaveResult[] saveResultList = Database.update(marketingCourseApplicationToBeUpdated);
        Test.stopTest();
        for(Database.SaveResult saveResult : saveResultList) {
            System.assert(saveResult.isSuccess(), 'A record was not successfully updated.');
        }
    }

 }