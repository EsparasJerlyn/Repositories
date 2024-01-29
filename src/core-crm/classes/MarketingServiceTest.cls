/**
 * @description Test Class for MarketingService
 * @see ..MarketingService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | roy.nino.s.regala              | Nov 28, 2023          | DEPP-6979              | Created file                                   |
 */

 @isTest
 @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
 //PMD ApexUnitTestClassShouldHaveRunAs is bypassed for service class methods 
 //because these methods are reusable, test method is mocked, and user access tests are performed on the caller
 public without sharing class MarketingServiceTest {
 
     @isTest
     public static void optInOrOutMarketingOptInTest(){
        Contact con = new Contact();
        MarketingService.optInOrOutMarketing(con, true);
        System.assertEquals(false, con.HasOptedOutOfEmail, 'Marketing field should be false');
        System.assertEquals(false, con.Learner_Email_Opt_Out__c, 'Marketing field should be false');
        System.assertEquals(false, con.Staff_Email_Opt_Out__c, 'Marketing field should be false');
        System.assertEquals(false, con.Work_Email_Opt_Out__c, 'Marketing field should be false');
        System.assertEquals(false, con.Work_SMS_Opt_Out__c, 'Marketing field should be false');
        System.assertEquals(false, con.hed__SMS_Opt_Out__c, 'Marketing field should be false');
        System.assertEquals(false, con.DoNotCall, 'Marketing field should be false');
        System.assertEquals(true, con.Sync_to_MC__c, 'Marketing field should be true');
        System.assertEquals(false, con.Do_Not_Sync_To_MC_Override__c, 'Marketing field should be false');
        System.assert(con.Dont_Market_Reason__c == null, 'Marketing field Dont_Market_Reason__c should be empty');
        System.assert(con.Email_Opt_In_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.Learner_Email_Opt_In_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.Staff_Email_Opt_In_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.Work_Email_Opt_In_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.Work_SMS_Opt_In_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.SMS_Opt_In_DateTime__c != null, 'Marketing field should be populated');
     }

     @isTest
     public static void optInOrOutMarketingOptOutTest(){
        Contact con = new Contact();
        MarketingService.optInOrOutMarketing(con, false);
        System.assertEquals(true, con.HasOptedOutOfEmail, 'Marketing field should be true');
        System.assertEquals(true, con.Learner_Email_Opt_Out__c, 'Marketing field should be true');
        System.assertEquals(true, con.Staff_Email_Opt_Out__c, 'Marketing field should be true');
        System.assertEquals(true, con.Work_Email_Opt_Out__c, 'Marketing field should be true');
        System.assertEquals(true, con.Work_SMS_Opt_Out__c, 'Marketing field should be true');
        System.assertEquals(true, con.hed__SMS_Opt_Out__c, 'Marketing field should be true');
        System.assertEquals(true, con.DoNotCall, 'Marketing field should be true');
        System.assertEquals(false, con.Sync_to_MC__c, 'Marketing field should be false');
        System.assertEquals(false, con.Do_Not_Sync_To_MC_Override__c, 'Marketing field should be false');
        System.assertEquals('QTAC Application QUT preferences withdrawn',con.Dont_Market_Reason__c, 'Marketing field Dont_Market_Reason__c should be QTAC Application QUT preferences withdrawn');
        System.assert(con.Email_Opt_Out_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.Learner_Email_Opt_Out_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.Staff_Email_Opt_Out_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.Work_Email_Opt_Out_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.Work_SMS_Opt_Out_DateTime__c != null, 'Marketing field should be populated');
        System.assert(con.SMS_Opt_Out_DateTime__c != null, 'Marketing field should be populated');
     }
 }