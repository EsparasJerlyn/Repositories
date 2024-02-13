/**
 * @description Tests the InternationalTierTriggerHandler
 *
 * @see InternationalTierTriggerHandlerTest
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | rhea.b.torres             | November 10, 2022     | DEPP-4448 | Created file                    | 
      | johanna.a.gibas           | November 24, 2023     | DEPP-7143 | Removed references to Priority  |
*/
@isTest
public with sharing class InternationalTierTriggerHandlerTest {

    @testSetup
    public static void makeData(){
        TestDataFactory.generateTestUsers();
    }

    @isTest
    public static void addingCountryTierTest(){
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
            List<International_Tier__c> tierList = TestDataFactory.createInternationalTierRecords(
                                                            new List<String>{'Wales','Australia'}, 'Tier 1',true);
            tierList.addAll(TestDataFactory.createInternationalTierRecords(
                                                                new List<String>{'Wales','Australia'}, 'Tier 1',false));                                                
            insert tierList;
            List<International_Tier__c> result = [SELECT Id FROM International_Tier__c];
            System.assertEquals(4, result.size(), 'More than one record exist.');
        }
        Test.stopTest();
    }

    @isTest
    public static void addingTierWithExistingActive(){
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
            Boolean hasException = false;
            List<International_Tier__c> tierList = TestDataFactory.createInternationalTierRecords(
                                                            new List<String>{'Wales','Australia'}, 'Tier 1',true);
            insert tierList;
            
            try{
                List<International_Tier__c> newTier = TestDataFactory.createInternationalTierRecords(
                                                            new List<String>{'Wales'}, 'Tier 1',true);
                insert newTier;
            }catch(Exception e){
                hasException = true;
            }

            List<International_Tier__c> result = [SELECT Id FROM International_Tier__c WHERE Country_Name__c='Wales'];
            System.assertEquals(true,hasException,'Record should not be saved.');
            System.assertEquals(1, result.size(), 'More than one record exist.');
        }
        Test.stopTest();
    }

    @isTest
    public static void testTwoActiveCountryTiers(){
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
            Boolean hasException = false;
            try{
                List<International_Tier__c> tierList = TestDataFactory.createInternationalTierRecords(
                                                                new List<String>{'Wales','Wales'}, 'Tier 1',true);
                insert tierList;
            }catch(Exception e){
                hasException = true;
            }

            System.assertEquals(true,hasException,'Records should not be saved.');
        }
        Test.stopTest();
    }

    @isTest
    public static void testSwitchingActiveTiers(){
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
            Boolean hasException = false;
            List<International_Tier__c> tierList = TestDataFactory.createInternationalTierRecords(
                                                            new List<String>{'Wales'}, 'Tier 1',true);
            tierList.addAll(TestDataFactory.createInternationalTierRecords(
                                                                new List<String>{'Wales'}, 'Tier 3',false));                                                
            insert tierList;
            try{
                // Switch the 2 created records to make Wales with Low TierPriority as the active one
                List<International_Tier__c> result = [SELECT Id, IsActive__c,Country_Name__c FROM International_Tier__c];
                for(International_Tier__c tier : result){
                    if(tier.IsActive__c == true){
                        tier.IsActive__c=false;
                    }else{
                        tier.IsActive__c=true;
                    }
                }
                update result;
            }catch(Exception e){
                hasException = true;
            }
            System.assertEquals(false, hasException, 'Records should be updated successfully.');
        }
        Test.stopTest();
    }

    @isTest
    public static void updatingOwnRecord(){
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
            Boolean hasException = false;
            List<International_Tier__c> tierList = TestDataFactory.createInternationalTierRecords(
                                                            new List<String>{'Wales','Australia'}, 'Tier 1',true);
            tierList.addAll(TestDataFactory.createInternationalTierRecords(
                                                                new List<String>{'Wales','Australia'}, 'Tier 1',false));                                                
            insert tierList;
            try{
                List<International_Tier__c> result = [SELECT Id, IsActive__c, Tier_Category__c FROM International_Tier__c WHERE Country_Name__c='Wales'];
                for(International_Tier__c tier : result){
                    tier.IsActive__c=true;
                    tier.Tier_Category__c='Tier 3';
                }
                update result;
            }catch(Exception e){
                hasException = true;
            }
            System.assertEquals(true,hasException,'Records should not be saved.');
        }
        Test.stopTest();
    }
}