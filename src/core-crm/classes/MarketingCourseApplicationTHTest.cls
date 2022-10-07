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
public without sharing class MarketingCourseApplicationTHTest {

    @isTest
    public static void testInsertMarketingCourseApplication() {
        Test.startTest();
        Marketing_Course_Application__c marketingCourseApplication = new Marketing_Course_Application__c();
        insert marketingCourseApplication;
        Test.stopTest();
    }

    @isTest
    public static void testUpdateMarketingCourseApplication() {
        Marketing_Course_Application__c marketingCourseApplication = new Marketing_Course_Application__c();
        insert marketingCourseApplication;

        Test.startTest();
        List<Marketing_Course_Application__c> marketingCourseApplicationToBeUpdated = [SELECT Id FROM Marketing_Course_Application__c LIMIT 1];
        update marketingCourseApplicationToBeUpdated;
        Test.stopTest();
    }

 }