/**
 * @description Test Class for MarketingInteractionTriggerHelper
 * @see ..MarketingInteractionTriggerHelper
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
 public without sharing class MarketingInteractionTriggerHelperTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTESB();
    }
 
     @isTest
     public static void optInOrOutMarketingOptInTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            List<Contact> contactList = TestDataFactory.createTestContactRecords(50);
            ContactsDAO.newInstance().insertRecords(contactList,false,AccessLevel.SYSTEM_MODE);
            List<Marketing_Interaction__c> marketingIntList = new List<Marketing_Interaction__c>();
            Set<Id> contactIds = new Set<Id>();
            for(Contact con: contactList){
                marketingIntList.addAll(TestDataFactory.createMarketingInteractionRecords(con.Id,1,''));
                contactIds.add(con.Id);
            }

            MarketingInteractionsDAO.newInstance().insertRecords(marketingIntList,false,AccessLevel.SYSTEM_MODE);
        
            for(Contact con: ContactsDAO.newInstance().getPersonContactsBySetIds(contactIds,AccessLevel.SYSTEM_MODE)){
                System.assertEquals(false, con.HasOptedOutOfEmail, 'HasOptedOutOfEmail field should be false');
                System.assertEquals(false, con.Learner_Email_Opt_Out__c, 'Learner_Email_Opt_Out__c field should be false');
                System.assertEquals(false, con.Staff_Email_Opt_Out__c, 'Staff_Email_Opt_Out__c field should be false');
                System.assertEquals(false, con.Work_Email_Opt_Out__c, 'Work_Email_Opt_Out__c field should be false');
                System.assertEquals(false, con.Work_SMS_Opt_Out__c, 'Work_SMS_Opt_Out__c field should be false');
                System.assertEquals(false, con.hed__SMS_Opt_Out__c, 'hed__SMS_Opt_Out__c field should be false');
                System.assertEquals(false, con.DoNotCall, 'DoNotCall field should be false');
                System.assertEquals(true, con.Sync_to_MC__c, 'Sync_to_MC__c field should be true');
                System.assertEquals(false, con.Do_Not_Sync_To_MC_Override__c, 'Do_Not_Sync_To_MC_Override__c field should be false');
                System.assert(con.Dont_Market_Reason__c == null, 'Marketing field Dont_Market_Reason__c should be empty');
                System.assert(con.Email_Opt_In_DateTime__c != null, 'Email_Opt_In_DateTime__c field should be populated');
                System.assert(con.Learner_Email_Opt_In_DateTime__c != null, 'Learner_Email_Opt_In_DateTime__c field should be populated');
                System.assert(con.Staff_Email_Opt_In_DateTime__c != null, 'Staff_Email_Opt_In_DateTime__c field should be populated');
                System.assert(con.Work_Email_Opt_In_DateTime__c != null, 'Work_Email_Opt_In_DateTime__c field should be populated');
                System.assert(con.Work_SMS_Opt_In_DateTime__c != null, 'Work_SMS_Opt_In_DateTime__c field should be populated');
                System.assert(con.SMS_Opt_In_DateTime__c != null, 'SMS_Opt_In_DateTime__c field should be populated');
            }
        }
     }
 }